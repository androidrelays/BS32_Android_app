import 'package:flutter/material.dart';
import '../services/bluetooth_manager.dart';

class DeviceSelectionDialog extends StatelessWidget {
  final BluetoothManager bluetoothManager;

  const DeviceSelectionDialog({
    super.key,
    required this.bluetoothManager,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: bluetoothManager,
      builder: (context, child) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 350,
            constraints: const BoxConstraints(
              maxHeight: 450,
            ),
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Select Device",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () {
                        bluetoothManager.closeDeviceSelection();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Scanning status
                if (bluetoothManager.isScanning)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Scanning for devices...",
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                
                // Device list or no devices message
                if (bluetoothManager.discoveredDevices.isEmpty && !bluetoothManager.isScanning)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        const Icon(Icons.search, size: 40, color: Colors.grey),
                        const SizedBox(height: 15),
                        const Text(
                          "No Devices Found",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Make sure your BS32 device is powered on and nearby",
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: () {
                            bluetoothManager.startScanning();
                          },
                          child: const Text("Scan Again"),
                        ),
                      ],
                    ),
                  )
                else if (bluetoothManager.discoveredDevices.isNotEmpty)
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Found ${bluetoothManager.discoveredDevices.length} device(s)",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: bluetoothManager.discoveredDevices.length,
                            itemBuilder: (context, index) {
                              final device = bluetoothManager.discoveredDevices[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: ElevatedButton(
                                  onPressed: () {
                                    bluetoothManager.connect(device);
                                    Navigator.of(context).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.withOpacity(0.1),
                                    foregroundColor: Colors.black,
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.all(16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.bluetooth, color: Colors.blue),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          device.advName.isEmpty
                                              ? "Unknown Device"
                                              : device.advName,
                                          style: const TextStyle(color: Colors.black),
                                        ),
                                      ),
                                      const Text(
                                        "Tap to connect",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

