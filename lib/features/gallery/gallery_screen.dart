import 'package:flutter/material.dart';

import '../../core/constants/flexvault_colors.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  static const routePath = '/app/gallery';

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  String _selectedFilter = 'All';
  final filters = ['All', 'Images', 'Documents', 'Videos', 'Audio', 'Archives'];

  @override
  Widget build(BuildContext context) {
    final files = List.generate(
      10,
      (index) => (
        'Project Moodboard ${index + 1}.png',
        'Images • 2.$index MB',
        Icons.image_outlined
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: FlexVaultColors.headerGradient,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 54,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final filter = filters[index];
                final isActive = _selectedFilter == filter;
                return ChoiceChip(
                  label: Text(filter),
                  selected: isActive,
                  onSelected: (_) => setState(() => _selectedFilter = filter),
                  selectedColor: FlexVaultColors.tangerineDream,
                  labelStyle: TextStyle(
                    color: isActive
                        ? FlexVaultColors.reddishBrown
                        : Colors.grey[700],
                  ),
                  backgroundColor: FlexVaultColors.lightYellow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: filters.length,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search files',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filledTonal(
                  onPressed: () {},
                  icon: const Icon(Icons.view_module_outlined),
                )
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                return Material(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onLongPress: () {},
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: FlexVaultColors.lightYellow,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  color: FlexVaultColors.teaGreen,
                                  size: 48,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            file.$1,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            file.$2,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: integrate upload flow
        },
        child: const Icon(Icons.cloud_upload_outlined),
      ),
    );
  }
}

