import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const NasaStreamDeckApp());
}

class NasaStreamDeckApp extends StatelessWidget {
  const NasaStreamDeckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NASA Control Deck',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF020205),
      ),
      home: const NasaControlDeckScreen(),
    );
  }
}

class NasaControlDeckScreen extends StatefulWidget {
  const NasaControlDeckScreen({super.key});

  @override
  State<NasaControlDeckScreen> createState() => _NasaControlDeckScreenState();
}

class _NasaControlDeckScreenState extends State<NasaControlDeckScreen>
    with SingleTickerProviderStateMixin {
  // 1. Grid configuration JSON String
  final String _jsonConfig = '''
  [
    {
      "title": "ARTEMIS MISSION",
      "subtitle": "Lunar Exploration Program",
      "url": "https://www.nasa.gov/specials/artemis/",
      "color": "0xFFFF2A6D",
      "icon": "rocket"
    },
    {
      "title": "APOD STREAM",
      "subtitle": "Astronomy Picture of the Day",
      "url": "https://apod.nasa.gov/apod/astropix.html",
      "color": "0xFF05D9E8",
      "icon": "photo"
    },
    {
      "title": "DEEP SPACE RADAR",
      "subtitle": "DSN Live Communications",
      "url": "https://eyes.nasa.gov/apps/dsn-now/dsn.html",
      "color": "0xFF00FF9F",
      "icon": "radar"
    },
    {
      "title": "MOON TO MARS",
      "subtitle": "Architecture & Strategy",
      "url": "https://www.nasa.gov/topics/moon-to-mars/",
      "color": "0xFFFFD000",
      "icon": "moon"
    }
  ]
  ''';
  List<dynamic> _deckItems = [];
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    // 2. Parse JSON
    _deckItems = json.decode(_jsonConfig);

    // Animation Controller για το συνεχές Glowing Pulse εφέ
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // 5. Icon Mapper
  IconData _getIconData(String iconKey) {
    switch (iconKey.toLowerCase()) {
      case 'rocket':
        return Icons.rocket_launch_rounded;
      case 'photo':
        return Icons.photo_camera_back_rounded;
      case 'radar':
        return Icons.radar_rounded;
      case 'moon':
        return Icons.nightlight_round;
      default:
        return Icons.space_dashboard_rounded;
    }
  }

  // 3. URL Launcher
  Future<void> _launchURL(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Adaptive Calculation (Προσαρμογή Στηλών & Αναλογίας)
    int crossAxisCount = 2;
    double childAspectRatio = 1.1;

    if (screenWidth > 1100) {
      crossAxisCount = 4;
      childAspectRatio = 1.3;
    } else if (screenWidth > 700) {
      crossAxisCount = 2;
      childAspectRatio = 1.35;
    } else if (screenWidth < 400) {
      crossAxisCount = 1;
      childAspectRatio = 1.8;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.4),
        elevation: 0,
        centerTitle: true,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.dataset_rounded,
              color: Color(0xFF05D9E8),
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              'NASA CONTROL DECK',
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w900,
                letterSpacing: 2.5,
                fontSize: screenWidth < 500 ? 16 : 20,
                color: const Color(0xFF05D9E8),
                shadows: [
                  BoxShadow(
                    color: const Color(0xFF05D9E8).withOpacity(0.8),
                    blurRadius: 14,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Background Cyberpunk Grid Paper Overlay
          Positioned.fill(
            child: GridPaper(
              color: const Color(0xFF05D9E8).withOpacity(0.04),
              divisions: 2,
              subdivisions: 2,
              interval: 100,
            ),
          ),
          // Sci-Fi Scanline Glow Layer
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.2,
                      colors: [
                        const Color(
                          0xFF05D9E8,
                        ).withOpacity(0.02 + (_pulseController.value * 0.03)),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Adaptive Responsive GridView
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _deckItems.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 20.0,
                      mainAxisSpacing: 20.0,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemBuilder: (context, index) {
                      final item = _deckItems[index];
                      final Color accentColor = Color(int.parse(item['color']));

                      return CyberDeckButton(
                        title: item['title'],
                        subtitle: item['subtitle'],
                        iconData: _getIconData(item['icon']),
                        glowColor: accentColor,
                        pulseAnimation: _pulseController,
                        onTap: () => _launchURL(item['url']),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 4. Adaptive, Animated & Interactive Glassmorphism Button
class CyberDeckButton extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData iconData;
  final Color glowColor;
  final Animation<double> pulseAnimation;
  final VoidCallback onTap;

  const CyberDeckButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconData,
    required this.glowColor,
    required this.pulseAnimation,
    required this.onTap,
  });
  @override
  State<CyberDeckButton> createState() => _CyberDeckButtonState();
}

class _CyberDeckButtonState extends State<CyberDeckButton> {
  bool _isHovered = false;
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: widget.pulseAnimation,
          builder: (context, child) {
            final double basePulse = widget.pulseAnimation.value * 0.2;

            return AnimatedScale(
              scale: _isPressed ? 0.95 : (_isHovered ? 1.03 : 1.0),
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutCubic,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: widget.glowColor.withOpacity(
                        _isHovered ? 0.7 : (0.2 + basePulse),
                      ),
                      blurRadius: _isHovered ? 24 : 12,
                      spreadRadius: _isHovered ? 4 : 1,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: widget.glowColor.withOpacity(
                            _isHovered ? 1.0 : 0.5,
                          ),
                          width: _isHovered ? 2.2 : 1.2,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 20.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated Icon Container
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.glowColor.withOpacity(
                                _isHovered ? 0.2 : 0.08,
                              ),
                              border: Border.all(
                                color: widget.glowColor.withOpacity(
                                  _isHovered ? 0.8 : 0.3,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              widget.iconData,
                              size: 38,
                              color: widget.glowColor,
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Glowing Title
                          Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              letterSpacing: 1.2,
                              shadows: [
                                Shadow(
                                  color: widget.glowColor,
                                  blurRadius: _isHovered ? 12 : 6,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Subtitle
                          Text(
                            widget.subtitle,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
