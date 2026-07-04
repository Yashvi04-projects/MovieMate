import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import 'booking_summary_screen.dart';

class SeatSelectionScreen extends StatelessWidget {
  const SeatSelectionScreen({super.key});

  static const List<String> _rows = ['A', 'B', 'C', 'D', 'E', 'F'];
  static const int _seatsPerRow = 5;

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingProvider>();
    final movie = booking.bookingMovie;

    return Scaffold(
      appBar: AppBar(
        title: Text(movie?.name ?? 'Select Seats'),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Center(
              child: Text('SCREEN', style: TextStyle(letterSpacing: 8)),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: _rows.map((row) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          child: Text(row, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        ...List.generate(_seatsPerRow, (index) {
                          final seatId = '$row${index + 1}';
                          final isSelected = booking.selectedSeats.contains(seatId);

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: _SeatWidget(
                              seatId: seatId,
                              isSelected: isSelected,
                              onTap: () => booking.toggleSeat(seatId),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected: ${booking.selectedSeats.join(", ")}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          // BUG-12: Incorrect seat counter
                          Text(
                            'Seats: ${booking.seatCount} | Total: ₹${booking.totalAmount.toInt()}',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _LegendItem(color: Colors.grey.shade300, label: 'Available'),
                          const SizedBox(width: 12),
                          _LegendItem(color: AppTheme.primaryColor, label: 'Selected'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: booking.selectedSeats.isEmpty
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const BookingSummaryScreen(),
                                ),
                              );
                            },
                      child: const Text('Continue'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeatWidget extends StatelessWidget {
  final String seatId;
  final bool isSelected;
  final VoidCallback onTap;

  const _SeatWidget({
    required this.seatId,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            seatId.substring(1),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
