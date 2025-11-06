import 'package:flutter/material.dart';

class LockButtonView extends StatelessWidget {
  final bool isLocked;
  final bool isLandscape;
  final VoidCallback onToggle;

  const LockButtonView({
    super.key,
    required this.isLocked,
    required this.isLandscape,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isLandscape ? 160 : 178, // Reduced by 2px in portrait (was 180, now 178)
      height: isLandscape ? 37 : 48, // 5px shorter in landscape (was 42, now 37)
      child: ElevatedButton(
        onPressed: onToggle,
        style: ElevatedButton.styleFrom(
          backgroundColor: isLocked ? Colors.orange : Colors.blue,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Colors.black, width: 3),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          isLocked ? "HOLD TO UNLOCK" : "HOLD TO LOCK",
          style: const TextStyle(
            fontSize: 14, // Reduced from 18 to 14
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

