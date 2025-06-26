import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:logger/logger.dart';
import 'package:onflix/core/config/environment.dart';
import 'package:onflix/core/errors/exceptions.dart';
import 'package:onflix/core/network/pocketbase_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentService {
  static PaymentService? _instance;
  late Logger _logger;
  late SharedPreferences _prefs;
  late PocketBaseClient _pbClient;

  // Payment management
  final Map<String, PaymentMethod> _savedPaymentMethods = {};
  final List<PaymentTransaction> _paymentHistory = [];
  final StreamController<PaymentEvent> _paymentEventController =
      StreamController<PaymentEvent>.broadcast();

  // Current subscription
  SubscriptionInfo? _currentSubscription;

  // Payment processing
  bool _isProcessingPayment = false;

  PaymentService._() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 1,
        errorMethodCount: 3,
        lineLength: 80,
        colors: true,
        printEmojis: true,
      ),
    );
    _pbClient = PocketBaseClient.instance;
  }

  static PaymentService get instance {
    _instance ??= PaymentService._();
    return _instance!;
  }

  // Stream for payment events
  Stream<PaymentEvent> get paymentEvents => _paymentEventController.stream;

  // Initialize the service
  Future<void> initialize() async {
    try {
      _logger.i('Initializing Payment Service...');

      _prefs = await SharedPreferences.getInstance();
      await _initializeStripe();
      await _loadPaymentData();
      await _loadCurrentSubscription();

      _logger.i('Payment Service initialized successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize Payment Service',
          error: e, stackTrace: stackTrace);
    }
  }

  // Initialize Stripe
  Future<void> _initializeStripe() async {
    try {
      Stripe.publishableKey = Environment.stripePublishableKey;

      if (Environment.stripePublishableKey.isEmpty) {
        _logger.w('Stripe publishable key not configured');
        return;
      }

      await Stripe.instance.applySettings();
      _logger.d('Stripe initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize Stripe: $e');
    }
  }

  // Load payment data
  Future<void> _loadPaymentData() async {
    try {
      await _loadSavedPaymentMethods();
      await _loadPaymentHistory();
    } catch (e) {
      _logger.w('Failed to load payment data: $e');
    }
  }

  // Load saved payment methods
  Future<void> _loadSavedPaymentMethods() async {
    try {
      final paymentMethodsJson = _prefs.getString('saved_payment_methods');
      if (paymentMethodsJson != null) {
        final Map<String, dynamic> data = jsonDecode(paymentMethodsJson);

        for (final entry in data.entries) {
          final methodData = entry.value as Map<String, dynamic>;
          final method = PaymentMethod.fromJson(methodData);
          _savedPaymentMethods[entry.key] = method;
        }
      }

      _logger.d('Loaded ${_savedPaymentMethods.length} saved payment methods');
    } catch (e) {
      _logger.w('Failed to load saved payment methods: $e');
      _savedPaymentMethods.clear();
    }
  }

  // Save payment methods
  Future<void> _savePaymentMethods() async {
    try {
      final data = <String, dynamic>{};
      for (final entry in _savedPaymentMethods.entries) {
        data[entry.key] = entry.value.toJson();
      }

      await _prefs.setString('saved_payment_methods', jsonEncode(data));
    } catch (e) {
      _logger.e('Failed to save payment methods: $e');
    }
  }

  // Load payment history
  Future<void> _loadPaymentHistory() async {
    try {
      final userId = _pbClient.currentUser?.id;
      if (userId == null) return;

      final response = await _pbClient.getRecords(
        'paymentHistory',
        filter: 'user="$userId"',
        sort: '-created',
        perPage: 50,
      );

      if (response.isSuccess && response.data != null) {
        _paymentHistory.clear();

        for (final record in response.data!.items) {
          final transaction = PaymentTransaction.fromRecord(record);
          _paymentHistory.add(transaction);
        }
      }

      _logger.d('Loaded ${_paymentHistory.length} payment history records');
    } catch (e) {
      _logger.w('Failed to load payment history: $e');
    }
  }

  // Load current subscription
  Future<void> _loadCurrentSubscription() async {
    try {
      final userId = _pbClient.currentUser?.id;
      if (userId == null) return;

      final response = await _pbClient.getRecords(
        'userSubscriptions',
        filter: 'user="$userId" && status="active"',
        expand: ['subscription'],
      );

      if (response.isSuccess &&
          response.data != null &&
          response.data!.items.isNotEmpty) {
        final record = response.data!.items.first;
        _currentSubscription = SubscriptionInfo.fromRecord(record);
      }

      _logger
          .d('Current subscription loaded: ${_currentSubscription?.planName}');
    } catch (e) {
      _logger.w('Failed to load current subscription: $e');
    }
  }

  // Get available subscription plans
  Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
    try {
      final response = await _pbClient.getRecords(
        'subscription_plans',
        filter: 'active=true',
        sort: 'price',
      );

      if (response.isSuccess && response.data != null) {
        return response.data!.items
            .map((record) => SubscriptionPlan.fromRecord(record))
            .toList();
      }

      return [];
    } catch (e) {
      _logger.e('Failed to get subscription plans: $e');
      rethrow;
    }
  }

  // Process subscription payment
  Future<PaymentResult> processSubscriptionPayment({
    required String planId,
    required String paymentMethodId,
    bool savePaymentMethod = false,
  }) async {
    if (_isProcessingPayment) {
      throw const SubscriptionException(
        message: 'Payment already in progress',
        code: 'PAYMENT_IN_PROGRESS',
      );
    }

    _isProcessingPayment = true;

    try {
      _logger.i('Processing subscription payment for plan: $planId');

      // Emit payment started event
      _paymentEventController.add(PaymentEvent(
        type: PaymentEventType.started,
        planId: planId,
      ));

      // Get plan details
      final planResponse =
          await _pbClient.getRecord('subscription_plans', planId);
      if (!planResponse.isSuccess || planResponse.data == null) {
        throw const SubscriptionException(
          message: 'Subscription plan not found',
          code: 'PLAN_NOT_FOUND',
        );
      }

      final plan = SubscriptionPlan.fromRecord(planResponse.data!);

      // Create payment intent
      final paymentIntent = await _createPaymentIntent(
        amount: plan.price,
        currency: plan.currency,
        planId: planId,
      );

      // Confirm payment
      final paymentResult = await _confirmPayment(
        paymentIntentClientSecret: paymentIntent['client_secret'],
        paymentMethodId: paymentMethodId,
      );

      if (paymentResult.status == PaymentStatus.succeeded) {
        // Create subscription
        await _createSubscription(
          planId: planId,
          paymentIntentId: paymentIntent['id'],
        );

        // Save payment method if requested
        if (savePaymentMethod) {
          await _savePaymentMethodFromIntent(paymentMethodId);
        }

        // Record payment transaction
        await _recordPaymentTransaction(
          amount: plan.price,
          currency: plan.currency,
          planId: planId,
          paymentIntentId: paymentIntent['id'],
          status: PaymentStatus.succeeded,
        );

        // Reload current subscription
        await _loadCurrentSubscription();

        // Emit success event
        _paymentEventController.add(PaymentEvent(
          type: PaymentEventType.succeeded,
          planId: planId,
          amount: plan.price,
          currency: plan.currency,
        ));

        _logger.i('Subscription payment successful');
      } else {
        throw SubscriptionException(
          message: 'Payment failed: ${paymentResult.failureReason}',
          code: 'PAYMENT_FAILED',
        );
      }

      return paymentResult;
    } catch (e) {
      _logger.e('Subscription payment failed: $e');

      _paymentEventController.add(PaymentEvent(
        type: PaymentEventType.failed,
        planId: planId,
        error: e.toString(),
      ));

      rethrow;
    } finally {
      _isProcessingPayment = false;
    }
  }

  // Create payment intent on server
  Future<Map<String, dynamic>> _createPaymentIntent({
    required double amount,
    required String currency,
    required String planId,
  }) async {
    try {
      final response = await _pbClient.createRecord('payment_intents', {
        'amount': (amount * 100).round(), // Convert to cents
        'currency': currency,
        'plan_id': planId,
        'user': _pbClient.currentUser?.id,
      });

      if (response.isSuccess && response.data != null) {
        return response.data!.data as Map<String, dynamic>;
      }

      throw const SubscriptionException(
        message: 'Failed to create payment intent',
        code: 'PAYMENT_INTENT_CREATION_FAILED',
      );
    } catch (e) {
      _logger.e('Failed to create payment intent: $e');
      rethrow;
    }
  }

  // Confirm payment with Stripe
  Future<PaymentResult> _confirmPayment({
    required String paymentIntentClientSecret,
    required String paymentMethodId,
  }) async {
    try {
      final result = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: paymentIntentClientSecret,
        data: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              email: _pbClient.currentUser?.data['email'],
              name: _pbClient.currentUser?.data['name'],
            ),
          ),
        ),
      );

      return PaymentResult(
        status: _mapStripeStatus(result.status),
        paymentIntentId: result.paymentMethodId,
        failureReason: result.paymentMethodId?.lastPaymentError?.message,
      );
    } on StripeException catch (e) {
      _logger.e('Stripe payment error: ${e.error}');
      return PaymentResult(
        status: PaymentStatus.failed,
        failureReason: e.error.message,
      );
    } catch (e) {
      _logger.e('Payment confirmation error: $e');
      return PaymentResult(
        status: PaymentStatus.failed,
        failureReason: e.toString(),
      );
    }
  }

  // Map Stripe status to our enum
  PaymentStatus _mapStripeStatus(PaymentIntentsStatus status) {
    switch (status) {
      case PaymentIntentsStatus.Succeeded:
        return PaymentStatus.succeeded;
      case PaymentIntentsStatus.Processing:
        return PaymentStatus.processing;
      case PaymentIntentsStatus.RequiresPaymentMethod:
      case PaymentIntentsStatus.RequiresConfirmation:
      case PaymentIntentsStatus.RequiresAction:
        return PaymentStatus.requiresAction;
      case PaymentIntentsStatus.RequiresCapture:
        return PaymentStatus.requiresCapture;
      case PaymentIntentsStatus.Canceled:
        return PaymentStatus.cancelled;
      default:
        return PaymentStatus.failed;
    }
  }

  // Create subscription record
  Future<void> _createSubscription({
    required String planId,
    required String paymentIntentId,
  }) async {
    try {
      final userId = _pbClient.currentUser?.id;
      if (userId == null) {
        throw const AuthException(
          message: 'User not authenticated',
          code: 'USER_NOT_AUTHENTICATED',
        );
      }

      // Cancel existing subscription if any
      if (_currentSubscription != null) {
        await _cancelSubscription(_currentSubscription!.id, immediate: true);
      }

      final subscriptionData = {
        'user': userId,
        'subscription': planId,
        'status': 'active',
        'payment_intent': paymentIntentId,
        'start_date': DateTime.now().toIso8601String(),
        'next_billing_date': _calculateNextBillingDate().toIso8601String(),
        'auto_renew': true,
      };

      await _pbClient.createRecord('userSubscriptions', subscriptionData);
      _logger.d('Subscription created successfully');
    } catch (e) {
      _logger.e('Failed to create subscription: $e');
      rethrow;
    }
  }

  // Calculate next billing date
  DateTime _calculateNextBillingDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, now.day);
  }

  // Save payment method
  Future<void> _savePaymentMethodFromIntent(String paymentMethodId) async {
    try {
      // Get payment method details from Stripe (this would require server implementation)
      // For now, we'll create a placeholder
      final paymentMethod = PaymentMethod(
        id: paymentMethodId,
        type: 'card',
        lastFour: '****', // Would get from Stripe
        brand: 'unknown',
        expiryMonth: 12,
        expiryYear: 2025,
        isDefault: _savedPaymentMethods.isEmpty,
        createdAt: DateTime.now(),
      );

      _savedPaymentMethods[paymentMethodId] = paymentMethod;
      await _savePaymentMethods();

      _logger.d('Payment method saved: $paymentMethodId');
    } catch (e) {
      _logger.e('Failed to save payment method: $e');
    }
  }

  // Record payment transaction
  Future<void> _recordPaymentTransaction({
    required double amount,
    required String currency,
    required String planId,
    required String paymentIntentId,
    required PaymentStatus status,
  }) async {
    try {
      final transactionData = {
        'user': _pbClient.currentUser?.id,
        'amount': amount,
        'currency': currency,
        'subscription_plan': planId,
        'payment_intent_id': paymentIntentId,
        'status': status.toString().split('.').last,
        'transaction_type': 'subscription',
      };

      final response =
          await _pbClient.createRecord('paymentHistory', transactionData);

      if (response.isSuccess && response.data != null) {
        final transaction = PaymentTransaction.fromRecord(response.data!);
        _paymentHistory.insert(0, transaction);
      }

      _logger.d('Payment transaction recorded');
    } catch (e) {
      _logger.e('Failed to record payment transaction: $e');
    }
  }

  // Cancel subscription
  Future<void> cancelSubscription({bool immediate = false}) async {
    try {
      if (_currentSubscription == null) {
        throw const SubscriptionException(
          message: 'No active subscription found',
          code: 'NO_ACTIVE_SUBSCRIPTION',
        );
      }

      await _cancelSubscription(_currentSubscription!.id, immediate: immediate);

      if (immediate) {
        _currentSubscription = null;
      } else {
        _currentSubscription!.status = 'cancelled';
        _currentSubscription!.cancelledAt = DateTime.now();
      }

      _paymentEventController.add(PaymentEvent(
        type: PaymentEventType.cancelled,
        planId: _currentSubscription?.planId,
      ));

      _logger.i(
          'Subscription cancelled${immediate ? ' immediately' : ' at period end'}');
    } catch (e) {
      _logger.e('Failed to cancel subscription: $e');
      rethrow;
    }
  }

  // Cancel subscription implementation
  Future<void> _cancelSubscription(String subscriptionId,
      {required bool immediate}) async {
    try {
      final updateData = {
        'status': immediate ? 'cancelled' : 'cancel_at_period_end',
        'cancelled_at': DateTime.now().toIso8601String(),
      };

      if (immediate) {
        updateData['end_date'] = DateTime.now().toIso8601String();
      }

      await _pbClient.updateRecord(
          'userSubscriptions', subscriptionId, updateData);
    } catch (e) {
      _logger.e('Failed to update subscription status: $e');
      rethrow;
    }
  }

  // Reactivate subscription
  Future<void> reactivateSubscription() async {
    try {
      if (_currentSubscription == null ||
          _currentSubscription!.status != 'cancel_at_period_end') {
        throw const SubscriptionException(
          message: 'No subscription to reactivate',
          code: 'NO_SUBSCRIPTION_TO_REACTIVATE',
        );
      }

      await _pbClient
          .updateRecord('userSubscriptions', _currentSubscription!.id, {
        'status': 'active',
        'cancelled_at': null,
      });

      _currentSubscription!.status = 'active';
      _currentSubscription!.cancelledAt = null;

      _paymentEventController.add(PaymentEvent(
        type: PaymentEventType.reactivated,
        planId: _currentSubscription?.planId,
      ));

      _logger.i('Subscription reactivated');
    } catch (e) {
      _logger.e('Failed to reactivate subscription: $e');
      rethrow;
    }
  }

  // Update payment method
  Future<void> updatePaymentMethod(String paymentMethodId) async {
    try {
      if (_currentSubscription == null) {
        throw const SubscriptionException(
          message: 'No active subscription found',
          code: 'NO_ACTIVE_SUBSCRIPTION',
        );
      }

      await _pbClient
          .updateRecord('userSubscriptions', _currentSubscription!.id, {
        'payment_method': paymentMethodId,
      });

      _currentSubscription!.paymentMethodId = paymentMethodId;

      _paymentEventController.add(PaymentEvent(
        type: PaymentEventType.paymentMethodUpdated,
        planId: _currentSubscription?.planId,
      ));

      _logger.i('Payment method updated');
    } catch (e) {
      _logger.e('Failed to update payment method: $e');
      rethrow;
    }
  }

  // Add payment method
  Future<String> addPaymentMethod({
    required String cardNumber,
    required int expiryMonth,
    required int expiryYear,
    required String cvc,
    bool setAsDefault = false,
  }) async {
    try {
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(),
          ),
        ),
      );

      final method = PaymentMethod(
        id: paymentMethod.id,
        type: 'card',
        lastFour: cardNumber.substring(cardNumber.length - 4),
        brand: paymentMethod.card.brand ?? 'unknown',
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        isDefault: setAsDefault || _savedPaymentMethods.isEmpty,
        createdAt: DateTime.now(),
      );

      if (setAsDefault) {
        // Mark other methods as not default
        for (final existingMethod in _savedPaymentMethods.values) {
          existingMethod.isDefault = false;
        }
      }

      _savedPaymentMethods[paymentMethod.id] = method;
      await _savePaymentMethods();

      _logger.i('Payment method added: ${paymentMethod.id}');
      return paymentMethod.id;
    } on StripeException catch (e) {
      _logger.e('Stripe error adding payment method: ${e.error}');
      throw SubscriptionException(
        message: e.error.message ?? 'Failed to add payment method',
        code: 'STRIPE_ERROR',
      );
    } catch (e) {
      _logger.e('Failed to add payment method: $e');
      rethrow;
    }
  }

  // Remove payment method
  Future<void> removePaymentMethod(String paymentMethodId) async {
    try {
      final removedMethod = _savedPaymentMethods.remove(paymentMethodId);
      if (removedMethod != null) {
        // If this was the default method, set another as default
        if (removedMethod.isDefault && _savedPaymentMethods.isNotEmpty) {
          _savedPaymentMethods.values.first.isDefault = true;
        }

        await _savePaymentMethods();

        // Detach from Stripe
        try {
          // This would require server-side implementation
          // await Stripe.instance.detachPaymentMethod(paymentMethodId);
        } catch (e) {
          _logger.w('Failed to detach payment method from Stripe: $e');
        }

        _logger.i('Payment method removed: $paymentMethodId');
      }
    } catch (e) {
      _logger.e('Failed to remove payment method: $e');
      rethrow;
    }
  }

  // Set default payment method
  Future<void> setDefaultPaymentMethod(String paymentMethodId) async {
    try {
      // Mark all methods as not default
      for (final method in _savedPaymentMethods.values) {
        method.isDefault = false;
      }

      // Set the specified method as default
      final method = _savedPaymentMethods[paymentMethodId];
      if (method != null) {
        method.isDefault = true;
        await _savePaymentMethods();

        _logger.i('Default payment method set: $paymentMethodId');
      }
    } catch (e) {
      _logger.e('Failed to set default payment method: $e');
      rethrow;
    }
  }

  // Get payment methods
  List<PaymentMethod> getPaymentMethods() {
    return _savedPaymentMethods.values.toList()
      ..sort((a, b) => a.isDefault ? -1 : 1);
  }

  // Get default payment method
  PaymentMethod? getDefaultPaymentMethod() {
    return _savedPaymentMethods.values.where((m) => m.isDefault).firstOrNull;
  }

  // Get payment history
  List<PaymentTransaction> getPaymentHistory() {
    return List.from(_paymentHistory);
  }

  // Get current subscription
  SubscriptionInfo? getCurrentSubscription() {
    return _currentSubscription;
  }

  // Check subscription status
  bool get hasActiveSubscription {
    return _currentSubscription?.status == 'active';
  }

  bool get hasValidSubscription {
    if (_currentSubscription == null) return false;

    final now = DateTime.now();
    return _currentSubscription!.status == 'active' ||
        (_currentSubscription!.status == 'cancel_at_period_end' &&
            _currentSubscription!.endDate?.isAfter(now) == true);
  }

  // Get subscription info
  Map<String, dynamic> getSubscriptionInfo() {
    if (_currentSubscription == null) {
      return {
        'hasSubscription': false,
        'status': 'none',
      };
    }

    return {
      'hasSubscription': true,
      'status': _currentSubscription!.status,
      'planName': _currentSubscription!.planName,
      'planPrice': _currentSubscription!.planPrice,
      'nextBillingDate':
          _currentSubscription!.nextBillingDate?.toIso8601String(),
      'endDate': _currentSubscription!.endDate?.toIso8601String(),
      'cancelledAt': _currentSubscription!.cancelledAt?.toIso8601String(),
      'autoRenew': _currentSubscription!.autoRenew,
    };
  }

  // Dispose resources
  void dispose() {
    _paymentEventController.close();
  }
}

