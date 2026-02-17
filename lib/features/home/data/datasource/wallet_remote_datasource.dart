import 'package:supabase_flutter/supabase_flutter.dart';

class WalletRemoteDatasource {
  final SupabaseClient client;

  WalletRemoteDatasource(this.client);

  Future<List<Map<String, dynamic>>> fetchWallets(String userId) async {
    final response = await client
        .from('wallets')
        .select()
        .eq('user_id', userId)
        .order('created_at');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> insertWallet(Map<String, dynamic> data) async {
    await client.from('wallets').insert(data);
  }

  Future<void> deleteWallet(String walletId) async {
    await client.from('wallets').delete().eq('id', walletId);
  }

  Future<void> updateWallet(
    String walletId,
    Map<String, dynamic> data,
  ) async {
    await client.from('wallets').update(data).eq('id', walletId);
  }
}
