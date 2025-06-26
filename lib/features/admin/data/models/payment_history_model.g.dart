// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentHistoryModel _$PaymentHistoryModelFromJson(Map<String, dynamic> json) =>
    PaymentHistoryModel(
      id: json['id'] as String,
      collectionId: json['collectionId'] as String?,
      collectionName: json['collectionName'] as String?,
      created: DateTime.parse(json['created'] as String),
      updated: DateTime.parse(json['updated'] as String),
      userId: json['userId'] as String,
      userName: json['userName'] as String?,
      userEmail: json['userEmail'] as String?,
      transactionId: json['transactionId'] as String,
      paymentIntentId: json['paymentIntentId'] as String?,
      paymentMethod: json['paymentMethod'] as String,
      paymentProvider: json['paymentProvider'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: json['status'] as String,
      type: json['type'] as String,
      subscriptionId: json['subscriptionId'] as String?,
      subscriptionPlan: json['subscriptionPlan'] as String?,
      description: json['description'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      processedAt: json['processedAt'] == null
          ? null
          : DateTime.parse(json['processedAt'] as String),
      refundedAt: json['refundedAt'] == null
          ? null
          : DateTime.parse(json['refundedAt'] as String),
      refundAmount: (json['refundAmount'] as num?)?.toDouble(),
      refundReason: json['refundReason'] as String?,
      failureReason: json['failureReason'] as String?,
      retryCount: (json['retryCount'] as num).toInt(),
      invoiceUrl: json['invoiceUrl'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
      billingDetails: json['billingDetails'] == null
          ? null
          : BillingDetails.fromJson(
              json['billingDetails'] as Map<String, dynamic>),
      events: (json['events'] as List<dynamic>?)
          ?.map((e) => PaymentEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PaymentHistoryModelToJson(
        PaymentHistoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'collectionId': instance.collectionId,
      'collectionName': instance.collectionName,
      'created': instance.created.toIso8601String(),
      'updated': instance.updated.toIso8601String(),
      'userId': instance.userId,
      'userName': instance.userName,
      'userEmail': instance.userEmail,
      'transactionId': instance.transactionId,
      'paymentIntentId': instance.paymentIntentId,
      'paymentMethod': instance.paymentMethod,
      'paymentProvider': instance.paymentProvider,
      'amount': instance.amount,
      'currency': instance.currency,
      'status': instance.status,
      'type': instance.type,
      'subscriptionId': instance.subscriptionId,
      'subscriptionPlan': instance.subscriptionPlan,
      'description': instance.description,
      'metadata': instance.metadata,
      'processedAt': instance.processedAt?.toIso8601String(),
      'refundedAt': instance.refundedAt?.toIso8601String(),
      'refundAmount': instance.refundAmount,
      'refundReason': instance.refundReason,
      'failureReason': instance.failureReason,
      'retryCount': instance.retryCount,
      'invoiceUrl': instance.invoiceUrl,
      'receiptUrl': instance.receiptUrl,
      'billingDetails': instance.billingDetails,
      'events': instance.events,
    };

BillingDetails _$BillingDetailsFromJson(Map<String, dynamic> json) =>
    BillingDetails(
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] == null
          ? null
          : Address.fromJson(json['address'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BillingDetailsToJson(BillingDetails instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'address': instance.address,
    };

Address _$AddressFromJson(Map<String, dynamic> json) => Address(
      line1: json['line1'] as String?,
      line2: json['line2'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      postalCode: json['postalCode'] as String?,
      country: json['country'] as String?,
    );

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
      'line1': instance.line1,
      'line2': instance.line2,
      'city': instance.city,
      'state': instance.state,
      'postalCode': instance.postalCode,
      'country': instance.country,
    };

PaymentEvent _$PaymentEventFromJson(Map<String, dynamic> json) => PaymentEvent(
      event: json['event'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      description: json['description'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PaymentEventToJson(PaymentEvent instance) =>
    <String, dynamic>{
      'event': instance.event,
      'timestamp': instance.timestamp.toIso8601String(),
      'description': instance.description,
      'data': instance.data,
    };
