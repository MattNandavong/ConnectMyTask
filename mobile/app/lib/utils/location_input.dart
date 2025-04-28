import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

class LocationInput extends StatefulWidget {
  final void Function(String address, double lat, double lng) onPlaceSelected;

  const LocationInput({
    required this.onPlaceSelected,
    super.key,
  });

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: GooglePlaceAutoCompleteTextField(
        textEditingController: _controller,
        googleAPIKey: "AIzaSyCw5oCey7i_yWvKuJVQ-apK_xenWUqgsUY",
        inputDecoration: InputDecoration(
          hintText: "Enter Location",
          border: OutlineInputBorder(),
        ),
        debounceTime: 800,
        countries: ["au"], // ✏️ You can customize country filter here
        isLatLngRequired: true, // We need lat/lng
        getPlaceDetailWithLatLng: (Prediction prediction) {
          // When lat/lng fetched
          final address = prediction.description ?? "";
          final lat = double.tryParse(prediction.lat ?? "") ?? 0.0;
          final lng = double.tryParse(prediction.lng ?? "") ?? 0.0;
          widget.onPlaceSelected(address, lat, lng);
        },
        itemClick: (Prediction prediction) {
          _controller.text = prediction.description ?? "";
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        },
        itemBuilder: (context, index, Prediction prediction) {
          return Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Icon(Icons.location_on),
                SizedBox(width: 7),
                Expanded(
                  child: Text(prediction.description ?? ""),
                ),
              ],
            ),
          );
        },
        seperatedBuilder: Divider(), // 🛠 correct spelling
        isCrossBtnShown: true,
        containerHorizontalPadding: 10,
        // placeType: PlaceType.geocode,
      ),
    );
  }
}
