import 'package:country_picker/country_picker.dart';

late Map<String, String> countryNameToFlag;

void initializeCountryMap() {
  countryNameToFlag = {};

  final allCountries = CountryService().getAll(); 

  for (final country in allCountries) {
    countryNameToFlag[country.name] = country.flagEmoji;
  }
}
