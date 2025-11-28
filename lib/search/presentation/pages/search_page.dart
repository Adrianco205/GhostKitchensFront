import 'package:flutter/material.dart';
import 'search_results_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _query = '';

  // Mocks solo para logos de cocinas relacionadas
  final List<_KitchenLogo> _kitchenLogos = const [
    _KitchenLogo(
      name: 'Carlos Burger',
      logoUrl:
          'https://images.pexels.com/photos/4109118/pexels-photo-4109118.jpeg',
    ),
    _KitchenLogo(
      name: 'La Santa Pizza',
      logoUrl:
          'https://images.pexels.com/photos/2290070/pexels-photo-2290070.jpeg',
    ),
    _KitchenLogo(
      name: 'Vir Viri',
      logoUrl:
          'https://images.pexels.com/photos/4109136/pexels-photo-4109136.jpeg',
    ),
    _KitchenLogo(
      name: 'Sushi Ghost',
      logoUrl:
          'https://images.pexels.com/photos/3298182/pexels-photo-3298182.jpeg',
    ),
  ];

  final List<String> _recentTags = const ['Distrito', 'Carne', 'Olimpica'];
  final List<String> _topTags = const [
    'Sushi',
    'Pizza',
    'Agua',
    'Leche',
    'Cerveza',
    'Huevo',
    'Queso',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() => _query = value);
  }

  void _onSubmitted(String value) {
    final q = value.trim();
    if (q.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchResultsPage(initialQuery: q),
      ),
    );
  }

  void _clearQuery() {
    setState(() {
      _controller.clear();
      _query = '';
    });
    _focusNode.requestFocus();
  }

  void _onTagTap(String tag) {
    _controller.text = tag;
    _onSubmitted(tag);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER CON BUSCADOR
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
                      alignment: Alignment.center,
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        onChanged: _onChanged,
                        onSubmitted: _onSubmitted,
                        textInputAction: TextInputAction.search,
                        decoration: const InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: '¿Qué quieres hoy?',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _clearQuery,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // CONTENIDO: LOGOS + RECIENTES + MÁS BUSCADOS
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // LOGOS DE COCINAS RELACIONADAS
                          SizedBox(
                            height: 80,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _kitchenLogos.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final k = _kitchenLogos[index];
                                return Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 26,
                                      backgroundColor: Colors.grey.shade300,
                                      backgroundImage:
                                          NetworkImage(k.logoUrl),
                                    ),
                                    const SizedBox(height: 4),
                                    SizedBox(
                                      width: 80,
                                      child: Text(
                                        k.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodySmall,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 24),

                          // RECIENTES
                          Text(
                            'Recientes',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _recentTags
                                .map(
                                  (tag) => _SearchChip(
                                    label: tag,
                                    onTap: () => _onTagTap(tag),
                                  ),
                                )
                                .toList(),
                          ),

                          const SizedBox(height: 24),

                          // LOS MÁS BUSCADOS
                          Text(
                            'Los más buscados',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _topTags
                                .map(
                                  (tag) => _SearchChip(
                                    label: tag,
                                    onTap: () => _onTagTap(tag),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
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
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
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

class _KitchenLogo {
  final String name;
  final String logoUrl;

  const _KitchenLogo({
    required this.name,
    required this.logoUrl,
  });
}
