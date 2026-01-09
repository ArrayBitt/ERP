import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ContractBalanceService {
  static const _baseUrl =
      'https://erp.somjai.app/api/debttrackings/send/balance/to/mobile';

  static Future<Map<String, dynamic>> fetchBalance({
    required String contractId,
    required String contractNo,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';

    Future<Map<String, dynamic>> _request(String idOrNo) async {
      try {
        final response = await http.get(
          Uri.parse('$_baseUrl/$idOrNo'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return {
            'intbalance': data['int_balance'] ?? 0,
            'free': data['feeBalance'] ?? 0,
            'all_balance': data['balance_all'] ?? 0,
          };
        }
      } catch (e) {
        print('Fetch balance error ($idOrNo): $e');
      }
      return {};
    }

    // 1. ใช้ contractId ก่อน
    var balance = await _request(contractId);

    // 2. fallback → contractNo
    if (balance.isEmpty && contractNo.isNotEmpty) {
      balance = await _request(contractNo);
    }

    return balance.isNotEmpty
        ? balance
        : {'intbalance': 0, 'free': 0, 'all_balance': 0};
  }
}
