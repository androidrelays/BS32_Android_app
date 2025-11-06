import 'package:flutter/material.dart';

class ControlButtonsView extends StatelessWidget {
  final bool breakerOpen;
  final bool switchToggled;
  final bool isLocked;
  final bool isLandscape;
  final VoidCallback onOpenTapped;
  final VoidCallback onCloseTapped;

  const ControlButtonsView({
    super.key,
    required this.breakerOpen,
    required this.switchToggled,
    required this.isLocked,
    required this.isLandscape,
    required this.onOpenTapped,
    required this.onCloseTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // OPEN Button
        SizedBox(
          width: isLandscape ? 180 : 178, // Reduced by 2px in portrait
          height: isLandscape ? 60 : 55, // Increased by 10px in landscape (was 50, now 60)
          child: ElevatedButton(
            onPressed: isLocked ? null : onOpenTapped,
            style: ElevatedButton.styleFrom(
              backgroundColor: isLocked
                  ? Colors.grey.withValues(alpha: 0.6)
                  : (breakerOpen ? Colors.green : const Color(0xFF005500)),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.black, width: 3),
              ),
              padding: EdgeInsets.zero,
            ),
            child: const Text(
              "OPEN",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 3), // Reduced from 5 to 3 to fit in landscape
        
        // CLOSE Button
        SizedBox(
          width: isLandscape ? 180 : 178, // Reduced by 2px in portrait
          height: isLandscape ? 60 : 55, // Increased by 10px in landscape (was 50, now 60)
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: isLandscape ? 180 : 178, // Reduced by 2px in portrait
                height: isLandscape ? 60 : 55, // Match outer SizedBox height (increased by 10px in landscape)
                child: ElevatedButton(
                  onPressed: (!switchToggled || isLocked) ? null : onCloseTapped,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLocked
                        ? Colors.grey.withValues(alpha: 0.6)
                        : (!breakerOpen ? Colors.red : const Color(0xFF550000)),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.black, width: 3),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    "CLOSE",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              // Prohibition symbol overlay when switch is DOWN
              if (!switchToggled)
                Center(
                  child: CustomPaint(
                    size: const Size(35, 35),
                    painter: ProhibitionSymbolPainter(),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class ProhibitionSymbolPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 - 1,
      paint,
    );

    // Draw diagonal line (slash)
    paint.style = PaintingStyle.fill;
    paint.strokeWidth = 2;
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.15),
      Offset(size.width * 0.85, size.height * 0.85),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

