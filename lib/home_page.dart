import 'package:flutter/material.dart';
import 'styles.dart';
import 'city_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _departureDateController = TextEditingController();
  final TextEditingController _returnDateController = TextEditingController();
  int _adultNo=1;
  int _chdNo=0;
  int _infNo=0;

  List<DropdownMenuItem<int>> _buildDropdownItems() {
    return List<DropdownMenuItem<int>>.generate(
      9,
      (index) => DropdownMenuItem<int>(
        value: index + 1,
        child: Text('${index + 1}'),
      ),
    );
  }

  Future<void> _selectDepartureDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _departureDateController.text = pickedDate.toLocal().toString().split(' ')[0];
      });
    }
  }

  Future<void> _selectReturnDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _returnDateController.text = pickedDate.toLocal().toString().split(' ')[0];
      });
    }
  }

  Widget buildAutocompleteField({
    required BuildContext context,
    required String labelText,
    required Function(String) onSelected,
  }) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }

        final input = textEditingValue.text.toLowerCase();

        // Filtering both city names and codes
        return cityMap.entries
            .where((entry) =>
                entry.key.toLowerCase().contains(input) ||
                entry.value.toLowerCase().contains(input))
            .map((entry) => '${entry.key} (${entry.value})');
      },
      onSelected: onSelected,
      fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: labelText,
            border: const OutlineInputBorder(),
            labelStyle: style2(context),
          ),
          style: style2(context),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      appBar: AppBar(
        title: Text('Search Flights', style: style(context)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildAutocompleteField(
              context: context,
              labelText: 'From',
              onSelected: (String selection) {
                print('From Selected: $selection');
              },
            ),
            const SizedBox(height: 16),
            // "To" Autocomplete field
            buildAutocompleteField(
              context: context,
              labelText: 'To',
              onSelected: (String selection) {
                print('To Selected: $selection');
              },
            ),
            const SizedBox(height: 16),
            // Departure date field
            TextField(
              controller: _departureDateController,
              decoration: InputDecoration(
                labelText: 'Departure Date',
                border: OutlineInputBorder(),
                labelStyle: style2(context),
              ),
              readOnly: true, // To use a date picker instead
              onTap: () => _selectDepartureDate(context),
            ),
            const SizedBox(height: 16),
            // Return date field
            TextField(
              controller: _returnDateController,
              decoration: InputDecoration(
                labelText: 'Return Date',
                border: OutlineInputBorder(),
                labelStyle: style2(context),
              ),
              readOnly: true, // To use a date picker instead
              onTap: () => _selectReturnDate(context),
            ),
            const SizedBox(height: 16),
            Text(
              'Adults',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<int>(
              
              value: _adultNo,
              items: _buildDropdownItems(),
              onChanged: (newValue) {
                setState(() {
                  _adultNo = newValue!;
                });
              },
            ),            
            const SizedBox(height: 16),
            // Search button
            ElevatedButton(
              onPressed: () {
                // Implement search functionality
              },
              child: Text(
                'Search',
                style: style2(context),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            // Results display
            Expanded(
              child: ListView.builder(
                itemCount: 10, // Replace with actual search results count
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Flight #$index'), // Replace with actual flight data
                    subtitle: Text('Details about the flight'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
