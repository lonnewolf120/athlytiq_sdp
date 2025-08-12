import 'package:flutter/material.dart';

class CustomHeaderWithMenu extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showMenuButton;
  final bool showLogo;
  final Gradient? gradient;
  final VoidCallback? onMenuTap;

  const CustomHeaderWithMenu({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showMenuButton = true,
    this.showLogo = true,
    this.gradient,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (showMenuButton)
                      Builder(
                        builder:
                            (context) => IconButton(
                              icon: const Icon(Icons.menu, color: Colors.white),
                              onPressed:
                                  onMenuTap ??
                                  () => Scaffold.of(context).openDrawer(),
                            ),
                      ),
                    if (showLogo)
                      Image.asset('assets/logos/logo.png', height: 30),
                    if (showLogo) const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Row(children: actions ?? []),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
