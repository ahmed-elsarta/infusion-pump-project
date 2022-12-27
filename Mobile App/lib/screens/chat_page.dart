import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:mi_project/widgets/heart_rate_container.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class ChatPage extends StatefulWidget {
  static String id = "ChatPageID";

  final BluetoothDevice server;

  const ChatPage({super.key, required this.server});

  @override
  _ChatPage createState() => _ChatPage();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _ChatPage extends State<ChatPage> {
  BluetoothConnection? connection;

  List<String> measures = [];
  AudioPlayer alarmPlayer = AudioPlayer();

  // List<_Message> messages = List<_Message>.empty(growable: true);
  String receivedMessageText = "";
  String _messageBuffer = '';
  bool isWarning = false;

  final TextEditingController textEditingController = TextEditingController();

  bool isConnecting = true;
  bool get isConnected => (connection?.isConnected ?? false);

  bool isDisconnecting = false;

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });
      connection!.input!.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serverName = widget.server.name ?? "Unknown";
    return Scaffold(
      appBar: AppBar(
          title: (isConnecting
              ? Text('Connecting chat to $serverName...')
              : isConnected
                  ? Text('Live chat with $serverName')
                  : Text('Chat log with $serverName'))),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              HeartRateContainer(
                  heartRate: measures[0], motorSpeed: measures[1]),
              ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset("assets/images/pulse.gif",
                      fit: BoxFit.cover)),
            ],
          ),
        ),
      ),
    );
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;

    for (var byte in data) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    }
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        receivedMessageText = backspacesCounter > 0
            ? _messageBuffer.substring(
                0, _messageBuffer.length - backspacesCounter)
            : _messageBuffer + dataString.substring(0, index);

        _messageBuffer = dataString.substring(index);

        // Check incoming message
        if (receivedMessageText.isNotEmpty) {
          receivedMessageText = receivedMessageText.trim();
          measures = receivedMessageText.split(",");
        }
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
    if (double.parse(measures[0]) < 50) {
      if (!isWarning) {
        isWarning = true;
        Alert(
          context: context,
          onWillPopActive: true,
          useRootNavigator: true,
          title: "Warning",
          desc: "Hypotensia",
          style: const AlertStyle(
            backgroundColor: Colors.white,
            animationDuration: Duration(milliseconds: 500),
            isCloseButton: false,
            isButtonVisible: false,
            titleStyle: TextStyle(fontSize: 40, color: Colors.red),
          ),
        ).show();
        alarmPlayer.play(AssetSource("audios/alarm.mp3"));
      }
    } else if (double.parse(measures[0]) > 120) {
      if (!isWarning) {
        isWarning = true;
        Alert(
          context: context,
          onWillPopActive: true,
          useRootNavigator: true,
          title: "Warning",
          desc: "Hypertensia",
          style: const AlertStyle(
            backgroundColor: Colors.white,
            animationDuration: Duration(milliseconds: 500),
            isCloseButton: false,
            isButtonVisible: false,
            titleStyle: TextStyle(fontSize: 40, color: Colors.red),
          ),
        ).show();
        alarmPlayer.play(AssetSource("audios/alarm.mp3"));
      }
    } else {
      if (isWarning) {
        alarmPlayer.stop();
        isWarning = false;
        Navigator.pop(context);
      }
    }
  }

  // void _sendMessage(String text) async {
  //   text = text.trim();
  //   textEditingController.clear();

  //   if (text.isNotEmpty) {
  //     try {
  //       connection!.output.add(Uint8List.fromList(utf8.encode("$text\r\n")));
  //       await connection!.output.allSent;

  //       // show message sent to arduino
  //       // setState(() {
  //       //   messages.add(_Message(clientID, text));
  //       // });
  //     } catch (e) {
  //       // Ignore error, but notify state
  //       setState(() {});
  //     }
  //   }
  // }
}
