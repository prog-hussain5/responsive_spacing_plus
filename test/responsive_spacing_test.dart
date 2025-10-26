import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_spacing_plus/responsive_spacing_plus.dart';

void main() {
  testWidgets('deviceType resolves correctly by width', (tester) async {
    DeviceType? type;

    Future<void> pumpWithWidth(double w) async {
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(size: Size(w, 800)),
          child: Builder(
            builder: (context) {
              type = Responsive.deviceType(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    }

    await pumpWithWidth(400);
    expect(type, DeviceType.mobile);

    await pumpWithWidth(800);
    expect(type, DeviceType.tablet);

    await pumpWithWidth(1300);
    expect(type, DeviceType.desktop);
  });

  testWidgets('font scales with width-based design', (tester) async {
    double? f1;
    double? f2;

    // width 375 -> ~16
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(375, 812)),
        child: Builder(
          builder: (context) {
            f1 = Responsive.font(context, 16);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(f1, closeTo(16, 0.001));

    // width 750 -> ~32 (clamp allows up to 35.2 by default)
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(750, 1624)),
        child: Builder(
          builder: (context) {
            f2 = Responsive.font(context, 16);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(f2, closeTo(32, 0.001));
  });

  testWidgets('padding scales by width and height', (tester) async {
    EdgeInsets? p;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(750, 1624)), // 2x of 375x812
        child: Builder(
          builder: (context) {
            p = Responsive.padding(
              context,
              const EdgeInsets.fromLTRB(10, 20, 30, 40),
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(p!.left, 20);
    expect(p!.top, 40);
    expect(p!.right, 60);
    expect(p!.bottom, 80);
  });
}
