import 'dart:convert';
import 'package:http/http.dart' as http;


Future<void> sendSoapRequest({
  required String flightType,
  required String fromLoc,
  required String toLoc,
  required String departureDate,
  required int adultNo,
  String? arrivalDate,
  int? chdNo,
  int? infNo,
}) async {
  // Your API URL
  const String url = 'https://apac.universal-api.pp.travelport.com/B2BGateway/connect/uAPI/AirService';

  // Encode authentication details
  const String username = 'Universal API/uAPI7426835859-9d6c0257';
  const String password = 'i+5JA4r!m/';
  String authHeader = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';

  // Headers for the request
  Map<String, String> headers = {
    'Content-Type': 'text/xml; charset=utf-8',
    'Accept': 'gzip,deflate',
    'Authorization': authHeader,
  };

  StringBuffer passengerXml = StringBuffer();

  for (int i = 0; i < adultNo; i++) {
    passengerXml.write('<com:SearchPassenger BookingTravelerRef="ADT01" Code="ADT"/>');
  }
  if (chdNo != null && chdNo > 0) {
    for (int i = 0; i < chdNo; i++) {
      passengerXml.write('<com:SearchPassenger BookingTravelerRef="CNN02" Code="CNN" Age="10" />');
    }
  }

  if (infNo != null && infNo > 0) {
    for (int i = 0; i < infNo; i++) {
      passengerXml.write('<com:SearchPassenger BookingTravelerRef="INF03" Code="INF" Age="1" />');
    }   
  }

  // Build the SOAP request body based on trip type
  String body = '';
  if (flightType.toLowerCase() == 'OW') {
    body = """
      <soapenv:Envelope xmlns:air="http://www.travelport.com/schema/air_v50_0" xmlns:com="http://www.travelport.com/schema/common_v50_0" xmlns:unv="http://www.travelport.com/schema/universal_v49_0" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
        <soap:Body>
          <air:LowFareSearchReq AuthorizedBy="MODETOUREDEV" TraceId="" TargetBranch="" ReturnUpsellFare="false"  SolutionResult="true" xmlns:air="http://www.travelport.com/schema/air_v52_0" xmlns:com="http://www.travelport.com/schema/common_v52_0">
            <com:BillingPointOfSaleInfo OriginApplication="uAPI"/>
            <air:SearchAirLeg>
              <air:SearchOrigin>
                <com:Airport Code="$fromLoc"/>
              </air:SearchOrigin>
              <air:SearchDestination>
                <com:Airport Code="$toLoc"/>
              </air:SearchDestination>
              <air:SearchDepTime PreferredTime="$departureDate"/>
            </air:SearchAirLeg>
            <air:AirSearchModifiers>
              <air:PreferredProviders>
                <com:Provider Code="1G"/>
              </air:PreferredProviders>
              <air:FlightType DoubleInterlineCon="false" DoubleOnlineCon="false" SingleInterlineCon="false" SingleOnlineCon="false" StopDirects="true" NonStopDirects="true"/>
            </air:AirSearchModifiers>
            $passengerXml
            <air:AirPricingModifiers ETicketability="Required" FaresIndicator="AllFares"/>
          </air:LowFareSearchReq>
        </soap:Body>
      </soap:Envelope>
    """;
  } else if (flightType.toLowerCase() == 'RT') {
    // Round trip request body
    body = """
      <soapenv:Envelope xmlns:air="http://www.travelport.com/schema/air_v50_0" xmlns:com="http://www.travelport.com/schema/common_v50_0" xmlns:unv="http://www.travelport.com/schema/universal_v49_0" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
        <soap:Body>
          <air:LowFareSearchReq AuthorizedBy="MODETOUREDEV" TraceId="" TargetBranch="" ReturnUpsellFare="false"  SolutionResult="true" xmlns:air="http://www.travelport.com/schema/air_v52_0" xmlns:com="http://www.travelport.com/schema/common_v52_0">
            <com:BillingPointOfSaleInfo OriginApplication="uAPI"/>
            <air:SearchAirLeg>
              <air:SearchOrigin>
                <com:Airport Code="$fromLoc"/>
              </air:SearchOrigin>
              <air:SearchDestination>
                <com:Airport Code="$toLoc"/>
              </air:SearchDestination>
              <air:SearchDepTime PreferredTime="$departureDate"/>
            </air:SearchAirLeg>
            <air:SearchAirLeg>
              <air:SearchOrigin>
                <com:Airport Code="$toLoc"/>
              </air:SearchOrigin>
              <air:SearchDestination>
                <com:Airport Code="$fromLoc"/>
              </air:SearchDestination>
              <air:SearchDepTime PreferredTime="$arrivalDate"/>
            </air:SearchAirLeg>
            <air:AirSearchModifiers>
              <air:PreferredProviders>
                <com:Provider Code="1G"/>
              </air:PreferredProviders>
                <air:PermittedCabins>
                  <com:CabinClass Type="Economy"/>
                </air:PermittedCabins>
              <air:FlightType DoubleInterlineCon="false" SingleInterlineCon="true" DoubleOnlineCon="false" SingleOnlineCon="true" StopDirects="true" NonStopDirects="true"/>
            </air:AirSearchModifiers>
            $passengerXml
            <air:AirPricingModifiers FaresIndicator="AllFares" ETicketability="Required">
            </air:AirPricingModifiers>
          </air:LowFareSearchReq>
        </soap:Body>
      </soap:Envelope>
    """;
  }

  // Send the POST request
  try {
    http.Response response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    // Check the response status
    if (response.statusCode == 200) {
      print('Response data: ${response.body}');
      // You can further process the response here
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  } catch (e) {
    print('Error sending SOAP request: $e');
  }
}
