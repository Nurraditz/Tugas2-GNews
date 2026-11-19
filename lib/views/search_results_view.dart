import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/article_model.dart';
import '../routes/app_routes.dart';
import '../services/news_api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/article_card.dart';
import '../widgets/error_view.dart';

/// Halaman hasil pencarian, menggunakan FutureBuilder.
/// Menerima query dari Get.arguments.
class SearchResultsView extends StatefulWidget {
  const SearchResultsView({super.key});

  @override
  State<SearchResultsView> createState() => _SearchResultsViewState();
}

class _SearchResultsViewState extends State<SearchResultsView> {
  final NewsApiService _service = NewsApiService();

  late final String _query;

  /// Future disimpan di State, BUKAN dibuat di dalam build()
  late Future<List<ArticleModel>> _searchFuture;

  @override
  void initState() {
    super.initState();
    _query = Get.arguments as String;
    _searchFuture = _service.searchNews(_query);
  }

  void _muatUlang() {
    setState(() {
      _searchFuture = _service.searchNews(_query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hasil: "$_query"'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<ArticleModel>>(
        future: _searchFuture,
        builder: (context, snapshot) {
          // 1. Loading
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
              child: Text('Tidak ada hasil untuk pencarian ini.'),
            );
          }

          // 4. Data ada
          return ListView.builder(
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
          );
        },
      ),
    );
  }
}
