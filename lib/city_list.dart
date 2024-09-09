const Map<String, Map<String, String>> cityCountryMap = {
  'USA': {
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
  },
  'South Korea': {
    'Seoul': 'ICN',
    'Busan': 'PUS',
  },
  'Vietnam': {
    'Ha Noi': 'HAN',
    'Ho Chi Minh': 'SGN',
    'Nha Trang': 'CXR',
    'Da Nang': 'DAD',
  },
};

const Map<String, String> nationalityMap = {
  'USA' : 'US',
  'Vietnam' : 'VN',
  'South Korea' : 'KR',

};



String getCityNameFromCode(String code) {
  for (var country in cityCountryMap.keys) {
    final cityMap = cityCountryMap[country]!;
    final cityEntry = cityMap.entries.firstWhere(
      (entry) => entry.value == code,
      orElse: () => MapEntry('Unknown', code)
    );
    if (cityEntry.key != 'Unknown') {
      return cityEntry.key;  // Return only the city name
    }
  }
  return code;  // If not found, return the code itself
}

String? findCountry(String code) {
  for (var country in cityCountryMap.keys) {
    for (var city in cityCountryMap[country]!.keys) {
      if (cityCountryMap[country]![city] == code) {
        return country;
      }
    }
  }
  return null; // Return null if the code is not found
}