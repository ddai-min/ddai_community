import 'package:ddai_community/core/constants/supabase_env.dart';
import 'package:ddai_community/core/utils/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 세션을 OS 보안 저장소(iOS Keychain · Android Keystore)에 넣는 [LocalStorage] 구현.
///
/// supabase_flutter 기본값은 `SharedPreferencesLocalStorage` 라 세션 JSON 이
/// iOS `NSUserDefaults` plist · Android SharedPreferences XML 에 **평문으로** 남는다.
/// 비밀번호는 앱 어디에도 저장하지 않지만, 여기 들어 있는 refresh token 이
/// 사실상 지속되는 자격증명이라 기기나 백업을 털리면 그대로 넘어간다.
///
/// `Bootstrap.run()` 에서 `Supabase.initialize` 의 `authOptions` 로 주입한다.
class SecureLocalStorage extends LocalStorage {
  SecureLocalStorage()
    : _legacyStorage = SharedPreferencesLocalStorage(
        persistSessionKey: sessionKey,
      );

  /// 세션 저장 키.
  ///
  /// supabase_flutter 기본 구현이 쓰던 키(`sb-<host 첫 라벨>-auth-token`)와
  /// **같아야 한다.** 기존 사용자의 세션을 찾아 옮겨오는 데 이 키를 쓴다.
  ///
  /// `supabaseUrl` 이 `.env` 에서 오므로 `dotenv.load()` 이후에 평가돼야 한다.
  /// `static final` 이라 첫 접근(=이 클래스 생성) 시점에 평가된다.
  static final String sessionKey =
      'sb-${Uri.parse(supabaseUrl).host.split('.').first}-auth-token';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    // `first_unlock` — 부팅 후 한 번이라도 잠금을 풀면 읽을 수 있다.
    // `*_this_device` 변형은 기기 백업으로 옮겨가지 않는데, 그러면 폰을 바꾼
    // 익명 유저가 계정을 통째로 잃는다. (익명 계정은 되찾을 수단이 없다)
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    // 기본값 `resetOnError: true` 를 그대로 쓴다. Android 자동 백업은 암호화된
    // 파일만 옮기고 Keystore 키는 안 옮기므로 기기를 바꾸면 복호화가 깨지는데,
    // 그때 예외를 던지는 대신 값을 비워야 앱이 시작이라도 한다.
    aOptions: AndroidOptions(),
  );

  /// 마이그레이션 원본. 옮기고 나면 쓰지 않는다.
  final SharedPreferencesLocalStorage _legacyStorage;

  @override
  Future<void> initialize() => _migrateFromSharedPreferences();

  /// SharedPreferences 에 남아 있던 세션을 보안 저장소로 한 번 옮긴다.
  ///
  /// 이 단계가 없으면 앱을 업데이트하는 순간 **기존 로그인이 전부 풀린다.**
  /// 익명 계정은 이메일도 비밀번호도 없어 다시 들어갈 방법이 없으므로
  /// 계정과 작성한 글이 통째로 사라진다.
  Future<void> _migrateFromSharedPreferences() async {
    try {
      if (await _secureStorage.containsKey(key: sessionKey)) {
        return;
      }

      await _legacyStorage.initialize();

      // 이름과 달리 access token 이 아니라 세션 JSON 전체를 돌려준다.
      final legacySession = await _legacyStorage.accessToken();

      if (legacySession == null) {
        return;
      }

      await _secureStorage.write(key: sessionKey, value: legacySession);

      // 평문 사본을 남겨두면 옮긴 의미가 없다.
      await _legacyStorage.removePersistedSession();
    } catch (error) {
      logger.e(error);
    }
  }

  // 읽기는 실패해도 예외를 삼킨다. 여기서 던지면 `Supabase.initialize` 가
  // 통째로 실패해 앱이 켜지지도 않는데, 최악이라야 "다시 로그인" 이면 된다.

  @override
  Future<bool> hasAccessToken() async {
    try {
      return await _secureStorage.containsKey(key: sessionKey);
    } catch (error) {
      logger.e(error);

      return false;
    }
  }

  @override
  Future<String?> accessToken() async {
    try {
      return await _secureStorage.read(key: sessionKey);
    } catch (error) {
      logger.e(error);

      return null;
    }
  }

  // 반면 쓰기·삭제는 **일부러 감싸지 않는다.** 조용히 실패시키면
  // 로그아웃했는데 세션이 디스크에 남아 있는 상태가 만들어진다.

  @override
  Future<void> persistSession(String persistSessionString) =>
      _secureStorage.write(key: sessionKey, value: persistSessionString);

  @override
  Future<void> removePersistedSession() =>
      _secureStorage.delete(key: sessionKey);
}
