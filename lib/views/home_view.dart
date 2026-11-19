import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/article_model.dart';
import '../routes/app_routes.dart';
import '../services/news_api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/article_card.dart';
import '../widgets/error_view.dart';

/// Halaman utama: daftar berita perfilman dengan ChoiceChip kategori.
/// Menggunakan endpoint /search dengan kata kunci film.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final NewsApiService _service = NewsApiService();

  // Kata kunci film → label di chip (tema perfilman)
  static const Map<String, String> _categories = {
    'Film Indonesia': 'Film Indonesia',
    'Hollywood': 'Hollywood',
    'Bioskop': 'Bioskop',
    'Streaming': 'Streaming',
    'Box Office': 'Box Office',
    'Festival Film': 'Festival Film',
    'Film Terbaru': 'Film Terbaru',
  };

  String _selectedKeyword = 'Film Indonesia';

  /// Cache Future per kategori agar kembali ke chip yang sama tidak memicu request baru.
  final Map<String, Future<List<ArticleModel>>> _cache = {};

  /// Future disimpan di State, BUKAN dibuat di dalam build()
  late Future<List<ArticleModel>> _futureNews;

  @override
  void initState() {
    super.initState();
    _futureNews = _ambilBerita(_selectedKeyword);
  }

  /// Ambil atau kembalikan Future dari cache untuk kata kunci tertentu.
  Future<List<ArticleModel>> _ambilBerita(String keyword) {
    return _cache.putIfAbsent(keyword, () => _service.searchNews(keyword));
  }

  /// Muat ulang: hapus cache kategori aktif dan buat Future baru (Coba Lagi).
  void _muatUlang() {
    setState(() {
      _cache.remove(_selectedKeyword);
      _futureNews = _ambilBerita(_selectedKeyword);
    });
  }

  /// Pindah kategori.
  void _gantiKategori(String keyword) {
    if (keyword == _selectedKeyword) return;
    setState(() {
      _selectedKeyword = keyword;
      _futureNews = _ambilBerita(keyword);
    });
  }

  /// Untuk RefreshIndicator: tunggu sampai request selesai.
  Future<void> _onRefresh() async {
    _muatUlang();
    try {
      await _futureNews;
    } catch (_) {
      // error sudah ditampilkan oleh FutureBuilder
    }
  }

  /// Tampilkan dialog pencarian.
  void _showSearchDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cari Berita Film'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Masukkan kata kunci...',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            Navigator.of(ctx).pop();
            _navigateToSearch(value.trim());
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _navigateToSearch(controller.text.trim());
            },
            child: const Text('Cari'),
          ),
        ],
      ),
    );
  }

  void _navigateToSearch(String query) {
    if (query.isEmpty) return;
    Get.toNamed(AppRoutes.searchResults, arguments: query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Berita Perfilman'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Cari berita',
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryChips(),
          Expanded(
            child: FutureBuilder<List<ArticleModel>>(
              future: _futureNews,
              builder: (context, snapshot) {
                // 1. Loading (belum selesai)
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 2. Error
                if (snapshot.hasError) {
                  return ErrorView(
                    message: snapshot.error.toString(),
                    onRetry: _muatUlang,
                  );
                }

                // 3. Data kosong
                final articles = snapshot.data ?? [];
                if (articles.isEmpty) {
                  return const Center(
                    child: Text('Belum ada berita untuk kategori ini.'),
                  );
                }

                // 4. Data ada
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      final article = articles[index];
                      return ArticleCard(
                        article: article,
                        onTap: () => Get.toNamed(
                          AppRoutes.detail,
                          arguments: article,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Container(
      height: 56,
      color: AppColors.surface,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final keyword = _categories.keys.elementAt(index);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: ChoiceChip(
              label: Text(_categories[keyword]!),
              selected: keyword == _selectedKeyword,
              onSelected: (_) => _gantiKategori(keyword),
            ),
          );
        },
      ),
    );
  }
}
