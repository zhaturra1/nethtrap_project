import 'dart:async';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';

import '../models/history_model.dart';
import '../models/telemetry_model.dart';

/// Singleton service that mediates all communication with Firebase RTDB.
///
/// Supports a **demo mode** when Firebase is not configured — streams
/// simulated data so the UI can be previewed without a backend.
class FirebaseService {
  // ── Singleton ────────────────────────────────────────────────────────────
  FirebaseService._internal();
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;

  /// When `true`, the service streams fake data instead of hitting Firebase.
  bool _demoMode = false;
  bool get isDemoMode => _demoMode;

  void enableDemoMode() => _demoMode = true;

  // ── Database references ──────────────────────────────────────────────────
  DatabaseReference get _deviceRef =>
      FirebaseDatabase.instance.ref('device_nephtrap_01');

  // ═══════════════════════════════════════════════════════════════════════════
  // REAL-TIME STREAM
  // ═══════════════════════════════════════════════════════════════════════════

  Stream<DeviceData> get deviceStream {
    if (_demoMode) return _demoStream();

    return _deviceRef.onValue.map((DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data == null) return DeviceData.empty();
      return DeviceData.fromMap(data as Map<dynamic, dynamic>);
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WRITE HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> resetFlyCount() async {
    if (_demoMode) {
      _demoFlyCount = 0;
      _pushDemoUpdate();
      return;
    }
    await _deviceRef.child('telemetry/fly_count').set(0);
  }

  Future<void> updateUvLamp(String mode) async {
    if (_demoMode) {
      _demoUvLamp = mode;
      _pushDemoUpdate();
      return;
    }
    await _deviceRef.child('status/uv_lamp').set(mode);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HISTORY STREAMS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Returns the last [days] of daily history records.
  Stream<List<DailyRecord>> getDailyHistory(int days) {
    if (_demoMode) return Stream.value(_generateDemoDaily(days));

    return _deviceRef
        .child('history/daily')
        .orderByKey()
        .limitToLast(days)
        .onValue
        .map((event) {
      final data = event.snapshot.value;
      if (data == null) return <DailyRecord>[];
      final map = data as Map<dynamic, dynamic>;
      final records = map.entries
          .map((e) =>
              DailyRecord.fromMap(e.key as String, e.value as Map<dynamic, dynamic>))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      return records;
    });
  }

  /// Returns hourly records for a specific date.
  Stream<List<HourlyRecord>> getHourlyHistory(String date) {
    if (_demoMode) return Stream.value(_generateDemoHourly(date));

    return _deviceRef
        .child('history/hourly')
        .orderByKey()
        .startAt('${date}_00')
        .endAt('${date}_23')
        .onValue
        .map((event) {
      final data = event.snapshot.value;
      if (data == null) return <HourlyRecord>[];
      final map = data as Map<dynamic, dynamic>;
      final records = map.entries
          .map((e) =>
              HourlyRecord.fromMap(e.key as String, e.value as Map<dynamic, dynamic>))
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return records;
    });
  }

  /// Returns the monthly report for a given year-month (e.g. "2026-06").
  Future<MonthlyReport?> getMonthlyReport(String yearMonth) async {
    if (_demoMode) return _generateDemoMonthlyReport(yearMonth);

    final snapshot = await _deviceRef.child('reports/$yearMonth').get();
    if (!snapshot.exists || snapshot.value == null) return null;
    return MonthlyReport.fromMap(
        yearMonth, snapshot.value as Map<dynamic, dynamic>);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DEMO MODE — REAL-TIME
  // ═══════════════════════════════════════════════════════════════════════════

  int _demoFlyCount = 142;
  String _demoUvLamp = 'AUTO';
  StreamController<DeviceData>? _demoController;

  Stream<DeviceData> _demoStream() {
    _demoController?.close();
    _demoController = StreamController<DeviceData>.broadcast();

    Future.microtask(() => _pushDemoUpdate());

    Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_demoController?.isClosed ?? true) {
        timer.cancel();
        return;
      }
      _demoFlyCount += 1;
      _pushDemoUpdate();
    });

    return _demoController!.stream;
  }

  void _pushDemoUpdate() {
    _demoController?.add(DeviceData(
      telemetry: TelemetryData(
        flyCount: _demoFlyCount,
        temp: 28.5,
        humidity: 70,
        pressure: 1011,
      ),
      status: DeviceStatus(
        uvLamp: _demoUvLamp,
        batteryLevel: 85,
        trapBox: 'SAFE',
      ),
    ));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DEMO MODE — HISTORICAL DATA GENERATORS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Cache so repeated calls return the same data within a session.
  List<DailyRecord>? _cachedDemoDaily;

  List<DailyRecord> _generateDemoDaily(int days) {
    if (_cachedDemoDaily != null && _cachedDemoDaily!.length >= days) {
      return _cachedDemoDaily!.sublist(_cachedDemoDaily!.length - days);
    }

    final rng = Random(42); // fixed seed for reproducibility
    final now = DateTime.now();
    final records = <DailyRecord>[];

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));

      // Simulate realistic seasonal variation
      // Base temp rises over the month, humidity fluctuates
      final dayProgress = (days - i) / days;
      final baseTemp = 26.0 + dayProgress * 4.0; // 26→30°C rising trend
      final baseHumidity = 60.0 + dayProgress * 15.0; // 60→75% rising trend
      final baseFlyCount = 80 + (dayProgress * 120).toInt(); // increasing flies

      records.add(DailyRecord(
        date: DateTime(date.year, date.month, date.day),
        flyCount: baseFlyCount + rng.nextInt(30) - 10,
        tempAvg: baseTemp + rng.nextDouble() * 2 - 1,
        humidityAvg: baseHumidity + rng.nextDouble() * 8 - 4,
        pressureAvg: 1008.0 + rng.nextDouble() * 6,
      ));
    }

    _cachedDemoDaily = records;
    return records;
  }

  List<HourlyRecord> _generateDemoHourly(String date) {
    final rng = Random(date.hashCode);
    final baseDate = DateTime.tryParse(date) ?? DateTime.now();
    final records = <HourlyRecord>[];

    for (int hour = 0; hour < 24; hour++) {
      // Temperature peaks at 14:00, lowest at 04:00
      final tempCurve = sin((hour - 4) * pi / 12) * 4;
      final temp = 27.0 + tempCurve + rng.nextDouble() - 0.5;

      // Humidity inverse to temperature
      final humidity = 75.0 - tempCurve * 2 + rng.nextDouble() * 3;

      // Flies more active during warm hours
      final flyBase = (temp > 28 ? 12 : 5).toInt();

      records.add(HourlyRecord(
        timestamp: DateTime(baseDate.year, baseDate.month, baseDate.day, hour),
        flyCount: flyBase + rng.nextInt(8),
        temp: temp,
        humidity: humidity,
      ));
    }

    return records;
  }

  MonthlyReport _generateDemoMonthlyReport(String yearMonth) {
    final daily = _generateDemoDaily(30);
    return MonthlyReport.compute(yearMonth: yearMonth, dailyRecords: daily);
  }
}
