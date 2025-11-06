import 'package:flutter/material.dart';
import 'switch_container_view.dart';
import 'control_buttons_view.dart';
import 'lock_button_view.dart';

class BreakerSetView extends StatelessWidget {
  final String title;
  final bool breakerOpen;
  final bool switchToggled;
  final bool isLocked;
  final VoidCallback onOpenTapped;
  final VoidCallback onCloseTapped;
  final VoidCallback onLockToggled;
  final Function(bool) onSwitchChanged;
  final bool isLandscape;

  const BreakerSetView({
    super.key,
    required this.title,
    required this.breakerOpen,
    required this.switchToggled,
    required this.isLocked,
    required this.onOpenTapped,
    required this.onCloseTapped,
    required this.onLockToggled,
    required this.onSwitchChanged,
    required this.isLandscape,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12, 
        vertical: isLandscape ? 0 : 6, // Reduced vertical padding in portrait by 2px (was 8, now 6)
      ),
      decoration: BoxDecoration(
        // Background color: if switch is down, always green; otherwise use breaker state
        color: !switchToggled 
            ? Colors.green  // Switch down = always green
            : (breakerOpen ? Colors.green : Colors.red),  // Switch up = green if open, red if closed
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title - centered above the entire UI control box
          // In landscape, move down to avoid status bar; in portrait, keep original position
          Transform.translate(
            offset: Offset(0, isLandscape ? 2 : -7), // Moved up 3px more in landscape (was 5, now 2)
            child: Text(
              title,
              style: TextStyle(
                fontSize: isLandscape ? 16 : 14, // Reduced font size in portrait by 2px
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 0), // Reduced to 0 to move everything down
          
          // Layout changes based on orientation
          if (isLandscape)
            // Landscape: Lock button on top, switch container below, buttons at bottom
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 0), // Reduced from 3 to 0 to move everything up 8px
                // Lock Button on top
                LockButtonView(
                  isLocked: isLocked,
                  isLandscape: true,
                  onToggle: onLockToggled,
                ),
                const SizedBox(height: 3), // Spacing between lock button and switch container
                
                // Switch Container in middle
                SwitchContainerView(
                  switchToggled: switchToggled,
                  isLocked: isLocked,
                  isLandscape: true,
                  onChanged: onSwitchChanged,
                ),
                const SizedBox(height: 3), // Spacing between switch container and open button
                
                // Control Buttons at bottom
                ControlButtonsView(
                  breakerOpen: breakerOpen,
                  switchToggled: switchToggled,
                  isLocked: isLocked,
                  isLandscape: true,
                  onOpenTapped: onOpenTapped,
                  onCloseTapped: onCloseTapped,
                ),
              ],
            )
          else
            // Portrait: Horizontal layout with switch on left, buttons on right
            Row(
              children: [
                // Left side: Switch Container
                Expanded(
                  child: SwitchContainerView(
                    switchToggled: switchToggled,
                    isLocked: isLocked,
                    isLandscape: false,
                    onChanged: onSwitchChanged,
                  ),
                ),
                const SizedBox(width: 5),
                
                // Right side: Lock button above Open, Close buttons
                Expanded(
                  child: Transform.translate(
                    offset: const Offset(0, -5), // Move up 5px in portrait to prevent scrolling
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const SizedBox(height: 3), // Reduced from 5 to 3
                        // Lock Button above buttons
                        LockButtonView(
                          isLocked: isLocked,
                          isLandscape: false,
                          onToggle: onLockToggled,
                        ),
                        const SizedBox(height: 3), // Reduced from 5 to 3
                        
                        // Control Buttons below lock
                        ControlButtonsView(
                          breakerOpen: breakerOpen,
                          switchToggled: switchToggled,
                          isLocked: isLocked,
                          isLandscape: false,
                          onOpenTapped: onOpenTapped,
                          onCloseTapped: onCloseTapped,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 5),
              ],
            ),
        ],
      ),
    );
  }
}

