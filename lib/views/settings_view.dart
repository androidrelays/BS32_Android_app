import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_manager.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final bluetoothManager = Provider.of<BluetoothManager>(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
      body: ListenableBuilder(
        listenable: bluetoothManager,
        builder: (context, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Connection Status Section
              Card(
                color: Colors.grey[900],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Connection Status",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            bluetoothManager.isConnected
                                ? Icons.bluetooth
                                : Icons.bluetooth_disabled,
                            color: bluetoothManager.isConnected
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            bluetoothManager.connectionStatus,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      if (bluetoothManager.isConnected) ...[
                        const SizedBox(height: 8),
                        Text(
                          "Device: ${bluetoothManager.deviceName}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Sense Selection Section
              Card(
                color: Colors.grey[900],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Sense Selection",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: bluetoothManager.isConnected
                                  ? () {
                                      bluetoothManager.sendSenseSelection(true);
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: bluetoothManager.senseA
                                    ? Colors.blue
                                    : Colors.grey[800],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(16),
                              ),
                              child: const Text("Sense A"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: bluetoothManager.isConnected
                                  ? () {
                                      bluetoothManager.sendSenseSelection(false);
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: !bluetoothManager.senseA
                                    ? Colors.blue
                                    : Colors.grey[800],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(16),
                              ),
                              child: const Text("Sense B"),
                            ),
                          ),
                        ],
                      ),
                      if (!bluetoothManager.isConnected)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            "Connect to device to change sense selection",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Connection Management Section
              if (bluetoothManager.isConnected)
                Card(
                  color: Colors.grey[900],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Connection Management",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            bluetoothManager.disconnect();
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text("Disconnect"),
                        ),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 24),
              
              // Save and Close Button
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  "Save and Close",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

