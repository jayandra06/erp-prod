import 'package:flutter/material.dart';

class MaritimeBackground extends StatelessWidget {
  const MaritimeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D47A1), // Deep ocean blue
            Color(0xFF1976D2), // Maritime blue
            Color(0xFF42A5F5), // Light blue
            Color(0xFF81C784), // Ocean green
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Animated waves
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: const Size(double.infinity, 200),
              painter: WavePainter(),
            ),
          ),
          
          // Floating elements
          Positioned(
            top: 100,
            left: 50,
            child: _FloatingElement(
              icon: Icons.anchor,
              delay: 0,
            ),
          ),
          
          Positioned(
            top: 200,
            right: 80,
            child: _FloatingElement(
              icon: Icons.directions_boat,
              delay: 1,
            ),
          ),
          
          Positioned(
            top: 300,
            left: 100,
            child: _FloatingElement(
              icon: Icons.waves,
              delay: 2,
            ),
          ),
          
          Positioned(
            top: 150,
            right: 120,
            child: _FloatingElement(
              icon: Icons.compass_calibration,
              delay: 3,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingElement extends StatefulWidget {
  final IconData icon;
  final int delay;

  const _FloatingElement({
    required this.icon,
    required this.delay,
  });

  @override
  State<_FloatingElement> createState() => _FloatingElementState();
}

class _FloatingElementState extends State<_FloatingElement>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    // Start animation with delay
    Future.delayed(Duration(seconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value * 20 - 10),
          child: Opacity(
            opacity: 0.3 + (_animation.value * 0.4),
            child: Icon(
              widget.icon,
              size: 30,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // First wave
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(
      size.width * 0.25, size.height * 0.6,
      size.width * 0.5, size.height * 0.8,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height * 1.0,
      size.width, size.height * 0.8,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Second wave
    final paint2 = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.9);
    path2.quadraticBezierTo(
      size.width * 0.3, size.height * 0.7,
      size.width * 0.6, size.height * 0.9,
    );
    path2.quadraticBezierTo(
      size.width * 0.8, size.height * 1.1,
      size.width, size.height * 0.9,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