// Payment method model
class PaymentMethod {
  final String id;
  final String type;
  final String lastFour;
  final String brand;
  final int expiryMonth;
  final int expiryYear;
  bool isDefault;
  final DateTime createdAt;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.lastFour,
    required this.brand,
    required this.expiryMonth,
    required this.expiryYear,
    required this.isDefault,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'lastFour': lastFour,
        'brand': brand,
        'expiryMonth': expiryMonth,
        'expiryYear': expiryYear,
        'isDefault': isDefault,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
        id: json['id'],
        type: json['type'],
        lastFour: json['lastFour'],
        brand: json['brand'],
        expiryMonth: json['expiryMonth'],
        expiryYear: json['expiryYear'],
        isDefault: json['isDefault'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  String get displayName => '•••• •••• •••• $lastFour';
  String get expiryDisplay =>
      '${expiryMonth.toString().padLeft(2, '0')}/${expiryYear.toString().substring(2)}';
  bool get isExpired =>
      DateTime.now().isAfter(DateTime(expiryYear, expiryMonth + 1));
}

// Subscription plan model
class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final String billingCycle;
  final List<String> features;
  final bool isPopular;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.billingCycle,
    required this.features,
    required this.isPopular,
  });

  factory SubscriptionPlan.fromRecord(dynamic record) => SubscriptionPlan(
        id: record.id,
        name: record.data['name'],
        description: record.data['description'],
        price: (record.data['price'] as num).toDouble(),
        currency: record.data['currency'],
        billingCycle: record.data['billing_cycle'],
        features: List<String>.from(record.data['features'] ?? []),
        isPopular: record.data['is_popular'] ?? false,
      );

  String get displayPrice =>
      '${currency.toUpperCase()} ${price.toStringAsFixed(2)}';
}

