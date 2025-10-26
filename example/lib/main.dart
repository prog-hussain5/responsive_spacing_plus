import 'package:flutter/material.dart';
import 'package:responsive_spacing_plus/responsive_spacing_plus.dart';

void main() {
  // Optional: override defaults
  Responsive.init(
    config: const ResponsiveConfig(
      designWidth: 375,
      designHeight: 812,
      breakpoints: ResponsiveBreakpoints(mobileMax: 600, tabletMax: 1024),
      maxTextScaleFactor: 2.0,
    ),
  );
  runApp(const DemoApp());
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'responsive_spacing demo',
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        // Apply suggested text scale (optional)
        final tsf = Responsive.textScaleFactor(context);
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(tsf)),
          child: child ?? const SizedBox.shrink(),
        );
      },
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const DemoHomePage(),
    );
  }
}

class DemoHomePage extends StatelessWidget {
  const DemoHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final device = Responsive.deviceType(context);
    final crossAxisCount = ResponsiveValue<int>(
      mobile: 2,
      tablet: 3,
      desktop: 5,
      fallback: 2,
    ).resolve(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'responsive_spacing_plus — ${device.name}',
          style: TextStyle(fontSize: context.font(18)),
        ),
      ),
      body: SingleChildScrollView(
        padding: context.pad(
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Typography',
              style: TextStyle(fontSize: context.font(22, max: 28)),
            ),
            SizedBox(height: context.space(8)),
            Wrap(
              spacing: context.space(12),
              runSpacing: context.space(8),
              children: [
                for (final size in [12.0, 14.0, 16.0, 18.0, 22.0, 28.0])
                  Chip(
                    label: Text(
                      'font ${size.toInt()}',
                      style: TextStyle(fontSize: context.font(size)),
                    ),
                  ),
              ],
            ),

            SizedBox(height: context.space(20)),
            Text('Spacing', style: TextStyle(fontSize: context.font(20))),
            SizedBox(height: context.space(8)),
            Row(
              children: [
                Container(
                  width: context.w(60),
                  height: context.h(16),
                  color: Colors.blue.shade200,
                ),
                SizedBox(width: context.space(12)),
                Container(
                  width: context.w(60),
                  height: context.h(16),
                  color: Colors.green.shade200,
                ),
                SizedBox(width: context.space(12)),
                Container(
                  width: context.w(60),
                  height: context.h(16),
                  color: Colors.orange.shade200,
                ),
              ],
            ),

            SizedBox(height: context.space(20)),
            Text(
              'Icons & radius',
              style: TextStyle(fontSize: context.font(20)),
            ),
            SizedBox(height: context.space(8)),
            Wrap(
              spacing: context.space(16),
              children: [
                Icon(Icons.star, size: context.iconSize(20)),
                Icon(Icons.star, size: context.iconSize(28)),
                Icon(Icons.star, size: context.iconSize(36)),
                Container(
                  padding: context.pad(const EdgeInsets.all(12)),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(context.radius(12)),
                  ),
                  child: const Text('Rounded box'),
                ),
              ],
            ),

            SizedBox(height: context.space(20)),
            Text(
              'Responsive grid (${crossAxisCount}x)',
              style: TextStyle(fontSize: context.font(20)),
            ),
            SizedBox(height: context.space(8)),
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 10,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: context.space(8),
                crossAxisSpacing: context.space(8),
                childAspectRatio: 1.2,
              ),
              itemBuilder: (context, index) {
                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.indigo[(index % 9 + 1) * 100],
                    borderRadius: BorderRadius.circular(context.radius(10)),
                  ),
                  child: Text(
                    'Item ${index + 1}',
                    style: TextStyle(
                      fontSize: context.font(16),
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.space(8)),
      child: Text(
        title,
        style: TextStyle(
          fontSize: context.font(20, max: 26),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class InfoTag extends StatelessWidget {
  final String label;
  final String value;
  const InfoTag({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.pad(
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      decoration: BoxDecoration(
        color: Colors.indigo.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(context.radius(10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: context.font(14),
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(value, style: TextStyle(fontSize: context.font(14))),
        ],
      ),
    );
  }
}

class DemoCard extends StatelessWidget {
  final String label;
  final Widget child;
  const DemoCard({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: context.pad(const EdgeInsets.all(12)),
        decoration: BoxDecoration(
          color: Colors.indigo.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(context.radius(12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: context.font(14),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: context.space(8)),
            child,
          ],
        ),
      ),
    );
  }
}

class FooterNote extends StatelessWidget {
  const FooterNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Tip: Resize the window or change the device/emulator to see responsive behavior.',
      style: TextStyle(
        fontSize: context.font(12, max: 14),
        color: Colors.black54,
      ),
    );
  }
}
