class FlightResponse {
  final String session;
  final List<FareData> fareDataLeg0;
  final List<FareData> fareDataLeg1;

  FlightResponse({
    required this.session,
    required this.fareDataLeg0,
    required this.fareDataLeg1,
  });

  factory FlightResponse.fromJson(Map<String, dynamic> json) {
    List<FareData> fareDataLeg0 = [];
    List<FareData> fareDataLeg1 = [];

if (json['ListFareData'] != null) {
  json['ListFareData'].forEach((v) {
    FareData fareData = FareData.fromJson(v);

    if (fareData.listOption.isNotEmpty && fareData.listOption[0].listFlight.isNotEmpty) {
      // Iterate over all flights in the listOption
      fareData.listOption[0].listFlight.forEach((flight) {
        if (flight.leg == 0) {
          // Add to fareDataLeg0 if the leg is 0
          fareDataLeg0.add(fareData);
        } else if (flight.leg == 1) {
          // Add to fareDataLeg1 if the leg is 1
          fareDataLeg1.add(fareData);
        }
      });
    }
  });
}


    return FlightResponse(
      session: json['Session'] ?? '', // Default empty string if null
      fareDataLeg0: fareDataLeg0,
      fareDataLeg1: fareDataLeg1,
    );
  }
}

class FareData {
  final int fareDataId;
  final String airline;
  final int itinerary;
  final String currency;
  final String system;
  final int adt;
  final int chd;
  final int inf;
  final double baseFareAdt;
  final double baseFareChd;
  final double baseFareInf;
  final double discountAdt;
  final double discountChd;
  final double discountInf;
  final double agentDiscountAdt;
  final double agentDiscountChd;
  final double agentDiscountInf;
  final double fareAdt;
  final double fareChd;
  final double fareInf;
  final double taxAdt;
  final double taxChd;
  final double taxInf;
  final double serviceFeeAdt;
  final double serviceFeeChd;
  final double serviceFeeInf;
  final double priceAdt;
  final double priceChd;
  final double priceInf;
  final int totalFare;
  final double totalTax;
  final double totalServiceFee;
  final double totalAirlineDiscount;
  final double totalAgentDiscount;
  final int totalPrice;
  final List<Option> listOption;

  FareData({
    required this.fareDataId,
    required this.airline,
    required this.itinerary,
    required this.currency,
    required this.system,
    required this.adt,
    required this.chd,
    required this.inf,
    required this.baseFareAdt,
    required this.baseFareChd,
    required this.baseFareInf,
    required this.discountAdt,
    required this.discountChd,
    required this.discountInf,
    required this.agentDiscountAdt,
    required this.agentDiscountChd,
    required this.agentDiscountInf,
    required this.fareAdt,
    required this.fareChd,
    required this.fareInf,
    required this.taxAdt,
    required this.taxChd,
    required this.taxInf,
    required this.serviceFeeAdt,
    required this.serviceFeeChd,
    required this.serviceFeeInf,
    required this.priceAdt,
    required this.priceChd,
    required this.priceInf,
    required this.totalFare,
    required this.totalTax,
    required this.totalServiceFee,
    required this.totalAirlineDiscount,
    required this.totalAgentDiscount,
    required this.totalPrice,
    required this.listOption,
  });

