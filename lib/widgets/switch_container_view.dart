import 'package:flutter/material.dart';

class SwitchContainerView extends StatelessWidget {
  final bool switchToggled;
  final bool isLocked;
  final bool isLandscape;
  final Function(bool) onChanged;

  const SwitchContainerView({
    super.key,
    required this.switchToggled,
    required this.isLocked,
    required this.isLandscape,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: isLandscape ? 140 : 178, // Reduced by 2px in portrait (was 180, now 178)
      decoration: BoxDecoration(
        color: Colors.yellow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 3),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // UP label at the very top
          Container(
            height: isLandscape ? 25 : 23, // Reduced by 2px in portrait
            alignment: Alignment.center,
            child: Text(
              "UP",
              style: TextStyle(
                fontSize: isLandscape ? 18 : 16, // Reduced by 2px in portrait
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          
          // Switch section
          Expanded(
            child: Row(
              children: [
                // 69 label on the left, vertically centered
                const SizedBox(
                  width: 35,
                  child: Center(
                    child: Text(
                      "69",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                
                // Switch positioned below UP label with proper spacing
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Spacer to push switch down
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: SizedBox(height: isLandscape ? 240 : 240),
                      ),
                      
                      // Switch
                      Positioned(
                        left: 10, // Moved 5px more to the left (was 15, now 10)
                        child: Transform.rotate(
                          angle: 270 * 3.14159 / 180, // 270 degrees in radians
                          child: Transform.scale(
                            scale: isLandscape ? 1.78 : 2.2, // Another 3px shorter in landscape (reduced scale from 1.81 to 1.78)
                            child: Switch(
                              value: switchToggled,
                              onChanged: isLocked ? null : onChanged,
                              activeColor: Colors.blue,
                              inactiveThumbColor: Colors.grey[700], // Dark grey instead of black when down
                              inactiveTrackColor: Colors.grey[400], // Light grey track when down
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // DOWN label at the very bottom
          Container(
            height: isLandscape ? 25 : 23, // Reduced by 2px in portrait
            alignment: Alignment.center,
            child: Text(
              "DOWN",
              style: TextStyle(
                fontSize: isLandscape ? 18 : 16, // Reduced by 2px in portrait
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

