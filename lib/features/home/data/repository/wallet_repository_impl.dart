import '../../domain/models/wallet.dart';
import '../../domain/repository/wallet_repository.dart';
import '../../../../services/local/local_database.dart';

class WalletRepositoryImpl implements WalletRepository {
  final LocalDatabase localDb;

  WalletRepositoryImpl(this.localDb);

  @override
  Future<List<Wallet>> fetchWallets(String userId) async {
    final data = localDb.getWallets(userId);
    return data.map(Wallet.fromMap).toList();
  }

  @override
  Future<void> addWallet(Wallet wallet) async {
    final row = {
      'id': wallet.id,
      'user_id': wallet.userId,
      'name': wallet.name,
      'type': wallet.type,
      'balance': wallet.balance,
      'currency': wallet.currency,
      'created_at': wallet.createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
    localDb.putWallet(row);
    await localDb.enqueueChange(
      userId: wallet.userId,
      entity: 'wallets',
      entityId: wallet.id,
      operation: 'create',
      payload: row,
    );
  }

  @override
  Future<void> deleteWallet(String walletId) async {
    final row = localDb.getWalletById(walletId);
    localDb.deleteWallet(walletId);
    if (row != null) {
      await localDb.enqueueChange(
        userId: row['user_id'] as String,
        entity: 'wallets',
        entityId: walletId,
        operation: 'delete',
      );
    }
  }

  @override
  Future<void> updateWallet(Wallet wallet) async {
    final existing = localDb.getWalletById(wallet.id);
    final row = {
      'id': wallet.id,
      'user_id': wallet.userId,
      'name': wallet.name,
      'type': wallet.type,
      'balance': wallet.balance,
      'currency': wallet.currency,
      'created_at': existing?['created_at'] ?? wallet.createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
    localDb.putWallet(row);
    await localDb.enqueueChange(
      userId: wallet.userId,
      entity: 'wallets',
      entityId: wallet.id,
      operation: 'update',
      payload: row,
    );
  }
}
