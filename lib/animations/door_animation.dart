import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/farm_state.dart';

const _duration = Duration(milliseconds: 1200);

class DoorAnimation extends StatefulWidget {
  final DoorState doorState;

  const DoorAnimation({super.key, required this.doorState});

  @override
  State<DoorAnimation> createState() => _DoorAnimationState();
}

class _DoorAnimationState extends State<DoorAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _slideAnimation; // 0.0 = closed, 1.0 = open (fully slid left)

  @override
  void initState() {
    super.initState();
    // Curves.easeInOutCubic represents a very smooth servo-like motion profile
    _ctrl = AnimationController(vsync: this, duration: _duration);
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic),
    );
    if (widget.doorState == DoorState.open) {
      _ctrl.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(DoorAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.doorState == widget.doorState) return;

    if (widget.doorState == DoorState.open) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 192,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double totalWidth = constraints.maxWidth;
            const double gateWidth = 152.0;
            final double leftPostPos = (totalWidth - gateWidth) / 2;
            final double rightPostPos = leftPostPos + gateWidth - 10;

            return AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, _) {
                final slideOffset = -gateWidth * _slideAnimation.value;

                return Stack(
                  children: [
                    // Sky gradient
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [AppColors.sky1, AppColors.sky2],
                          ),
                        ),
                      ),
                    ),
                    // Grass
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 96,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [AppColors.grass1, AppColors.grass2],
                          ),
                        ),
                      ),
                    ),
                    // Grass divider
                    Positioned(
                      bottom: 96,
                      left: 0,
                      right: 0,
                      height: 10,
                      child: Container(color: AppColors.grass3),
                    ),

                    // Left fence - spans from 0 to leftPostPos
                    Positioned(
                      bottom: 64,
                      left: 0,
                      width: leftPostPos,
                      child: _ResponsiveFence(width: leftPostPos),
                    ),

                    // Right fence - spans from rightPostPos + 10 to totalWidth
                    Positioned(
                      bottom: 64,
                      left: rightPostPos + 10,
                      width: totalWidth - (rightPostPos + 10),
                      child: _ResponsiveFence(width: totalWidth - (rightPostPos + 10)),
                    ),

                    // Gate and Ground Shadow clipped to the doorway area
                    Positioned(
                      bottom: 56,
                      left: leftPostPos,
                      width: gateWidth,
                      height: 104, // Space for shadow + gate
                      child: ClipRect(
                        child: Stack(
                          children: [
                            // Ground shadow (offset 8px lower than gate bottom: 64 - 56 = 8)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              width: gateWidth,
                              height: 12,
                              child: Transform.translate(
                                offset: Offset(slideOffset, 0),
                                child: Container(
                                  width: gateWidth,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    color: Colors.black.withOpacity(0.20),
                                  ),
                                ),
                              ),
                            ),
                            // Gate
                            Positioned(
                              bottom: 8, // aligns to bottom: 64 relative to the main Stack
                              left: 0,
                              width: gateWidth,
                              height: 96,
                              child: Transform.translate(
                                offset: Offset(slideOffset, 0),
                                child: const _Gate(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Hinge post (left of doorway)
                    Positioned(
                      bottom: 64,
                      left: leftPostPos,
                      child: _Post(),
                    ),
                    // Latch post (right of doorway)
                    Positioned(
                      bottom: 64,
                      left: rightPostPos,
                      child: _Post(),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ResponsiveFence extends StatelessWidget {
  final double width;
  const _ResponsiveFence({required this.width});

  @override
  Widget build(BuildContext context) {
    // Generate posts dynamically based on fence width
    final int postCount = (width / 35.0).floor().clamp(1, 10);
    return SizedBox(
      width: width,
      height: 80,
      child: Stack(
        children: [
          // Top rail
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            height: 8,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.wood,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // Bottom rail
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            height: 8,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.wood,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // Dynamically spaced posts
          ...List.generate(postCount, (i) {
            double leftPos = 10.0;
            if (postCount > 1) {
              leftPos = 5.0 + i * ((width - 15.0) / (postCount - 1));
            }
            return Positioned(
              left: leftPos.clamp(0.0, width - 8.0),
              top: 0,
              bottom: 0,
              width: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.woodDark,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Post extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 96,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9AA3AB), Color(0xFFC9D0D6), Color(0xFF7C858D)],
        ),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4)],
      ),
    );
  }
}

class _Gate extends StatelessWidget {
  const _Gate();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 152,
      height: 96,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFCAA477), Color(0xFFB98F5F)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF7C858D), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Inner frame
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: const Color(0x808B939B), width: 2),
              ),
            ),
          ),
          // Wooden planks
          Positioned(
            left: 6,
            right: 6,
            top: 6,
            bottom: 6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                4,
                (_) => Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xA0A67C52),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          // Diagonal brace
          Positioned(
            left: 8,
            right: 8,
            top: 8,
            bottom: 8,
            child: ClipRect(
              child: Transform.rotate(
                angle: -0.59,
                alignment: Alignment.bottomLeft,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xCC9AA3AB),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          // Hinges (left) - visually kept for consistency with current style
          Positioned(
            top: 8,
            left: -4,
            child: Container(
              width: 8,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFF6B7178),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: -4,
            child: Container(
              width: 8,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFF6B7178),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Latch handle (right)
          Positioned(
            right: -4,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF5C626A),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
