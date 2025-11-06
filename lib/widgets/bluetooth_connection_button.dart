import 'package:flutter/material.dart';
import '../services/bluetooth_manager.dart';
import 'device_selection_dialog.dart';

class BluetoothConnectionButton extends StatelessWidget {
  final BluetoothManager bluetoothManager;

  const BluetoothConnectionButton({
    super.key,
    required this.bluetoothManager,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: bluetoothManager,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 8),
              Icon(
                bluetoothManager.isConnected
                    ? Icons.bluetooth
                    : Icons.bluetooth_disabled,
                color: bluetoothManager.isConnected ? Colors.green : Colors.red,
                size: 20,
              ),
              Text(
                bluetoothManager.isConnected ? "Connected" : "Disconnected",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (bluetoothManager.isConnected) {
                    bluetoothManager.disconnect();
                  } else {
                    bluetoothManager.startScanning();
                    showDialog(
                      context: context,
                      builder: (context) => DeviceSelectionDialog(
                        bluetoothManager: bluetoothManager,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: bluetoothManager.isConnected
                      ? Colors.red
                      : Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  bluetoothManager.isConnected ? "Disconnect" : "Connect",
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

