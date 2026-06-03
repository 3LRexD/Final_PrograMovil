import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Obx(() => AnimatedOpacity(
                  opacity: controller.isLastPage ? 0 : 1,
                  duration: const Duration(milliseconds: 300),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed:
                          controller.isLastPage ? null : controller.skip,
                      child: Text(
                        'Saltar',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )),

            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.totalPages,
                itemBuilder: (context, index) {
                  final page = controller.pages[index];
                  return _OnboardingPageItem(
                    page: page,
                    size: size,
                    colorScheme: colorScheme,
                    theme: theme,
                  );
                },
              ),
            ),

            Obx(() => _DotIndicator(
                  count: controller.totalPages,
                  current: controller.currentPage.value,
                  activeColor: colorScheme.primary,
                  inactiveColor: colorScheme.primary.withOpacity(0.25),
                )),

            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Obx(() => _ActionButtons(
                    isLastPage: controller.isLastPage,
                    onNext: controller.nextPage,
                    primaryColor: colorScheme.primary,
                    onPrimaryColor: colorScheme.onPrimary,
                    theme: theme,
                  )),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageItem extends StatelessWidget {
  const _OnboardingPageItem({
    required this.page,
    required this.size,
    required this.colorScheme,
    required this.theme,
  });

  final OnboardingPage page;
  final Size size;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Imagen
          SizedBox(
            height: size.height * 0.38,
            child: Image.asset(
              page.imagePath,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => _ImagePlaceholder(
                color: colorScheme.primaryContainer,
                iconColor: colorScheme.onPrimaryContainer,
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Título
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              height: 1.25,
            ),
          ),

          const SizedBox(height: 16),

          // Descripción
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.65),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({
    required this.count,
    required this.current,
    required this.activeColor,
    required this.inactiveColor,
  });

  final int count;
  final int current;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.isLastPage,
    required this.onNext,
    required this.primaryColor,
    required this.onPrimaryColor,
    required this.theme,
  });

  final bool isLastPage;
  final VoidCallback onNext;
  final Color primaryColor;
  final Color onPrimaryColor;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.15),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: SizedBox(
        key: ValueKey(isLastPage),
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: onNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: onPrimaryColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            isLastPage ? 'Empezar' : 'Siguiente',
            style: theme.textTheme.titleMedium?.copyWith(
              color: onPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({
    required this.color,
    required this.iconColor,
  });

  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 80,
          color: iconColor,
        ),
      ),
    );
  }
}
