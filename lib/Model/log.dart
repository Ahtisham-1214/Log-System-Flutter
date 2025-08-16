class Log {
  late String id;
  late String _name;
  late String _detail;
  late String _purpose;
  late String _date;
  late String _timeFrom;
  late String _timeTo;
  late String _remarks;
  late double _initialMeterReading;
  late double _finalMeterReading;
  late double _kilometersCovered;

  Log({
    required String id,
    required String name,
    required String detail,
    required String purpose,
    required String date,
    required String timeFrom,
    required String timeTo,
    required String remarks,
    required double initialMeterReading,
    required double finalMeterReading,
    required double kilometersCovered,
  }) {
    this.id = id;
    this.name = name;
    this.detail = detail;
    this.purpose = purpose;
    this.date = date;
    this.timeFrom = timeFrom;
    this.timeTo = timeTo;
    this.remarks = remarks;
    this.initialMeterReading = initialMeterReading;
    this.finalMeterReading = finalMeterReading;
    this.kilometersCovered = kilometersCovered;
  }

  Log.pickLog({
    required String name,
    required String detail,
    required String purpose,
    required String date,
    required String timeFrom,
    required String remarks,
    required double initialMeterReading,
  }) {
    this.name = name;
    this.detail = detail;
    this.purpose = purpose;
    this.date = date;
    this.timeFrom = timeFrom;
    this.remarks = remarks;
    this.initialMeterReading = initialMeterReading;
    this.finalMeterReading = initialMeterReading;
    kilometersCovered = 0;
  }

  String get name => _name;

  set name(String value) {
    if (value.trim().isEmpty) {
      throw Exception('Name cannot be empty');
    }
    _name = value;
  }

  String get detail => _detail;

  double get kilometersCovered => _kilometersCovered;

  set kilometersCovered(double value) {
    if (value < 0) {
      throw Exception('Kilometers covered cannot be negative');
    }
    _kilometersCovered = value;
  }

  double get finalMeterReading => _finalMeterReading;

  set finalMeterReading(double value) {
    if (value < 0) {
      throw Exception('Final meter reading cannot be negative');
    }
    if (value < _initialMeterReading) {
      throw Exception('Final meter reading cannot be less than initial');
    }
    _finalMeterReading = value;
  }

  double get initialMeterReading => _initialMeterReading;

  set initialMeterReading(double value) {
    if (value < 0) {
      throw Exception('Initial meter reading cannot be negative');
    }
    _initialMeterReading = value;
  }

  String get remarks => _remarks;

  set remarks(String value) {
    if (value.trim().isEmpty) {
      _remarks = 'null';
    }else {
      _remarks = value;
    }
  }

  String get timeTo => _timeTo;

  set timeTo(String value) {
    if (value.trim().isEmpty) {
      throw Exception('Time to cannot be empty');
    }
    _timeTo = value;
  }

  String get timeFrom => _timeFrom;

  set timeFrom(String value) {
    if (value.trim().isEmpty) {
      throw Exception('Time from cannot be empty');
    }
    _timeFrom = value;
  }

  String get date => _date;

  set date(String value) {
    if (value.trim().isEmpty) {
      throw Exception('Date cannot be empty');
    }
    _date = value;
  }

  String get purpose => _purpose;

  set purpose(String value) {
    if (value.trim().isEmpty) {
      throw Exception('Purpose cannot be empty');
    }
    _purpose = value;
  }

  set detail(String value) {
    if (value.trim().isEmpty) {
      throw Exception('Detail cannot be empty');
    }
    _detail = value;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'detail': detail,
      'purpose': purpose,
      'date': date,
      'timeFrom': timeFrom,
      'timeTo': timeTo,
      'remarks': remarks,
      'initialMeterReading': initialMeterReading,
      'finalMeterReading': finalMeterReading,
      'kilometersCovered': kilometersCovered,
    };
  }

  @override
  String toString() {
    return 'Log{id: $id, name: $name, detail: $detail, purpose: $purpose, date: $date, timeFrom: $timeFrom, timeTo: $timeTo, remarks: $remarks, initialMeterReading: $initialMeterReading, finalMeterReading: $finalMeterReading, kilometersCovered: $kilometersCovered}';
  }
  // --- NEW: Factory constructor for creating Log objects from Firebase Map data ---
  factory Log.fromMap(Map<String, dynamic> map) {
    // Handle potential nulls from Firebase for optional fields
    final double? finalMeterReading = (map['finalMeterReading'] as num?)?.toDouble();
    final double? kilometersCovered = (map['kilometersCovered'] as num?)?.toDouble();

    return Log(
      // 'id' from Firebase Realtime Database is usually the push key,
      // which is typically handled separately if you need it.
      // For now, let's assume if it's in the map, we use it, otherwise, an empty string.
      // Or, you might pass the 'key' (the Firebase push ID) from the calling function.
      id: map['id'] as String? ?? '', // Assuming 'id' field is explicitly stored, or assign push key
      name: map['name'] as String,
      detail: map['detail'] as String,
      purpose: map['purpose'] as String,
      date: map['date'] as String,
      timeFrom: map['timeFrom'] as String,
      // Null-safe access for nullable fields
      timeTo: map['timeTo'],
      remarks: map['remarks'],
      initialMeterReading: (map['initialMeterReading'] as num).toDouble(),
      finalMeterReading: finalMeterReading as double,
      kilometersCovered: kilometersCovered as double,
    );
  }
}
