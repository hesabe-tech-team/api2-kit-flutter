library hesabe;

import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:eventify/eventify.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hesabe/src/api/api_interface.dart';
import 'package:hesabe/src/api/dio_helper.dart';
import 'package:hesabe/src/crypto/hesabe_crypt.dart';
import 'package:hesabe/src/webview_screen.dart';

class Hesabe {
  late EventEmitter _eventEmitter;

  // Event names
  static const EVENT_PAYMENT_SUCCESS = 'success';
  static const EVENT_PAYMENT_ERROR = 'error';
  static const EVENT_PAYMENT_CANCELLED_BY_USER = 'cancelled_by_user';

  final String baseUrl;
  final String secretKey;
  final String ivKey;
  final String accessCode;

  final RegExp _trimmingRegExp = RegExp(
    '(\u000e|\u0000|\u0004|\u0005|\u0006|\u0007|\u0008|\u0009|\u000A|\u000B\u000C|\u000D|\u000E|\u000F|\u0010|\u0011|\u0012|\u0013|\u0014|\u0015|\u0016|\u0017|\u0018|\u0019|\u001A|\u001B|\u001C|\u001D|\u001E|\u001F)',
  );

  Hesabe({
    required this.baseUrl,
    required this.secretKey,
    required this.ivKey,
    required this.accessCode,
  }) {
    _eventEmitter = EventEmitter();
  }

  late String responseUrl;
  late String failureUrl;

  Future<void> openCheckout(
    BuildContext context, {
    required Map<String, dynamic> paymentRequestObject,
  }) async {
    responseUrl = paymentRequestObject['responseUrl'];
    failureUrl = paymentRequestObject['failureUrl'];
    final request = json.encode(paymentRequestObject);
    final encryptedData = HesabeCrypt().encrypt(request, secretKey, ivKey);
    await checkOutRequest(encryptedData, context);
  }

  Future<void> checkOutRequest(
    String encryptedData,
    BuildContext context,
  ) async {
    final Dio dio = DioHelper.getDio(baseUrl);
    try {
      final response = await ApiInterface(dio).hesabePay(
        accessCode,
        encryptedData,
      );
      processResponse(response, context);
    } catch (e, st) {
      log('Checkout Error: ${e.toString()}\nStackTrace: $st');
      throw e;
    }
  }

  Future<void> processResponse(String response, BuildContext context) async {
    /* Decrypt Response */
    final decryptedResponse = HesabeCrypt().decrypt(response, secretKey, ivKey);
    final trimmedData =
        decryptedResponse.replaceAll(_trimmingRegExp, '').trim();
    /* Get token from decrypted response */
    final responseToken = json.decode(trimmedData)['response']['data'];
    /* Create payment URL with response token */
    final paymentURL = '$baseUrl/payment?data=$responseToken';

    /* Open WebView Activity to load the URL */
    final data = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WebviewScreen(
          paymentURL: paymentURL,
          responseUrl: responseUrl,
          failureUrl: failureUrl,
        ),
      ),
    );

    String eventName;

    if (data == EVENT_PAYMENT_CANCELLED_BY_USER) {
      eventName = EVENT_PAYMENT_ERROR;
      _eventEmitter.emit(eventName, null, 'Payment Cancelled by user.');
    } else if (data != null) {
      final decryptedData = HesabeCrypt()
          .decrypt(data, secretKey, ivKey)
          .replaceAll(_trimmingRegExp, '')
          .trim();

      final decodedResponse = json.decode(utf8.decode(decryptedData.codeUnits));

      if (decodedResponse['status']) {
        eventName = EVENT_PAYMENT_SUCCESS;
        _eventEmitter.emit(eventName, null, decodedResponse['response']);
      } else {
        eventName = EVENT_PAYMENT_ERROR;
        _eventEmitter.emit(eventName, null, decodedResponse['response']);
      }
    }
  }

  /// Registers event listeners for payment events
  void on(String event, Function handler) {
    EventCallback cb = (event, cont) {
      handler(event.eventData);
    };
    _eventEmitter.on(event, null, cb);
  }

  /// Clears all event listeners
  void clear() {
    _eventEmitter.clear();
  }
}
