import 'dart:convert';
import 'dart:developer';

import 'package:encrypt/encrypt.dart';

class HesabeCrypt {
  String encrypt(String result, String key, String iv) {
    try {
      final keyFromUTF = Key.fromUtf8(key);
      final ivFromLength = IV.fromUtf8(iv);

      final encrypter = Encrypter(
        AES(
          keyFromUTF,
          mode: AESMode.cbc,
        ),
      );
      final encrypted = encrypter.encrypt(result, iv: ivFromLength);
      print('encrypted.base64 ${encrypted.base64}');
      return base64ToHex(encrypted.base64);
    } catch (e, st) {
      log('Error: $e StackTrace: $st');
      throw e;
    }
  }

  String decrypt(String code, String key, String iv) {
    try {
      final keyFromUTF = Key.fromUtf8(key);
      final ivFromLength = IV.fromUtf8(iv);

      final encrypter = Encrypter(
        AES(
          keyFromUTF,
          mode: AESMode.cbc,
          padding: null,
        ),
      );
      log('code $code');
      final decrypted = encrypter.decrypt16(
        code,
        iv: ivFromLength,
      );
      log('decrypted $decrypted');
      return decrypted;
    } catch (e, st) {
      log('Error: ${e.toString()}\nStackTrace: $st');
      throw e;
    }
  }

  String base64ToHex(String source) =>
      base64Decode(LineSplitter.split(source).join())
          .map((e) => e.toRadixString(16).padLeft(2, '0'))
          .join();
}