// Subscription info model
class SubscriptionInfo {
  final String id;
  final String planId;
  final String planName;
  final double planPrice;
  String status;
  final DateTime startDate;
  DateTime? nextBillingDate;
  DateTime? endDate;
  DateTime? cancelledAt;
  bool autoRenew;
  String? paymentMethodId;

  SubscriptionInfo({
    required this.id,
    required this.planId,
    required this.planName,
    required this.planPrice,
    required this.status,
    required this.startDate,
    this.nextBillingDate,
    this.endDate,
    this.cancelledAt,
    required this.autoRenew,
    this.paymentMethodId,
  });

  factory SubscriptionInfo.fromRecord(dynamic record) => SubscriptionInfo(
        id: record.id,
        planId: record.data['subscription'],
        planName: record.expand?['subscription']?['name'] ?? 'Unknown Plan',
        planPrice:
            (record.expand?['subscription']?['price'] as num?)?.toDouble() ??
                0.0,
        status: record.data['status'],
        startDate: DateTime.parse(record.data['start_date']),
        nextBillingDate: record.data['next_billing_date'] != null
            ? DateTime.parse(record.data['next_billing_date'])
            : null,
        endDate: record.data['end_date'] != null
            ? DateTime.parse(record.data['end_date'])
            : null,
        cancelledAt: record.data['cancelled_at'] != null
            ? DateTime.parse(record.data['cancelled_at'])
            : null,
        autoRenew: record.data['auto_renew'] ?? true,
        paymentMethodId: record.data['payment_method'],
      );
}

