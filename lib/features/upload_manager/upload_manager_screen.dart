import 'package:flutter/material.dart';

import '../../core/constants/flexvault_colors.dart';

class UploadManagerScreen extends StatelessWidget {
  const UploadManagerScreen({super.key});

  static const routePath = '/app/upload-manager';

  @override
  Widget build(BuildContext context) {
    final uploads = [
      ('hero-video.mp4', 'Uploading • 65%', 0.65),
      ('branding-kit.zip', 'Paused • 32%', 0.32),
      ('travel-photos.dng', 'Completed', 1.0),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Manager'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: FlexVaultColors.headerGradient,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: FlexVaultColors.teaGreen,
                  style: BorderStyle.solid,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_upload_outlined,
                        size: 48, color: FlexVaultColors.teaGreen),
                    const SizedBox(height: 12),
                    Text(
                      'Drag files here or tap to select',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () {},
                      child: const Text('Choose Files'),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: uploads.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final upload = uploads[index];
                  final isComplete = upload.$3 == 1.0;
                  final color =
                      isComplete ? FlexVaultColors.teaGreen : FlexVaultColors.tangerineDream;
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(isComplete ? Icons.check_circle_outline : Icons.upload_file,
                                color: color),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(upload.$1,
                                      style: Theme.of(context).textTheme.bodyLarge),
                                  const SizedBox(height: 4),
                                  Text(upload.$2,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(color: Colors.grey[600])),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(isComplete ? Icons.download : Icons.pause),
                              onPressed: () {},
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: upload.$3,
                            backgroundColor: FlexVaultColors.lightYellow,
                            color: color,
                            minHeight: 8,
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: FlexVaultColors.tangerineDream,
                  foregroundColor: FlexVaultColors.reddishBrown,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {},
                child: const Text('Upload All Files'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

