import 'package:flutter/material.dart';

enum SnackBarType { success, error, warning, info }

SnackBar customSnackBar({
  required String message,
  SnackBarType type = SnackBarType.info,
  Duration duration = const Duration(seconds: 3),
  IconData? icon,
  Color? backgroundColor,
}) {
  Color bgColor;
  IconData displayIcon;

  // タイプごとのデフォルトの色とアイコンを設定
  switch (type) {
    case SnackBarType.success:
      bgColor = backgroundColor ?? Colors.green;
      displayIcon = icon ?? Icons.check_circle;
      break;
    case SnackBarType.error:
      bgColor = backgroundColor ?? Colors.red;
      displayIcon = icon ?? Icons.error;
      break;
    case SnackBarType.warning:
      bgColor = backgroundColor ?? Colors.orange;
      displayIcon = icon ?? Icons.warning_amber;
      break;
    case SnackBarType.info:
    default:
      bgColor = backgroundColor ?? Colors.blue;
      displayIcon = icon ?? Icons.info_outline;
      break;
  }

  return SnackBar(
    content: Row(
      children: [
        Icon(displayIcon, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
    backgroundColor: bgColor,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    duration: duration,
  );
}

/// 以下、アニメーション付き SnackBar（Overlay を利用）
///
/// AnimatedSnackBarWidget は、下からスライドしながらフェードインし、
/// 表示後にフェードアウトして上方向に消えるアニメーションを実現します。
class AnimatedSnackBarWidget extends StatefulWidget {
  final String message;
  final SnackBarType type;
  final Duration displayDuration;
  final VoidCallback onDismiss;

  const AnimatedSnackBarWidget({
    Key? key,
    required this.message,
    required this.type,
    this.displayDuration = const Duration(seconds: 3),
    required this.onDismiss,
  }) : super(key: key);

  @override
  _AnimatedSnackBarWidgetState createState() => _AnimatedSnackBarWidgetState();
}

class _AnimatedSnackBarWidgetState extends State<AnimatedSnackBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);

    _animationController.forward();

    Future.delayed(widget.displayDuration, () async {
      await _animationController.reverse();
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    IconData displayIcon;
    switch (widget.type) {
      case SnackBarType.success:
        bgColor = Colors.green;
        displayIcon = Icons.check_circle;
        break;
      case SnackBarType.error:
        bgColor = Colors.red;
        displayIcon = Icons.error;
        break;
      case SnackBarType.warning:
        bgColor = Colors.orange;
        displayIcon = Icons.warning_amber;
        break;
      case SnackBarType.info:
      default:
        bgColor = Colors.blue;
        displayIcon = Icons.info_outline;
        break;
    }

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Material(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(displayIcon, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

/// OverlayEntry を利用して上記 AnimatedSnackBarWidget を表示します。
void showAnimatedSnackBar(
  BuildContext context, {
  required String message,
  SnackBarType type = SnackBarType.info,
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (context) => AnimatedSnackBarWidget(
      message: message,
      type: type,
      displayDuration: duration,
      onDismiss: () {
        overlayEntry.remove();
      },
    ),
  );
  overlay.insert(overlayEntry);
}
