import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/features/report/domain/entities/report_entities.dart';
import 'package:rahmani_project/features/report/presentation/providers/report_provider.dart';
import 'package:rahmani_project/features/report/presentation/widgets/report_form.dart';

/// Screen to submit a report for a product, booth, user, or review.
class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({required this.target, super.key});

  final ReportTarget target;

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  final _descriptionController = TextEditingController();
  ReportReason _selectedReason = ReportReason.spam;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('گزارش تخلف')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ReportForm(
            target: widget.target,
            selectedReason: _selectedReason,
            descriptionController: _descriptionController,
            onReasonChanged: (reason) => setState(() => _selectedReason = reason),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('ارسال گزارش'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    final result = await ref.read(submitReportProvider).call(
          SubmitReportInput(
            targetType: widget.target.type,
            targetId: widget.target.targetId,
            reason: _selectedReason,
            description: _descriptionController.text,
          ),
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (_) {
        ref.invalidate(myReportsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('گزارش شما ثبت شد و در انتظار بررسی است.')),
        );
        context.pop();
      },
    );
  }
}