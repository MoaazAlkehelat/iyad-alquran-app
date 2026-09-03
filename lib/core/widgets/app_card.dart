import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';

/// The one card container used across the app so every surface matches.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final bool shadow;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpace.lg),
    this.margin,
    this.color,
    this.shadow = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Ink(
      decoration: AppSurface.card(color: color, shadow: shadow),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return Padding(padding: margin ?? EdgeInsets.zero, child: content);

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.cardR,
        child: InkWell(
          borderRadius: AppRadius.cardR,
          onTap: onTap,
          child: content,
        ),
      ),
    );
  }
}
