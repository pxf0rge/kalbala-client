import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/features/review/presentation/providers/review_provider.dart';
import 'package:rahmani_project/features/review/presentation/widgets/star_rating.dart';

/// Form to submit a product review after delivery.
class WriteReviewScreen extends ConsumerStatefulWidget {
  const WriteReviewScreen({
    required this.orderItemId,
    required this.productName,
    super.key,
  });

  final String orderItemId;
  final String productName;

  @override
  ConsumerState<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends ConsumerState<WriteReviewScreen> {
  final _commentController = TextEditingController();
  int _rating = 5;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ثبت نظر')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            widget.productName,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          const Text('امتیاز شما'),
          StarRating(
            rating: _rating,
            onChanged: (value) => setState(() => _rating = value),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: 'نظر (اختیاری)',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 5,
            maxLength: 1000,
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
                : const Text('ثبت نظر'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    final result = await ref.read(submitReviewProvider).call(
          orderItemId: widget.orderItemId,
          rating: _rating,
          comment: _commentController.text,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('نظر شما ثبت شد')),
        );
        context.pop(true);
      },
    );
  }
}