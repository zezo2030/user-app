import 'package:equatable/equatable.dart';
import 'banner_entity.dart';
import 'offer_entity.dart';
import 'branch_entity.dart';

class HomeDataEntity extends Equatable {
  final List<BannerEntity> banners;
  final List<OfferEntity> offers;
  final List<BranchEntity> featuredBranches;

  const HomeDataEntity({
    required this.banners,
    required this.offers,
    required this.featuredBranches,
  });

  @override
  List<Object?> get props => [banners, offers, featuredBranches];
}
