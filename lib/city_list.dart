const Map<String, String> cityMap = {
  'New York': 'NYC',
  'Los Angeles': 'LAX',
  'Chicago': 'CHI',
  'Houston': 'HOU',
  'Phoenix': 'PHX',
  'Philadelphia': 'PHL',
  'San Antonio': 'SAT',
  'San Diego': 'SAN',
  'Dallas': 'DAL',
  'San Jose': 'SJC',
  'Seoul': 'ICN',
  'Busan': 'PUS',
  'Hanoi': 'HAN',
  'Ho Chi Minh': 'SGN',

};

String getCityNameFromCode(String code) {
  return cityMap.entries.firstWhere((entry) => entry.value == code,
    orElse: () => const MapEntry('Unknown', 'Unknown')).key;
}