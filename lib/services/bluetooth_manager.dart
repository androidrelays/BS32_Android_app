import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/foundation.dart';

class BluetoothManager extends ChangeNotifier {
  // Published properties
  bool _isScanning = false;
  bool _isConnected = false;
  List<BluetoothDevice> _discoveredDevices = [];
  
  // Per-breaker state (0-based index: 0=Breaker1, 1=Breaker2, 2=Breaker3)
  List<bool> breakerStates = [true, true, true];  // [Breaker1, Breaker2, Breaker3]
  List<bool> switchStates = [true, true, true];    // [Switch1, Switch2, Switch3]
  List<bool> lockStates = [false, false, false];   // [Lock1, Lock2, Lock3]
  
  bool senseA = true;  // Sense selection (true = Sense A, false = Sense B)
  
  // UUIDs (matching ESP32 exactly)
  static const String serviceUUID = "12345678-1234-1234-1234-123456789abc";
  static const String commandCharUUID = "87654321-4321-4321-4321-cba987654321";
  static const String statusCharUUID = "11011111-2222-3333-4444-555555555555";
  static const String lockCharUUID = "22222222-3333-4444-5555-666666666666";
  static const String senseCharUUID = "33333333-4444-5555-6666-777777777777";
  
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _statusCharacteristic;
  BluetoothCharacteristic? _lockCharacteristic;
  BluetoothCharacteristic? _senseCharacteristic;
  
  // Command management
  String _lastCommand = "";
  DateTime _lastCommandTime = DateTime.now();
  final Duration commandDebounceInterval = const Duration(milliseconds: 100);
  
  // Getters
  bool get isScanning => _isScanning;
  bool get isConnected => _isConnected;
  List<BluetoothDevice> get discoveredDevices => List.unmodifiable(_discoveredDevices);
  String get deviceName => _connectedDevice?.advName ?? "BS32 Device";
  String get connectionStatus => _isConnected ? "Connected" : "Disconnected";
  
  BluetoothManager() {
    _initializeBluetooth();
  }
  
