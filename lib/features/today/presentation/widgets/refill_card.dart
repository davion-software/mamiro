import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mamiro/core/app_log.dart';
import 'package:mamiro/core/medication.dart';
import 'package:mamiro/l10n/l10n.dart';
import 'package:mamiro/theme/palette.dart';
import 'package:mamiro/theme/widgets/paper_card.dart';
import 'package:mamiro/theme/widgets/pill_glyph.dart';

final class RefillCard extends StatelessWidget {
  const RefillCard({
    required this.medication,
    required this.onRestock,
    super.key,
  });

  final Medication medication;
  final ValueChanged<int> onRestock;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PaperCard(
      padding: const EdgeInsetsDirectional.fromSTEB(14, 6, 6, 6),
      child: Row(
        children: [
          PillGlyph(shape: medication.shape, color: medication.color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: medication.name),
                  TextSpan(
                    text: '  ·  ${l10n.pillsLeft(medication.quantity ?? 0)}',
                    style: const TextStyle(color: MamiroPalette.coralDeep),
                  ),
                ],
              ),
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: () => unawaited(
              _restock(
                context,
              ).catchError(unexpectedLogger('mamiro.today', 'today.restock')),
            ),
            child: Text(l10n.restock),
          ),
        ],
      ),
    );
  }

  Future<void> _restock(BuildContext context) async {
    final count = await showDialog<int>(
      context: context,
      builder: (context) => _RestockDialog(name: medication.name),
    );
    if (count != null && count > 0) onRestock(count);
  }
}

final class _RestockDialog extends StatefulWidget {
  const _RestockDialog({required this.name});

  final String name;

  @override
  State<_RestockDialog> createState() => _RestockDialogState();
}

final class _RestockDialogState extends State<_RestockDialog> {
  final _count = TextEditingController();

  @override
  void dispose() {
    _count.dispose();
    super.dispose();
  }

  void _submit() => Navigator.pop(context, int.tryParse(_count.text));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.restockTitle(widget.name)),
      content: TextField(
        controller: _count,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(labelText: l10n.restockField),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(onPressed: _submit, child: Text(l10n.restockConfirm)),
      ],
    );
  }
}
