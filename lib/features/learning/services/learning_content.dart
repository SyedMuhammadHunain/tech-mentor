import '../../banking/models/banking_lesson.dart';

abstract final class LearningContent {
  static List<LearningCategory> get categories => [
        LearningCategory(
          id: 'smartphone_basics',
          title: 'Smartphone Basics',
          description: 'Learn the phone buttons and simple settings.',
          iconName: 'phone',
          lessons: [
            _l(
              'sb1',
              'Turning the phone on and unlocking',
              'Your phone needs power and a lock for safety.',
              'The side button usually turns the screen on. Then you unlock with PIN, pattern, or fingerprint.',
              [
                'Press the side power button once.',
                'Swipe up or enter your lock method.',
                'You are now on the Home screen.',
              ],
              'Lock and unlock your phone three times slowly.',
            ),
            _l(
              'sb2',
              'Finding and opening apps',
              'Apps are tools on your phone.',
              'Each icon is an app. Tap once to open.',
              [
                'From the Home screen, look for the app icon.',
                'Tap the icon once.',
                'To leave, tap the Home or gesture bar.',
              ],
              'Open Settings, then return Home.',
            ),
          ],
        ),
        LearningCategory(
          id: 'whatsapp',
          title: 'WhatsApp',
          description: 'Messages, calls, and photos made simple.',
          iconName: 'chat',
          lessons: [
            _l(
              'wa1',
              'Sending a text message',
              'Messaging is like sending a short letter.',
              'Open a chat, type, and tap send.',
              [
                'Open WhatsApp.',
                'Open a chat with someone you know.',
                'Type a short message and tap the send arrow.',
              ],
              'Send “Assalam-o-Alaikum” to a trusted family member.',
            ),
            _l(
              'wa2',
              'Making a voice call',
              'A voice call talks through internet.',
              'The phone icon starts a voice call.',
              [
                'Open a WhatsApp chat.',
                'Tap the phone icon at the top.',
                'Wait for the other person to answer.',
              ],
              'Try a short call with a trusted person.',
            ),
          ],
        ),
        LearningCategory(
          id: 'internet_basics',
          title: 'Internet Basics',
          description: 'Wi-Fi, mobile data, and safe browsing.',
          iconName: 'wifi',
          lessons: [
            _l(
              'net1',
              'Connecting to Wi-Fi',
              'Wi-Fi is wireless internet.',
              'Choose your network and enter the password.',
              [
                'Open Settings → Wi-Fi.',
                'Turn Wi-Fi on.',
                'Select your network and enter the password.',
              ],
              'Connect to your home Wi-Fi successfully.',
            ),
          ],
        ),
        LearningCategory(
          id: 'video_calling',
          title: 'Video Calling',
          description: 'See and speak with family.',
          iconName: 'videocam',
          lessons: [
            _l(
              'vc1',
              'Starting a video call',
              'Video calls show faces while talking.',
              'Use the video camera icon in WhatsApp.',
              [
                'Open the chat.',
                'Tap the video icon.',
                'Allow camera if asked, then smile and say hello.',
              ],
              'Complete one video call practice with a trusted person.',
            ),
          ],
        ),
        LearningCategory(
          id: 'digital_payments',
          title: 'Digital Payments',
          description: 'Wallets and careful payments.',
          iconName: 'payments',
          lessons: [
            _l(
              'pay1',
              'What is a digital payment?',
              'Paying without physical cash.',
              'Money moves through an app after you confirm.',
              [
                'Open a trusted payment app.',
                'Choose send or pay.',
                'Review details, then confirm.',
              ],
              'Practise a transfer in TechSaathi Demo Bank (simulation only).',
            ),
          ],
        ),
        LearningCategory(
          id: 'online_banking',
          title: 'Online Banking',
          description: 'Bank apps without fear.',
          iconName: 'account_balance',
          lessons: [
            _l(
              'ob1',
              'Reading your balance',
              'Balance is your available money.',
              'Find Balance on the home screen of your bank app.',
              [
                'Open your bank app.',
                'Find Account Balance.',
                'Read the amount slowly.',
              ],
              'Open Banking Saathi and complete the balance lesson.',
            ),
          ],
        ),
        LearningCategory(
          id: 'cybersecurity',
          title: 'Cybersecurity',
          description: 'Stay safe from tricks and scams.',
          iconName: 'shield',
          lessons: [
            _l(
              'cs1',
              'Protecting OTP and PIN',
              'Secrets must stay secret.',
              'OTP and PIN are keys to your money.',
              [
                'Never type OTP into a chat.',
                'Never tell PIN on a phone call.',
                'If someone asks, stop and verify independently.',
              ],
              'Analyse one sample message in ScamShield.',
            ),
          ],
        ),
        LearningCategory(
          id: 'government_websites',
          title: 'Government Websites',
          description: 'Finding official information carefully.',
          iconName: 'public',
          lessons: [
            _l(
              'gov1',
              'Recognising official sites',
              'Official sites usually use trusted web addresses.',
              'Prefer links from official apps or known government pages.',
              [
                'Do not trust random SMS links.',
                'Type known official addresses carefully when possible.',
                'Look for lock icons and correct spellings.',
              ],
              'Ask AI Teacher: “How do I open an official government website safely?”',
            ),
          ],
        ),
      ];

  static LearningLesson? lessonById(String id) {
    for (final c in categories) {
      for (final l in c.lessons) {
        if (l.id == id) return l;
      }
    }
    return null;
  }

  static LearningCategory? categoryById(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  static LearningLesson _l(
    String id,
    String title,
    String intro,
    String explanation,
    List<String> steps,
    String practice,
  ) {
    return LearningLesson(
      id: id,
      title: title,
      introduction: intro,
      explanation: explanation,
      steps: steps,
      practiceHint: practice,
      quiz: [
        QuizQuestion(
          question: 'The best way to remember this lesson is to…',
          options: [
            'Only watch once',
            'Practise the steps yourself',
            'Share your OTP',
          ],
          answerIndex: 1,
          explanation: 'Practice builds independence.',
        ),
      ],
    );
  }
}
