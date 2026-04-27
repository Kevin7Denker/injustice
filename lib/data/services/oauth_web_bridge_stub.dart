const bool isWebOAuthBridgeAvailable = false;

Uri webCurrentUri() {
  throw UnsupportedError('OAuth web bridge indisponivel nesta plataforma.');
}

String? webStorageGet(String key) {
  return null;
}

void webStorageSet(String key, String value) {}

void webStorageRemove(String key) {}

void webRedirectTo(String url) {
  throw UnsupportedError('OAuth web redirect indisponivel nesta plataforma.');
}

void webClearOAuthQueryParams() {}
