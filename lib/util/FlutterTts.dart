import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

typedef void ErrorHandler(dynamic message);

// Provides Platform specific TTS services (Android: TextToSpeech, IOS: AVSpeechSynthesizer)
class FlutterTts {
  static const MethodChannel _channel = const MethodChannel('reader/flutter_tts');

  VoidCallback initHandler;
  VoidCallback callingHandler;
  ValueSetter<int> startHandler;
  ValueSetter<int> completionHandler;
  ErrorHandler errorHandler;

  FlutterTts() {
    _channel.setMethodCallHandler(platformCallHandler);
  }

  /// [Future] which invokes the platform specific method for speaking
  Future<dynamic> speak(String text, String uuid) {
    var data = {'text' : text, 'uuid' : uuid};
    _channel.invokeMethod('speak', data);
  }

  /// [Future] which invokes the platform specific method for speaking
  Future<dynamic> speakAdd(String text, String uuid) {
    var data = {'text' : text, 'uuid' : uuid};
    _channel.invokeMethod('speakAdd', data);
  }

  /// [Future] which invokes the platform specific method for setLanguage
  Future<dynamic> setLanguage(String language) =>
      _channel.invokeMethod('setLanguage', language);

  /// [Future] which invokes the platform specific method for setSpeechRate
  /// Allowed values are in the range from 0.0 (silent) to 1.0 (loudest)
  Future<dynamic> setSpeechRate(double rate) =>
      _channel.invokeMethod('setSpeechRate', rate);

  /// [Future] which invokes the platform specific method for setVolume
  /// Allowed values are in the range from 0.0 (silent) to 1.0 (loudest)
  Future<dynamic> setVolume(double volume) =>
      _channel.invokeMethod('setVolume', volume);

  /// [Future] which invokes the platform specific method for setPitch
  /// 1.0 is default and ranges from .5 to 2.0
  Future<dynamic> setPitch(double pitch) =>
      _channel.invokeMethod('setPitch', pitch);

  /// [Future] which invokes the platform specific method for setVoice
  /// ***Android supported only***
  Future<dynamic> setVoice(String voice) =>
      _channel.invokeMethod('setVoice', voice);

  /// [Future] which invokes the platform specific method for stop
  Future<dynamic> stop() => _channel.invokeMethod('stop');

  /// [Future] which invokes the platform specific method for getLanguages
  /// Android issues with API 21 & 22
  /// Returns a list of available languages
  Future<dynamic> get getLanguages async {
    final languages = await _channel.invokeMethod('getLanguages');
    return languages;
  }

  /// [Future] which invokes the platform specific method for getVoices
  /// ***Android supported only ***
  /// Returns a `List` of voice names
  Future<dynamic> get getVoices async {
    final voices = await _channel.invokeMethod('getVoices');
    return voices;
  }

  /// [Future] which invokes the platform specific method for isLanguageAvailable
  /// Returns `true` or `false`
  Future<dynamic> isLanguageAvailable(String language) => _channel.invokeMethod(
      'isLanguageAvailable', <String, Object>{'language': language});

  void setStartHandler(ValueSetter callback) {
    startHandler = callback;
  }

  void setCompletionHandler(ValueSetter callback) {
    completionHandler = callback;
  }

  void setErrorHandler(ErrorHandler handler) {
    errorHandler = handler;
  }

  void ttsInitHandler(VoidCallback handler) {
    initHandler = handler;
  }

  void setCallingHandler(VoidCallback handler) {
    callingHandler = handler;
  }

  /// Platform listeners
  Future platformCallHandler(MethodCall call) async {
    switch (call.method) {
      case "tts.init":
        if (initHandler != null) {
          initHandler();
        }
        break;
      case "tts.phonecalling":
        if (callingHandler != null) {
          callingHandler();
        }
        break;
      case "speak.onStart":
        if (startHandler != null) {
          startHandler(int.parse(call.arguments));
        }
        break;
      case "speak.onComplete":
        if (completionHandler != null) {
          completionHandler(int.parse(call.arguments));
        }
        break;
      case "speak.onError":
        if (errorHandler != null) {
          errorHandler(call.arguments);
        }
        break;
      default:
        print('Unknowm method ${call.method}');
    }
  }
}