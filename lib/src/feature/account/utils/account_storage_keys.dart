String legacyAccountStorageKey(String issuer, String label) => '$issuer:$label';

String accountStorageKey(String issuer, String label) =>
    legacyAccountStorageKey(issuer, label);

String legacySecretStorageKey(String accountId) => '${accountId}_secret';

String authoritativeAccountStorageKey(String issuer, String label) {
  return 'account:${Uri.encodeComponent(issuer)}:${Uri.encodeComponent(label)}';
}

bool isAuthoritativeAccountStorageKey(String key) {
  return key.startsWith('account:');
}
