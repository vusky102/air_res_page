import 'package:flutter/material.dart';
import 'styles.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary, 
          appBar: AppBar(
            title: Text('Search Flights',style: style(context)),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'From',
                    border: OutlineInputBorder(),
                    labelStyle: style2(context),
                    
                  ),
                  style: style2(context),
                ),
                const SizedBox(height: 16),
                // Destination field
                TextField(
                  decoration: InputDecoration(
                    labelText: 'To',
                    border: OutlineInputBorder(),
                    labelStyle: style2(context),
                  ),
                ),
                const SizedBox(height: 16),
                // Departure date field
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Departure Date',
                    border: OutlineInputBorder(),
                    labelStyle: style2(context),
                  ),
                  readOnly: true, // To use a date picker instead
                  onTap: () async {
                    // Show DatePicker dialog here
                  },
                ),
                const SizedBox(height: 16),
                // Return date field
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Return Date',
                    border: OutlineInputBorder(),
                    labelStyle: style2(context),
                  ),
                  readOnly: true, // To use a date picker instead
                  onTap: () async {
                    // Show DatePicker dialog here
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
        ),
    );
  }
}