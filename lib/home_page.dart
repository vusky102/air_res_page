import 'package:air_reservation/hugeicons.dart';
import 'package:flutter/material.dart';
import 'styles.dart';
import 'city_list.dart';
import 'kao_faresearch_rq.dart';
import 'package:intl/intl.dart';
import 'fare_data.dart';
import 'dart:convert';
import 'air_logo_map.dart';
import 'passenger_page.dart';

class HomePage extends StatefulWidget {
  final void Function(int) onConfirm;
  const HomePage({super.key, required this.onConfirm});


  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final TextEditingController _departureDateController = TextEditingController();
  final TextEditingController _returnDateController = TextEditingController();
  int adultNo = 1;
  int chdNo = 0;
  int infNo = 0;
  String _flightType = 'RT'; // default type
  String _fromLoc = ''; // State to store the selected departure location
  String _toLoc = ''; // State to store the selected arrival location
  late bool shouldShowReturnDateField;
  int? _selectedFlightId; // State variable to track selected flight ID
  String? _selectedFlightValue0;
  String? _selectedFlightValue1;
  int? _itineraryNo;
  int? _selectedRadio;
  bool _isLoading = false;
  bool _hasSearched = false; // Track whether a search has been performed
  bool _showReturnFlight=false;
  late bool _isDomestic;

  // State variable to hold flight data leg0
  List<FareData> _fareData0= [];
  List<Flight> _flight0=[];
  List<Segment> _segment0=[];
  List<int> _fareID0=[];
  
  List<FareData> _fareData1= [];
  List<Flight> _flight1=[];
  List<Segment> _segment1=[];
  List<int> _fareID1=[];

  List<Flight> _flight2=[];
  List<Segment> _segment2=[];
  List<Flight> _flight3=[];
  List<Segment> _segment3=[];

  List<Segment> _stopSegment10=[];
  List<Segment?> _stopSegment11=[];
  List<Segment> _stopSegment20=[];
  List<Segment?> _stopSegment21=[];

  @override
  void initState() {
    super.initState();
    shouldShowReturnDateField = _flightType == 'RT';
  }

  void _updateFlightType(String newType) {
    setState(() {
      _flightType = newType;
      shouldShowReturnDateField = _flightType == 'RT'; // Update visibility based on the new flight type
    });
  }

  List<DropdownMenuItem<int>> _buildDropdownItems(int start, int end) {
    return List<DropdownMenuItem<int>>.generate(
      end - start + 1,
      (index) => DropdownMenuItem<int>(
        value: start + index,
        child: Text('${start + index}'),
      ),
    );
  }

  String extractAirportCode(String location) {
    final RegExp regExp = RegExp(r'\((\w+)\)$');
    final match = regExp.firstMatch(location);
    if (match != null && match.groupCount > 0) {
      return match.group(1) ?? '';
    }
    return '';
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final formattedDate = DateFormat('ddMMyyyy').format(pickedDate);
      setState(() {
        controller.text = formattedDate;
      });
    }
  }

  Widget buildAutocompleteField({
  required BuildContext context,
  required String labelText,
  required Function(String) onSelected,
  required String initialValue,
}) {
  return Autocomplete<String>(
    optionsBuilder: (TextEditingValue textEditingValue) {
      if (textEditingValue.text.isEmpty) {
        return const Iterable<String>.empty();
      }

      final input = textEditingValue.text.toLowerCase();

      // Flatten the nested map to filter and format the options
      final options = <String>{};
      for (var country in cityCountryMap.keys) {
        final cityMap = cityCountryMap[country]!;
        for (var entry in cityMap.entries) {
          final city = entry.key;
          final code = entry.value;
          if (city.toLowerCase().contains(input) || code.toLowerCase().contains(input)) {
            options.add('$city ($code)');
          }
        }
      }

      return options;
    },
    onSelected: (String selected) {
      final code = extractAirportCode(selected);
      onSelected(code);
    },
    fieldViewBuilder: (BuildContext context,
        TextEditingController fieldTextEditingController,
        FocusNode fieldFocusNode,
        VoidCallback onFieldSubmitted) {
      fieldTextEditingController.text = initialValue;

      return TextField(
        controller: fieldTextEditingController,
        focusNode: fieldFocusNode,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
          labelStyle: style2(context),
        ),
        style: style2(context),
        onSubmitted: (String value) {
          onFieldSubmitted();
        },
      );
    },
  );
}



