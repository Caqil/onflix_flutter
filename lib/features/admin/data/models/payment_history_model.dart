import 'package:json_annotation/json_annotation.dart';
import 'package:onflix/shared/models/base_model.dart';

part 'payment_history_model.g.dart';

@JsonSerializable()
class PaymentHistoryModel extends BaseModel {
  final String userId;
  final String? userName;
  final String? userEmail;
  final String transactionId;
  final String? paymentIntentId;
  final String paymentMethod;
  final String paymentProvider;
  final double amount;
  final String currency;
  final String status;
  final String type;
  final String? subscriptionId;
  final String? subscriptionPlan;
  final String? description;
  final Map<String, dynamic>? metadata;
  final DateTime? processedAt;
  final DateTime? refundedAt;
  final double? refundAmount;
  final String? refundReason;
  final String? failureReason;
  final int retryCount;
  final String? invoiceUrl;
  final String? receiptUrl;
  final BillingDetails? billingDetails;
  final List<PaymentEvent>? events;

  const PaymentHistoryModel({
    required super.id,
    super.collectionId,
    super.collectionName,
    required super.created,
    required super.updated,
    required this.userId,
    this.userName,
    this.userEmail,
    required this.transactionId,
    this.paymentIntentId,
    required this.paymentMethod,
    required this.paymentProvider,
    required this.amount,
    required this.currency,
    required this.status,
    required this.type,
    this.subscriptionId,
    this.subscriptionPlan,
    this.description,
    this.metadata,
    this.processedAt,
    this.refundedAt,
    this.refundAmount,
    this.refundReason,
    this.failureReason,
    required this.retryCount,
    this.invoiceUrl,
    this.receiptUrl,
    this.billingDetails,
    this.events,
  });

  factory PaymentHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentHistoryModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PaymentHistoryModelToJson(this);