  void _initializeBluetooth() {
    FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.on) {
        print("✅ Bluetooth adapter is ON");
      } else {
        print("❌ Bluetooth adapter is OFF or unavailable");
        _isConnected = false;
        notifyListeners();
      }
    });
  }
  
  Future<void> startScanning() async {
    if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
      print("❌ Bluetooth not available");
      return;
    }
    
    _isScanning = true;
    _discoveredDevices.clear();
    notifyListeners();
    
    print("🔍 Starting scan for BS32 devices...");
    
    // Scan for devices with specific service
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (!_discoveredDevices.contains(result.device) && 
            result.device.advName.contains("BS32")) {
          _discoveredDevices.add(result.device);
          notifyListeners();
        }
      }
    });
    
    // Start scan
    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 15),
      withServices: [Guid(serviceUUID)],
    );
    
    // After 5 seconds, if no devices found, scan for all devices
    Future.delayed(const Duration(seconds: 5), () {
      if (_discoveredDevices.isEmpty) {
        print("🔍 No devices found with specific service, scanning for all devices...");
        FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
      }
    });
    
    // Stop scanning after 15 seconds total
    Future.delayed(const Duration(seconds: 15), () {
      stopScanning();
    });
  }
  
  void stopScanning() {
    FlutterBluePlus.stopScan();
    _isScanning = false;
    notifyListeners();
    print("🛑 Scanning stopped");
  }
  
  void closeDeviceSelection() {
    stopScanning();
    print("🔒 Device selection dialog closed");
  }
  
  Future<void> connect(BluetoothDevice device) async {
    print("🔗 Connecting to ${device.advName}...");
    _connectedDevice = device;
    
    try {
      await device.connect(timeout: const Duration(seconds: 15));
      _isConnected = true;
      notifyListeners();
      
      print("✅ Connected to ${device.advName}");
      
      // Discover services
      List<BluetoothService> services = await device.discoverServices();
      
      for (BluetoothService service in services) {
        if (service.uuid.toString() == serviceUUID) {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            String charUUID = characteristic.uuid.toString();
            
            if (charUUID == commandCharUUID) {
              _writeCharacteristic = characteristic;
              await characteristic.setNotifyValue(true);
              characteristic.onValueReceived.listen(_handleCommandNotification);
              print("✅ Found command characteristic and enabled notifications");
            } else if (charUUID == statusCharUUID) {
              _statusCharacteristic = characteristic;
              await characteristic.setNotifyValue(true);
              characteristic.onValueReceived.listen(_handleStatusNotification);
              print("✅ Found status characteristic and enabled notifications");
            } else if (charUUID == lockCharUUID) {
              _lockCharacteristic = characteristic;
              await characteristic.setNotifyValue(true);
              characteristic.onValueReceived.listen(_handleLockNotification);
              print("✅ Found lock characteristic and enabled notifications");
            } else if (charUUID == senseCharUUID) {
              _senseCharacteristic = characteristic;
              await characteristic.setNotifyValue(true);
              characteristic.onValueReceived.listen(_handleSenseNotification);
              print("✅ Found sense characteristic and enabled notifications");
            }
          }
        }
      }
      
      // Request initial status after connection delay
      Future.delayed(const Duration(milliseconds: 300), () {
        requestSystemStatus();
      });
      
    } catch (e) {
      print("❌ Connection failed: $e");
      _isConnected = false;
      notifyListeners();
    }
    
    // Listen for disconnection
    device.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        _isConnected = false;
        _connectedDevice = null;
        _writeCharacteristic = null;
        _statusCharacteristic = null;
        _lockCharacteristic = null;
        _senseCharacteristic = null;
        notifyListeners();
        print("❌ Disconnected from device");
      }
    });
  }
  
  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _isConnected = false;
      _connectedDevice = null;
      _writeCharacteristic = null;
      _statusCharacteristic = null;
      _lockCharacteristic = null;
      _senseCharacteristic = null;
      notifyListeners();
      print("🔌 Disconnected");
    }
  }
  
  Future<void> sendBreakerCommand(int breakerIndex, String property, bool value) async {
    // Check debouncing
    final timeSinceLastCommand = DateTime.now().difference(_lastCommandTime);
    if (timeSinceLastCommand < commandDebounceInterval) {
      print("🔒 Flutter BluetoothManager: Debouncing rapid command");
      return;
    }
    
    if (_writeCharacteristic == null) {
      print("❌ Flutter BluetoothManager: No write characteristic available");
      return;
    }
    
    if (breakerIndex < 0 || breakerIndex >= 3) {
      print("❌ Flutter BluetoothManager: Invalid breaker index: $breakerIndex");
      return;
    }
    
    // Create JSON command
    final json = {
      "setIndex": breakerIndex,
      "property": property,
      "value": value
    };
    
    final jsonString = jsonEncode(json);
    final jsonData = utf8.encode(jsonString);
    
    _lastCommand = "Breaker ${breakerIndex + 1}: $property = $value";
    _lastCommandTime = DateTime.now();
    
    print("🔧 Flutter BluetoothManager: Sending JSON command for Breaker ${breakerIndex + 1}: $jsonString");
    
    try {
      await _writeCharacteristic!.write(jsonData, withoutResponse: false);
    } catch (e) {
      print("❌ Failed to write command: $e");
    }
  }
  
  Future<void> requestSystemStatus() async {
    if (_writeCharacteristic == null) {
      print("❌ Flutter BluetoothManager: No write characteristic available");
      return;
    }
    
    final json = {"type": "status_request"};
    final jsonData = utf8.encode(jsonEncode(json));
    
    print("📊 Flutter BluetoothManager: Requesting system status");
    
    try {
      await _writeCharacteristic!.write(jsonData, withoutResponse: false);
    } catch (e) {
      print("❌ Failed to request status: $e");
    }
  }
  
  Future<void> sendSenseSelection(bool senseA) async {
    if (!_isConnected) {
      print("❌ Flutter BluetoothManager: Not connected");
      return;
    }
    
    this.senseA = senseA;
    notifyListeners();
    
    // Method 1: Send via JSON command
    if (_writeCharacteristic != null) {
      final json = {
        "type": "sense_select",
        "value": senseA
      };
      final jsonData = utf8.encode(jsonEncode(json));
      
      print("📡 Flutter BluetoothManager: Sending sense selection via JSON: ${senseA ? "Sense A" : "Sense B"}");
      
      try {
        await _writeCharacteristic!.write(jsonData, withoutResponse: false);
      } catch (e) {
        print("❌ Failed to send sense selection: $e");
      }
    }
    
    // Method 2: Also write directly to sense characteristic
    if (_senseCharacteristic != null) {
      final senseValue = senseA ? 0 : 1; // 0 = Sense A, 1 = Sense B
      final data = [senseValue];
      
      print("📡 Flutter BluetoothManager: Writing sense selection to characteristic: ${senseA ? "Sense A" : "Sense B"}");
      
      try {
        await _senseCharacteristic!.write(data, withoutResponse: false);
      } catch (e) {
        print("❌ Failed to write sense characteristic: $e");
      }
    }
  }
  
  void _handleStatusNotification(List<int> value) {
    // Status characteristic sends binary data: 9 bytes (3 bytes per breaker set)
    // Format: [breaker1, switch1, locked1, breaker2, switch2, locked2, breaker3, switch3, locked3]
    if (value.length != 9) {
      print("⚠️ Flutter BluetoothManager: Status notification has wrong length: ${value.length} bytes (expected 9)");
      return;
    }
    
    print("📨 Flutter BluetoothManager: Received status notification (binary): $value");
    
    for (int i = 0; i < 3; i++) {
      breakerStates[i] = (value[i * 3] == 1);
      switchStates[i] = (value[i * 3 + 1] == 1);
      lockStates[i] = (value[i * 3 + 2] == 1);
    }
    
    notifyListeners();
  }
  
  void _handleCommandNotification(List<int> value) {
    // Command characteristic sends JSON strings for individual state changes
    if (value.isEmpty) return;
    
    try {
      final jsonString = utf8.decode(value, allowMalformed: true);
      
      // Check if it's valid JSON (starts with {)
      if (!jsonString.trim().startsWith('{')) {
        return; // Not JSON, ignore
      }
      
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      
      print("📨 Flutter BluetoothManager: Received command notification: $jsonString");
      
      // Handle individual state updates
      if (json.containsKey("setIndex") && json.containsKey("property") && json.containsKey("value")) {
        final setIndex = json["setIndex"] as int;
        final property = json["property"] as String;
        final value = json["value"] as bool;
        
        if (setIndex >= 0 && setIndex < 3) {
          if (property == "breaker") {
            breakerStates[setIndex] = value;
          } else if (property == "switch") {
            switchStates[setIndex] = value;
          } else if (property == "locked") {
            lockStates[setIndex] = value;
          }
          notifyListeners();
        }
      }
    } catch (e) {
      print("❌ Error parsing command notification: $e");
    }
  }
  
  void _handleLockNotification(List<int> value) {
    if (value.isEmpty) return;
    
    try {
      final jsonString = utf8.decode(value);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      
      print("🔒 Flutter BluetoothManager: Received lock notification: $jsonString");
      
      if (json.containsKey("setIndex") && json.containsKey("locked")) {
        final setIndex = json["setIndex"] as int;
        final locked = json["locked"] as bool;
        
        if (setIndex >= 0 && setIndex < 3) {
          lockStates[setIndex] = locked;
          notifyListeners();
        }
      }
    } catch (e) {
      print("❌ Error parsing lock notification: $e");
    }
  }
  
  void _handleSenseNotification(List<int> value) {
    if (value.isEmpty) return;
    
    try {
      final senseValue = value[0];
      senseA = (senseValue == 0); // 0 = Sense A, 1 = Sense B
      notifyListeners();
      print("📡 Flutter BluetoothManager: Received sense notification: ${senseA ? "Sense A" : "Sense B"}");
    } catch (e) {
      print("❌ Error parsing sense notification: $e");
    }
  }
}