  factory FareData.fromJson(Map<String, dynamic> json) {
    var listOption = <Option>[];
    if (json['ListOption'] != null) {
      json['ListOption'].forEach((v) {
        listOption.add(Option.fromJson(v));
      });
    }

    return FareData(
      fareDataId: json['FareDataId'] ?? 0, // Default value if null
      airline: json['Airline'] ?? '', // Default empty string if null
      itinerary: json['Itinerary'] ?? 0, // Default value if null
      currency: json['Currency'] ?? '', // Default empty string if null
      system: json['System'] ?? '', // Default empty string if null
      adt: json['Adt'] ?? 0, // Default value if null
      chd: json['Chd'] ?? 0, // Default value if null
      inf: json['Inf'] ?? 0, // Default value if null
      baseFareAdt: (json['BaseFareAdt'] ?? 0.0).toDouble(),
      baseFareChd: (json['BaseFareChd'] ?? 0.0).toDouble(),
      baseFareInf: (json['BaseFareInf'] ?? 0.0).toDouble(),
      discountAdt: (json['DiscountAdt'] ?? 0.0).toDouble(),
      discountChd: (json['DiscountChd'] ?? 0.0).toDouble(),
      discountInf: (json['DiscountInf'] ?? 0.0).toDouble(),
      agentDiscountAdt: (json['AgentDiscountAdt'] ?? 0.0).toDouble(),
      agentDiscountChd: (json['AgentDiscountChd'] ?? 0.0).toDouble(),
      agentDiscountInf: (json['AgentDiscountInf'] ?? 0.0).toDouble(),
      fareAdt: (json['FareAdt'] ?? 0.0).toDouble(),
      fareChd: (json['FareChd'] ?? 0.0).toDouble(),
      fareInf: (json['FareInf'] ?? 0.0).toDouble(),
      taxAdt: (json['TaxAdt'] ?? 0.0).toDouble(),
      taxChd: (json['TaxChd'] ?? 0.0).toDouble(),
      taxInf: (json['TaxInf'] ?? 0.0).toDouble(),
      serviceFeeAdt: (json['ServiceFeeAdt'] ?? 0.0).toDouble(),
      serviceFeeChd: (json['ServiceFeeChd'] ?? 0.0).toDouble(),
      serviceFeeInf: (json['ServiceFeeInf'] ?? 0.0).toDouble(),
      priceAdt: (json['PriceAdt'] ?? 0.0).toDouble(),
      priceChd: (json['PriceChd'] ?? 0.0).toDouble(),
      priceInf: (json['PriceInf'] ?? 0.0).toDouble(),
      totalFare: json['TotalFare'] ?? 0, // Default value if null
      totalTax: (json['TotalTax'] ?? 0.0).toDouble(),
      totalServiceFee: (json['TotalServiceFee'] ?? 0.0).toDouble(),
      totalAirlineDiscount: (json['TotalAirlineDiscount'] ?? 0.0).toDouble(),
      totalAgentDiscount: (json['TotalAgentDiscount'] ?? 0.0).toDouble(),
      totalPrice: json['TotalPrice'] ?? 0, // Default value if null
      listOption: listOption,
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
    var listFlight = <Flight>[];
    if (json['ListFlight'] != null) {
      json['ListFlight'].forEach((v) {
        listFlight.add(Flight.fromJson(v));
      });
    }

    return Option(
      optionId: json['OptionId'] ?? 0, // Default value if null
      listFlight: listFlight,
    );
  }
}

class Flight {
  final int flightId;
  final int leg;
  final String airline;
  final String operating;
  final String startPoint;
  final String endPoint;
  final DateTime startDate;
  final DateTime endDate;
  final String flightNumber;
  final int stopNum;
  final bool hasDownStop;
  final int duration;
  final bool noRefund;
  final String? cabin;
  final String? fareClass;
  final bool promo;
  final String flightValue;
  final List<Segment> listSegment;

