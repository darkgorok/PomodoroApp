import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('en'),
    Locale('ru'),
    Locale('uk'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String get languageName {
    switch (locale.languageCode) {
      case 'ru':
        return 'Русский';
      case 'uk':
        return 'Українська';
      default:
        return 'English';
    }
  }

  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'app_title': 'Focus Timer',
      'home_title': 'Start Now',
      'today_focused': 'Today focused',
      'minutes_short': 'min',
      'sessions_completed': 'Sessions completed: {count}',
      'start_now': 'Start Now',
      'start_now_subtitle': 'Anti-procrastination',
      'pomodoro': 'Pomodoro',
      'pomodoro_subtitle': 'Focus + break',
      'customize': 'Customize',
      'customize_premium': 'Customize (Premium)',
      'customize_locked_subtitle': 'Presets & white noise',
      'small_rule': 'Small rule',
      'small_rule_text': "If you can't start, do 5 minutes. Starting is the win.",
      'focus': 'Focus',
      'break': 'Break',
      'ready_when': 'Ready when you are.',
      'start': 'Start',
      'end': 'End',
      'pause': 'Pause',
      'nice_again': 'Nice. Want to go again?',
      'back_home': 'Back Home',
      'start_again': 'Start Again',
      'upgrade': 'Upgrade',
      'unlock_deep_focus': 'Unlock Deep Focus',
      'upgrade_subtitle': 'Build a routine. Track progress.',
      'custom_timers': 'Custom timers',
      'custom_timers_subtitle': 'Set your own intervals',
      'stats_streaks': 'Stats & streaks',
      'stats_streaks_subtitle': 'See your progress',
      'white_noise': 'White noise',
      'white_noise_subtitle': 'Focus with sound',
      'smart_reminders': 'Smart reminders',
      'smart_reminders_subtitle': 'Stay on track',
      'weekly': 'Weekly',
      'yearly': 'Yearly',
      'price_weekly': '€2.99 / week',
      'price_yearly': '€29.99 / year',
      'most_popular': 'Most popular',
      'best_value': 'Best value',
      'continue': 'Continue',
      'not_now': 'Not now',
      'paywall_title': 'Unlock Your Full Potential',
      'paywall_subtitle': 'Get instant access to all premium features!',
      'start_free_trial': 'Start Free Trial',
      'trial_caption': '3 days free, then €2.99 / week. Cancel anytime.',
      'restore_purchase': 'Restore Purchase',
      'privacy_policy': 'Privacy Policy',
      'save_50': 'Save 50%',
      'settings': 'Settings',
      'language': 'Language',
      'system_default': 'System default',
    },
    'ru': {
      'app_title': 'Фокус Таймер',
      'home_title': 'Старт сейчас',
      'today_focused': 'Сегодня в фокусе',
      'minutes_short': 'мин',
      'sessions_completed': 'Сессий завершено: {count}',
      'start_now': 'Старт сейчас',
      'start_now_subtitle': 'Антипрокрастинация',
      'pomodoro': 'Помодоро',
      'pomodoro_subtitle': 'Фокус + перерыв',
      'customize': 'Настроить',
      'customize_premium': 'Настроить (Премиум)',
      'customize_locked_subtitle': 'Пресеты и белый шум',
      'small_rule': 'Малое правило',
      'small_rule_text': 'Не можешь начать — сделай 5 минут. Начать — уже победа.',
      'focus': 'Фокус',
      'break': 'Перерыв',
      'ready_when': 'Готов, когда будешь ты.',
      'start': 'Старт',
      'end': 'Стоп',
      'pause': 'Пауза',
      'nice_again': 'Отлично. Повторим?',
      'back_home': 'На главную',
      'start_again': 'Начать снова',
      'upgrade': 'Апгрейд',
      'unlock_deep_focus': 'Открой глубокий фокус',
      'upgrade_subtitle': 'Сформируй рутину. Отслеживай прогресс.',
      'custom_timers': 'Свои таймеры',
      'custom_timers_subtitle': 'Задай свои интервалы',
      'stats_streaks': 'Статистика и серии',
      'stats_streaks_subtitle': 'Смотри свой прогресс',
      'white_noise': 'Белый шум',
      'white_noise_subtitle': 'Фокус со звуком',
      'smart_reminders': 'Умные напоминания',
      'smart_reminders_subtitle': 'Держи ритм',
      'weekly': 'Неделя',
      'yearly': 'Год',
      'price_weekly': '€2.99 / неделя',
      'price_yearly': '€29.99 / год',
      'most_popular': 'Самый популярный',
      'best_value': 'Лучшая цена',
      'continue': 'Продолжить',
      'not_now': 'Не сейчас',
      'paywall_title': 'Раскрой свой потенциал',
      'paywall_subtitle': 'Мгновенный доступ ко всем премиум‑функциям!',
      'start_free_trial': 'Начать пробный период',
      'trial_caption': '3 дня бесплатно, затем €2.99 / неделя. Отмена в любой момент.',
      'restore_purchase': 'Восстановить покупки',
      'privacy_policy': 'Политика конфиденциальности',
      'save_50': 'Скидка 50%',
      'settings': 'Настройки',
      'language': 'Язык',
      'system_default': 'Системный',
    },
    'uk': {
      'app_title': 'Фокус Таймер',
      'home_title': 'Почати зараз',
      'today_focused': 'Сьогодні у фокусі',
      'minutes_short': 'хв',
      'sessions_completed': 'Сесій завершено: {count}',
      'start_now': 'Почати зараз',
      'start_now_subtitle': 'Антипрокрастинація',
      'pomodoro': 'Помодоро',
      'pomodoro_subtitle': 'Фокус + перерва',
      'customize': 'Налаштувати',
      'customize_premium': 'Налаштувати (Преміум)',
      'customize_locked_subtitle': 'Пресети та білий шум',
      'small_rule': 'Мале правило',
      'small_rule_text': 'Не можеш почати — зроби 5 хвилин. Почати — вже перемога.',
      'focus': 'Фокус',
      'break': 'Перерва',
      'ready_when': 'Готовий, коли ти.',
      'start': 'Старт',
      'end': 'Стоп',
      'pause': 'Пауза',
      'nice_again': 'Чудово. Повторимо?',
      'back_home': 'На головну',
      'start_again': 'Почати знову',
      'upgrade': 'Оновлення',
      'unlock_deep_focus': 'Відкрий глибокий фокус',
      'upgrade_subtitle': 'Побудуй рутину. Відстежуй прогрес.',
      'custom_timers': 'Власні таймери',
      'custom_timers_subtitle': 'Задай свої інтервали',
      'stats_streaks': 'Статистика і серії',
      'stats_streaks_subtitle': 'Дивись свій прогрес',
      'white_noise': 'Білий шум',
      'white_noise_subtitle': 'Фокус зі звуком',
      'smart_reminders': 'Розумні нагадування',
      'smart_reminders_subtitle': 'Тримай ритм',
      'weekly': 'Тиждень',
      'yearly': 'Рік',
      'price_weekly': '€2.99 / тиждень',
      'price_yearly': '€29.99 / рік',
      'most_popular': 'Найпопулярніший',
      'best_value': 'Найкраща ціна',
      'continue': 'Продовжити',
      'not_now': 'Не зараз',
      'paywall_title': 'Розкрий свій потенціал',
      'paywall_subtitle': 'Миттєвий доступ до всіх преміум‑функцій!',
      'start_free_trial': 'Почати безкоштовну пробу',
      'trial_caption': '3 дні безкоштовно, потім €2.99 / тиждень. Скасувати будь‑коли.',
      'restore_purchase': 'Відновити покупки',
      'privacy_policy': 'Політика конфіденційності',
      'save_50': 'Знижка 50%',
      'settings': 'Налаштування',
      'language': 'Мова',
      'system_default': 'Системна',
    },
  };

  String t(String key, {Map<String, String> params = const {}}) {
    final lang = _strings[locale.languageCode] ?? _strings['en']!;
    var value = lang[key] ?? _strings['en']![key] ?? key;
    params.forEach((param, replacement) {
      value = value.replaceAll('{$param}', replacement);
    });
    return value;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .any((supported) => supported.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
