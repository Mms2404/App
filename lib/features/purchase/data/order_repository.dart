// ORDER REPOSITORY
// -----------------------------------------------------------------------------
// Handles HTTP for the shop order flow:
//   • POST /api/shop/checkout/            → create order + get razorpay_order_id
//   • POST /api/shop/payment/verify/      → verify HMAC signature after payment
//   • GET  /api/shop/orders/?phone=       → customer order tracking
//   • GET  /api/shop/admin/orders/        → admin: all orders
//   • PATCH /api/shop/admin/orders/<id>/  → admin: update order status
// -----------------------------------------------------------------------------

import 'package:app/core/constants/api_config.dart';
import 'package:app/features/purchase/providers/cart_model.dart';
import 'package:dio/dio.dart';

const _baseUrl = ApiConfig.shop_url;

class OrderException implements Exception {
  final String message;
  OrderException(this.message);
  @override
  String toString() => message;
}

class CheckoutResponse {
  final int orderId;
  final String razorpayOrderId;
  final double amount;
  final String currency;

  CheckoutResponse({
    required this.orderId,
    required this.razorpayOrderId,
    required this.amount,
    required this.currency,
  });

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutResponse(
      orderId: json['order_id'] as int,
      razorpayOrderId: json['razorpay_order_id'] as String,
      amount: double.parse(json['amount'] as String),
      currency: json['currency'] as String,
    );
  }
}

class OrderItemDetail {
  final String productName;
  final String productType;
  final double productPrice;
  final int quantity;

  OrderItemDetail({
    required this.productName,
    required this.productType,
    required this.productPrice,
    required this.quantity,
  });

  factory OrderItemDetail.fromJson(Map<String, dynamic> json) {
    return OrderItemDetail(
      productName: json['product_name'] as String,
      productType: json['product_type'] as String,
      productPrice: double.parse(json['product_price'].toString()),
      quantity: json['quantity'] as int,
    );
  }
}

class OrderDetail {
  final int id;
  final String phone;
  final String address;
  final double totalAmount;
  final String status;
  final String createdAt;
  final List<OrderItemDetail> items;

  OrderDetail({
    required this.id,
    required this.phone,
    required this.address,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.items,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'] as int,
      phone: json['phone'] as String,
      address: json['address'] as String,
      totalAmount: double.parse(json['total_amount'].toString()),
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItemDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  OrderDetail copyWith({String? status}) {
    return OrderDetail(
      id: id,
      phone: phone,
      address: address,
      totalAmount: totalAmount,
      status: status ?? this.status,
      createdAt: createdAt,
      items: items,
    );
  }
}

class OrderRepository {
  final Dio _dio;
  OrderRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<CheckoutResponse> createCheckout({
    required String phone,
    required String address,
    double? latitude,
    double? longitude,
    required List<CartLine> lines,
    String paymentMethod = 'online', // 'online' or 'cod'
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/checkout/',
        data: {
          'phone': phone,
          'address': address,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          'payment_method': paymentMethod,
          'items': lines.map((line) => {
                'product_name': line.item.name,
                'product_price': line.item.price,
                'product_type': line.item.productType,
                'quantity': line.qty,
              }).toList(),
        },
      );
      return CheckoutResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw OrderException(_mapDioError(e));
    } catch (e) {
      throw OrderException('Could not create order: $e');
    }
  }

  Future<void> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      await _dio.post(
        '$_baseUrl/payment/verify/',
        data: {
          'razorpay_order_id': razorpayOrderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
        },
      );
    } on DioException catch (e) {
      throw OrderException(_mapDioError(e));
    }
  }

  Future<List<OrderDetail>> fetchOrdersByPhone(String phone) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/orders/',
        queryParameters: {'phone': phone},
      );
      final list = response.data as List<dynamic>;
      return list
          .map((e) => OrderDetail.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw OrderException(_mapDioError(e));
    }
  }

  Future<List<OrderDetail>> fetchAllOrders(String token,
      {String? statusFilter}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/admin/orders/',
        queryParameters: statusFilter != null ? {'status': statusFilter} : null,
        options: Options(headers: {'Authorization': 'Token $token'}),
      );
      final list = response.data as List<dynamic>;
      return list
          .map((e) => OrderDetail.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw OrderException('Invalid admin credentials.');
      }
      throw OrderException(_mapDioError(e));
    }
  }

  Future<void> updateOrderStatus({
    required String token,
    required int orderId,
    required String status,
  }) async {
    try {
      await _dio.patch(
        '$_baseUrl/admin/orders/$orderId/',
        data: {'status': status},
        options: Options(headers: {'Authorization': 'Token $token'}),
      );
    } on DioException catch (e) {
      throw OrderException(_mapDioError(e));
    }
  }

  Future<String> adminLogin({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.api_token_auth,
        data: {'username': username, 'password': password},
      );
      return response.data['token'] as String;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw OrderException('Wrong username or password.');
      }
      throw OrderException(_mapDioError(e));
    }
  }

  String _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'No connection. Check your internet.';
    }
    if (e.response?.statusCode == 400) {
      final data = e.response?.data;
      if (data is Map && data.isNotEmpty) {
        final first = data.values.first;
        if (first is List) return first.first.toString();
        return first.toString();
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
