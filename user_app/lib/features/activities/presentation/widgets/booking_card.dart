import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
                                child: const Icon(Icons.image_not_supported),
                              ),
                            )
                          : Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(Icons.image, size: 40),
                              ),
                            ),
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.people,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'x${widget.booking.persons}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
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
