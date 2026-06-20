import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionService {
  // Base URL de ton API Laravel
  static const String _baseUrl = 'https://rungobf.com/taxi/public/api/v1';

  /*
  |--------------------------------------------------------------------------
  | RÃ©cupÃ©rer le token du driver connectÃ©
  |--------------------------------------------------------------------------
  */
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /*
  |--------------------------------------------------------------------------
  | Headers communs avec Authorization
  |--------------------------------------------------------------------------
  */
  static Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /*
  |--------------------------------------------------------------------------
  | 1. GET /api/v1/driver/subscription/status
  | Retourne le statut de l'abonnement du driver connectÃ©
  |--------------------------------------------------------------------------
  */
  static Future<SubscriptionStatusResult> getStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/driver/subscription/status'),
        headers: await _headers(),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return SubscriptionStatusResult(
          success: true,
          hasSubscription: data['has_subscription'] ?? false,
          isActive: data['is_active'] ?? false,
          subscriptionStatus: data['subscription_status'] ?? 'none',
          paymentStatus: data['payment_status'],
          data: data['data'] != null
              ? SubscriptionData.fromJson(data['data'])
              : null,
        );
      }

      return SubscriptionStatusResult(
        success: false,
        hasSubscription: false,
        isActive: false,
        subscriptionStatus: 'none',
        error: data['message'] ?? 'Erreur inconnue',
      );
    } catch (e) {
      return SubscriptionStatusResult(
        success: false,
        hasSubscription: false,
        isActive: false,
        subscriptionStatus: 'none',
        error: 'Erreur rÃ©seau : $e',
      );
    }
  }

  /*
  |--------------------------------------------------------------------------
  | 2. POST /api/v1/payment/cinetpay/subscribe
  | Initier un paiement d'abonnement â€” retourne le payment_url CinetPay
  |--------------------------------------------------------------------------
  */
  static Future<InitSubscriptionResult> initSubscription(String plan) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payment/cinetpay/subscribe'),
        headers: await _headers(),
        body: jsonEncode({'plan': plan}),
      ).timeout(const Duration(seconds: 20));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return InitSubscriptionResult(
          success: true,
          paymentUrl: data['payment_url'],
          transactionId: data['transaction_id'],
          plan: data['plan'],
          amount: (data['amount'] as num).toDouble(),
          currency: data['currency'] ?? 'XOF',
        );
      }

      return InitSubscriptionResult(
        success: false,
        error: data['message'] ?? 'Ã‰chec de l\'initialisation du paiement.',
      );
    } catch (e) {
      return InitSubscriptionResult(
        success: false,
        error: 'Erreur rÃ©seau : $e',
      );
    }
  }
}

/*
|--------------------------------------------------------------------------
| ModÃ¨les de rÃ©sultat
|--------------------------------------------------------------------------
*/

class SubscriptionStatusResult {
  final bool success;
  final bool hasSubscription;
  final bool isActive;
  final String subscriptionStatus;
  final String? paymentStatus;
  final SubscriptionData? data;
  final String? error;

  SubscriptionStatusResult({
    required this.success,
    required this.hasSubscription,
    required this.isActive,
    required this.subscriptionStatus,
    this.paymentStatus,
    this.data,
    this.error,
  });
}

class SubscriptionData {
  final String id;
  final String plan;
  final double amount;
  final String currency;
  final String? startsAt;
  final String? expiresAt;
  final int daysRemaining;

  SubscriptionData({
    required this.id,
    required this.plan,
    required this.amount,
    required this.currency,
    this.startsAt,
    this.expiresAt,
    required this.daysRemaining,
  });

  factory SubscriptionData.fromJson(Map<String, dynamic> json) {
    return SubscriptionData(
      id: json['id'] ?? '',
      plan: json['plan'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] ?? 'XOF',
      startsAt: json['starts_at'],
      expiresAt: json['expires_at'],
      daysRemaining: json['days_remaining'] ?? 0,
    );
  }

  String get planLabel {
    switch (plan) {
      case 'weekly':
        return 'Hebdomadaire';
      case 'monthly':
        return 'Mensuel';
      case 'yearly':
        return 'Annuel';
      default:
        return plan;
    }
  }
}

class InitSubscriptionResult {
  final bool success;
  final String? paymentUrl;
  final String? transactionId;
  final String? plan;
  final double? amount;
  final String? currency;
  final String? error;

  InitSubscriptionResult({
    required this.success,
    this.paymentUrl,
    this.transactionId,
    this.plan,
    this.amount,
    this.currency,
    this.error,
  });
}
