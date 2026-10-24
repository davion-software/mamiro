import 'package:flutter/material.dart';
import 'package:mamiro/core/storage_failure.dart';
import 'package:mamiro/l10n/l10n.dart';
import 'package:mamiro/theme/widgets/paper_card.dart';

final class StorageBanner extends StatelessWidget {
  const StorageBanner({required this.failure, super.key});

  final StorageFailure failure;

  @override
  Widget build(BuildContext context) {
    return PaperCard(
      child: Text(
        context.formats.storageFailure(failure),
        style: Theme.of(context).textTheme.bodyLarge
            ?.copyWith(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}

void showStorageFailureSnackBar(BuildContext context, StorageFailure failure) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(context.formats.storageFailure(failure))),
  );
}