  factory PaymentHistoryModel.fromRecord(dynamic record) {
    final data = record.data;
    
    return PaymentHistoryModel(
      id: record.id,
      collectionId: record.collectionId,
      collectionName: record.collectionName,
      created: DateTime.parse(record.created),
      updated: DateTime.parse(record.updated),
      userId: data['user_id'] ?? '',
      userName: data['user_name'],
      userEmail: data['user_email'],
      transactionId: data['transaction_id'] ?? '',
      paymentIntentId: data['payment_intent_id'],
      paymentMethod: data['payment_method'] ?? '',
      paymentProvider: data['payment_provider'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'USD',
      status: data['status'] ?? PaymentStatus.pending,
      type: data['type'] ?? PaymentType.subscription,
      subscriptionId: data['subscription_id'],
      subscriptionPlan: data['subscription_plan'],
      description: data['description'],
      metadata: data['metadata'],
      processedAt: data['processed_at'] != null 
          ? DateTime.parse(data['processed_at'])
          : null,
      refundedAt: data['refunded_at'] != null 
          ? DateTime.parse(data['refunded_at'])
          : null,
      refundAmount: data['refund_amount']?.toDouble(),
      refundReason: data['refund_reason'],
      failureReason: data['failure_reason'],
      retryCount: data['retry_count'] ?? 0,
      invoiceUrl: data['invoice_url'],
      receiptUrl: data['receipt_url'],
      billingDetails: data['billing_details'] != null
          ? BillingDetails.fromJson(data['billing_details'])
          : null,
      events: data['events'] != null
          ? (data['events'] as List)
              .map((event) => PaymentEvent.fromJson(event))
              .toList()
          : null,
    );
  }

  // Status checks
  bool get isPending => status == PaymentStatus.pending;
  bool get isProcessing => status == PaymentStatus.processing;
  bool get isSucceeded => status == PaymentStatus.succeeded;
  bool get isFailed => status == PaymentStatus.failed;
  bool get isCanceled => status == PaymentStatus.canceled;
  bool get isRefunded => status == PaymentStatus.refunded;
  bool get isPartiallyRefunded => status == PaymentStatus.partiallyRefunded;

  // Type checks
  bool get isSubscriptionPayment => type == PaymentType.subscription;
  bool get isOneTimePayment => type == PaymentType.oneTime;
  bool get isRefundPayment => type == PaymentType.refund;
  bool get isUpgradePayment => type == PaymentType.upgrade;
  bool get isDowngradePayment => type == PaymentType.downgrade;

  // Utility methods
  String get statusDisplayName => PaymentStatus.getDisplayName(status);
  String get typeDisplayName => PaymentType.getDisplayName(type);
  String get paymentMethodDisplayName => PaymentMethod.getDisplayName(paymentMethod);
  
  String get formattedAmount {
    final currencySymbol = CurrencySymbols.getSymbol(currency);
    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }

  String get formattedRefundAmount {
    if (refundAmount == null) return '';
    final currencySymbol = CurrencySymbols.getSymbol(currency);
    return '$currencySymbol${refundAmount!.toStringAsFixed(2)}';
  }

  bool get canBeRefunded {
    return isSucceeded && 
           refundedAt == null && 
           DateTime.now().difference(processedAt ?? created).inDays <= 30;
  }

  bool get isRecent {
    return DateTime.now().difference(created).inDays <= 7;
  }

  double get netAmount {
    return amount - (refundAmount ?? 0);
  }

  String get userDisplayName {
    return userName ?? userEmail ?? 'Unknown User';
  }

  // Copy with method
  PaymentHistoryModel copyWith({
    String? userId,
    String? userName,
    String? userEmail,
    String? transactionId,
    String? paymentIntentId,
    String? paymentMethod,
    String? paymentProvider,
    double? amount,
    String? currency,
    String? status,
    String? type,
    String? subscriptionId,
    String? subscriptionPlan,
    String? description,
    Map<String, dynamic>? metadata,
    DateTime? processedAt,
    DateTime? refundedAt,
    double? refundAmount,
    String? refundReason,
    String? failureReason,
    int? retryCount,
    String? invoiceUrl,
    String? receiptUrl,
    BillingDetails? billingDetails,
    List<PaymentEvent>? events,
  }) {
    return PaymentHistoryModel(
      id: id,
      collectionId: collectionId,
      collectionName: collectionName,
      created: created,
      updated: updated,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      transactionId: transactionId ?? this.transactionId,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentProvider: paymentProvider ?? this.paymentProvider,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      type: type ?? this.type,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
      processedAt: processedAt ?? this.processedAt,
      refundedAt: refundedAt ?? this.refundedAt,
      refundAmount: refundAmount ?? this.refundAmount,
      refundReason: refundReason ?? this.refundReason,
      failureReason: failureReason ?? this.failureReason,
      retryCount: retryCount ?? this.retryCount,
      invoiceUrl: invoiceUrl ?? this.invoiceUrl,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      billingDetails: billingDetails ?? this.billingDetails,
      events: events ?? this.events,
    );
  }

  @override
  String toString() {
    return 'PaymentHistoryModel(id: $id, transactionId: $transactionId, amount: $formattedAmount, status: $status)';
  }
}

@JsonSerializable()
class BillingDetails {
  final String? name;
  final String? email;
  final String? phone;
  final Address? address;

  const BillingDetails({
    this.name,
    this.email,
    this.phone,
    this.address,
  });

  factory BillingDetails.fromJson(Map<String, dynamic> json) =>
      _$BillingDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$BillingDetailsToJson(this);
}

@JsonSerializable()
class Address {
  final String? line1;
  final String? line2;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;

  const Address({
    this.line1,
    this.line2,
    this.city,
    this.state,
    this.postalCode,
    this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);

  Map<String, dynamic> toJson() => _$AddressToJson(this);

  String get fullAddress {
    final parts = [
      line1,
      line2,
      city,
      state,
      postalCode,
      country,
    ].where((part) => part != null && part.isNotEmpty);
    
    return parts.join(', ');
  }
}

@JsonSerializable()
class PaymentEvent {
  final String event;
  final DateTime timestamp;
  final String? description;
  final Map<String, dynamic>? data;

