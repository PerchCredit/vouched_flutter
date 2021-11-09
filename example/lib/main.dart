import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vouched_plugin/models/user_data_model.dart';

import 'package:vouched_plugin/vouched_plugin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool showProgress = false;

  void setProgressIndicator(bool value) {
    setState(() {
      showProgress = value;
    });
  }

  void displayInstruction(String value) {
    print(value);
  }

  void fetchUserData(UserDataModel value) {
    print(value);
  }

  void displayErrorMessage(String value) {
    print(value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
      appBar: AppBar(title: const Text('Vouched example app')),
      body: Builder(
        builder: (context) {
          return Center(
            child: SizedBox(height: MediaQuery.of(context).size.width - 16.0, width: MediaQuery.of(context).size.width - 16.0,
              child: Stack(alignment: Alignment.center, 
                children: [ 
                  NativeViewScannerCard(showProgress: setProgressIndicator, showInstruction: displayInstruction, setUserData: fetchUserData, showErrorMessage: displayErrorMessage),
                (showProgress)
                  ? Align(alignment: Alignment.center,
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.purple)))
                  : Container()
              ])
          ));
        })
    ));
  }
}

class NativeViewScannerCard extends StatelessWidget {

  final Function(bool) showProgress;
  final Function(String) showInstruction;
  final Function(UserDataModel) setUserData;
  final Function(String) showErrorMessage;

  const NativeViewScannerCard({ Key key, this.showProgress, this.showInstruction, this.setUserData, this.showErrorMessage }) : super(key: key);

  void initializeVouched(BuildContext context) async {
    VouchedPlugin.getDataFromNative();
    await VouchedPlugin.showScanner(MediaQuery.of(context).size.width - 16.0, MediaQuery.of(context).size.width - 16.0);
        
    VouchedPlugin.setProgressIndicator((value) => showProgress(value));
    VouchedPlugin.setInstruction((value) => showInstruction(value));
    VouchedPlugin.setUserData((value) => setUserData(value));
    VouchedPlugin.setErrorMessage((value) => showErrorMessage(value));   
  }

  @override
  Widget build(BuildContext context) {
    final String viewType = 'vouchedScannerCardView';

    switch(defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidView(viewType: viewType, onPlatformViewCreated: (id) async {
          try {
            initializeVouched(context);
          }
          catch (e) {
            print(e);
          }
        });
      case TargetPlatform.iOS:
        return UiKitView(viewType: viewType, onPlatformViewCreated: (id) async {
          try {
            initializeVouched(context);             
          } 
          catch (e) {
            print(e);
          }
        });
      default:
      throw UnsupportedError("Unsupported platform view");
    }
  }
}
