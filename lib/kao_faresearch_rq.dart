import 'dart:convert';
import 'package:http/http.dart' as http;
import 'fare_data.dart';

Future<String> sendRequest({
  required String flightType,
  required String fromLoc,
  required String toLoc,
  required String departureDate,
  required int adultNo,
  String? arrivalDate,
  int chdNo = 0, // Default to 0 if not provided
  int infNo = 0, // Default to 0 if not provided
}) async {
  final url = 'http://environment.techlive.vn/Flight/Search';

  final List<Map<String, dynamic>> listFlight = [
    {
      "Leg": 0,
      "StartPoint": fromLoc,
      "EndPoint": toLoc,
      "DepartDate": departureDate
    }
  ];

  // Add return leg if flight type is roundtrip
  if (flightType == 'RT' && arrivalDate != null) {
    listFlight.add({
      "Leg": 1,
      "StartPoint": toLoc,
      "EndPoint": fromLoc,
      "DepartDate": arrivalDate
    });
  }

  final jsonData = {
    "Adt": adultNo,
    "Chd": chdNo,
    "Inf": infNo,
    "System": "VNA",
    "ListFlight": listFlight,
    "MemberUser": "",
    "HeaderUser": "TechLive",
    "HeaderPass": "EVHLt5gvLc6GN6p",
    "AgentCode": "KAO1609",
    "ProductKey": "lxce8dfo0qecglc"
  };

  // Convert JSON data to a string
  final body = json.encode(jsonData);

  // Send the POST request
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    // Check the response status code
    if (response.statusCode == 200) {
      print('Request successful!');
      //print('Response body: ${response.body}');
      
      return response.body;
    } else {
      print('Request failed with status: ${response.statusCode}');
      return ''; 
    }
  } catch (e) {
    print('An error occurred: $e');
    return ''; 
  }
}

void parseAndHandleResponse(String responseBody) {
  try {
    final parsed = jsonDecode(responseBody);
    FlightResponse flightResponse = FlightResponse.fromJson(parsed);

    // Now you can access `flightResponse.fareDataLeg0`, `flightResponse.fareDataLeg1`, etc.
    print("Session: ${flightResponse.session}");
    print("Fare data for leg 0: ${flightResponse.fareDataLeg0.length}");
    print("Fare data for leg 1: ${flightResponse.fareDataLeg1.length}");
  } catch (e) {
    print('Error parsing response: $e');
  }
}
