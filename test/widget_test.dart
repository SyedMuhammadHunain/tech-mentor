import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techsaathi_ai/app/app.dart';
import 'package:techsaathi_ai/core/services/ai_service.dart';
import 'package:techsaathi_ai/data/models/user_preferences.dart';
import 'package:techsaathi_ai/features/banking/services/banking_content.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App launches to splash/onboarding', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: TechSaathiApp()));
    await tester.pump();
    expect(find.textContaining('TechSaathi'), findsWidgets);
    await tester.pump(const Duration(seconds: 2));
  });

  test('Banking content has 14 lessons', () {
    expect(BankingContent.lessons.length, 14);
    expect(BankingContent.byId('understanding_beneficiaries'), isNotNull);
  });

  test('Demo AI fallback explains WhatsApp', () {
    final text = DemoAiFallback.technology(
      'How do I use WhatsApp?',
      AppLanguage.english,
    );
    expect(text.toLowerCase(), contains('whatsapp'));
    expect(text.toLowerCase(), contains('step'));
  });

  test('Scam analysis flags OTP request', () {
    final text = DemoAiFallback.scam(
      'Send your OTP urgently to keep account',
      AppLanguage.english,
    );
    expect(text.toLowerCase(), contains('risk'));
    expect(text.toLowerCase(), contains('otp'));
  });
}