// Payment transaction model
class PaymentTransaction {
  final String id;
  final double amount;
  final String currency;
  final String status;
  final String type;
  final DateTime createdAt;
  final String? planName;
  final String? paymentIntentId;

  PaymentTransaction({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.type,
    required this.createdAt,
    this.planName,
    this.paymentIntentId,
  });

  factory PaymentTransaction.fromRecord(dynamic record) => PaymentTransaction(
        id: record.id,
        amount: (record.data['amount'] as num).toDouble(),
        currency: record.data['currency'],
        status: record.data['status'],
        type: record.data['transaction_type'],
        createdAt: DateTime.parse(record.data['created']),
        planName: record.expand?['subscription_plan']?['name'],
        paymentIntentId: record.data['payment_intent_id'],
      );

  String get displayAmount =>
      '${currency.toUpperCase()} ${amount.toStringAsFixed(2)}';
}

// Payment result model
class PaymentResult {
  final PaymentStatus status;
  final String? paymentIntentId;
  final String? failureReason;

  PaymentResult({
    required this.status,
    this.paymentIntentId,
    this.failureReason,
  });
}

// Payment event model
class PaymentEvent {
  final PaymentEventType type;
  final String? planId;
  final double? amount;
  final String? currency;
  final String? error;

  PaymentEvent({
    required this.type,
    this.planId,
    this.amount,
    this.currency,
    this.error,
  });
}

// Enums
enum PaymentStatus {
  succeeded,
  processing,
  requiresAction,
  requiresCapture,
  cancelled,
  failed,
}

enum PaymentEventType {
  started,
  succeeded,
  failed,
  cancelled,
  reactivated,
  paymentMethodUpdated,
}
