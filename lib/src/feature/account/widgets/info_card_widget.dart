import 'package:cipher/src/providers/styles.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class InfoCardWidget extends HookConsumerWidget {
  final String title;
  final String subtitle;
  final Image? image;
  final String? description;

  const InfoCardWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.image,
    this.description,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = ref.watch(textStyleProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: styles.heading1.copyWith(fontSize: 24, height: 1.5)),
        const Gap(16),
        Text(subtitle, style: styles.heading3),
        const Gap(4),
        if (image != null) Expanded(child: image!),
        const Gap(4),
        if (description != null) Text(description!, style: styles.heading3),
      ],
    );
  }
}
