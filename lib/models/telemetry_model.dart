/// Data models representing the NephTrap device's Firebase RTDB schema.
///
/// Maps directly to the JSON structure:
/// ```json
/// {
///   "device_nephtrap_01": {
///     "telemetry": { "fly_count", "temp", "humidity", "pressure" },
///     "status":    { "uv_lamp", "battery_level", "trap_box" }
///   }
/// }
/// ```
library;

// ---------------------------------------------------------------------------
// Telemetry
// ---------------------------------------------------------------------------

class TelemetryData {
  final int flyCount;
  final double temp;
  final int humidity;
  final int pressure;

  const TelemetryData({
    required this.flyCount,
    required this.temp,
    required this.humidity,
    required this.pressure,
  });

  factory TelemetryData.fromMap(Map<dynamic, dynamic> map) {
    return TelemetryData(
      flyCount: (map['fly_count'] as num?)?.toInt() ?? 0,
      temp: (map['temp'] as num?)?.toDouble() ?? 0.0,
      humidity: (map['humidity'] as num?)?.toInt() ?? 0,
      pressure: (map['pressure'] as num?)?.toInt() ?? 0,
    );
  }

  /// Returns a default / empty instance for loading states.
  factory TelemetryData.empty() => const TelemetryData(
        flyCount: 0,
        temp: 0,
        humidity: 0,
        pressure: 0,
      );
}

// ---------------------------------------------------------------------------
// Device Status
// ---------------------------------------------------------------------------

class DeviceStatus {
  final String uvLamp; // "AUTO" | "MANUAL_ON" | "MANUAL_OFF"
  final int batteryLevel;
  final String trapBox; // "SAFE" | "ALERT" etc.

  const DeviceStatus({
    required this.uvLamp,
    required this.batteryLevel,
    required this.trapBox,
  });

  factory DeviceStatus.fromMap(Map<dynamic, dynamic> map) {
    return DeviceStatus(
      uvLamp: (map['uv_lamp'] as String?) ?? 'AUTO',
      batteryLevel: (map['battery_level'] as num?)?.toInt() ?? 0,
      trapBox: (map['trap_box'] as String?) ?? 'SAFE',
    );
  }

  factory DeviceStatus.empty() => const DeviceStatus(
        uvLamp: 'AUTO',
        batteryLevel: 0,
        trapBox: 'SAFE',
      );
}

// ---------------------------------------------------------------------------
// Combined Device Data
// ---------------------------------------------------------------------------

class DeviceData {
  final TelemetryData telemetry;
  final DeviceStatus status;

  const DeviceData({
    required this.telemetry,
    required this.status,
  });

  factory DeviceData.fromMap(Map<dynamic, dynamic> map) {
    final telemetryMap =
        (map['telemetry'] as Map<dynamic, dynamic>?) ?? <dynamic, dynamic>{};
    final statusMap =
        (map['status'] as Map<dynamic, dynamic>?) ?? <dynamic, dynamic>{};

    return DeviceData(
      telemetry: TelemetryData.fromMap(telemetryMap),
      status: DeviceStatus.fromMap(statusMap),
    );
  }

  factory DeviceData.empty() => DeviceData(
        telemetry: TelemetryData.empty(),
        status: DeviceStatus.empty(),
      );
}
