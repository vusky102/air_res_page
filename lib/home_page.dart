import 'package:air_reservation/hugeicons.dart';
import 'package:flutter/material.dart';
import 'styles.dart';
import 'city_list.dart';
import 'kao_faresearch_rq.dart';
import 'package:intl/intl.dart';
import 'fare_data.dart';
import 'dart:convert';
import 'air_logo_map.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final TextEditingController _departureDateController = TextEditingController();
  final TextEditingController _returnDateController = TextEditingController();
  int _adultNo = 1;
  int _chdNo = 0;
  int _infNo = 0;
  String _flightType = 'RT'; // default type
  String _fromLoc = ''; // State to store the selected departure location
  String _toLoc = ''; // State to store the selected arrival location
  late bool shouldShowReturnDateField;
  int? _selectedFlightId; // State variable to track selected flight ID
  bool _isLoading = false;
  bool _hasSearched = false; // Track whether a search has been performed

  // State variable to hold flight data
  List<dynamic> _flights = [];
  List<int> _fares=[];
  List<int> _prices=[];
  List<String> _currency=[];
  List<dynamic> _segment = [];

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

        return cityMap.entries
            .where((entry) =>
                entry.key.toLowerCase().contains(input) ||
                entry.value.toLowerCase().contains(input))
            .map((entry) => '${entry.key} (${entry.value})');
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
        adultNo: _adultNo,
        chdNo: _chdNo,
        infNo: _infNo,
      );

      print('API Response: $response'); // Print the raw response

      if (response.isNotEmpty) {
        final jsonMap = jsonDecode(response);
        final listFareData = (jsonMap['ListFareData'] as List)
            .map((fareDataJson) => FareData.fromJson(fareDataJson))
            .toList();


        setState(() {
          _flights = listFareData.expand((fareData) => fareData.listOption.expand((option) => option.listFlight)).toList();
          _fares = listFareData
            .map((fareData) => fareData.fareDataId)
            .toList();
          _prices= listFareData
            .map((fareData) => fareData.totalPrice)
            .toList();
          _currency= listFareData
            .map((fareData) => fareData.currency)
            .toList();
          _segment = listFareData.expand((fareData) => fareData.listOption
          .expand((option) => option.listFlight
          .expand((flight) => flight.listSegment)))
          .toList();
          _hasSearched = true; // Update search status

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
            shouldShowReturnDateField
                ? TextField(
                    controller: _returnDateController,
                    decoration: InputDecoration(
                      labelText: 'Return Date',
                      border: const OutlineInputBorder(),
                      labelStyle: style2(context),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context, _returnDateController),
                  )
                : Container(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Adults', style: style2(context)),
                DropdownButton<int>(
                  style: style3(context),
                  value: _adultNo,
                  dropdownColor: themeColor.withAlpha(1),
                  items: _buildDropdownItems(1, 9),
                  onChanged: (newValue) {
                    setState(() {
                      _adultNo = newValue!;
                    });
                  },
                ),
                Text('Children', style: style2(context)),
                DropdownButton<int>(
                  style: style3(context),
                  value: _chdNo,
                  dropdownColor: themeColor.withAlpha(1),
                  items: _buildDropdownItems(0, 9),
                  onChanged: (newValue) {
                    setState(() {
                      _chdNo = newValue!;
                    });
                  },
                ),
                Text('Infants', style: style2(context)),
                DropdownButton<int>(
                  style: style3(context),
                  value: _infNo,
                  dropdownColor: themeColor.withAlpha(1),
                  items: _buildDropdownItems(0, 9),
                  onChanged: (newValue) {
                    setState(() {
                      _infNo = newValue!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _searchFlights,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: Text('Search', style: style2(context)),
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: Stack(
                children: [
                  if (!_isLoading)
              _fares.isEmpty
              ? Center(child: Text(_hasSearched ? 'No flights available' : 'No search request yet, press search for result'))
              : ListView.builder(
                itemCount: _fares.length,
                itemBuilder: (context, index) {
                  final flight = _flights[index];
                  final fareId = _fares[index];
                  final price = _prices[index];
                  final currency = _currency[index];
                  final segment = _segment[index];
                  final startPointCity = getCityNameFromCode(segment.startPoint);
                  final endPointCity = getCityNameFromCode(segment.endPoint);

                  String? airlineLogoPath = airlineLogos[flight.airline];

                  final formattedPrice = NumberFormat('#,##0').format(price);
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
                  child:
                  ListTile(
                    title: airlineLogoPath != null
                          ? Image.asset(
                              airlineLogoPath,
                              width: 80,  // Adjust the width and height as needed
                              height: 80,
                              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                // Fallback in case the image is not found
                                return Text('Airline: ${flight.airline}');
                              },
                            )
                          : Text('Airline: ${flight.airline}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text('$startPointCity'),
                            Image.asset(
                              'assets/segment_line.png',
                              width: 120,  // Adjust the width and height as needed
                              height: 120,
                              ),
                            Text('$endPointCity')
                          ]
                        ),
                        Text('Total Price: $formattedPrice $currency'),
                      ],
                    ),
                    leading: Radio<int>(
                      value: fareId,
                      groupValue: _selectedFlightId,
                      onChanged: (int? value) {
                        setState(() {
                          _selectedFlightId = value;
                        });
                      },
                    ),
                    onTap: () {
                      setState(() {
                        _selectedFlightId = fareId;
                      });
                    },
                  )
                );
                },
              ),
              ]
              )
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_selectedFlightId != null) {
                  // Handle flight selection
                  print('Selected Flight ID: $_selectedFlightId');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select a flight.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: Text('Confirm Selection', style: style2(context)),
            ),
          ],
        ),
      ),
      if (_isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black45, // Semi-transparent overlay
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ]
    )
    );
  }
}
