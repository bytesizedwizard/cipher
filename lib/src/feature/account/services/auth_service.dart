import 'package:cipher/src/feature/account/models/auth_models.dart';
import 'package:cipher/src/feature/account/models/errors.dart';
import 'package:cipher/src/feature/account/services/account_storage_service.dart';
import 'package:cipher/src/feature/account/utils/constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_service.g.dart';

class AuthService {
  const AuthService({required AccountStorageService accountStorageService})
    : _accountStorageService = accountStorageService;

  final AccountStorageService _accountStorageService;

  Future<List<Account>> getAccounts(String query) async {
    final result = await _accountStorageService.loadAll();
    if (result.records.isEmpty && result.issues.isNotEmpty) {
      throw result.issues.first;
    }

    final normalizedQuery = query.toLowerCase();
    return result.accounts.where((account) {
      if (normalizedQuery.isEmpty) {
        return true;
      }
      return account.toJson().toString().toLowerCase().contains(
        normalizedQuery,
      );
    }).toList();
  }

  Future<List<AccountStorageIssue>> migrateLegacyAccounts() {
    return _accountStorageService.migrateLegacyAccounts();
  }

  Future<void> addAccount(Account account, String secret) async {
    await _accountStorageService.save(account, secret);
  }

  Future<void> deleteAccount(String id) async {
    await _accountStorageService.deleteById(id);
  }

  Future<void> advanceHotp(String id) async {
    Account? account;
    for (final candidate in await getAccounts('')) {
      if (candidate.id == id) {
        account = candidate;
        break;
      }
    }
    if (account == null || account.type != AuthConstants.hotp) {
      throw AccountStorageIssue(
        code: AccountStorageIssueCode.invalidRecord,
        operation: 'advanceHotp',
        accountId: id,
      );
    }
    await _accountStorageService.updateCounter(account, account.counter + 1);
  }
}

@Riverpod(keepAlive: true)
AuthService authService(Ref ref) {
  final accountStorageService = ref.watch(accountStorageServiceProvider);

  return AuthService(accountStorageService: accountStorageService);
}