Future<void> _searchFlights() async {
  setState(() {
    _isLoading = true;
    _showReturnFlight = false;
    _fareData0.clear();
    _flight0.clear();
    _segment0.clear();
    _fareID0.clear();
    _fareData1.clear();
    _flight1.clear();
    _segment1.clear();
    _segment2.clear();
    _segment3.clear();
    _fareID1.clear();
    _flight2.clear();
    _flight3.clear();
    _selectedFlightId=null;
    _selectedFlightValue0=null;
    _selectedFlightValue1=null;
    _selectedRadio=null;
  });

  if (_fromLoc.isEmpty || _toLoc.isEmpty || _departureDateController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please fill in all required fields.')),
    );
    setState(() {
      _isLoading = false;
    });
    return;
  }

  try {
    final response = await sendRequest(
      flightType: _flightType,
      fromLoc: _fromLoc,
      toLoc: _toLoc,
      departureDate: _departureDateController.text,
      arrivalDate: _flightType == 'RT' ? _returnDateController.text : null,
      adultNo: adultNo,
      chdNo: chdNo,
      infNo: infNo,
    );

    //print('API Response: $response'); // Print the raw response

    if (response.isNotEmpty) {
      // Parse the response to extract flight data
      final parsed = jsonDecode(response);
      FlightResponse flightResponse = FlightResponse.fromJson(parsed);
      print("Fare data for leg 0: ${flightResponse.fareDataLeg0.length}");
      print("Fare data for leg 1: ${flightResponse.fareDataLeg1.length}");
      // Update the state with the new data
      setState(() {
        _hasSearched = true; // Update search status
        _isDomestic = findCountry(_toLoc)=='Vietnam' && findCountry(_fromLoc)=='Vietnam'? true: false;
        _fareData0 = flightResponse.fareDataLeg0.toList();
        _flight0= flightResponse.fareDataLeg0
          .expand((fareData) => fareData.listOption)
          .expand((listOption) => listOption.listFlight)
          .toList();
        
        _segment0=flightResponse.fareDataLeg0
          .expand((fareData) => fareData.listOption)
          .expand((listOption) => listOption.listFlight)
          .expand((listFlight) => listFlight.listSegment).toList();
        
        _fareID0= _fareData0.map((fareData0) => fareData0.fareDataId).toList();

        
        _fareData1 = flightResponse.fareDataLeg1.toList();
        _flight1= flightResponse.fareDataLeg1
          .expand((fareData) => fareData.listOption)
          .expand((listOption) => listOption.listFlight)
          .toList();
        
        _segment1=flightResponse.fareDataLeg1
          .expand((fareData) => fareData.listOption)
          .expand((listOption) => listOption.listFlight)
          .expand((listFlight) => listFlight.listSegment).toList();
        
        _fareID1= _fareData1.map((fareData1) => fareData1.fareDataId).toList();

        _flight2=flightResponse.fareDataLeg0
          .expand((fareData) => fareData.listOption)
          .map((listOption) => listOption.listFlight[0])
          .toList();

        _segment2= _flight2.expand((flight)=> flight.listSegment).toList();
        _stopSegment10 = _flight2.map((flight) =>flight.listSegment[0]).toList();
        _stopSegment11 = _flight2.map((flight) {
            // Check if the flight has a second segment, if not return null
            return flight.listSegment.length > 1 ? flight.listSegment[1] : null;
          }).toList();

        _flight3=flightResponse.fareDataLeg0
          .expand((fareData) => fareData.listOption)
          .map((listOption) => listOption.listFlight[1])
          .toList();
        _segment3= _flight3.expand((flight)=> flight.listSegment).toList();
        _stopSegment20 = _flight3.map((flight) =>flight.listSegment[0]).toList();
        _stopSegment21 = _flight3.map((flight) {
            // Check if the flight has a second segment, if not return null
            return flight.listSegment.length > 1 ? flight.listSegment[1] : null;
          }).toList();
        
        print('$_stopSegment10 , $_stopSegment11, $_stopSegment20, $_stopSegment21');
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load flight data.')),
      );
    }
  } catch (e) {
    print('An error occurred: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred while searching for flights.')),
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    appBar: AppBar(
      title: Text('Search Flights', style: style(context)),
      backgroundColor: Theme.of(context).colorScheme.primary,
    ),
    body: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Flight Type Selection
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text(
                        'Round Trip',
                        style: style2(context),
                      ),
                      value: 'RT',
                      groupValue: _flightType,
                      onChanged: (String? value) {
                        setState(() {
                          if (value != null) _updateFlightType(value);
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text(
                        'One Way',
                        style: style2(context),
                      ),
                      value: 'OW',
                      groupValue: _flightType,
                      onChanged: (String? value) {
                        setState(() {
                          if (value != null) _updateFlightType(value);
                        });
                      },
                    ),
                  ),
                ],
              ),
              // Locations and Swap Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: buildAutocompleteField(
                      context: context,
                      labelText: 'From',
                      onSelected: (String dept) {
                        setState(() {
                          _fromLoc = dept;
                        });
                      },
                      initialValue: _fromLoc,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            final temp = _fromLoc;
                            _fromLoc = _toLoc;
                            _toLoc = temp;
                          });
                        },
                        child: const Icon(
                          HugeIcons.strokeRoundedArrowDataTransferHorizontal,
                          size: 30,
                          color: Color.fromARGB(255, 248, 248, 248),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: buildAutocompleteField(
                      context: context,
                      labelText: 'To',
                      onSelected: (String arvl) {
                        setState(() {
                          _toLoc = arvl;
                        });
                      },
                      initialValue: _toLoc,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Departure Date
              TextField(
                controller: _departureDateController,
                decoration: InputDecoration(
                  labelText: 'Departure Date',
                  border: const OutlineInputBorder(),
                  labelStyle: style2(context),
                ),
                readOnly: true,
                onTap: () => _selectDate(context, _departureDateController),
              ),
              const SizedBox(height: 16),
              // Return Date (Conditional)
              if (_flightType == 'RT')
                TextField(
                  controller: _returnDateController,
                  decoration: InputDecoration(
                    labelText: 'Return Date',
                    border: const OutlineInputBorder(),
                    labelStyle: style2(context),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context, _returnDateController),
                ),
              const SizedBox(height: 16),
              // Passengers Selection
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Adults', style: style2(context)),
                  DropdownButton<int>(
                    style: style3(context),
                    value: adultNo,
                    dropdownColor: themeColor.withAlpha(1),
                    items: _buildDropdownItems(1, 9),
                    onChanged: (newValue) {
                      setState(() {
                        adultNo = newValue!;
                      });
                    },
                  ),
                  Text('Children', style: style2(context)),
                  DropdownButton<int>(
                    style: style3(context),
                    value: chdNo,
                    dropdownColor: themeColor.withAlpha(1),
                    items: _buildDropdownItems(0, 9),
                    onChanged: (newValue) {
                      setState(() {
                        chdNo = newValue!;
                      });
                    },
                  ),
                  Text('Infants', style: style2(context)),
                  DropdownButton<int>(
                    style: style3(context),
                    value: infNo,
                    dropdownColor: themeColor.withAlpha(1),
                    items: _buildDropdownItems(0, 9),
                    onChanged: (newValue) {
                      setState(() {
                        infNo = newValue!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Search Button
              ElevatedButton(
                onPressed: _searchFlights,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: Text('Search', style: style2(context)),
              ),
              const SizedBox(height: 16),
              // Flights List
              Expanded(
                child: Stack(
                  children: [
                    if (!_isLoading)
                      _flight0.isEmpty
                          ? Center(
                              child: Text(_hasSearched
                                  ? 'No flights available'
                                  : 'No search request yet, press search for result'))
                          : !(_showReturnFlight) ? ListView.builder(
                              itemCount: _fareID0.length,
                              itemBuilder: (context, index) {
                                final flight = _fareData0[index].itinerary==1 ? _flight0[index] : _flight2[index];
                                final fareData= _fareData0[index];
                                
                                // final segment0 = _fareData0[index].itinerary==1? _segment0[index] : _segment2[index];
                                
                                final stopSegment = _stopSegment10[index];
                                final stopCityCode = stopSegment != null ? stopSegment.stopPoint : null;
                                final stopCity = stopCityCode != null ? getCityNameFromCode(stopCityCode) : stopCityCode;
                                
                                final startPointCity = getCityNameFromCode(flight.startPoint);
                                final endPointCity = getCityNameFromCode(flight.endPoint);
                                final deptTime = DateFormat.Hm().format(DateTime.parse(flight.startDate));
                                final deptDate = DateFormat.yMd().format(DateTime.parse(flight.startDate));
                                final arrvDate = DateFormat.yMd().format(DateTime.parse(flight.endDate));
                                final arrvTime = DateFormat.Hm().format(DateTime.parse(flight.endDate));
                                String? airlineLogoPath = airlineLogos[flight.airline];

                                final formattedPrice = NumberFormat('#,##0').format(fareData.totalPrice);
                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white, // Background color
                                    borderRadius: BorderRadius.circular(15.0), // Rounded corners
                                    boxShadow: [ // Optional: Add shadow for better visual appeal
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 8.0,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    title: airlineLogoPath != null
                                        ? Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                airlineLogoPath,
                                                width: 65,  // Adjust the width and height as needed
                                                height: 65,
                                                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                                  // Fallback in case the image is not found
                                                  return Text('Airline: ${flight.airline}');
                                                },
                                              ),
                                              Text(flight.flightNumber),
                                            ]
                                          )
                                        : Text('Airline: ${flight.airline}'),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Column(
                                              children: [
                                                Text(deptDate),
                                                Text(
                                                  deptTime,
                                                  style: TextStyle(color: themeColor, fontSize: 20, fontWeight: FontWeight.bold),
                                                ),
                                                Text(startPointCity),
                                              ]
                                            ),
                                            Image.asset(
                                              'assets/segment_line.png',
                                              width: 120,  // Adjust the width and height as needed
                                              height: 50,
                                            ),
                                            Column(
                                              children: [
                                                Text(arrvDate),
                                                Text(
                                                  arrvTime,
                                                  style: TextStyle(color: themeColor, fontSize: 20, fontWeight: FontWeight.bold),
                                                ),
                                                Text(endPointCity),
                                              ]
                                            ),
                                          ]
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [Text(flight.stopNum>0? 'Stop: ${flight.stopNum} - ${stopCity}':'Nonstop'),]
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              '$formattedPrice ${fareData.currency}',
                                              style: TextStyle(color: themeColor, fontSize: 18, fontWeight: FontWeight.bold)
                                            ),
                                          ]
                                        ),
                                      ],
                                    ),
                                    leading: Radio<int>(
                                      value: fareData.fareDataId,
                                      groupValue: _selectedFlightId,
                                      onChanged: (int? value) {
                                        setState(() {
                                          _selectedFlightId = value;
                                          _selectedRadio=value;
                                          _itineraryNo= fareData.itinerary;
                                          _selectedFlightValue0 = flight.flightValue;
                                        });
                                      },
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _selectedFlightId = fareData.fareDataId;
                                        _selectedRadio=fareData.fareDataId;
                                        _itineraryNo= fareData.itinerary;
                                        _selectedFlightValue0 = flight.flightValue;
                                      });
                                    },
                                  )
                                );
                              },
                            ) : _flightType =='RT' && _isDomestic
                            ?
                            ListView.builder(
                              itemCount: _fareID1.length,
                              itemBuilder: (context, index) {

                                final flight = _flight1[index];
                                final fareData= _fareData1[index];
                                
                                // final segment0 = _fareData0[index].itinerary==1 ? _segment1[index] : _segment3[index];
                                
                                final startPointCity = getCityNameFromCode(flight.startPoint);
                                final endPointCity = getCityNameFromCode(flight.endPoint);
                                final deptTime = DateFormat.Hm().format(DateTime.parse(flight.startDate));
                                final deptDate = DateFormat.yMd().format(DateTime.parse(flight.startDate));
                                final arrvDate = DateFormat.yMd().format(DateTime.parse(flight.endDate));
                                final arrvTime = DateFormat.Hm().format(DateTime.parse(flight.endDate));
                                String? airlineLogoPath = airlineLogos[flight.airline];

                                final formattedPrice = NumberFormat('#,##0').format(fareData.totalPrice);
                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white, // Background color
                                    borderRadius: BorderRadius.circular(15.0), // Rounded corners
                                    boxShadow: [ // Optional: Add shadow for better visual appeal
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 8.0,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    title: airlineLogoPath != null
                                        ? Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                airlineLogoPath,
                                                width: 65,  // Adjust the width and height as needed
                                                height: 65,
                                                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                                  // Fallback in case the image is not found
                                                  return Text('Airline: ${flight.airline}');
                                                },
                                              ),
                                              Text(flight.flightNumber),
                                            ]
                                          )
                                        : Text('Airline: ${flight.airline}'),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Column(
                                              children: [
                                                Text(deptDate),
                                                Text(
                                                  deptTime,
                                                  style: TextStyle(color: themeColor, fontSize: 20, fontWeight: FontWeight.bold),
                                                ),
                                                Text(startPointCity),
                                              ]
                                            ),
                                            Image.asset(
                                              'assets/segment_line.png',
                                              width: 120,  // Adjust the width and height as needed
                                              height: 50,
                                            ),
                                            Column(
                                              children: [
                                                Text(arrvDate),
                                                Text(
                                                  arrvTime,
                                                  style: TextStyle(color: themeColor, fontSize: 20, fontWeight: FontWeight.bold),
                                                ),
                                                Text(endPointCity),
                                              ]
                                            ),
                                          ]
                                        ),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [Text(flight.stopNum>0? 'Stop: ${flight.stopNum}':'Nonstop'),]
                                        ),

                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              '$formattedPrice ${fareData.currency}',
                                              style: TextStyle(color: themeColor, fontSize: 18, fontWeight: FontWeight.bold)
                                            ),
                                          ]
                                        ),
                                      ],
                                    ),
                                    leading: Radio<int>(
                                      value: fareData.fareDataId,
                                      groupValue: _selectedFlightId,
                                      onChanged: (int? value) {
                                        setState(() {
                                          _selectedFlightId = value;
                                          _selectedRadio=value;
                                          _selectedFlightValue1=flight.flightValue;

                                        });
                                      },
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _selectedFlightId = fareData.fareDataId;
                                        _selectedRadio=fareData.fareDataId;
                                        _selectedFlightValue1=flight.flightValue;
                                      });
                                    },
                                  )
                                );
                              },
                            ) 
                            :
                            _flightType =='RT' && !(_isDomestic) && _itineraryNo==1 ?
                            ListView.builder(
                              itemCount: _fareID1.length,
                              itemBuilder: (context, index) {

                                final flight = _flight3[index];
                                final fareData= _fareData1[index];
                                
                                // final segment0 = _fareData0[index].itinerary==1 ? _segment1[index] : _segment3[index];
                                final stopSegment = _stopSegment20[index];
                                final stopCityCode = stopSegment != null ? stopSegment.stopPoint : null;
                                final stopCity = stopCityCode != null ? getCityNameFromCode(stopCityCode) : stopCityCode;

                                final startPointCity = getCityNameFromCode(flight.startPoint);
                                final endPointCity = getCityNameFromCode(flight.endPoint);
                                final deptTime = DateFormat.Hm().format(DateTime.parse(flight.startDate));
                                final deptDate = DateFormat.yMd().format(DateTime.parse(flight.startDate));
                                final arrvDate = DateFormat.yMd().format(DateTime.parse(flight.endDate));
                                final arrvTime = DateFormat.Hm().format(DateTime.parse(flight.endDate));
                                String? airlineLogoPath = airlineLogos[flight.airline];

                                final formattedPrice = NumberFormat('#,##0').format(fareData.totalPrice);
                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white, // Background color
                                    borderRadius: BorderRadius.circular(15.0), // Rounded corners
                                    boxShadow: [ // Optional: Add shadow for better visual appeal
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 8.0,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    title: airlineLogoPath != null
                                        ? Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                airlineLogoPath,
                                                width: 65,  // Adjust the width and height as needed
                                                height: 65,
                                                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                                  // Fallback in case the image is not found
                                                  return Text('Airline: ${flight.airline}');
                                                },
                                              ),
                                              Text(flight.flightNumber),
                                            ]
                                          )
                                        : Text('Airline: ${flight.airline}'),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Column(
                                              children: [
                                                Text(deptDate),
                                                Text(
                                                  deptTime,
                                                  style: TextStyle(color: themeColor, fontSize: 20, fontWeight: FontWeight.bold),
                                                ),
                                                Text(startPointCity),
                                              ]
                                            ),
                                            Image.asset(
                                              'assets/segment_line.png',
                                              width: 120,  // Adjust the width and height as needed
                                              height: 50,
                                            ),
                                            Column(
                                              children: [
                                                Text(arrvDate),
                                                Text(
                                                  arrvTime,
                                                  style: TextStyle(color: themeColor, fontSize: 20, fontWeight: FontWeight.bold),
                                                ),
                                                Text(endPointCity),
                                              ]
                                            ),
                                          ]
                                        ),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [Text(flight.stopNum>0? 'Stop: ${flight.stopNum}- $stopCity':'Nonstop'),]
                                        ),

                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              '$formattedPrice ${fareData.currency}',
                                              style: TextStyle(color: themeColor, fontSize: 18, fontWeight: FontWeight.bold)
                                            ),
                                          ]
                                        ),
                                      ],
                                    ),
                                    leading: Radio<int>(
                                      value: fareData.fareDataId,
                                      groupValue: _selectedFlightId,
                                      onChanged: (int? value) {
                                        setState(() {
                                          _selectedFlightId = value;
                                          _selectedRadio=value;
                                          _selectedFlightValue1=flight.flightValue;

                                        });
                                      },
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _selectedFlightId = fareData.fareDataId;
                                        _selectedRadio=fareData.fareDataId;
                                        _selectedFlightValue1=flight.flightValue;
                                      });
                                    },
                                  )
                                );
                              },
                            ) : 
                            ListView.builder(
                              itemCount: _itineraryNo!-1,
                              itemBuilder: (context, index) {

                                final flight = _fareData1[_selectedFlightId!].itinerary==1 ? _flight1[_selectedFlightId!] : _flight3[_selectedFlightId!];
                                final fareData= _fareData1[_selectedFlightId!];
                                
                                // final segment0 = _fareData0[_selectedFlightId!].itinerary==1? _segment1[_selectedFlightId!] : _segment3[_selectedFlightId!];

                                final startPointCity = getCityNameFromCode(flight.startPoint);
                                final endPointCity = getCityNameFromCode(flight.endPoint);
                                final stopSegment = _stopSegment20[_selectedFlightId!];
                                final stopCityCode = stopSegment != null ? stopSegment.stopPoint : null;
                                final stopCity = stopCityCode != null ? getCityNameFromCode(stopCityCode) : stopCityCode;
                                final deptTime = DateFormat.Hm().format(DateTime.parse(flight.startDate));
                                final deptDate = DateFormat.yMd().format(DateTime.parse(flight.startDate));
                                final arrvDate = DateFormat.yMd().format(DateTime.parse(flight.endDate));
                                final arrvTime = DateFormat.Hm().format(DateTime.parse(flight.endDate));
                                String? airlineLogoPath = airlineLogos[flight.airline];

                                final formattedPrice = NumberFormat('#,##0').format(fareData.totalPrice);
                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white, // Background color
                                    borderRadius: BorderRadius.circular(15.0), // Rounded corners
                                    boxShadow: [ // Optional: Add shadow for better visual appeal
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 8.0,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    title: airlineLogoPath != null
                                        ? Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                airlineLogoPath,
                                                width: 65,  // Adjust the width and height as needed
                                                height: 65,
                                                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                                  // Fallback in case the image is not found
                                                  return Text('Airline: ${flight.airline}');
                                                },
                                              ),
                                              Text(flight.flightNumber),
                                            ]
                                          )
                                        : Text('Airline: ${flight.airline}'),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Column(
                                              children: [
                                                Text(deptDate),
                                                Text(
                                                  deptTime,
                                                  style: TextStyle(color: themeColor, fontSize: 20, fontWeight: FontWeight.bold),
                                                ),
                                                Text(startPointCity),
                                              ]
                                            ),
                                            Image.asset(
                                              'assets/segment_line.png',
                                              width: 120,  // Adjust the width and height as needed
                                              height: 50,
                                            ),
                                            Column(
                                              children: [
                                                Text(arrvDate),
                                                Text(
                                                  arrvTime,
                                                  style: TextStyle(color: themeColor, fontSize: 20, fontWeight: FontWeight.bold),
                                                ),
                                                Text(endPointCity),
                                              ]
                                            ),
                                          ]
                                        ),
                                        
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [Text(flight.stopNum>0? 'Stop: ${flight.stopNum} - $stopCity':'Nonstop'),]
                                        ),

                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              '$formattedPrice ${fareData.currency}',
                                              style: TextStyle(color: themeColor, fontSize: 18, fontWeight: FontWeight.bold)
                                            ),
                                          ]
                                        ),
                                      ],
                                    ),
                                    leading: Radio<int>(
                                      value: _selectedFlightId!,
                                      groupValue: _selectedFlightId,
                                      onChanged: (int? value) {
                                        setState(() {
                                          
                                          _selectedRadio=value;
                                          _selectedFlightValue1=flight.flightValue;

                                        });
                                      },
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _selectedFlightId = fareData.fareDataId;
                                        _selectedRadio=fareData.fareDataId;
                                        _selectedFlightValue1=flight.flightValue;
                                      });
                                    },
                                  )
                                );
                              },
                            )
                            
                            ,
                    if (_isLoading)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black45, // Semi-transparent overlay
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Confirm Selection Button
              _flightType=='RT'? ElevatedButton(
                onPressed: _selectedRadio != null
                    ? () {
                        // Handle flight selection
                        print('Selected Flight ID: $_selectedFlightId $_selectedFlightValue0 $_selectedFlightValue1');
                        setState(() {
                          _selectedRadio = null;
                          _showReturnFlight = true;
                          int totalPassengers = adultNo + chdNo + infNo;
                          _selectedFlightValue0!=null && _selectedFlightValue1!=null ? widget.onConfirm(totalPassengers): null;
                        });
                      }
                    : null, // Disable the button when no flight is selected
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Theme.of(context).colorScheme.primary, // Button color for enabled state
                  disabledBackgroundColor: Colors.grey, // Color when the button is disabled (default is grey)
                  disabledForegroundColor: Colors.white, // Color when the button is disabled (default is grey)
                ),
                child: !(_showReturnFlight)? Text('Next Selection', style: style2(context)):Text('Confirm', style: style2(context)),
              ) :
              ElevatedButton(
                onPressed: _selectedRadio != null
                    ? () {
                        
                        int totalPassengers = adultNo + chdNo + infNo;
                        widget.onConfirm(totalPassengers);
                      
                        print('Selected Flight ID: $_selectedFlightId  $_selectedFlightValue0 $_selectedFlightValue1');
                        setState(() {
                          _selectedRadio = null;
                          _showReturnFlight = true;
                        });
                      }
                    : null, // Disable the button when no flight is selected
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Theme.of(context).colorScheme.primary, // Button color for enabled state
                  disabledBackgroundColor: Colors.grey, // Color when the button is disabled (default is grey)
                  disabledForegroundColor: Colors.white, // Color when the button is disabled (default is grey)
                ),
                child: Text('Confirm', style: style2(context)),
              ),

            ],
          ),
        ),
      ],
    ),
  );
}
}