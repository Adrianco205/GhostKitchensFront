import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'search_results_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  // ---------------------------------------------------------------
  // 🔹 Cargar búsquedas recientes almacenadas localmente
  // ---------------------------------------------------------------
  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList("recent_searches") ?? [];
    setState(() {
      _recentSearches = list;
    });
  }

  // ---------------------------------------------------------------
  // 🔹 Guardar una búsqueda en SharedPreferences
  // ---------------------------------------------------------------
  Future<void> _addRecentSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();

    // Evitar duplicados
    _recentSearches.remove(query);

    // Insertar al inicio
    _recentSearches.insert(0, query);

    // Mantener máximo 5
    if (_recentSearches.length > 5) {
      _recentSearches = _recentSearches.sublist(0, 5);
    }

    await prefs.setStringList("recent_searches", _recentSearches);
    setState(() {});
  }

  // ---------------------------------------------------------------
  // 🔹 Al enviar búsqueda
  // ---------------------------------------------------------------
  void _onSubmitted(String value) async {
    final q = value.trim();
    if (q.isEmpty) return;

    await _addRecentSearch(q);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchResultsPage(initialQuery: q),
      ),
    );
  }

  void _clearQuery() {
    setState(() {
      _controller.clear();
    });
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------------------- HEADER --------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        onSubmitted: _onSubmitted,
                        textInputAction: TextInputAction.search,
                        decoration: const InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: "¿Qué quieres hoy?",
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _clearQuery,
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // -------------------- RECIENTES --------------------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Recientes",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (_recentSearches.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        children: _recentSearches.map((item) {
                          return _SearchChip(
                            label: item,
                            onTap: () => _onSubmitted(item),
                          );
                        }).toList(),
                      )
                    else
                      Text(
                        "Aquí verás tus búsquedas recientes.",
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.grey),
                      ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _SearchChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SearchChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium,
        ),
      ),
    );
  }
}
