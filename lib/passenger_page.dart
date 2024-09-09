import 'package:air_reservation/hugeicons.dart';
import 'package:flutter/material.dart';
import 'styles.dart';
import 'city_list.dart';
import 'kao_faresearch_rq.dart';
import 'package:intl/intl.dart';
import 'fare_data.dart';
import 'dart:convert';
import 'air_logo_map.dart';
import 'air_logo_map.dart';
import 'home_page.dart';




class PassengerPage extends StatefulWidget {
  final int numberOfPassengers;  // Pass the number of passengers

  const PassengerPage({super.key, required this.numberOfPassengers});

  @override
  PassengerPageState createState() => PassengerPageState();
}

class PassengerPageState extends State<PassengerPage> {
  final _formKey = GlobalKey<FormState>();

  // Create lists of controllers for each passenger
  List<TextEditingController> _nameControllers = [];
  List<TextEditingController> _surnameControllers = [];
  List<TextEditingController> _passportNumberControllers = [];
  List<TextEditingController> _dobControllers = [];
  List<TextEditingController> _passportExpiryControllers = [];
  List<String> nationalities = [];
  List<String> issueCountries = [];
  List<String> genders = [];



      Widget buildAutocompleteField2({
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
        final options = nationalityMap.entries
          .where((entry) => entry.key.toLowerCase().contains(input) || entry.value.toLowerCase().contains(input))
          .map((entry) => '${entry.key} (${entry.value})')
          .toList();

        return options;
      },
      onSelected: (String selected) {
        final code = extractCountryCode(selected);
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

  String extractCountryCode(String selected) {
  final startIndex = selected.indexOf('(');
  final endIndex = selected.indexOf(')');
  if (startIndex != -1 && endIndex != -1) {
    return selected.substring(startIndex + 1, endIndex); // Extracts the country code from (US), (VN), etc.
  }
  return selected;
}

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize lists based on the number of passengers
    for (int i = 0; i < widget.numberOfPassengers; i++) {
      _nameControllers.add(TextEditingController());
      _surnameControllers.add(TextEditingController());
      _passportNumberControllers.add(TextEditingController());
      _dobControllers.add(TextEditingController());
      _passportExpiryControllers.add(TextEditingController());
      nationalities.add('');
      issueCountries.add('');
      genders.add('M');  // Default gender is 'Male'
    }
  }

  @override
  void dispose() {
    // Dispose of controllers
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    for (var controller in _surnameControllers) {
      controller.dispose();
    }
    for (var controller in _passportNumberControllers) {
      controller.dispose();
    }
    for (var controller in _dobControllers) {
      controller.dispose();
    }
    for (var controller in _passportExpiryControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Build individual passenger form
  Widget buildPassengerForm(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Passenger ${index + 1}', style: style(context)),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _surnameControllers[index],
                decoration: InputDecoration(
                  labelText: 'Last name',
                  border: const OutlineInputBorder(),
                  labelStyle: style2(context),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the last name';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _nameControllers[index],
                decoration: InputDecoration(
                  labelText: 'First name',
                  border: const OutlineInputBorder(),
                  labelStyle: style2(context),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the first name';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Gender radio buttons
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: Text('Male', style: style2(context)),
                value: 'M',
                groupValue: genders[index],
                onChanged: (String? value) {
                  setState(() {
                    if (value != null) genders[index] = value;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: Text('Female', style: style2(context)),
                value: 'F',
                groupValue: genders[index],
                onChanged: (String? value) {
                  setState(() {
                    if (value != null) genders[index] = value;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Date of Birth
        TextFormField(
          controller: _dobControllers[index],
          decoration: InputDecoration(
            labelText: 'Date of Birth',
            border: const OutlineInputBorder(),
            labelStyle: style2(context),
          ),
          readOnly: true,
          onTap: () => _selectDate(context, _dobControllers[index]),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select the date of birth';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Nationality Autocomplete
        buildAutocompleteField2(
          context: context,
          labelText: 'Nationality',
          onSelected: (String nationality) {
            setState(() {
              nationalities[index] = nationality;
            });
          },
          initialValue: nationalities[index],
        ),
        const SizedBox(height: 16),

        // Passport Number
        TextFormField(
          controller: _passportNumberControllers[index],
          decoration: InputDecoration(
            labelText: 'Passport No.',
            border: const OutlineInputBorder(),
            labelStyle: style2(context),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the passport number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Issue Country Autocomplete
        buildAutocompleteField2(
          context: context,
          labelText: 'Issue Country',
          onSelected: (String issueCountry) {
            setState(() {
              issueCountries[index] = issueCountry;
            });
          },
          initialValue: issueCountries[index],
        ),
        const SizedBox(height: 16),

        // Passport Expiry Date
        TextFormField(
          controller: _passportExpiryControllers[index],
          decoration: InputDecoration(
            labelText: 'Passport Expiration Date',
            border: const OutlineInputBorder(),
            labelStyle: style2(context),
          ),
          readOnly: true,
          onTap: () => _selectDate(context, _passportExpiryControllers[index]),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select the passport expiration date';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      appBar: AppBar(
        title: Text('Passenger Information', style: style(context)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView.builder(
            itemCount: widget.numberOfPassengers,  // Build as many forms as needed
            itemBuilder: (context, index) {
              return buildPassengerForm(index);
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Process the data
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Processing Passenger Information')),
            );
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
