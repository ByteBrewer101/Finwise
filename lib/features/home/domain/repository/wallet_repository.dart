import '../models/wallet.dart';

abstract class WalletRepository {
  Future<List<Wallet>> fetchWallets(String userId);

  Future<void> addWallet(Wallet wallet);

  Future<void> deleteWallet(String walletId);

  Future<void> updateWallet(Wallet wallet);
}