  Flight({
    required this.flightId,
    required this.leg,
    required this.airline,
    required this.operating,
    required this.startPoint,
    required this.endPoint,
    required this.startDate,
    required this.endDate,
    required this.flightNumber,
    required this.stopNum,
    required this.hasDownStop,
    required this.duration,
    required this.noRefund,
    this.cabin,
    this.fareClass,
    required this.promo,
    required this.flightValue,
    required this.listSegment,
  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    var listSegment = <Segment>[];
    if (json['ListSegment'] != null) {
      json['ListSegment'].forEach((v) {
        listSegment.add(Segment.fromJson(v));
      });
    }

    return Flight(
      flightId: json['FlightId'] ?? 0, // Default value if null
      leg: json['Leg'] ?? 0, // Default value if null
      airline: json['Airline'] ?? '', // Default empty string if null
      operating: json['Operating'] ?? '', // Default empty string if null
      startPoint: json['StartPoint'] ?? '', // Default empty string if null
      endPoint: json['EndPoint'] ?? '', // Default empty string if null
      startDate: DateTime.parse(json['StartDate'] ?? DateTime.now().toIso8601String()), // Handle null
      endDate: DateTime.parse(json['EndDate'] ?? DateTime.now().toIso8601String()), // Handle null
      flightNumber: json['FlightNumber'] ?? '', // Default empty string if null
      stopNum: json['StopNum'] ?? 0, // Default value if null
      hasDownStop: json['HasDownStop'] ?? false, // Default value if null
      duration: json['Duration'] ?? 0, // Default value if null
      noRefund: json['NoRefund'] ?? false, // Default value if null
      cabin: json['Cabin'], // Nullable
      fareClass: json['FareClass'], // Nullable
      promo: json['Promo'] ?? false, // Default value if null
      flightValue: json['FlightValue'] ?? '', // Default empty string if null
      listSegment: listSegment,
    );
  }
}

class Segment {
  final int indexSegment;
  final int id;
  final String airline;
  final String startPoint;
  final String endPoint;
  final String startTime;
  final String endTime;
  final String flightNumber;
  final int duration;
  final String classType;
  final String fareBasis;
  final String cabin;
  final String cabinName;
  final int seatAvl;
  final String plane;
  final String startTerminal;
  final String endTerminal;
  final String status;
  final bool hasStop;
  final String? stopPoint;
  final double stopTime;
  final bool dayChange;

  Segment({
    required this.indexSegment,
    required this.id,
    required this.airline,
    required this.startPoint,
    required this.endPoint,
    required this.startTime,
    required this.endTime,
    required this.flightNumber,
    required this.duration,
    required this.classType,
    required this.fareBasis,
    required this.cabin,
    required this.cabinName,
    required this.seatAvl,
    required this.plane,
    required this.startTerminal,
    required this.endTerminal,
    required this.status,
    required this.hasStop,
    this.stopPoint,
    required this.stopTime,
    required this.dayChange,
  });

  factory Segment.fromJson(Map<String, dynamic> json) {
    return Segment(
      indexSegment: json['IndexSegment'] ?? 0, // Default value if null
      id: json['Id'] ?? 0, // Default value if null
      airline: json['Airline'] ?? '', // Default empty string if null
      startPoint: json['StartPoint'] ?? '', // Default empty string if null
      endPoint: json['EndPoint'] ?? '', // Default empty string if null
      startTime: json['StartTime'] ?? '', // Default empty string if null
      endTime: json['EndTime'] ?? '', // Default empty string if null
      flightNumber: json['FlightNumber'] ?? '', // Default empty string if null
      duration: json['Duration'] ?? 0, // Default value if null
      classType: json['ClassType'] ?? '', // Default empty string if null
      fareBasis: json['FareBasis'] ?? '', // Default empty string if null
      cabin: json['Cabin'] ?? '', // Default empty string if null
      cabinName: json['CabinName'] ?? '', // Default empty string if null
      seatAvl: json['SeatAvl'] ?? 0, // Default value if null
      plane: json['Plane'] ?? '', // Default empty string if null
      startTerminal: json['StartTerminal'] ?? '', // Default empty string if null
      endTerminal: json['EndTerminal'] ?? '', // Default empty string if null
      status: json['Status'] ?? '', // Default empty string if null
      hasStop: json['HasStop'] ?? false, // Default value if null
      stopPoint: json['StopPoint'], // Nullable
      stopTime: (json['StopTime'] ?? 0.0).toDouble(),
      dayChange: json['DayChange'] ?? false, // Default value if null
    );
  }
}
