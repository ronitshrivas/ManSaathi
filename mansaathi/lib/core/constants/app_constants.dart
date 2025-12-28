class AppConstants {
  // App Info
  static const String appName = 'मनसाथी';
  static const String appNameEnglish = 'ManSaathi';
  static const String appVersion = '1.0.0';

  // Crisis Hotlines (Nepal)
  static const String suicidePreventionHotline = '16600';
  static const String tuthPsychiatryEmergency = '01-4412303';
  static const String patanHospitalCrisis = '01-5522266';

  // Subscription Plans
  static const double freeMessagesPerDay = 10;
  static const double premiumPriceMonthly = 999.0; // NPR
  static const int premiumSessionsIncluded = 2;

  // Session Pricing
  static const double minSessionPrice = 500.0; // NPR
  static const double maxSessionPrice = 800.0; // NPR

  // Mood Levels
  static const int moodVeryUnhappy = 1;
  static const int moodUnhappy = 2;
  static const int moodOkay = 3;
  static const int moodHappy = 4;
  static const int moodVeryHappy = 5;

  // Anonymous Name Prefixes (Nepali themed)
  static const List<String> anonymousNamePrefixes = [
    'शान्त', // Peaceful
    'साहसी', // Brave
    'मौन', // Silent
    'आशावादी', // Hopeful
    'स्वतन्त्र', // Free
    'बुद्धिमान', // Wise
    'दयालु', // Kind
    'सजग', // Aware
  ];

  static const List<String> anonymousNameSuffixes = [
    'कमल 🪷', // Lotus
    'हिमाल ⛰️', // Mountain
    'नदी 🌊', // River
    'चरा 🦅', // Bird
    'बादल ☁️', // Cloud
    'तारा ⭐', // Star
    'फूल 🌸', // Flower
    'रुख 🌳', // Tree
  ];

  // Areas of Concern
  static const Map<String, String> areasOfConcern = {
    'stress': 'तनाव (Stress/Anxiety)',
    'depression': 'डिप्रेसन (Depression)',
    'relationship': 'सम्बन्ध समस्या (Relationship Issues)',
    'family': 'परिवार समस्या (Family Problems)',
    'academic': 'पढाइको चाप (Academic Pressure)',
    'work': 'जागिरको तनाव (Work Stress)',
    'suicidal': 'आत्महत्याको विचार (Suicidal Thoughts)',
    'other': 'अन्य (Other)',
  };

  // Mood Triggers
  static const Map<String, String> moodTriggers = {
    'family': 'परिवार (Family)',
    'work_study': 'काम/पढाइ (Work/Study)',
    'health': 'स्वास्थ्य (Health)',
    'money': 'पैसा (Money)',
    'relationship': 'सम्बन्ध (Relationships)',
    'loneliness': 'एक्लोपन (Loneliness)',
    'fatigue': 'थकान (Fatigue)',
  };

  // Meditation Categories
  static const Map<String, String> meditationCategories = {
    'breathing': 'सास फेर्ने अभ्यास (Breathing Exercises)',
    'meditation': 'ध्यान (Meditation)',
    'yoga_nidra': 'योग निद्रा (Yoga Nidra)',
    'mantras': 'बौद्ध मन्त्र (Buddhist Mantras)',
    'body_scan': 'शरीर स्क्यान (Body Scan)',
    'affirmations': 'सकारात्मक सोच (Positive Affirmations)',
  };

  // Community Groups
  static const Map<String, String> communityGroups = {
    'stress_management': 'तनाव व्यवस्थापन (Stress Management)',
    'depression_support': 'डिप्रेसन सपोर्ट (Depression Support)',
    'relationship_issues': 'सम्बन्ध समस्या (Relationship Issues)',
    'exam_stress': 'परीक्षा तनाव (Exam Stress)',
    'living_abroad': 'विदेश बसेका (Living Abroad)',
    'marital_issues': 'विवाह समस्या (Marital Issues)',
    'new_mothers': 'नयाँ आमाहरु (New Mothers)',
    'suicide_survivors': 'आत्महत्या बचेका (Suicide Survivors)',
    'addiction_recovery': 'लत छुटाउने (Addiction Recovery)',
  };

  // Crisis Keywords (for detection in chat)
  static const List<String> crisisKeywordsNepali = [
    'आत्महत्या',
    'मर्न चाहन्छु',
    'मर्ने सोच',
    'आफैलाई मार्ने',
    'बाँच्न मन छैन',
    'जीवन समाप्त',
    'आत्मघाती',
  ];

  static const List<String> crisisKeywordsEnglish = [
    'suicide',
    'kill myself',
    'want to die',
    'end my life',
    'self harm',
    'hurt myself',
    'no reason to live',
  ];

  // Agora Config
  static const String agoraAppId = 'YOUR_AGORA_APP_ID'; // Replace with actual

  // Claude API Config
  static const String claudeApiUrl = 'https://api.anthropic.com/v1/messages';
  static const String claudeModel = 'claude-sonnet-4-20250514';

  // Khalti Payment Config
  static const String khaltiPublicKey = 'YOUR_KHALTI_PUBLIC_KEY'; // Replace

  // Session Types
  static const String sessionTypeVideo = 'video';
  static const String sessionTypeAudio = 'audio';
  static const String sessionTypeChat = 'chat';

  // Session Status
  static const String sessionStatusScheduled = 'scheduled';
  static const String sessionStatusInProgress = 'in_progress';
  static const String sessionStatusCompleted = 'completed';
  static const String sessionStatusCancelled = 'cancelled';
  static const String sessionStatusNoShow = 'no_show';

  // Notification Types
  static const String notifTypeMoodReminder = 'mood_reminder';
  static const String notifTypeSessionReminder = 'session_reminder';
  static const String notifTypeCommunityReply = 'community_reply';
  static const String notifTypeTherapistMessage = 'therapist_message';
  static const String notifTypeSubscriptionExpiry = 'subscription_expiry';

  // Local Storage Keys
  static const String keyUserLanguage = 'user_language';
  static const String keyThemeMode = 'theme_mode';
  static const String keyMoodReminderTime = 'mood_reminder_time';
  static const String keyLastMoodCheckIn = 'last_mood_check_in';
  static const String keyStreakCount = 'streak_count';
  static const String keyOnboardingCompleted = 'onboarding_completed';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxChatMessageLength = 500;
  static const int maxCommunityPostLength = 1000;

  // Pagination
  static const int postsPerPage = 20;
  static const int messagesPerPage = 50;

  // File Size Limits (in bytes)
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxAudioSize = 50 * 1024 * 1024; // 50MB
  static const int maxVideoSize = 100 * 1024 * 1024; // 100MB

  // URLs
  static const String privacyPolicyUrl = 'https://mansaathi.com/privacy';
  static const String termsOfServiceUrl = 'https://mansaathi.com/terms';
  static const String supportEmail = 'support@mansaathi.com';
  static const String feedbackUrl = 'https://mansaathi.com/feedback';

  // Educational Content Categories
  static const List<String> educationalCategories = [
    'मानसिक स्वास्थ्य बुझ्ने',
    'डिप्रेसन',
    'तनाव व्यवस्थापन',
    'परिवार सहयोग',
    'बाल मानसिक स्वास्थ्य',
  ];

  // Therapist Specializations
  static const List<String> therapistSpecializations = [
    'तनाव र चिन्ता (Stress & Anxiety)',
    'डिप्रेसन (Depression)',
    'ट्राउमा (Trauma)',
    'सम्बन्ध परामर्श (Relationship Counseling)',
    'परिवार थेरापी (Family Therapy)',
    'बाल मनोविज्ञान (Child Psychology)',
    'लत उपचार (Addiction Treatment)',
    'खाने विकार (Eating Disorders)',
    'OCD',
    'PTSD',
  ];

  // Daily Quotes (Nepali)
  static const List<String> dailyQuotesNepali = [
    'हरेक दिन नयाँ सुरुवात हो। आज राम्रो हुनेछ।',
    'तपाईं एक्लै हुनुहुन्न। हामी सँगै छौं।',
    'सानो कदम पनि प्रगति हो।',
    'आफूलाई माया गर्नुहोस्। तपाईं यसको लायक हुनुहुन्छ।',
    'कठिन समय पनि बित्छ। धैर्य गर्नुहोस्।',
    'तपाईंको भावना महत्वपूर्ण छ।',
    'मद्दत माग्नु बलियोपनको चिन्ह हो।',
    'एक पटकमा एक दिन। तपाईं गर्न सक्नुहुन्छ।',
  ];
}
