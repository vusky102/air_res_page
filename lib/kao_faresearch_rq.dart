import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> sendRequest({
    required String flightType,
    required String fromLoc,
    required String toLoc,
    required String departureDate,
    required int adultNo,
    String? arrivalDate,
    required int? chdNo,
    required int? infNo,
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
    if (flightType == 'RT') {
      listFlight.add(
        {
          "Leg": 1,
          "StartPoint": toLoc,
          "EndPoint": fromLoc,
          "DepartDate": arrivalDate ?? departureDate 
        }
      );
    }


    final jsonData = {
      "Adt": adultNo,
      "Chd": chdNo ?? 0,
      "Inf": infNo ?? 0,
      "System": "VNA",
      "ListFlight": listFlight,
      "MemberUser": "",
      "HeaderUser": "TechLive",
      "HeaderPass": "EVHLt5gvLc6GN6p",
      "AgentCode": "KAO1609",
      "ProductKey": "lxce8dfo0qecglc"
    };

  //   final requestData = {
  //   'Adt': adultNo,
  //   'Chd': chdNo ?? 0,
  //   'Inf': infNo ?? 0,
  //   'System': 'VNA', // Update as necessary
  //   'ListFlight': listFlight, // Ensure this is a List<Map<String, dynamic>>
  //   'MemberUser': '',
  //   'HeaderUser': 'TechLive',
  //   'HeaderPass': 'EVHLt5gvLc6GN6p',
  //   'AgentCode': 'KAO1609',
  //   'ProductKey': 'lxce8dfo0qecglc',
  //  };
  //   print('Sending request with the following data:');
  //   print(jsonEncode(requestData));

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
        print('Response body: ${response.body}');
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
