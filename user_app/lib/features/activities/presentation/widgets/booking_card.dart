import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/network/dio_client.dart';
import '../../../home/data/datasources/home_remote_datasource.dart';
import '../../../booking/data/models/booking_model.dart';
import '../../../tickets/data/datasources/tickets_remote_datasource.dart';

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

  // Simple in-memory cache for hall images per session
  static final Map<String, String?> _hallImageCache = <String, String?>{};

  @override
  void initState() {
    super.initState();
    _imageFuture = _loadHallImage();
  }

  // Status color no longer used after hiding status chip

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onDetails,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image header with people chip overlay
            FutureBuilder<String?>(
              future: _imageFuture,
              builder: (context, snapshot) {
                final loading =
                    snapshot.connectionState != ConnectionState.done;
                final imageUrl = snapshot.data;
                return Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: loading
                          ? const Center(child: CircularProgressIndicator())
                          : (imageUrl != null && imageUrl.isNotEmpty)
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
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
                            ),
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
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
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Iconsax.people,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.booking.persons}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [const SizedBox.shrink()],
                    ),
                  ),
                  const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _loadHallImage() async {
    final hallId = widget.booking.hallId;
    if (_hallImageCache.containsKey(hallId)) {
      return _hallImageCache[hallId];
    }
    try {
      final ds = HomeRemoteDataSourceImpl(dio: DioClient.instance);
      final hall = await ds.getHallDetails(hallId);
      final imageUrl = (hall.images != null && hall.images!.isNotEmpty)
          ? hall.images!.first
          : null;
      _hallImageCache[hallId] = imageUrl;
      return imageUrl;
    } catch (_) {
      _hallImageCache[hallId] = null;
      return null;
    }
  }
}
