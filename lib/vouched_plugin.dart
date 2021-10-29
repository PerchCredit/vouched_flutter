import 'dart:async';

import 'package:flutter/services.dart';
import 'package:vouched_plugin/models/user_data_model.dart';

class VouchedPlugin {

  // Attributes
  static const MethodChannel _channel = const MethodChannel('vouched_plugin');

  // Callbacks
  static Function(bool) setIndicatorCallback;
  static Function(String) setinstructionCallback;
  static Function(UserDataModel) setUserDataCallback;
  static Function(String) setErrorMessageCallback;

  // Handlers
  static void setProgressIndicator(Function callback) {
    setIndicatorCallback = callback;
  }

  static void setInstruction(Function callback) {
    setinstructionCallback = callback;
  }

  static void setUserData(Function callback) {
    setUserDataCallback = callback;
  }

  static void setErrorMessage(Function callback) {
    setErrorMessageCallback = callback;
  }

  // Platform Methods
  static Future<void> showScanner(double height, double width) async {
    await _channel.invokeMethod('startAuth', {'height': height, 'width': width});
  }

  static void getDataFromNative() {
    _channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'showInstruction': {
          setinstructionCallback.call(call.arguments);
          break;
        }
        case 'showIndicator': {
          setIndicatorCallback.call(true);
          break;
        }
        case 'dataReceived': {
          try {
            UserDataModel vouchedResult = UserDataModel(id: call.arguments['id'], firstName: call.arguments['firstName'], lastName: call.arguments['lastName'], 
            issueDate: call.arguments['issueDate'], expiryDate: call.arguments["expiryDate"], state: call.arguments['state'], 
            country: call.arguments['country']);
            setUserDataCallback.call(vouchedResult);
          } 
          catch (e) {
            setIndicatorCallback.call(false);
          }
          break;
        }
        case 'errorReceived': {
          setIndicatorCallback.call(false);
          setErrorMessageCallback.call('Error');
          break;
        }
        default:
        break;
     }
    });
  }
}


