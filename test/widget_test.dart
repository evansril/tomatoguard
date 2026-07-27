import 'package:flutter_test/flutter_test.dart';
import 'package:tomatoguard/app/app.dart';

void main() {
  testWidgets('opens the detect page after the splash screen', (tester) async {
    await tester.pumpWidget(const TomatoGuardApp());

    expect(find.text('TomatoGuard'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1700));
    await tester.pumpAndSettle();

    expect(find.text('Detect disease'), findsOneWidget);
    expect(find.text('Take a photo'), findsOneWidget);
  });
}
