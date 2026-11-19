/// Membaca konfigurasi URL dan API key dari --dart-define-from-file.
/// Tidak ada URL atau key yang ditulis langsung di kode.
class Env {
  Env._();

  static const String baseUrl = String.fromEnvironment('GNEWS_BASE_URL');
  static const String apiKey = String.fromEnvironment('GNEWS_API_KEY');

  /// true jika konfigurasi sudah diisi (baseUrl wajib, apiKey wajib saat development).
  static bool get lengkap => baseUrl.isNotEmpty && apiKey.isNotEmpty;

  /// Menyamarkan API key di teks log / pesan error.
  static String samarkan(String teks) {
    var hasil = teks.replaceAllMapped(
      RegExp(r'(apikey=)[^&\s"]+', caseSensitive: false),
      (m) => '${m[1]}***',
    );
    if (apiKey.isNotEmpty) hasil = hasil.replaceAll(apiKey, '***');
    return hasil;
  }
}
