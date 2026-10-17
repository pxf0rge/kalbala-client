import 'package:rahmani_project/core/errors/exceptions.dart' as app_errors;
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class SettlementRemoteDataSource {
  Future<Map<String, dynamic>> fetchBalance();

  Future<List<dynamic>> fetchBankAccounts();

  Future<String> createBankAccount({
    required String bankName,
    required String accountNumber,
    required String accountHolder,
  });

  Future<void> removeBankAccount(String bankAccountId);

  Future<String> createSettlementRequest({
    required double amount,
    required String bankAccountId,
  });

  Future<List<dynamic>> fetchSettlements();
}

final class SettlementRemoteDataSourceImpl implements SettlementRemoteDataSource {
  SettlementRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<Map<String, dynamic>> fetchBalance() async {
    try {
      final data = await _client.rpc('get_seller_balance');
      if (data is Map<String, dynamic>) return data;
      return Map<String, dynamic>.from(data as Map);
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<List<dynamic>> fetchBankAccounts() async {
    try {
      final data = await _client.rpc('get_my_bank_accounts');
      return data as List<dynamic>? ?? [];
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<String> createBankAccount({
    required String bankName,
    required String accountNumber,
    required String accountHolder,
  }) async {
    try {
      final data = await _client.rpc(
        'add_bank_account',
        params: {
          'p_bank_name': bankName,
          'p_account_number': accountNumber,
          'p_account_holder': accountHolder,
        },
      );
      return data as String;
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<void> removeBankAccount(String bankAccountId) async {
    try {
      await _client.rpc('delete_bank_account', params: {'p_bank_account_id': bankAccountId});
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<String> createSettlementRequest({
    required double amount,
    required String bankAccountId,
  }) async {
    try {
      final data = await _client.rpc(
        'request_settlement',
        params: {
          'p_amount': amount,
          'p_bank_account_id': bankAccountId,
        },
      );
      return data as String;
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<List<dynamic>> fetchSettlements() async {
    try {
      final data = await _client.rpc('get_my_settlements');
      return data as List<dynamic>? ?? [];
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }
}
