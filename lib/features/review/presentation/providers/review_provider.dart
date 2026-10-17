import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahmani_project/core/config/supabase_config.dart';
import 'package:rahmani_project/features/review/data/datasources/review_remote_datasource.dart';
import 'package:rahmani_project/features/review/data/repositories/review_repository_impl.dart';
import 'package:rahmani_project/features/review/domain/entities/review_entities.dart';
import 'package:rahmani_project/features/review/domain/repositories/review_repository.dart';
import 'package:rahmani_project/features/review/domain/usecases/review_usecases.dart';

final reviewRemoteDataSourceProvider = Provider<ReviewRemoteDataSource?>((ref) {
  if (!SupabaseConfig.isInitialized) return null;
  return ReviewRemoteDataSourceImpl(SupabaseConfig.client);
});

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final remote = ref.watch(reviewRemoteDataSourceProvider);
  if (remote == null) return const UnconfiguredReviewRepository();
  return ReviewRepositoryImpl(remote: remote, client: SupabaseConfig.client);
});

final submitReviewProvider = Provider((ref) => SubmitReview(ref.watch(reviewRepositoryProvider)));

final canReviewOrderItemProvider =
    Provider((ref) => CanReviewOrderItem(ref.watch(reviewRepositoryProvider)));

final getListingReviewsProvider =
    Provider((ref) => GetListingReviews(ref.watch(reviewRepositoryProvider)));

final getBoothReviewsProvider =
    Provider((ref) => GetBoothReviews(ref.watch(reviewRepositoryProvider)));

final getListingReviewSummaryProvider =
    Provider((ref) => GetListingReviewSummary(ref.watch(reviewRepositoryProvider)));

final getBoothReviewSummaryProvider =
    Provider((ref) => GetBoothReviewSummary(ref.watch(reviewRepositoryProvider)));

final listingReviewsProvider =
    FutureProvider.family<List<ReviewEntity>, String>((ref, listingId) async {
  final result = await ref.read(getListingReviewsProvider).call(listingId);
  return result.fold((_) => [], (reviews) => reviews);
});

final listingReviewSummaryProvider =
    FutureProvider.family<ReviewSummaryEntity, String>((ref, listingId) async {
  final result = await ref.read(getListingReviewSummaryProvider).call(listingId);
  return result.fold(
    (_) => const ReviewSummaryEntity(averageRating: 0, reviewCount: 0),
    (summary) => summary,
  );
});

final boothReviewsProvider = FutureProvider.family<List<ReviewEntity>, String>((ref, boothId) async {
  final result = await ref.read(getBoothReviewsProvider).call(boothId);
  return result.fold((_) => [], (reviews) => reviews);
});

final boothReviewSummaryProvider =
    FutureProvider.family<ReviewSummaryEntity, String>((ref, boothId) async {
  final result = await ref.read(getBoothReviewSummaryProvider).call(boothId);
  return result.fold(
    (_) => const ReviewSummaryEntity(averageRating: 0, reviewCount: 0),
    (summary) => summary,
  );
});
