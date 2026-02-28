import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/global_providers.dart';
import '../../../../services/sync/sync_service.dart';
import '../../data/repository/wallet_repository_impl.dart';
import '../../domain/models/wallet.dart';
import '../../domain/repository/wallet_repository.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final localDb = ref.read(localDatabaseProvider);
  return WalletRepositoryImpl(localDb);
});

final walletProvider =
    StateNotifierProvider<WalletNotifier, AsyncValue<List<Wallet>>>(
      (ref) => WalletNotifier(ref),
    );

class WalletNotifier extends StateNotifier<AsyncValue<List<Wallet>>> {
  final Ref ref;

  WalletNotifier(this.ref) : super(const AsyncLoading()) {
    loadWallets();
  }

  Future<void> loadWallets() async {
    try {
      final userId = ref.read(currentUserIdProvider);

      if (userId == null) {
        if (!mounted) return;
        state = const AsyncData([]);
        return;
      }

      final repo = ref.read(walletRepositoryProvider);
      var wallets = await repo.fetchWallets(userId);
      if (wallets.isEmpty) {
        await ref.read(syncServiceProvider).syncNow();
        wallets = await repo.fetchWallets(userId);
      }

      if (!mounted) return;
      state = AsyncData(wallets);
    } catch (e, st) {
      if (!mounted) return;
      state = AsyncError(e, st);
    }
  }
}
