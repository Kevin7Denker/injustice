import 'dart:html' as html;

const bool isWebOAuthBridgeAvailable = true;

Uri webCurrentUri() {
  return Uri.parse(html.window.location.href);
}

String? webStorageGet(String key) {
  return html.window.sessionStorage[key];
}

void webStorageSet(String key, String value) {
  html.window.sessionStorage[key] = value;
}

void webStorageRemove(String key) {
  html.window.sessionStorage.remove(key);
}

void webRedirectTo(String url) {
  html.window.location.assign(url);
}

void webClearOAuthQueryParams() {
  final uri = Uri.parse(html.window.location.href);
  final query = Map<String, String>.from(uri.queryParameters)
    ..remove('code')
    ..remove('state')
    ..remove('error')
    ..remove('error_description');

  final cleanedUri = uri.replace(queryParameters: query.isEmpty ? null : query);
  html.window.history.replaceState(null, '', cleanedUri.toString());
}
