import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';
import 'package:rahmani_project/features/listing/domain/entities/listing_entities.dart';
import 'package:rahmani_project/features/listing/domain/repositories/listing_repository.dart';

class GetBoothListings {
  const GetBoothListings(this._repository);
  final ListingRepository _repository;

  Future<Either<Failure, List<ListingEntity>>> call(String boothId) =>
      _repository.getBoothListings(boothId);
}

class GetListingDetail {
  const GetListingDetail(this._repository);
  final ListingRepository _repository;

  Future<Either<Failure, ListingEntity>> call(String listingId) =>
      _repository.getListing(listingId);
}

class GetPublicListingDetail {
  const GetPublicListingDetail(this._repository);
  final ListingRepository _repository;

  Future<Either<Failure, PublicListingEntity>> call(String listingId) =>
      _repository.getPublicListing(listingId);
}

class GetRelatedListings {
  const GetRelatedListings(this._repository);
  final ListingRepository _repository;

  Future<Either<Failure, List<PublicListingEntity>>> call(
    String listingId, {
    int limit = 8,
  }) =>
      _repository.getRelatedListings(listingId, limit: limit);
}

class CreateListing {
  const CreateListing(this._repository);
  final ListingRepository _repository;

  Future<Either<Failure, ListingEntity>> call(ListingInput input) {
    if (input.price < 0) {
      return Future.value(const Left(ValidationFailure('قیمت نامعتبر است.')));
    }
    if (input.stock < 0) {
      return Future.value(const Left(ValidationFailure('موجودی نامعتبر است.')));
    }
    return _repository.createListing(input);
  }
}

class UpdateListing {
  const UpdateListing(this._repository);
  final ListingRepository _repository;

  Future<Either<Failure, ListingEntity>> call({
    required String listingId,
    required ListingInput input,
  }) {
    if (input.price < 0) {
      return Future.value(const Left(ValidationFailure('قیمت نامعتبر است.')));
    }
    return _repository.updateListing(listingId: listingId, input: input);
  }
}

class DeleteListing {
  const DeleteListing(this._repository);
  final ListingRepository _repository;

  Future<Either<Failure, void>> call(String listingId) =>
      _repository.deleteListing(listingId);
}

class AddVariant {
  const AddVariant(this._repository);
  final ListingRepository _repository;

  Future<Either<Failure, ListingVariantEntity>> call({
    required String listingId,
    required VariantInput input,
  }) {
    if (input.name.trim().isEmpty) {
      return Future.value(const Left(ValidationFailure('نام تنوع الزامی است.')));
    }
    return _repository.addVariant(listingId: listingId, input: input);
  }
}

class UpdateVariant {
  const UpdateVariant(this._repository);
  final ListingRepository _repository;

  Future<Either<Failure, ListingVariantEntity>> call({
    required String variantId,
    required VariantInput input,
  }) => _repository.updateVariant(variantId: variantId, input: input);
}

class DeleteVariant {
  const DeleteVariant(this._repository);
  final ListingRepository _repository;

  Future<Either<Failure, void>> call(String variantId) =>
      _repository.deleteVariant(variantId);
}
