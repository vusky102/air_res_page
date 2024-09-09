import 'package:air_reservation/passenger_page.dart';
import 'package:flutter/material.dart';
import 'styles.dart';
import 'home_page.dart';
import 'hugeicons.dart';
import 'passenger_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'E9PAY AIR TICKET',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: themeColor),
          iconTheme: IconThemeData(
            color: themeColor,
          ),
        ),
        home: const MyHomePage(),     
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});  
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  var selectedIndex=1;
  int totalPassengers=0;
  @override
  Widget build(BuildContext context) {
    
    Widget page;
    switch (selectedIndex) {
      case 1:
        page = HomePage(onConfirm: (int totalPassengersFromHomePage) {
          setState(() {
            selectedIndex = 2; // Update selectedIndex to 2 when confirmed
            totalPassengers = totalPassengersFromHomePage;
          });
        });
        break;
      case 2:
        page = PassengerPage(numberOfPassengers: totalPassengers);
        break;
        

      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    final destinations = [              
      const NavigationRailDestination(
        icon: Stack(
          children: [
            CircleAvatar(
                maxRadius: 30, 
                minRadius: 20,
                backgroundImage: AssetImage('assets/logo.jpg'),
              ), 
          ],
        ),
        // label: Text(' ', style: TextStyle(color: Colors.transparent)),
        label: Text(
          'Air Ticket',
          style: TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.bold
          ),
        ),
      ),

      const NavigationRailDestination(
        icon: Icon(HugeIcons.strokeRoundedHome09),
        label: Text('Home'),
      ),

      const NavigationRailDestination(
        icon: Icon(HugeIcons.strokeRoundedShoppingCartCheckOut01),
        label: Text('Checkout'),
      ),
      ];

    var mainArea = ColoredBox(
      color: Theme.of(context).colorScheme.primary,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child:page,
      ),  
    );  
      
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        body: LayoutBuilder(
          builder: (context,constraints) {
            if (constraints.maxWidth<450) {
              return Column(
                children: [
                  Expanded(child: mainArea),
                  SafeArea(
                    child: NavigationRail(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        extended: constraints.maxWidth>=600,
                        destinations: destinations,
                        selectedIndex: selectedIndex,
                        onDestinationSelected: (value) {
                          setState(() {
                            selectedIndex=value;
                          });                    
                        },
                      ),
                    )
                  
                ],  
              );
            } else {
                return Row(
                  children: [
                    SafeArea(
                      
                      child: NavigationRail(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        extended: constraints.maxWidth >= 600,         
                        destinations: destinations,
                        selectedIndex: selectedIndex,
                        onDestinationSelected: (value) {
                          if (value != 0) {
                            setState(() {
                              selectedIndex = value;
                          });
                          }
                        },
                      ),
                      
                    ),
                    Expanded(child: mainArea),
                  ],
                );
              }
          },
        ),
      );
  }
}

