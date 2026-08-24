import 'dart:js_interop';

@JS('window.Telegram.WebApp')
external _WebAppJS? get _webApp;

@JS()
@staticInterop
extension type _WebAppJS._(JSObject _) implements JSObject {
  external void expand();

  external void ready();

  external _InitDataUnsafeJS? get initDataUnsafe;

  external JSString? get initData;
}

@JS()
@staticInterop
extension type _InitDataUnsafeJS._(JSObject _) implements JSObject {
  external _UserJS? get user;
}

@JS()
@staticInterop
extension type _UserJS._(JSObject _) implements JSObject {
  external JSNumber? get id;

  external JSString? get firstName;

  external JSString? get username;
}

class TelegramService {
  static void init() {
    try {
      _webApp?.expand();
      _webApp?.ready();
    } catch (_) {}
  }

  static int? get userId => _webApp?.initDataUnsafe?.user?.id?.toDartDouble.toInt();

  static String? get firstName => _webApp?.initDataUnsafe?.user?.firstName?.toDart;

  static String? get username => _webApp?.initDataUnsafe?.user?.username?.toDart;

  static String? get initData => _webApp?.initData?.toDart;
}
