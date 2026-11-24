class AdRemoteRequest {
  const AdRemoteRequest({
    required this.url,
    required this.headers,
    required this.body,
    required this.mapping,
    this.timeout = const Duration(seconds: 40),
  });

  final String url;
  final Map<String, dynamic> headers;
  final Map<String, dynamic> body;

  /// 明文字段完整路径到混淆字段完整路径的映射。
  ///
  /// 数组层级使用单独的 `*` 路径段。
  final Map<String, String> mapping;
  final Duration timeout;

  void validate() {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      throw ArgumentError.value(url, 'url', 'must be a valid absolute URL');
    }
    if (mapping.isEmpty) {
      throw ArgumentError.value(mapping, 'mapping', 'must not be empty');
    }
    if (timeout <= Duration.zero) {
      throw ArgumentError.value(timeout, 'timeout', 'must be positive');
    }
  }
}
