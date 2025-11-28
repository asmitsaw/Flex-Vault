import 'package:flutter/material.dart';

import '../../core/constants/flexvault_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routePath = '/app/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const _GradientHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _StorageCard(),
                  SizedBox(height: 24),
                  _RecentFilesCarousel(),
                  SizedBox(height: 24),
                  _QuickActionsGrid(),
                  SizedBox(height: 24),
                  _SuggestedFilesSection(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _GradientHeader extends StatelessWidget {
  const _GradientHeader();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      expandedHeight: 120,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: FlexVaultColors.headerGradient,
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Good Morning, Maya',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ready to conquer your files?',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey[800]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none),
                  color: FlexVaultColors.reddishBrown,
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.settings_outlined),
                  color: FlexVaultColors.reddishBrown,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StorageCard extends StatelessWidget {
  const _StorageCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Storage', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            '4.2 GB / 15 GB',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: 4.2 / 15,
              backgroundColor: FlexVaultColors.lightYellow,
              color: FlexVaultColors.tangerineDream,
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upgrade to FlexVault Pro',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: FlexVaultColors.teaGreen),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.pie_chart_outline_rounded),
                color: FlexVaultColors.tangerineDream,
              )
            ],
          )
        ],
      ),
    );
  }
}

class _RecentFilesCarousel extends StatelessWidget {
  const _RecentFilesCarousel();

  @override
  Widget build(BuildContext context) {
    final files = List.generate(
      6,
      (index) => (
        'Invoice-${index + 1}.pdf',
        'PDF • 1.2 MB',
        Icons.picture_as_pdf_outlined
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Files', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: files.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final file = files[index];
              return Container(
                width: 140,
                padding: const EdgeInsets.all(12),
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
                    CircleAvatar(
                      backgroundColor: FlexVaultColors.lightYellow,
                      foregroundColor: FlexVaultColors.reddishBrown,
                      radius: 24,
                      child: Icon(file.$3),
                    ),
                    const Spacer(),
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
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    final actions = [
      ('Upload File', Icons.cloud_upload_outlined, FlexVaultColors.tangerineDream),
      ('Create Folder', Icons.create_new_folder_outlined, FlexVaultColors.teaGreen),
      ('Shared with Me', Icons.people_outline, FlexVaultColors.teaGreen),
      ('Recycle Bin', Icons.delete_outline, FlexVaultColors.reddishBrown),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        GridView.builder(
          itemCount: actions.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 120,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final action = actions[index];
            return Container(
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
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: action.$3.withOpacity(0.2),
                        foregroundColor: action.$3,
                        child: Icon(action.$2),
                      ),
                      Text(
                        action.$1,
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SuggestedFilesSection extends StatelessWidget {
  const _SuggestedFilesSection();

  @override
  Widget build(BuildContext context) {
    final suggestions = List.generate(
      3,
      (index) => (
        'Design Sprint ${index + 1}',
        'AI suggested',
        Icons.lightbulb_outline
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Suggested for You',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Column(
          children: suggestions
              .map(
                (s) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: FlexVaultColors.teaGreen.withOpacity(0.2),
                        foregroundColor: FlexVaultColors.teaGreen,
                        child: Icon(s.$3),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.$1,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              s.$2,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.more_horiz),
                        color: Colors.grey[600],
                      )
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

