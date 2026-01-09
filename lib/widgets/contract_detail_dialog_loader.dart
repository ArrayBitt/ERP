import 'package:flutter/material.dart';
import '../services/contract_balance_service.dart';
import 'contract_detail_dialog.dart';

class ContractDetailDialogLoader {
  static Future<void> show({
    required BuildContext context,
    required dynamic contract,
    required String username,
    required int employeesId,
    required String employeesRecordId,
  }) async {
    // ❗ validate ก่อน
    if (employeesId <= 0 || employeesRecordId.isEmpty) {
      showDialog(
        context: context,
        builder:
            (_) => const AlertDialog(
              title: Text('ข้อมูลพนักงานไม่ถูกต้อง'),
              content: Text('กรุณา logout แล้วเข้าใหม่'),
            ),
      );
      return; // หยุดการเปิด dialog
    }

    // ดึง balance จาก API
    final balance = await ContractBalanceService.fetchBalance(
      contractId: contract['contractid']?.toString() ?? '',
      contractNo: contract['contractno']?.toString() ?? '',
    );

    // แสดง ContractDetailDialog
    showDialog(
      context: context,
      builder:
          (_) => ContractDetailDialog(
            contract: contract,
            username: username,
            balance: balance,
            employeesId: employeesId,
            employeesRecordId: employeesRecordId,
          ),
    );
  }
}
