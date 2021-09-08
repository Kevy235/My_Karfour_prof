import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mykarfour/exceptions/db_storage_exception.dart';
import 'package:mykarfour/model/tokens.dart';
import 'package:mykarfour/model/user.dart';
import 'package:mykarfour/utils/apirequest.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DbService {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  SharedPreferences _sharedPreferences;

  static const ACCESS_TOKEN_KEY = "mykarfour.access_token";
  static const REFRESH_TOKEN_KEY = "mykarfour.refresh_token";
  static const ACCESS_TOKEN_EXPIRATION_KEY = "mykarfour.expires_in";
  static const TOKEN_TYPE_KEY = "mykarfour.token_type";
  static const USER_NAME_KEY = "mykarfour.user_name";
  static const USER_FIRSTNAME_KEY = "mykarfour.user_first_name";
  static const USER_USERNAME_KEY = "mykarfour.user_username";
  static const USER_EMAIL_KEY = "mykarfour.user_email";
  static const USER_ID_KEY = "mykarfour.user_id";
  static const USER_SYSTEM_ID_KEY = "mykarfour.system_id";
  static const USER_CLASS_ID_KEY = "mykarfour.class_id";
  static const USER_CLASSNAME_KEY = "mykarfour.class_name";
  static const USER_PROVINCE_KEY = "mykarfour.province";
  static const USER_BIRTHDAY_KEY = "mykarfour.birthday";
  static const USER_IMAGE_KEY = "mykarfour.user_image";
  static const USER_COVER_KEY = "mykarfour.user_cover";
  static const USER_STUDENTS_KEY = "mykarfour.user_students";
  static const USER_FANS_KEY = "mykarfour.user_fans";
  static const USER_SCHOOL_KEY = "mykarfour.school";
  static const USER_ACTIVATED_KEY = "mykarfour.activated";
  static const USER_LIKES_KEY = "mykarfour.user_likes";
  static const USER_VISIBILITY = "mykarfour.user_visibility";
  static const USER_POSTS_KEY = "mykarfour.user_posts";
  static const USER_SUBJECT_ID_KEY = "mykarfour.subject_id";
  static const USER_SUBJECT_NAME_KEY = "mykarfour.subject_name";
  static const USER_VERIFIED_AT_KEY = "mykarfour.verified_at";

  Future<bool> saveUser(dynamic user) async {
    try {
      final prefs = await _preferences;

      prefs.setString(USER_EMAIL_KEY, user["phone_number"]);
      prefs.setString(USER_USERNAME_KEY, user['username']);
      prefs.setString(USER_NAME_KEY, user['name']);
      prefs.setString(USER_FIRSTNAME_KEY, user['first_name']);
      prefs.setString(USER_SCHOOL_KEY, user['school']);
      prefs.setInt(USER_ID_KEY, user["id"]);
      prefs.setString(USER_EMAIL_KEY, user["email"]);
      prefs.setInt(USER_SYSTEM_ID_KEY, user["school_system_id"]);
      prefs.setString(USER_PROVINCE_KEY, user["province"]);
      prefs.setString(USER_BIRTHDAY_KEY, user["birthday"]);
      prefs.setBool(
          USER_ACTIVATED_KEY, (user["classes"] as List<dynamic>).isNotEmpty);
      prefs.setInt(
          USER_SUBJECT_ID_KEY, (user["subjects"] as List<dynamic>)[0]["id"]);
      prefs.setString(USER_SUBJECT_NAME_KEY,
          (user["subjects"] as List<dynamic>)[0]["name"]);
      // print("grk,l");
      if (user['picture'] != null)
        prefs.setString(
            USER_IMAGE_KEY,
            (user["picture"].toString().contains("assets") ||
                    user["picture"].toString() == 'default')
                ? user["picture"]
                : (Apirequest.uploadHost + user["picture"]));
      else
        prefs.setString(USER_IMAGE_KEY, 'default');

      prefs.setString(USER_VERIFIED_AT_KEY, user["phone_number_verified_at"]);

      return true;
    } catch (e) {
      throw DbStorageException(e.toString());
    }
  }

  Future<bool> updateProfilePicture(String path) async {
    try {
      final prefs = await _preferences;

      prefs.setString(USER_IMAGE_KEY, path);

      return true;
    } catch (e) {
      throw DbStorageException(e.toString());
    }
  }

  Future<bool> updateClass(int systemId, int classId, String className) async {
    try {
      final prefs = await _preferences;

      print(className + " " + classId.toString() + " " + systemId.toString());

      prefs.setInt(USER_CLASS_ID_KEY, classId);
      prefs.setString(USER_CLASSNAME_KEY, className);
      prefs.setInt(USER_SYSTEM_ID_KEY, systemId);

      return true;
    } catch (e) {
      throw DbStorageException(e.toString());
    }
  }

  Future<bool> saveTokens(Tokens tokens) async {
    try {
      await Future.wait<void>(
        [
          _secureStorage.write(
            key: ACCESS_TOKEN_KEY,
            value: tokens.accessToken,
          ),
          _secureStorage.write(
            key: REFRESH_TOKEN_KEY,
            value: tokens.refreshToken,
          ),
          _secureStorage.write(
            key: TOKEN_TYPE_KEY,
            value: tokens.tokenType,
          ),
        ],
      );
      return true;
    } catch (e) {
      throw DbStorageException(e.toString());
    }
  }

  Future<SharedPreferences> get _preferences async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }
    return _sharedPreferences;
  }

  Future<Tokens> getTokens() async {
    return Tokens(
      await _secureStorage.read(key: TOKEN_TYPE_KEY),
      await _secureStorage.read(key: ACCESS_TOKEN_KEY),
      await _secureStorage.read(key: REFRESH_TOKEN_KEY),
      null,
    );
  }

  Future<String> getAccessToken() async {
    final tokens = await getTokens();
    return tokens.accessToken;
  }

  Future<String> getRefreshToken() async {
    final tokens = await getTokens();
    return tokens.refreshToken;
  }

  Future<User> getUser() async {
    final prefs = await _preferences;
    return User(
        id: await prefs.getInt(USER_ID_KEY),
        name: await prefs.getString(USER_NAME_KEY),
        username: await prefs.getString(USER_USERNAME_KEY),
        classroom: await prefs.getString(USER_CLASSNAME_KEY),
        photo: await prefs.getString(USER_IMAGE_KEY),
        email: await prefs.getString(USER_EMAIL_KEY),
        students: await prefs.getInt(USER_STUDENTS_KEY) ?? 0,
        province: await prefs.getString(USER_PROVINCE_KEY),
        subject_name: await prefs.getString(USER_SUBJECT_NAME_KEY),
        subject_id: await prefs.getInt(USER_SUBJECT_ID_KEY),
        activated: await prefs.getBool(USER_ACTIVATED_KEY),
        birthday: await prefs.getString(USER_BIRTHDAY_KEY));
  }

  // Future<bool> hasVerifiedUser() async {
  //   final user = await getUser();
  //   return user.isValid && user.isVerified;
  // }

  Future<void> clearAll() async {
    await Future.wait<void>([
      (await _preferences).clear(),
      (await _secureStorage).deleteAll(),
    ]);
  }
}
