import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  String get(String key) {
    final translations = _getTranslations(locale.languageCode);
    return translations[key] ?? _getTranslations('en')[key] ?? key;
  }

  // ─── Dashboard / Common ────────────────────────────────────────────────────
  String get appName => get('appName');
  String get welcomeBack => get('welcomeBack');
  String get howCanWeHelp => get('howCanWeHelp');
  String get selectLanguage => get('selectLanguage');
  String get notifications => get('notifications');
  String get profile => get('profile');
  String get settings => get('settings');
  String get helpSupport => get('helpSupport');
  String get editProfile => get('editProfile');
  String get logOut => get('logOut');
  String get save => get('save');
  String get cancel => get('cancel');
  String get saveChanges => get('saveChanges');
  String get gender => get('gender');
  String get male => get('male');
  String get female => get('female');
  String get fullName => get('fullName');
  String get you => get('you');

  // ─── Login / Auth ───────────────────────────────────────────────────────────
  String get welcomeBackExclaim => get('welcomeBackExclaim');
  String get signInToContinue => get('signInToContinue');
  String get emailAddress => get('emailAddress');
  String get password => get('password');
  String get forgotPassword => get('forgotPassword');
  String get signIn => get('signIn');
  String get dontHaveAccount => get('dontHaveAccount');
  String get signUp => get('signUp');
  String get orContinueWith => get('orContinueWith');
  String get loginAsAdmin => get('loginAsAdmin');

  // ─── Sign Up ────────────────────────────────────────────────────────────────
  String get createAccount => get('createAccount');
  String get joinUs => get('joinUs');
  String get yourName => get('yourName');
  String get confirmPassword => get('confirmPassword');
  String get alreadyHaveAccount => get('alreadyHaveAccount');
  String get selectGender => get('selectGender');

  // ─── Dashboard Actions ──────────────────────────────────────────────────────
  String get requestHelp => get('requestHelp');
  String get requestHelpSub => get('requestHelpSub');
  String get findVolunteers => get('findVolunteers');
  String get findVolunteersSub => get('findVolunteersSub');
  String get myTasks => get('myTasks');
  String get myTasksSub => get('myTasksSub');
  String get emergencyAssistance => get('emergencyAssistance');

  // ─── Navigation ─────────────────────────────────────────────────────────────
  String get home => get('home');
  String get schedule => get('schedule');
  String get chat => get('chat');

  // ─── Volunteer Dashboard ─────────────────────────────────────────────────────
  String get upcomingVisits => get('upcomingVisits');
  String get tasksCompleted => get('tasksCompleted');
  String get totalHours => get('totalHours');
  String get quickActions => get('quickActions');
  String get viewTasks => get('viewTasks');
  String get mySchedule => get('mySchedule');
  String get messages => get('messages');
  String get noNotifications => get('noNotifications');

  String get hours => get('hours');
  String get goal20ThisMonth => get('goal20ThisMonth');
  String get seniors => get('seniors');
  String get impactedHearts => get('impactedHearts');
  String get availableTask => get('availableTask');
  String get findNewWaysToHelp => get('findNewWaysToHelp');
  String get myTask => get('myTask');
  String get viewManageSchedule => get('viewManageSchedule');
  String get nextAppointment => get('nextAppointment');
  String get groceryHelp => get('groceryHelp');
  String get today => get('today');

  // ─── Profile ────────────────────────────────────────────────────────────────
  String get verifiedMember => get('verifiedMember');
  String get taskBoard => get('taskBoard');
  String get helpRequested => get('helpRequested');
  String get acceptTask => get('acceptTask');
  String get viewDetails => get('viewDetails');
  String get availableCommunityTasks => get('availableCommunityTasks');
  String get noNewRequestsAvailable => get('noNewRequestsAvailable');
  String get youHaventAcceptedAnyTasksYet =>
      get('youHaventAcceptedAnyTasksYet');
  String get checkYourTasks => get('checkYourTasks');
  String get myTaskList => get('myTaskList');
  String get online => get('online');
  String get offline => get('offline');
  String get currentRequests => get('currentRequests');
  String get activePastRequests => get('activePastRequests');
  String get medicineReminder => get('medicineReminder');
  String get dontMissPills => get('dontMissPills');
  String get sendingSOS => get('sendingSOS');
  String get sosSentMessage => get('sosSentMessage');
  String get errorSendingSOS => get('errorSendingSOS');
  String get leaderboard => get('leaderboard');
  String get topVolunteers => get('topVolunteers');
  String get pts => get('pts');
  String get nearby => get('nearby');
  String get global => get('global');
  String get yourRank => get('yourRank');
  String get silverBadge => get('silverBadge');
  String get goldBadge => get('goldBadge');
  String get bronzeBadge => get('bronzeBadge');
  String get steady => get('steady');
  String get requests => get('requests');
  String get sessions => get('sessions');
  String get shareRank => get('shareRank');
  String get imMakingADifference => get('imMakingADifference');
  String get shareYourAchievement => get('shareYourAchievement');
  String get downloadImage => get('downloadImage');
  String get instagram => get('instagram');
  String get whatsapp => get('whatsapp');
  String get facebook => get('facebook');
  String get twitter => get('twitter');

  static Map<String, String> _getTranslations(String code) {
    switch (code) {
      case 'ml':
        return _malayalam;
      case 'ta':
        return _tamil;
      case 'hi':
        return _hindi;
      default:
        return _english;
    }
  }

  // ─── ENGLISH ─────────────────────────────────────────────────────────────────
  static const Map<String, String> _english = {
    'appName': 'Senior Care Connect',
    'welcomeBack': 'Welcome back',
    'howCanWeHelp': 'How we can help today?',
    'selectLanguage': 'Select Language',
    'notifications': 'Notifications',
    'profile': 'Profile ',
    'settings': 'Settings',
    'helpSupport': 'Help and Support',
    'editProfile': 'Edit Profile',
    'logOut': 'Log Out',
    'save': 'Save',
    'cancel': 'Cancel',
    'saveChanges': 'Save Changes',
    'gender': 'Gender',
    'male': 'Male',
    'female': 'Female',
    'fullName': 'Full Name',
    'you': 'You',

    'welcomeBackExclaim': 'Welcome Back!',
    'signInToContinue': 'Sign in to continue',
    'emailAddress': 'Email Address',
    'password': 'Password',
    'forgotPassword': 'Forgot Password?',
    'signIn': 'Sign In',
    'dontHaveAccount': "Don't have an account? ",
    'signUp': 'Sign Up',
    'orContinueWith': 'Or continue with',
    'loginAsAdmin': 'Login as Admin',

    'createAccount': 'Create Account',
    'joinUs': 'Join us to find care or provide care',
    'yourName': 'Full Name',
    'confirmPassword': 'Confirm Password',
    'alreadyHaveAccount': 'Already have an account? ',
    'selectGender': 'Select Gender',

    'requestHelp': 'Request Help',
    'requestHelpSub': 'Get assistance from volunteers',
    'findVolunteers': 'Find Volunteers',
    'findVolunteersSub': 'Browse available volunteers',
    'myTasks': 'My Tasks',
    'myTasksSub': 'View your scheduled tasks',
    'emergencyAssistance': 'EMERGENCY ASSISTANCE',

    'home': 'Home',
    'schedule': 'Schedule',
    'chat': 'Chat',

    'upcomingVisits': 'Upcoming Visits',
    'tasksCompleted': 'Tasks Completed',
    'totalHours': 'Total Hours',
    'quickActions': 'Quick Actions',
    'viewTasks': 'View Tasks',
    'mySchedule': 'My Schedule',
    'messages': 'Messages',
    'noNotifications': 'No notifications yet',

    'hours': 'Hours',
    'goal20ThisMonth': 'Goal: 20 this month',
    'seniors': 'Seniors',
    'impactedHearts': 'Impacted hearts',
    'availableTask': 'Available task',
    'findNewWaysToHelp': 'Find new ways to help today',
    'myTask': 'My task',
    'viewManageSchedule': 'View and manage your schedule',
    'nextAppointment': 'Next Appointment',
    'groceryHelp': 'Grocery Help',
    'today': 'Today',

    'verifiedMember': 'Verified member since 2026',
    'taskBoard': 'Task Board',
    'helpRequested': 'Help Requested',
    'acceptTask': 'Accept Task',
    'viewDetails': 'View Details',
    'availableCommunityTasks': 'Available community tasks',
    'noNewRequestsAvailable': 'No new requests available',
    'youHaventAcceptedAnyTasksYet': 'You haven\'t accepted any tasks yet',
    'checkYourTasks': 'Please log in to see your tasks',
    'myTaskList': 'My Task List',
    'online': 'Online',
    'offline': 'Offline',
    'currentRequests': 'Current Requests',
    'activePastRequests': 'Active and past help requests',
    'medicineReminder': 'Medicine Reminder',
    'dontMissPills': 'Don\'t miss your pills',
    'sendingSOS': 'Sending SOS...',
    'sosSentMessage': 'SOS Alert Sent! Nearby volunteers notified immediately.',
    'errorSendingSOS': 'Error sending SOS',
    'leaderboard': 'Leaderboard',
    'topVolunteers': 'TOP VOLUNTEERS',
    'pts': 'pts',
    'nearby': 'Nearby',
    'global': 'Global',
    'yourRank': 'YOUR RANK',
    'silverBadge': 'Silver Badge',
    'goldBadge': 'Gold Badge',
    'bronzeBadge': 'Bronze Badge',
    'steady': 'Steady',
    'requests': 'Requests',
    'sessions': 'sessions',
    'shareRank': 'Share Rank',
    'imMakingADifference': 'I\'m making a difference!',
    'shareYourAchievement': 'Share your achievement',
    'downloadImage': 'Download Image',
    'instagram': 'Instagram',
    'whatsapp': 'WhatsApp',
    'facebook': 'Facebook',
    'twitter': 'Twitter',
  };

  // ─── MALAYALAM ────────────────────────────────────────────────────────────────
  static const Map<String, String> _malayalam = {
    'appName': 'സീനിയർ കെയർ കണക്ട്',
    'welcomeBack': 'തിരികെ സ്വാഗതം',
    'howCanWeHelp': 'ഇന്ന് ഞങ്ങൾ എങ്ങനെ സഹായിക്കാം?',
    'selectLanguage': 'ഭാഷ തിരഞ്ഞെടുക്കുക',
    'notifications': 'അറിയിപ്പുകൾ',
    'profile': 'പ്രൊഫൈൽ ',
    'settings': 'ക്രമീകരണങ്ങൾ',
    'helpSupport': 'സഹായവും പിന്തുണയും',
    'editProfile': 'പ്രൊഫൈൽ എഡിറ്റ് ചെയ്യുക',
    'logOut': 'ലോഗ് ഔട്ട്',
    'save': 'സംരക്ഷിക്കുക',
    'cancel': 'റദ്ദ് ചെയ്യുക',
    'saveChanges': 'മാറ്റങ്ങൾ സംരക്ഷിക്കുക',
    'gender': 'ലിംഗം',
    'male': 'പുരുഷൻ',
    'female': 'സ്ത്രീ',
    'fullName': 'പൂർണ്ണ നാമം',
    'you': 'നിങ്ങൾ',

    'welcomeBackExclaim': 'തിരികെ സ്വാഗതം!',
    'signInToContinue': 'തുടരാൻ സൈൻ ഇൻ ചെയ്യുക',
    'emailAddress': 'ഇമെയിൽ വിലാസം',
    'password': 'പാസ്‌വേഡ്',
    'forgotPassword': 'പാസ്‌വേഡ് മറന്നോ?',
    'signIn': 'സൈൻ ഇൻ',
    'dontHaveAccount': 'അക്കൗണ്ട് ഇല്ലേ? ',
    'signUp': 'സൈൻ അപ്',
    'orContinueWith': 'അല്ലെങ്കിൽ ഇതിലൂടെ തുടരുക',
    'loginAsAdmin': 'അഡ്മിൻ ആയി ലോഗിൻ',

    'createAccount': 'അക്കൗണ്ട് സൃഷ്ടിക്കുക',
    'joinUs': 'സേവനം നൽകാനോ സ്വീകരിക്കാനോ ഞങ്ങളോടൊപ്പം ചേരൂ',
    'yourName': 'പൂർണ്ണ നാമം',
    'confirmPassword': 'പാസ്‌വേഡ് സ്ഥിരീകരിക്കുക',
    'alreadyHaveAccount': 'ഇതിനകം ഒരു അക്കൗണ്ട് ഉണ്ടോ? ',
    'selectGender': 'ലിംഗം തിരഞ്ഞെടുക്കുക',

    'requestHelp': 'സഹായം അഭ്യർത്ഥിക്കുക',
    'requestHelpSub': 'സ്വയംസേവകരിൽ നിന്ന് സഹായം നേടുക',
    'findVolunteers': 'സ്വയംസേവകരെ കണ്ടെത്തുക',
    'findVolunteersSub': 'ലഭ്യമായ സ്വയംസേവകരെ ബ്രൗസ് ചെയ്യുക',
    'myTasks': 'എന്റെ ചുമതലകൾ',
    'myTasksSub': 'നിങ്ങളുടെ ചുമതലകൾ കാണുക',
    'emergencyAssistance': 'അടിയന്തര സഹായം',

    'home': 'ഹോം',
    'schedule': 'ഷെഡ്യൂൾ',
    'chat': 'ചാറ്റ്',

    'upcomingVisits': 'വരാനിരിക്കുന്ന സന്ദർശനങ്ങൾ',
    'tasksCompleted': 'പൂർത്തിയായ ചുമതലകൾ',
    'totalHours': 'മൊത്തം മണിക്കൂർ',
    'quickActions': 'ദ്രുത പ്രവർത്തനങ്ങൾ',
    'viewTasks': 'ചുമതലകൾ കാണുക',
    'mySchedule': 'എന്റെ ഷെഡ്യൂൾ',
    'messages': 'സന്ദേശങ്ങൾ',
    'noNotifications': 'ഇതുവരെ അറിയിപ്പുകൾ ഒന്നുമില്ല',

    'hours': 'മണിക്കൂറുകൾ',
    'goal20ThisMonth': 'ലക്ഷ്യം: ഈ മാസം 20',
    'seniors': 'മുതിർന്നവർ',
    'impactedHearts': 'സ്വാധീനിച്ച ഹൃദയങ്ങൾ',
    'availableTask': 'ലഭ്യമായ ചുമതല',
    'findNewWaysToHelp': 'ഇന്ന് സഹായിക്കാൻ പുതിയ വഴികൾ കണ്ടെത്തുക',
    'myTask': 'എന്റെ ചുമതല',
    'viewManageSchedule': 'നിങ്ങളുടെ ഷെഡ്യൂൾ കാണുക, നിയന്ത്രിക്കുക',
    'nextAppointment': 'അടുത്ത കൂടിക്കാഴ്ച',
    'groceryHelp': 'പലചരക്ക് സഹായം',
    'today': 'ഇന്ന്',

    'verifiedMember': '2026 മുതൽ സ്ഥിരീകരിക്കപ്പെട്ട അംഗം',
    'taskBoard': 'ടാസ്ക് ബോർഡ്',
    'helpRequested': 'സഹായം ആവശ്യപ്പെട്ടവ',
    'acceptTask': 'ഏറ്റെടുക്കുക',
    'viewDetails': 'വിശദാംശങ്ങൾ',
    'availableCommunityTasks': 'ലഭ്യമായ സാമൂഹിക സേവനങ്ങൾ',
    'noNewRequestsAvailable': 'പുതിയ സേവനങ്ങൾ ലഭ്യമല്ല',
    'youHaventAcceptedAnyTasksYet':
        'നിങ്ങൾ ഇതുവരെ ജോലികളൊന്നും ഏറ്റെടുത്തിട്ടില്ല',
    'checkYourTasks': 'നിങ്ങളുടെ ടാസ്ക്കുകൾ കാണുന്നതിന് ലോഗിൻ ചെയ്യുക',
    'myTaskList': 'എന്റെ ചുമതലകൾ',
    'online': 'ഓൺലൈൻ',
    'offline': 'ഓഫ്‌ലൈൻ',
    'currentRequests': 'നിലവിലെ അഭ്യർത്ഥനകൾ',
    'activePastRequests': 'സജീവവും കഴിഞ്ഞതുമായ സഹായ അഭ്യർത്ഥനകൾ',
    'medicineReminder': 'മരുന്ന് ഓർമ്മപ്പെടുത്തൽ',
    'dontMissPills': 'നിങ്ങളുടെ ഗുളികകൾ മറക്കരുത്',
    'sendingSOS': 'SOS അയക്കുന്നു...',
    'sosSentMessage':
        'SOS അലേർട്ട് അയച്ചു! അടുത്തുള്ള സന്നദ്ധപ്രവർത്തകരെ ഉടൻ അറിയിച്ചു.',
    'errorSendingSOS': 'SOS അയക്കുന്നതിൽ പരാജയപ്പെട്ടു',
    'leaderboard': 'ലീഡർബോർഡ്',
    'topVolunteers': 'മികച്ച സന്നദ്ധപ്രവർത്തകർ',
    'pts': 'pts',
    'nearby': 'അടുത്തുള്ളവർ',
    'global': 'ആഗോളതലം',
    'yourRank': 'നിങ്ങളുടെ റാങ്ക്',
    'silverBadge': 'സിൽവർ ബാഡ്‌ജ്‌',
    'goldBadge': 'ഗോൾഡ് ബാഡ്‌ജ്‌',
    'bronzeBadge': 'ബ്രോൺസ് ബാഡ്‌ജ്‌',
    'steady': 'മാറ്റമില്ല',
    'requests': 'അഭ്യർത്ഥനകൾ',
    'sessions': 'സെഷനുകൾ',
    'shareRank': 'റാങ്ക് പങ്കിടുക',
    'imMakingADifference': 'ഞാൻ ഒരു മാറ്റം വരുത്തുന്നു!',
    'shareYourAchievement': 'നിങ്ങളുടെ നേട്ടം പങ്കിടുക',
    'downloadImage': 'ചിത്രം ഡൗൺലോഡ് ചെയ്യുക',
    'instagram': 'ഇൻസ്റ്റാഗ്രാം',
    'whatsapp': 'വാട്ട്‌സ്ആപ്പ്',
    'facebook': 'ഫേസ്ബുക്ക്',
    'twitter': 'ട്വിറ്റർ',
  };

  // ─── TAMIL ────────────────────────────────────────────────────────────────────
  static const Map<String, String> _tamil = {
    'appName': 'சீனியர் கேர் கனெக்ட்',
    'welcomeBack': 'மீண்டும் வரவேற்கிறோம்',
    'howCanWeHelp': 'இன்று நாங்கள் எவ்வாறு உதவலாம்?',
    'selectLanguage': 'மொழியைத் தேர்ந்தெடுக்கவும்',
    'notifications': 'அறிவிப்புகள்',
    'profile': 'சுயவிவரம் & அமைப்புகள்',
    'settings': 'அமைப்புகள்',
    'helpSupport': 'உதவி மற்றும் ஆதரவு',
    'editProfile': 'சுயவிவரத்தைத் திருத்து',
    'logOut': 'வெளியேறு',
    'save': 'சேமி',
    'cancel': 'ரத்து செய்',
    'saveChanges': 'மாற்றங்களைச் சேமி',
    'gender': 'பாலினம்',
    'male': 'ஆண்',
    'female': 'பெண்',
    'fullName': 'முழு பெயர்',
    'you': 'நீங்கள்',

    'welcomeBackExclaim': 'மீண்டும் வரவேற்கிறோம்!',
    'signInToContinue': 'தொடர உள்நுழையவும்',
    'emailAddress': 'மின்னஞ்சல் முகவரி',
    'password': 'கடவுச்சொல்',
    'forgotPassword': 'கடவுச்சொல் மறந்தீர்களா?',
    'signIn': 'உள்நுழை',
    'dontHaveAccount': 'கணக்கு இல்லையா? ',
    'signUp': 'பதிவு செய்',
    'orContinueWith': 'அல்லது இதன் மூலம் தொடரவும்',
    'loginAsAdmin': 'நிர்வாகியாக உள்நுழை',

    'createAccount': 'கணக்கை உருவாக்கு',
    'joinUs': 'சேவை வழங்க அல்லது பெற எங்களுடன் சேரவும்',
    'yourName': 'முழு பெயர்',
    'confirmPassword': 'கடவுச்சொல்லை உறுதிப்படுத்து',
    'alreadyHaveAccount': 'ஏற்கனவே கணக்கு உள்ளதா? ',
    'selectGender': 'பாலினத்தைத் தேர்ந்தெடுக்கவும்',

    'requestHelp': 'உதவி கோரு',
    'requestHelpSub': 'தன்னார்வலர்களிடம் உதவி பெறவும்',
    'findVolunteers': 'தன்னார்வலர்களை கண்டறி',
    'findVolunteersSub': 'கிடைக்கக்கூடிய தன்னார்வலர்களை பார்வையிடவும்',
    'myTasks': 'என் பணிகள்',
    'myTasksSub': 'உங்கள் திட்டமிடப்பட்ட பணிகளை பார்க்கவும்',
    'emergencyAssistance': 'அவசர உதவி',

    'home': 'முகப்பு',
    'schedule': 'அட்டவணை',
    'chat': 'அரட்டை',

    'upcomingVisits': 'வரவிருக்கும் வருகைகள்',
    'tasksCompleted': 'முடிந்த பணிகள்',
    'totalHours': 'மொத்த மணி நேரம்',
    'quickActions': 'விரைவு செயல்கள்',
    'viewTasks': 'பணிகளைக் காண்க',
    'mySchedule': 'என் அட்டவணை',
    'messages': 'செய்திகள்',
    'noNotifications': 'இதுவரை அறிவிப்புகள் இல்லை',

    'hours': 'மணிநேரங்கள்',
    'goal20ThisMonth': 'இலக்கு: இந்த மாதம் 20',
    'seniors': 'முதியோர்கள்',
    'impactedHearts': 'பாதிக்கப்பட்ட இதயங்கள்',
    'availableTask': 'கிடைக்கும் பணி',
    'findNewWaysToHelp': 'உதவ புதிய வழிகளைக் கண்டறியவும்',
    'myTask': 'என் பணி',
    'viewManageSchedule': 'உங்கள் அட்டவணையைப் பார்த்து நிர்வகிக்கவும்',
    'nextAppointment': 'அடுத்த சந்திப்பு',
    'groceryHelp': 'மளிகை உதவி',
    'today': 'இன்று',

    'verifiedMember': '2026 முதல் சரிபார்க்கப்பட்ட உறுப்பினர்',
    'taskBoard': 'பணி வாரியம்',
    'helpRequested': 'உதவி கோரப்பட்டது',
    'acceptTask': 'ஏற்றுக்கொள்',
    'viewDetails': 'விவரங்களைக் காண்க',
    'availableCommunityTasks': 'கிடைக்கக்கூடிய சமூகப் பணிகள்',
    'noNewRequestsAvailable': 'புதிய கோரிக்கைகள் எதுவும் இல்லை',
    'youHaventAcceptedAnyTasksYet':
        'நீங்கள் இன்னும் எந்தப் பணிகளையும் ஏற்கவில்லை',
    'checkYourTasks': 'உங்கள் பணிகளைக் காண உள்நுழையவும்',
    'myTaskList': 'எனது பணிப் பட்டியல்',
    'online': 'ஆன்லைன்',
    'offline': 'ஆஃப்லைன்',
    'currentRequests': 'தற்போதைய கோரிக்கைகள்',
    'activePastRequests': 'செயலில் உள்ள மற்றும் கடந்தகால உதவி கோரிக்கைகள்',
    'medicineReminder': 'மருந்து நினைவூட்டல்',
    'dontMissPills': 'உங்கள் மாத்திரைகளைத் தவறவிடாதீர்கள்',
    'sendingSOS': 'SOS அனுப்பப்படுகிறது...',
    'sosSentMessage':
        'SOS எச்சரிக்கை அனுப்பப்பட்டது! அருகில் உள்ள தன்னார்வலர்களுக்கு உடனடியாக தகவல் தெரிவிக்கப்பட்டது.',
    'errorSendingSOS': 'SOS அனுப்புவதில் பிழை',
    'leaderboard': 'தலைமைப் பலகை',
    'topVolunteers': 'சிறந்த தன்னார்வலர்கள்',
    'pts': 'pts',
    'nearby': 'அருகிலுள்ள',
    'global': 'உலகளாவிய',
    'yourRank': 'உங்கள் தரம்',
    'silverBadge': 'வெள்ளி பதக்கம்',
    'goldBadge': 'தங்க பதக்கம்',
    'bronzeBadge': 'வெண்கல பதக்கம்',
    'steady': 'மாற்றமில்லை',
    'requests': 'கோரிக்கைகள்',
    'sessions': 'அமர்வுகள்',
    'shareRank': 'தரத்தைப் பகிரவும்',
    'imMakingADifference': 'நான் ஒரு மாற்றத்தை ஏற்படுத்துகிறேன்!',
    'shareYourAchievement': 'உங்கள் சாதனையைப் பகிரவும்',
    'downloadImage': 'படத்தைப் பதிவிறக்கவும்',
    'instagram': 'இன்ஸ்டாகிராம்',
    'whatsapp': 'வாட்ஸ்அப்',
    'facebook': 'பேஸ்புக்',
    'twitter': 'ட்விட்டர்',
  };

  // ─── HINDI ────────────────────────────────────────────────────────────────────
  static const Map<String, String> _hindi = {
    'appName': 'सीनियर केयर कनेक्ट',
    'welcomeBack': 'वापसी पर स्वागत है',
    'howCanWeHelp': 'आज हम कैसे मदद कर सकते हैं?',
    'selectLanguage': 'भाषा चुनें',
    'notifications': 'सूचनाएं',
    'profile': 'प्रोफ़ाइल और सेटिंग्स',
    'settings': 'सेटिंग्स',
    'helpSupport': 'सहायता और समर्थन',
    'editProfile': 'प्रोफ़ाइल संपादित करें',
    'logOut': 'लॉग आउट',
    'save': 'सहेजें',
    'cancel': 'रद्द करें',
    'saveChanges': 'परिवर्तन सहेजें',
    'gender': 'लिंग',
    'male': 'पुरुष',
    'female': 'महिला',
    'fullName': 'पूरा नाम',
    'you': 'आप',

    'welcomeBackExclaim': 'वापसी पर स्वागत है!',
    'signInToContinue': 'जारी रखने के लिए साइन इन करें',
    'emailAddress': 'ईमेल पता',
    'password': 'पासवर्ड',
    'forgotPassword': 'पासवर्ड भूल गए?',
    'signIn': 'साइन इन',
    'dontHaveAccount': 'खाता नहीं है? ',
    'signUp': 'साइन अप',
    'orContinueWith': 'या इससे जारी रखें',
    'loginAsAdmin': 'एडमिन के रूप में लॉगिन',

    'createAccount': 'खाता बनाएं',
    'joinUs': 'देखभाल पाने या देने के लिए हमसे जुड़ें',
    'yourName': 'पूरा नाम',
    'confirmPassword': 'पासवर्ड की पुष्टि करें',
    'alreadyHaveAccount': 'पहले से खाता है? ',
    'selectGender': 'लिंग चुनें',

    'requestHelp': 'सहायता अनुरोध करें',
    'requestHelpSub': 'स्वयंसेवकों से सहायता प्राप्त करें',
    'findVolunteers': 'स्वयंसेवक खोजें',
    'findVolunteersSub': 'उपलब्ध स्वयंसेवकों को देखें',
    'myTasks': 'मेरे कार्य',
    'myTasksSub': 'अपने निर्धारित कार्य देखें',
    'emergencyAssistance': 'आपातकालीन सहायता',

    'home': 'होम',
    'schedule': 'शेड्यूल',
    'chat': 'चैट',

    'upcomingVisits': 'आगामी दौरे',
    'tasksCompleted': 'पूर्ण किए गए कार्य',
    'totalHours': 'कुल घंटे',
    'quickActions': 'त्वरित क्रियाएं',
    'viewTasks': 'कार्य देखें',
    'mySchedule': 'मेरा शेड्यूल',
    'messages': 'संदेश',
    'noNotifications': 'अभी तक कोई सूचना नहीं',

    'hours': 'घंटे',
    'goal20ThisMonth': 'लक्ष्य: इस महीने 20',
    'seniors': 'बुज़ुर्ग',
    'impactedHearts': 'प्रभावित हृदय',
    'availableTask': 'उपलब्ध कार्य',
    'findNewWaysToHelp': 'आज मदद करने के नए तरीके खोजें',
    'myTask': 'मेरा कार्य',
    'viewManageSchedule': 'अपना शेड्यूल देखें और प्रबंधित करें',
    'nextAppointment': 'अगली मुलाकात',
    'groceryHelp': 'किराने की मदद',
    'today': 'आज',

    'verifiedMember': '2026 से सत्यापित सदस्य',
    'taskBoard': 'कार्य बोर्ड',
    'helpRequested': 'सहायता अनुरोधित',
    'acceptTask': 'स्वीकार करें',
    'viewDetails': 'विवरण देखें',
    'availableCommunityTasks': 'उपलब्ध सामुदायिक कार्य',
    'noNewRequestsAvailable': 'कोई नया अनुरोध उपलब्ध नहीं है',
    'youHaventAcceptedAnyTasksYet':
        'आपने अभी तक कोई कार्य स्वीकार नहीं किया है',
    'checkYourTasks': 'अपने कार्य देखने के लिए कृपया लॉगिन करें',
    'myTaskList': 'मेरी कार्य सूची',
    'online': 'ऑनलाइन',
    'offline': 'ऑफलाइन',
    'currentRequests': 'वर्तमान अनुरोध',
    'activePastRequests': 'सक्रिय और पिछले सहायता अनुरोध',
    'medicineReminder': 'दवा अनुस्मारक',
    'dontMissPills': 'अपनी गोलियां लेना न भूलें',
    'sendingSOS': 'SOS भेज रहा है...',
    'sosSentMessage':
        'SOS अलर्ट भेजा गया! पास के स्वयंसेवकों को तुरंत सूचित किया गया।',
    'errorSendingSOS': 'SOS भेजने में त्रुटि',
    'leaderboard': 'लीडरबोर्ड',
    'topVolunteers': 'शीर्ष स्वयंसेवक',
    'pts': 'अंक',
    'nearby': 'निकटतम',
    'global': 'वैश्विक',
    'yourRank': 'आपकी रैंक',
    'silverBadge': 'रजत पदक',
    'goldBadge': 'स्वर्ण पदक',
    'bronzeBadge': 'कांस्य पदक',
    'steady': 'स्थिर',
    'requests': 'अनुरोध',
    'sessions': 'सत्र',
    'shareRank': 'रैंक साझा करें',
    'imMakingADifference': 'मैं बदलाव ला रहा हूँ!',
    'shareYourAchievement': 'अपनी उपलब्धि साझा करें',
    'downloadImage': 'छवि डाउनलोड करें',
    'instagram': 'इंस्टाग्राम',
    'whatsapp': 'व्हाट्सएप',
    'facebook': 'फेसबुक',
    'twitter': 'ट्विटर',
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'ml', 'ta', 'hi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
