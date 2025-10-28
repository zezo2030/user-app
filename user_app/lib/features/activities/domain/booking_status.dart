// Booking status used for filtering in My Activities
enum BookingStatusFilter { all, upcoming, past, cancelled }

extension BookingStatusFilterQuery on BookingStatusFilter {
  String? get apiValue {
    switch (this) {
      case BookingStatusFilter.all:
        return null;
      case BookingStatusFilter.upcoming:
        return 'upcoming';
      case BookingStatusFilter.past:
        return 'past';
      case BookingStatusFilter.cancelled:
        return 'cancelled';
    }
  }
}
