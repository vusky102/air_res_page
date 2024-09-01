class FareData {
  final int fareDataId;
  final String airline;
  final String currency;
  final int totalPrice;
  final List<Option> listOption;

  FareData({
    required this.fareDataId,
    required this.airline,
    required this.currency,
    required this.totalPrice,
    required this.listOption,
  });

  factory FareData.fromJson(Map<String, dynamic> json) {
    return FareData(
      fareDataId: json['FareDataId'],
      airline: json['Airline'],
      currency: json['Currency'],
      totalPrice: json['TotalPrice'].toInt(),
      listOption: (json['ListOption'] as List)
          .map((optionJson) => Option.fromJson(optionJson))
          .toList(),
    );
  }
}

class Option {
  final int optionId;
  final List<Flight> listFlight;

  Option({
    required this.optionId,
    required this.listFlight,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      optionId: json['OptionId'],
      listFlight: (json['ListFlight'] as List)
          .map((flightJson) => Flight.fromJson(flightJson))
          .toList(),
    );
  }
}

class Flight {
  final int flightId;
  final String airline;
  final List<Segment> listSegment;

  Flight({
    required this.flightId,
    required this.airline,
    required this.listSegment,
  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      flightId: json['FlightId'],
      airline: json['Airline'],
      listSegment: (json['ListSegment'] as List)
          .map((segmentJson) => Segment.fromJson(segmentJson))
          .toList(),
    );
  }
}

class Segment {
  final int indexSegment;
  final String startPoint;
  final String endPoint;
  final String startTime;
  final String endTime;

  Segment({
    required this.indexSegment,
    required this.startPoint,
    required this.endPoint,
    required this.startTime,
    required this.endTime,
  });

  factory Segment.fromJson(Map<String, dynamic> json) {
    return Segment(
      indexSegment: json['IndexSegment'],
      startPoint: json['StartPoint'],
      endPoint: json['EndPoint'],
      startTime: json['StartTime'],
      endTime: json['EndTime'],
    );
  }
}
