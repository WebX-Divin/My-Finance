import 'package:my_finance/export.dart';
import 'dart:math' as math;

class FlipPageRoute<T> extends PageRouteBuilder<T> {
  final Widget Function(BuildContext) builder;
  final Duration duration;

  FlipPageRoute({
    required this.builder,
    this.duration = const Duration(milliseconds: 700),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var curve = Curves.easeInOut;
            var tween =
                Tween<double>(begin: 0, end: 1).chain(CurveTween(curve: curve));

            var rotationAnimation = animation.drive(tween);

            return AnimatedBuilder(
              animation: rotationAnimation,
              builder: (context, child) {
                double angle = rotationAnimation.value * math.pi; // Flip angle
                bool isFlipped = rotationAnimation.value >= 0.5;

                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // Perspective depth
                    ..rotateY(angle), // Apply rotation
                  child: AnimatedSwitcher(
                    duration: duration,
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    child: isFlipped
                        ? Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(math.pi),
                            child: child,
                          )
                        : child,
                  ),
                );
              },
              child: child,
            );
          },
        );
}
