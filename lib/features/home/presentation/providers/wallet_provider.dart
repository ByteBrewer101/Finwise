import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/global_providers.dart';
import '../../data/datasource/wallet_remote_datasource.dart';
import '../../data/repository/wallet_repository_impl.dart';
import '../../domain/models/wallet.dart';
import '../../domain/repository/wallet_repository.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final client = Supabase.instance.client;
  return WalletRepositoryImpl(WalletRemoteDatasource(client));
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
        state = const AsyncData([]);
        return;
      }

      final repo = ref.read(walletRepositoryProvider);
      final wallets = await repo.fetchWallets(userId);

      state = AsyncData(wallets);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
