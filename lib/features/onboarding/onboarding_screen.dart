import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/flexvault_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const routePath = '/onboarding';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  final _pages = <_OnboardingPageData>[
    const _OnboardingPageData(
      title: 'Upload Any File Type',
      subtitle: 'Images, videos, documents, audio, code — everything.',
      icon: Icons.cloud_upload_outlined,
      accentColor: FlexVaultColors.tangerineDream,
    ),
    const _OnboardingPageData(
      title: 'AI-Powered Organization',
      subtitle: 'Smart labels generated instantly on your device.',
      icon: Icons.auto_awesome,
      accentColor: FlexVaultColors.teaGreen,
    ),
    const _OnboardingPageData(
      title: 'Smart Folders',
      subtitle: 'Automate grouping by rules, time and tags.',
      icon: Icons.folder_special_outlined,
      accentColor: FlexVaultColors.tangerineDream,
    ),
    const _OnboardingPageData(
      title: 'Search Anything',
      subtitle: 'Find files by name, tags, or OCR text.',
      icon: Icons.search_rounded,
      accentColor: FlexVaultColors.teaGreen,
    ),
    const _OnboardingPageData(
      title: 'Secure & Private',
      subtitle: 'Protected cloud storage with safe sharing.',
      icon: Icons.lock_outline,
      accentColor: FlexVaultColors.reddishBrown,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_currentPage == _pages.length - 1) {
      context.go('/auth');
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 8),
              child: Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.go('/auth'),
                    child: const Text(
                      'Skip',
                      style: TextStyle(color: FlexVaultColors.reddishBrown),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (value) => setState(() {
                  _currentPage = value;
                }),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final data = _pages[index];
                  return _OnboardingSlide(data: data);
                },
              ),
            ),
            _DotsIndicator(
              count: _pages.length,
              index: _currentPage,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: FlexVaultColors.lightYellow,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (_currentPage + 1) / _pages.length,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: FlexVaultColors.headerGradient,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FlexVaultColors.tangerineDream,
                      foregroundColor: FlexVaultColors.reddishBrown,
                      minimumSize: const Size(120, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _handleNext,
                    child: Text(
                      _currentPage == _pages.length - 1 ? 'Start' : 'Next',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({required this.data});

  final _OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  data.accentColor.withOpacity(0.5),
                  data.accentColor.withOpacity(0.1),
                ],
              ),
            ),
            child: Icon(
              data.icon,
              size: 100,
              color: FlexVaultColors.reddishBrown,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          count,
          (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: index == i ? 16 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: index == i
                  ? FlexVaultColors.teaGreen
                  : FlexVaultColors.lightYellow,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}

