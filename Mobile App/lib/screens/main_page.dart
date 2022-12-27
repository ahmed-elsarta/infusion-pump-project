import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:mi_project/other_files/BackgroundCollectingTask.dart';
import 'chat_page.dart';
import 'discovery_page.dart';
import 'select_bonded_device_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  static String id = "MainPageID";

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  Timer? _discoverableTimeoutTimer;

  BackgroundCollectingTask? _collectingTask;

  bool _autoAcceptPairingRequests = false;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {});
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {});
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _collectingTask?.dispose();
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Settings'),
      ),
      body: TweenAnimationBuilder(
        duration: const Duration(seconds: 2),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SwitchListTile(
                    title: const Text('Enable Bluetooth'),
                    value: _bluetoothState.isEnabled,
                    activeColor: Colors.blue,
                    onChanged: (bool value) {
                      // Do the request and update with the true value then
                      future() async {
                        // async lambda seems to not working
                        if (value) {
                          await FlutterBluetoothSerial.instance.requestEnable();
                        } else {
                          await FlutterBluetoothSerial.instance
                              .requestDisable();
                        }
                      }

                      future().then((_) {
                        setState(() {});
                      });
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Bluetooth status'),
                    subtitle: Text(_bluetoothState.toString()),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[900]),
                      child: const Text('Settings'),
                      onPressed: () {
                        FlutterBluetoothSerial.instance.openSettings();
                      },
                    ),
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Auto-try specific pin when pairing'),
                    subtitle: const Text('Pin 1234'),
                    value: _autoAcceptPairingRequests,
                    activeColor: Colors.blue,
                    onChanged: (bool value) {
                      setState(() {
                        _autoAcceptPairingRequests = value;
                      });
                      if (value) {
                        FlutterBluetoothSerial.instance
                            .setPairingRequestHandler(
                                (BluetoothPairingRequest request) {
                          print("Trying to auto-pair with Pin 1234");
                          if (request.pairingVariant == PairingVariant.Pin) {
                            return Future.value("1234");
                          }
                          return Future.value(null);
                        });
                      } else {
                        FlutterBluetoothSerial.instance
                            .setPairingRequestHandler(null);
                      }
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[900]),
                        onPressed: () async {
                          final BluetoothDevice? selectedDevice =
                              await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return const DiscoveryPage();
                              },
                            ),
                          );

                          if (selectedDevice != null) {
                            print(
                                'Discovery -> selected ${selectedDevice.address}');
                          } else {
                            print('Discovery -> no device selected');
                          }
                        },
                        child: const Text('Explore discovered devices')),
                  ),
                  ListTile(
                    title: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[900]),
                      onPressed: () async {
                        final BluetoothDevice? selectedDevice =
                            await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return const SelectBondedDevicePage(
                                  checkAvailability: false);
                            },
                          ),
                        );

                        if (selectedDevice != null) {
                          print(
                              'Connect -> selected ${selectedDevice.address}');
                          _startChat(context, selectedDevice);
                        } else {
                          print('Connect -> no device selected');
                        }
                      },
                      child: const Text('Connect to paired device'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _startChat(BuildContext context, BluetoothDevice server) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ChatPage(server: server);
        },
      ),
    );
  }
}
