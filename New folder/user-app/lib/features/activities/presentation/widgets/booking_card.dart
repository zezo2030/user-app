import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/url_utils.dart';
import '../../../home/data/datasources/home_remote_datasource.dart';
import '../../../home/data/models/branch_model.dart';
import '../../../booking/data/models/booking_model.dart';
import '../../../tickets/data/datasources/tickets_remote_datasource.dart';
import 'ticket_shape.dart';
import 'dashed_divider.dart';

class BookingCard extends StatefulWidget {
  final BookingModel booking;
  final TicketsRemoteDataSource ticketsDs;
  final VoidCallback onDetails;

  const BookingCard({
    super.key,
    required this.booking,
    required this.ticketsDs,
    required this.onDetails,
  });

  @override
  State<BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> {
  late final Future<String?> _imageFuture;
  late final Future<BranchModel?> _branchFuture;

  // Simple in-memory cache for hall images per session
  static final Map<String, String?> _hallImageCache = <String, String?>{};
  static final Map<String, String?> _branchImageCache = <String, String?>{};
  static final Map<String, BranchModel?> _branchCache =
      <String, BranchModel?>{};

  @override
  void initState() {
    super.initState();
    _imageFuture = _loadHallImage();
    _branchFuture = _loadBranch();
  }

  // Status color no longer used after hiding status chip

  @override
  Widget build(BuildContext context) {
    const double cardHeight = 132;
    const double imageWidth = 132;
    const double borderRadius = 16;
    const double notchRadius = 10;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Material(
        elevation: 2,
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onDetails,
          child: ClipPath(
            clipper: const TicketClipper(
              borderRadius: borderRadius,
              notchRadius: notchRadius,
            ),
            child: SizedBox(
              height: cardHeight,
              child: Row(
                textDirection: TextDirection.rtl, // image on the right in RTL
                children: [
                  // Image
                  SizedBox(
                    width: imageWidth,
                    height: double.infinity,
                    child: _buildImageWithOverlay(),
                  ),
                  // Dashed divider
                  SizedBox(
                    width: 14,
                    child: Center(
                      child: SizedBox(
                        width: 1,
                        height: cardHeight - 24,
                        child: const DashedDivider(),
                      ),
                    ),
                  ),
                  // Info
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 12,
                        end: 12,
                        top: 12,
                        bottom: 12,
                      ),
                      child: _buildInfoSection(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageWithOverlay() {
    return FutureBuilder<String?>(
      future: _imageFuture,
      builder: (context, snapshot) {
        final loading = snapshot.connectionState != ConnectionState.done;
        final imageUrl = snapshot.data;
        final imageChild = loading
            ? const Center(child: CircularProgressIndicator())
            : (imageUrl != null && imageUrl.isNotEmpty)
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Iconsax.gallery_slash),
                    ),
                  )
                : Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Iconsax.gallery, size: 40),
                    ),
                  );

        return Stack(
          fit: StackFit.expand,
          children: [
            imageChild,
            PositionedDirectional(
              top: 10,
              start: 10,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.people, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.booking.persons}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return FutureBuilder<BranchModel?>(
      future: _branchFuture,
      builder: (context, snapshot) {
        final branch = snapshot.data;
        final branchName = branch != null && branch.nameAr.isNotEmpty
            ? branch.nameAr
            : 'عنوان المركز الترفيهي';
        final location = branch?.location ?? 'المدينة - حي السلام';
        final rating = (branch?.rating ?? 4).toDouble();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title
            Text(
              branchName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            // Date row
            Row(
              children: [
                _smallRedDot(),
                const SizedBox(width: 6),
                const Icon(Iconsax.calendar_1, size: 14, color: Colors.black54),
                const SizedBox(width: 6),
                Text(
                  _formatDate(widget.booking.startTime),
                  style: const TextStyle(fontSize: 12.5, color: Colors.black87),
                ),
              ],
            ),
            // Location row
            Row(
              children: [
                const Icon(Iconsax.map_1, size: 14, color: Color(0xFFE11D48)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(fontSize: 12.5, color: Colors.black87),
                  ),
                ),
              ],
            ),
            // Button + rating
            Row(
              children: [
                _gradientButton(
                  label: 'تفاصيل الحجز',
                  onPressed: widget.onDetails,
                ),
                const SizedBox(width: 8),
                _stars(rating),
              ],
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y/$m/$day';
  }

  Widget _smallRedDot() {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: const Color(0xFFE11D48),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE11D48).withOpacity(0.35),
            blurRadius: 6,
            spreadRadius: 0.5,
          ),
        ],
      ),
    );
  }

  Widget _gradientButton({required String label, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFF3D8E), // pinkish
              Color(0xFFFF8A3D), // orange-ish
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }

  Widget _stars(double rating) {
    final stars = List<Widget>.generate(5, (i) {
      final filled = i < rating.round().clamp(0, 5);
      return Icon(
        Iconsax.star1,
        size: 14,
        color: filled ? const Color(0xFFF59E0B) : const Color(0xFFDDDDDD),
      );
    });
    return Row(children: stars);
  }

  Future<String?> _loadHallImage() async {
    final hallId = widget.booking.hallId;
    if (_hallImageCache.containsKey(hallId)) {
      return _hallImageCache[hallId];
    }
    final ds = HomeRemoteDataSourceImpl(dio: DioClient.instance);
    try {
      final hall = await ds.getHallDetails(hallId);
      final hallImagePath = (hall.images != null && hall.images!.isNotEmpty)
          ? hall.images!.first
          : null;
      final hallImageUrl = resolveFileUrl(hallImagePath);
      if (hallImageUrl.isNotEmpty) {
        _hallImageCache[hallId] = hallImageUrl;
        return hallImageUrl;
      }

      final branchId = widget.booking.branchId;
      if (_branchImageCache.containsKey(branchId)) {
        final fallback = _branchImageCache[branchId];
        _hallImageCache[hallId] = fallback;
        return fallback;
      }

      final branch = await ds.getBranchDetails(branchId);
      final branchImagePath = (branch.images != null && branch.images!.isNotEmpty)
          ? branch.images!.first
          : null;
      final branchImageUrl = resolveFileUrl(branchImagePath);
      final resolvedBranchImage = branchImageUrl.isNotEmpty ? branchImageUrl : null;
      _branchImageCache[branchId] = resolvedBranchImage;
      _hallImageCache[hallId] = resolvedBranchImage;
      return resolvedBranchImage;
    } catch (_) {
      final branchId = widget.booking.branchId;
      if (_branchImageCache.containsKey(branchId)) {
        final fallback = _branchImageCache[branchId];
        _hallImageCache[hallId] = fallback;
        return fallback;
      }
      try {
        final branch = await ds.getBranchDetails(branchId);
        final branchImagePath = (branch.images != null && branch.images!.isNotEmpty)
            ? branch.images!.first
            : null;
        final branchImageUrl = resolveFileUrl(branchImagePath);
        final resolvedBranchImage =
            branchImageUrl.isNotEmpty ? branchImageUrl : null;
        _branchImageCache[branchId] = resolvedBranchImage;
        _hallImageCache[hallId] = resolvedBranchImage;
        return resolvedBranchImage;
      } catch (_) {
        _branchImageCache[branchId] = null;
      }
      _hallImageCache[hallId] = null;
      return null;
    }
  }

  Future<BranchModel?> _loadBranch() async {
    final branchId = widget.booking.branchId;
    if (_branchCache.containsKey(branchId)) {
      return _branchCache[branchId];
    }
    final ds = HomeRemoteDataSourceImpl(dio: DioClient.instance);
    try {
      final b = await ds.getBranchDetails(branchId);
      _branchCache[branchId] = b;
      return b;
    } catch (_) {
      _branchCache[branchId] = null;
      return null;
    }
  }
}
