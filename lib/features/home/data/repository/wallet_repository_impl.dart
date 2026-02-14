import '../../domain/models/wallet.dart';
import '../../domain/repository/wallet_repository.dart';
import '../datasource/wallet_remote_datasource.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDatasource datasource;

  WalletRepositoryImpl(this.datasource);

  @override
  Future<List<Wallet>> fetchWallets(String userId) async {
    final data = await datasource.fetchWallets(userId);
    return data.map(Wallet.fromMap).toList();
  }

  @override
  Future<void> addWallet(Wallet wallet) async {
    await datasource.insertWallet({
      'user_id': wallet.userId,
      'name': wallet.name,
      'type': wallet.type,
      'balance': wallet.balance,
      'currency': wallet.currency,
    });
  }

  @override
  Future<void> deleteWallet(String walletId) async {
    await datasource.deleteWallet(walletId);
  }

  @override
  Future<void> updateWallet(Wallet wallet) async {
    await datasource.updateWallet(
      wallet.id,
      {
        'name': wallet.name,
        'type': wallet.type,
        'balance': wallet.balance,
        'currency': wallet.currency,
      },
    );
  }
}
