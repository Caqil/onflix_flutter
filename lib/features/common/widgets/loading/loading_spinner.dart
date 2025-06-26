import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingSpinner extends StatelessWidget {
  final double? size;
  final Color? color;
  final String? message;

  const LoadingSpinner({
    super.key,
    this.size,
    this.color,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: size ?? 80,
              height: size ?? 80,
              child: Lottie.asset(
                'assets/animations/loading.json',
                fit: BoxFit.contain,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: color ??
                          Theme.of(context).textTheme.bodyMedium?.color,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
