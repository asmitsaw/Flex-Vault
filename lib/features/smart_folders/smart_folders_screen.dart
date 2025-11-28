import 'package:flutter/material.dart';

import '../../core/constants/flexvault_colors.dart';

class SmartFoldersScreen extends StatelessWidget {
  const SmartFoldersScreen({super.key});

  static const routePath = '/app/smart-folders';

  @override
  Widget build(BuildContext context) {
    final folders = [
      ('Work Documents', Icons.work_outline, 42),
      ('Family Photos', Icons.photo_library_outlined, 128),
      ('Important Notes', Icons.bookmark_outline, 18),
      ('Favorites', Icons.star_outline, 9),
      ('Personal Files', Icons.folder_open, 33),
      ('Creative Projects', Icons.palette_outlined, 21),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Folders'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: FlexVaultColors.headerGradient,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, color: FlexVaultColors.reddishBrown),
            label: const Text(
              'New',
              style: TextStyle(color: FlexVaultColors.reddishBrown),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.create_new_folder_outlined),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemCount: folders.length + 1,
        itemBuilder: (context, index) {
          if (index == folders.length) {
            return DottedBorderCard(
              onTap: () {},
            );
          }
          final folder = folders[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(folder.$2, size: 32, color: FlexVaultColors.teaGreen),
                const Spacer(),
                Text(folder.$1, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '${folder.$3} files',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class DottedBorderCard extends StatelessWidget {
  const DottedBorderCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: FlexVaultColors.teaGreen,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, color: FlexVaultColors.teaGreen),
              SizedBox(height: 8),
              Text(
                'Create Folder',
                style: TextStyle(color: FlexVaultColors.teaGreen),
              )
            ],
          ),
        ),
      ),
    );
  }
}

