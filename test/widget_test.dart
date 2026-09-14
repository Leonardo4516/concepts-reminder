import 'package:flutter_test/flutter_test.dart';
import 'package:concepts_reminder/main.dart';
import 'package:concepts_reminder/models/app_settings.dart';

void main() {
  testWidgets('App renders main dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ConceptsReminderApp(
        initialSettings: AppSettings(),
      ),
    );

    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Temas'), findsOneWidget);
    expect(find.text('Ajustes'), findsOneWidget);
  });
}
