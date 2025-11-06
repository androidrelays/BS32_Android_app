import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_manager.dart';
import '../widgets/breaker_set_view.dart';
import '../widgets/bluetooth_connection_button.dart';
import 'settings_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  // State variables for three breaker sets
  bool breaker1Open = true;
  bool switch1Toggled = true;
  bool isLock1 = false;
  
  bool breaker2Open = true;
  bool switch2Toggled = true;
  bool isLock2 = false;
  
  bool breaker3Open = true;
  bool switch3Toggled = true;
  bool isLock3 = false;
  
  @override
  void initState() {
    super.initState();
    final bluetoothManager = Provider.of<BluetoothManager>(context, listen: false);
    
    // Listen to BluetoothManager state changes
    bluetoothManager.addListener(_onBluetoothStateChanged);
  }
  
  void _onBluetoothStateChanged() {
    final bluetoothManager = Provider.of<BluetoothManager>(context, listen: false);
    
    setState(() {
      breaker1Open = bluetoothManager.breakerStates[0];
      breaker2Open = bluetoothManager.breakerStates[1];
      breaker3Open = bluetoothManager.breakerStates[2];
      
      switch1Toggled = bluetoothManager.switchStates[0];
      switch2Toggled = bluetoothManager.switchStates[1];
      switch3Toggled = bluetoothManager.switchStates[2];
      
      isLock1 = bluetoothManager.lockStates[0];
      isLock2 = bluetoothManager.lockStates[1];
      isLock3 = bluetoothManager.lockStates[2];
    });
  }
  
  @override
  void dispose() {
    final bluetoothManager = Provider.of<BluetoothManager>(context, listen: false);
    bluetoothManager.removeListener(_onBluetoothStateChanged);
    super.dispose();
  }
  
  void _setBreakerState(int breakerNumber, bool open) {
    setState(() {
      switch (breakerNumber) {
        case 1:
          breaker1Open = open;
          break;
        case 2:
          breaker2Open = open;
          break;
        case 3:
          breaker3Open = open;
          break;
      }
    });
    
    final bluetoothManager = Provider.of<BluetoothManager>(context, listen: false);
    final breakerIndex = breakerNumber - 1;
    bluetoothManager.sendBreakerCommand(breakerIndex, "breaker", open);
  }
  
  void _toggleLock(int lockNumber) {
    bool newLockState = false;
    setState(() {
      switch (lockNumber) {
        case 1:
          newLockState = !isLock1;
          isLock1 = newLockState;
          break;
        case 2:
          newLockState = !isLock2;
          isLock2 = newLockState;
          break;
        case 3:
          newLockState = !isLock3;
          isLock3 = newLockState;
          break;
        default:
          return;
      }
    });
    
    final bluetoothManager = Provider.of<BluetoothManager>(context, listen: false);
    final breakerIndex = lockNumber - 1;
    bluetoothManager.sendBreakerCommand(breakerIndex, "locked", newLockState);
  }
  
  void _onSwitchChanged(int breakerNumber, bool newValue) {
    // Safety rule: if switch goes DOWN, ALWAYS force breaker OPEN
    if (!newValue) {
      switch (breakerNumber) {
        case 1:
          if (!breaker1Open) {
            breaker1Open = true;
          }
          break;
        case 2:
          if (!breaker2Open) {
            breaker2Open = true;
          }
          break;
        case 3:
          if (!breaker3Open) {
            breaker3Open = true;
          }
          break;
      }
    }
    
    setState(() {
      switch (breakerNumber) {
        case 1:
          switch1Toggled = newValue;
          break;
        case 2:
          switch2Toggled = newValue;
          break;
        case 3:
          switch3Toggled = newValue;
          break;
      }
    });
    
    final bluetoothManager = Provider.of<BluetoothManager>(context, listen: false);
    final breakerIndex = breakerNumber - 1;
    bluetoothManager.sendBreakerCommand(breakerIndex, "switch", newValue);
  }
  
  @override
  Widget build(BuildContext context) {
    final bluetoothManager = Provider.of<BluetoothManager>(context);
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    // Hide status bar in landscape, show in portrait
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isLandscape) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
        ));
      }
    });
    
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: false,
      body: SizedBox.expand(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscapeLayout = constraints.maxWidth > constraints.maxHeight;
            
            if (isLandscapeLayout) {
              // Landscape orientation - UI controls only
              return MediaQuery.removePadding(
                context: context,
                removeTop: true,
                removeBottom: true,
                removeLeft: true,
                removeRight: true,
                child: SizedBox.expand(
                  child: Stack(
                    children: [
                      // Full-screen black background - covers entire screen including display cutout
                      Positioned.fill(
                        child: Container(
                          color: Colors.black,
                        ),
                      ),
                    // Main content
                    SafeArea(
                      top: false, // Allow black background behind status bar
                      bottom: false,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 6, right: 6, top: 15),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch, // Make breaker sets fill height
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Breaker Set 1
                              Expanded(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      right: BorderSide(color: Colors.black, width: 2),
                                    ),
                                  ),
                                  child: BreakerSetView(
                                    title: "Breaker 1",
                                    breakerOpen: breaker1Open,
                                    switchToggled: switch1Toggled,
                                    isLocked: isLock1,
                                    onOpenTapped: () => _setBreakerState(1, true),
                                    onCloseTapped: () => _setBreakerState(1, false),
                                    onLockToggled: () => _toggleLock(1),
                                    onSwitchChanged: (value) => _onSwitchChanged(1, value),
                                    isLandscape: true,
                                  ),
                                ),
                              ),
                              
                              // Breaker Set 2
                              Expanded(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      right: BorderSide(color: Colors.black, width: 2),
                                    ),
                                  ),
                                  child: BreakerSetView(
                                    title: "Breaker 2",
                                    breakerOpen: breaker2Open,
                                    switchToggled: switch2Toggled,
                                    isLocked: isLock2,
                                    onOpenTapped: () => _setBreakerState(2, true),
                                    onCloseTapped: () => _setBreakerState(2, false),
                                    onLockToggled: () => _toggleLock(2),
                                    onSwitchChanged: (value) => _onSwitchChanged(2, value),
                                    isLandscape: true,
                                  ),
                                ),
                              ),
                              
                              // Breaker Set 3
                              Expanded(
                                child: BreakerSetView(
                                  title: "Breaker 3",
                                  breakerOpen: breaker3Open,
                                  switchToggled: switch3Toggled,
                                  isLocked: isLock3,
                                  onOpenTapped: () => _setBreakerState(3, true),
                                  onCloseTapped: () => _setBreakerState(3, false),
                                  onLockToggled: () => _toggleLock(3),
                                  onSwitchChanged: (value) => _onSwitchChanged(3, value),
                                  isLandscape: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                ),
              );
            } else {
            // Portrait orientation
            return SizedBox.expand(
              child: Container(
                color: Colors.black, // Ensure black background covers entire screen including status bar area
                child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Column(
                  children: [
                    // Top row with Bluetooth and Settings buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BluetoothConnectionButton(bluetoothManager: bluetoothManager),
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SettingsView()),
                            );
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Main content area - three sets stacked vertically
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                        children: [
                          // Breaker Set 1
                          Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.black, width: 2),
                              ),
                            ),
                            child: BreakerSetView(
                              title: "Breaker 1",
                              breakerOpen: breaker1Open,
                              switchToggled: switch1Toggled,
                              isLocked: isLock1,
                              onOpenTapped: () => _setBreakerState(1, true),
                              onCloseTapped: () => _setBreakerState(1, false),
                              onLockToggled: () => _toggleLock(1),
                              onSwitchChanged: (value) => _onSwitchChanged(1, value),
                              isLandscape: false,
                            ),
                          ),
                          
                          // Breaker Set 2
                          Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.black, width: 2),
                              ),
                            ),
                            child: BreakerSetView(
                              title: "Breaker 2",
                              breakerOpen: breaker2Open,
                              switchToggled: switch2Toggled,
                              isLocked: isLock2,
                              onOpenTapped: () => _setBreakerState(2, true),
                              onCloseTapped: () => _setBreakerState(2, false),
                              onLockToggled: () => _toggleLock(2),
                              onSwitchChanged: (value) => _onSwitchChanged(2, value),
                              isLandscape: false,
                            ),
                          ),
                          
                          // Breaker Set 3
                          BreakerSetView(
                            title: "Breaker 3",
                            breakerOpen: breaker3Open,
                            switchToggled: switch3Toggled,
                            isLocked: isLock3,
                            onOpenTapped: () => _setBreakerState(3, true),
                            onCloseTapped: () => _setBreakerState(3, false),
                            onLockToggled: () => _toggleLock(3),
                            onSwitchChanged: (value) => _onSwitchChanged(3, value),
                            isLandscape: false,
                          ),
                        ],
                      ),
                  ),
                ],
              ),
            ),
            ),
              ),
            );
            }
          },
        ),
      ),
    );
  }
}

