import 'package:flutter_config_pdf_ad_plugins/load/loaded_ad_cache_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CachedAdWidgetLease', () {
    test('allows only one reservation at a time', () {
      final lease = CachedAdWidgetLease();

      expect(lease.tryReserve(timeout: const Duration(seconds: 1)), isTrue);
      expect(lease.tryReserve(timeout: const Duration(seconds: 1)), isFalse);

      lease.release();

      expect(lease.tryReserve(timeout: const Duration(seconds: 1)), isTrue);
      lease.release();
    });

    test('keeps an attached widget leased until release', () {
      final lease = CachedAdWidgetLease();

      expect(
        lease.tryReserve(timeout: const Duration(milliseconds: 10)),
        isTrue,
      );
      expect(lease.attach(), isTrue);
      expect(lease.isHeld, isTrue);
      expect(lease.attach(), isFalse);

      lease.release();

      expect(lease.isHeld, isFalse);
    });

    test('expires a reservation that was never attached', () async {
      final lease = CachedAdWidgetLease();
      var expirationCount = 0;

      expect(
        lease.tryReserve(
          timeout: const Duration(milliseconds: 5),
          onReservationExpired: () => expirationCount++,
        ),
        isTrue,
      );

      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(lease.isHeld, isFalse);
      expect(expirationCount, 1);
    });
  });
}
