package com.strongnguyen.bookreader;

import android.annotation.TargetApi;
import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.speech.tts.UtteranceProgressListener;
import android.speech.tts.Voice;
import android.util.Log;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

@TargetApi(21)
public class MainActivity extends FlutterActivity implements MethodChannel.MethodCallHandler {

  private MethodChannel channel;
  private TextToSpeech tts;
  private final String tag = "TTS";
  private final String googleTtsEngine = "com.google.android.tts";
  Bundle bundle;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    channel = new MethodChannel(getFlutterView(), "reader/flutter_tts");
    channel.setMethodCallHandler(this);
    bundle = new Bundle();
    tts = new TextToSpeech(getApplicationContext(), onInitListener, googleTtsEngine);
  }

  private UtteranceProgressListener utteranceProgressListener =
          new UtteranceProgressListener() {
            @Override
            public void onStart(String utteranceId) {
              channel.invokeMethod("speak.onStart", utteranceId);
            }

            @Override
            public void onDone(String utteranceId) {
              channel.invokeMethod("speak.onComplete", utteranceId);
            }

            @Override
            @Deprecated
            public void onError(String utteranceId) {
              channel.invokeMethod("speak.onError", "Error from TextToSpeech");
            }

            @Override
            public void onError(String utteranceId, int errorCode) {
              channel.invokeMethod("speak.onError", "Error from TextToSpeech - " + errorCode);
            }
          };

  private TextToSpeech.OnInitListener onInitListener =
          new TextToSpeech.OnInitListener() {
            @Override
            public void onInit(int status) {
              if (status == TextToSpeech.SUCCESS) {
                tts.setOnUtteranceProgressListener(utteranceProgressListener);
                channel.invokeMethod("tts.init", true);

                try {
                  Locale locale = tts.getDefaultVoice().getLocale();
                  if (isLanguageAvailable(locale)) {
                    tts.setLanguage(locale);
                  }
                } catch (NullPointerException | java.lang.IllegalArgumentException e) {
                  Log.d(tag, "getDefaultVoice: " + e.getMessage() + " (known issue with API 21 & 22)");
                }
              } else {
                Log.d(tag, "Failed to initialize TextToSpeech");
              }
            }
          };

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    if (call.method.equals("speak")) {
      Map<String, String> data = (Map<String, String>) call.arguments;
      speak(data);
      result.success(1);
    } else if (call.method.equals("speakAdd")) {
      Map<String, String> data = (Map<String, String>) call.arguments;
      speakAdd(data);
      result.success(1);
    } else if (call.method.equals("stop")) {
      stop();
      result.success(1);
    } else if (call.method.equals("setSpeechRate")) {
      String rate = call.arguments.toString();
      setSpeechRate(Float.parseFloat(rate));
      result.success(1);
    } else if (call.method.equals("setVolume")) {
      String volume = call.arguments.toString();
      setVolume(Float.parseFloat(volume), result);
    } else if (call.method.equals("setPitch")) {
      String pitch = call.arguments.toString();
      setPitch(Float.parseFloat(pitch), result);
    } else if (call.method.equals("setLanguage")) {
      String language = call.arguments.toString();
      setLanguage(language, result);
    } else if (call.method.equals("getLanguages")) {
      getLanguages(result);
    } else if (call.method.equals("getVoices")) {
      getVoices(result);
    } else if (call.method.equals("setVoice")) {
      String voice = call.arguments.toString();
      setVoice(voice, result);
    } else if (call.method.equals("isLanguageAvailable")) {
      String language = ((HashMap) call.arguments()).get("language").toString();
      Locale locale = Locale.forLanguageTag(language);
      result.success(isLanguageAvailable(locale));
    } else {
      result.notImplemented();
    }
  }

  void setSpeechRate(float rate) {
    tts.setSpeechRate(rate);
  }

  Boolean isLanguageAvailable(Locale locale) {
    Boolean isLanguageAvailable = false;
    if (tts.isLanguageAvailable(locale) == TextToSpeech.LANG_COUNTRY_AVAILABLE) {
      isLanguageAvailable = true;
    } else {
      Log.d(tag, "Language is not available - " + locale);
    }
    return isLanguageAvailable;
  }

  void setLanguage(String language, MethodChannel.Result result) {
    Locale locale = Locale.forLanguageTag(language);
    if (isLanguageAvailable(locale)) {
      tts.setLanguage(locale);
      result.success(1);
    } else {
      result.success(0);
    }
  }

  void setVoice(String voice, MethodChannel.Result result) {
    for (Voice ttsVoice : tts.getVoices()) {
      if (ttsVoice.getName().equals(voice)) {
        tts.setVoice(ttsVoice);
        result.success(1);
        return;
      }
    }
    Log.d(tag, "Voice name not found: " + voice);
    result.success(0);
  }

  void setVolume(float volume, MethodChannel.Result result) {
    if (volume >= 0.0F && volume <= 1.0F) {
      bundle.putFloat(TextToSpeech.Engine.KEY_PARAM_VOLUME, volume);
      result.success(1);
    } else {
      Log.d(tag, "Invalid volume " + volume + " value - Range is from 0.0 to 1.0");
      result.success(0);
    }
  }

  void setPitch(float pitch, MethodChannel.Result result) {
    if (pitch >= 0.5F && pitch <= 2.0F) {
      tts.setPitch(pitch);
      result.success(1);
    } else {
      Log.d(tag, "Invalid pitch " + pitch + " value - Range is from 0.5 to 2.0");
      result.success(0);
    }
  }

  void getVoices(MethodChannel.Result result) {
    ArrayList<String> voices = new ArrayList<>();
    try {
      for (Voice voice : tts.getVoices()) {
        voices.add(voice.getName());
      }
      result.success(voices);
    } catch(NullPointerException e) {
      Log.d(tag, "getVoices: " + e.getMessage());
      result.success(null);
    }
  }

  void getLanguages(MethodChannel.Result result) {
    ArrayList<String> locales = new ArrayList<>();
    try {
      for (Locale locale : tts.getAvailableLanguages()) {
        locales.add(locale.toLanguageTag());
      }
      result.success(locales);
    } catch (NullPointerException e) {
      Log.d(tag, "getAvailableLanguages: " + e.getMessage() + " - (known issue with API 21 & 22)");
      result.success(null);
    }
  }

  void speak(Map<String, String> data) {
    tts.speak(data.get("text"), TextToSpeech.QUEUE_FLUSH, bundle, data.get("uuid"));
  }

  void speakAdd(Map<String, String> data) {
    tts.speak(data.get("text"), TextToSpeech.QUEUE_ADD, bundle, data.get("uuid"));
  }

  void stop() {
    tts.stop();
  }
}
