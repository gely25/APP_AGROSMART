import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smartfarm_app/main.dart';
import 'package:smartfarm_app/providers/farm_provider.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => FarmProvider()),
        ],
        child: const SmartFarmApp(),
      ),
    );

    expect(find.text('SMARTFARM'), findsOneWidget);
  });
}

