class Language {
  final int id;
  final String flag;
  final String name;
  final String languageCode;
  final String countryCode;
  final String currencySymbol;
  final String currencyCode;
  final String currencyName;
  const Language(
      this.id,
      this.flag,
      this.name,
      this.languageCode,
      this.countryCode,
      this.currencySymbol,
      this.currencyCode,
      this.currencyName);
  static List<Language> languageList = [
    const Language(
        1, "🇺🇸", "English", "en", 'US', '\$', 'USD', 'United States Dollar'),
    // Language(2, "🇸🇦", "العربية", "ar", 'SA', 'R'),
    const Language(3, "🇩🇪", "Deutsch", "de", 'DE', '€', 'EUR', 'Euro'),
    const Language(4, "🇪🇸", "Español", "es", 'ES', '€', 'EUR', 'Euro'),
    const Language(5, "🇫🇷", "Français", "fr", 'FR', '€', 'EUR', 'Euro'),
    const Language(6, "🇮🇳", "हिन्दी", "hi", 'IN', '₹', 'INR', 'Indian Rupee'),
    const Language(7, "🇯🇵", "日本語", "ja", 'JP', '¥', 'JPY', 'Japanese Yen'),
    const Language(
        8, "🇰🇷", "한국어", "ko", 'KR', '₩', 'KRW', 'South Korean Won'),
    const Language(9, "🇵🇹", "Português", "pt", 'PT', '€', 'EUR', 'Euro'),
    const Language(
        10, "🇷🇺", "Русский язык", "ru", 'RU', 'руб', 'RUB', 'Russian Ruble'),
    const Language(
        11, "🇹🇷", "Türkçe", "tr", 'TR', 'TL', 'TRY', 'Turkish Lira'),
    const Language(
        12, "🇻🇳", "Tiếng Việt", "vi", 'VN', '₫', 'VND', 'Vietnamese Dong'),
    const Language(13, "🇨🇳", "中文", "zh", 'CN', '¥', 'CNY', 'Chinese Yuan'),
  ];
}