  const PaymentEvent({
    required this.event,
    required this.timestamp,
    this.description,
    this.data,
  });

  factory PaymentEvent.fromJson(Map<String, dynamic> json) =>
      _$PaymentEventFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentEventToJson(this);

  String get eventDisplayName => PaymentEventType.getDisplayName(event);
}

// Payment status constants
class PaymentStatus {
  static const String pending = 'pending';
  static const String processing = 'processing';
  static const String succeeded = 'succeeded';
  static const String failed = 'failed';
  static const String canceled = 'canceled';
  static const String refunded = 'refunded';
  static const String partiallyRefunded = 'partially_refunded';

  static const List<String> all = [
    pending,
    processing,
    succeeded,
    failed,
    canceled,
    refunded,
    partiallyRefunded,
  ];

  static String getDisplayName(String status) {
    switch (status) {
      case pending:
        return 'Pending';
      case processing:
        return 'Processing';
      case succeeded:
        return 'Succeeded';
      case failed:
        return 'Failed';
      case canceled:
        return 'Canceled';
      case refunded:
        return 'Refunded';
      case partiallyRefunded:
        return 'Partially Refunded';
      default:
        return 'Unknown';
    }
  }
}

// Payment type constants
class PaymentType {
  static const String subscription = 'subscription';
  static const String oneTime = 'one_time';
  static const String refund = 'refund';
  static const String upgrade = 'upgrade';
  static const String downgrade = 'downgrade';

  static const List<String> all = [
    subscription,
    oneTime,
    refund,
    upgrade,
    downgrade,
  ];

  static String getDisplayName(String type) {
    switch (type) {
      case subscription:
        return 'Subscription';
      case oneTime:
        return 'One-time Payment';
      case refund:
        return 'Refund';
      case upgrade:
        return 'Upgrade';
      case downgrade:
        return 'Downgrade';
      default:
        return 'Unknown';
    }
  }
}

// Payment method constants
class PaymentMethod {
  static const String card = 'card';
  static const String paypal = 'paypal';
  static const String bankTransfer = 'bank_transfer';
  static const String applePay = 'apple_pay';
  static const String googlePay = 'google_pay';
  static const String crypto = 'crypto';

  static const List<String> all = [
    card,
    paypal,
    bankTransfer,
    applePay,
    googlePay,
    crypto,
  ];

  static String getDisplayName(String method) {
    switch (method) {
      case card:
        return 'Credit/Debit Card';
      case paypal:
        return 'PayPal';
      case bankTransfer:
        return 'Bank Transfer';
      case applePay:
        return 'Apple Pay';
      case googlePay:
        return 'Google Pay';
      case crypto:
        return 'Cryptocurrency';
      default:
        return 'Unknown';
    }
  }
}

// Payment event type constants
class PaymentEventType {
  static const String created = 'created';
  static const String processing = 'processing';
  static const String succeeded = 'succeeded';
  static const String failed = 'failed';
  static const String refunded = 'refunded';
  static const String disputed = 'disputed';
  static const String updated = 'updated';

  static const List<String> all = [
    created,
    processing,
    succeeded,
    failed,
    refunded,
    disputed,
    updated,
  ];

  static String getDisplayName(String event) {
    switch (event) {
      case created:
        return 'Payment Created';
      case processing:
        return 'Payment Processing';
      case succeeded:
        return 'Payment Succeeded';
      case failed:
        return 'Payment Failed';
      case refunded:
        return 'Payment Refunded';
      case disputed:
        return 'Payment Disputed';
      case updated:
        return 'Payment Updated';
      default:
        return 'Unknown Event';
    }
  }
}

// Currency symbols
class CurrencySymbols {
  static const Map<String, String> _symbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'CNY': '¥',
    'INR': '₹',
    'CAD': 'C\$',
    'AUD': 'A\$',
    'CHF': 'Fr',
    'SEK': 'kr',
    'NOK': 'kr',
    'DKK': 'kr',
  };

  static String getSymbol(String currency) {
    return _symbols[currency.toUpperCase()] ?? currency.toUpperCase();
  }
}