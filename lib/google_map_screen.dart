import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googlemapplaceapi/repository/repo.dart';
import 'model/place_model/place_model.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_maps_webservice/directions.dart';
import 'package:google_maps_polyline/google_maps_polyline.dart';

Color color = const Color(0xfffe8903);

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  BitmapDescriptor? currentLocation;
  TextEditingController placeController = TextEditingController();

  late final GoogleMapController _controller;
  Position? _currentPosition;
  LatLng _currentLatLng = const LatLng(27.671332124757402, 85.3125417636781);
  late final Set<Marker> _markers = {};
  late final GoogleMapsPlaces _places;
  late final GoogleMapsDirections _directions;

  @override
  void initState() {
    _getLocation();
    _places =
        GoogleMapsPlaces(apiKey: 'AIzaSyBhX9-wyrQCpjNt9JBRSwSIaQ_y7tbl5NY');
    _directions =
        GoogleMapsDirections(apiKey: 'AIzaSyBhX9-wyrQCpjNt9JBRSwSIaQ_y7tbl5NY');
    super.initState();
  }

  Future<void> _getLocation() async {
    _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLatLng = LatLng(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      _markers.add(Marker(
        markerId: const MarkerId('currentLocation'),
        position: _currentLatLng,
        infoWindow: const InfoWindow(title: 'Current Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
    });
  }

  // Declaração das variáveis para os serviços de Places e Directions
  final GoogleMapsPlaces _place =
      GoogleMapsPlaces(apiKey: 'AIzaSyBhX9-wyrQCpjNt9JBRSwSIaQ_y7tbl5NY');
  final GoogleMapsDirections _direction =
      GoogleMapsDirections(apiKey: 'AIzaSyBhX9-wyrQCpjNt9JBRSwSIaQ_y7tbl5NY');

// Função para pesquisar locais
  Future<List<PlacesSearchResult>> searchPlaces(String query) async {
    PlacesSearchResponse response = await _places.searchByText(query);
    return response.results;
  }

// Função para traçar a rota até o local selecionado
  Future<void> getDirections(LatLng origin, LatLng destination) async {
    DirectionsResponse response = await _direction.directionsWithLocation(
      Location(lat: origin.latitude, lng: origin.longitude),
      Location(lat: destination.latitude, lng: destination.longitude),
    );

    if (response.isOkay) {
      List<LatLng> decodedPoints =
          GoogleMapsPolyline.decode(response.routes![0].overviewPolyline!);

      List<LatLng> routeCoordinates = decodedPoints.map((point) {
        return LatLng(point.latitude, point.longitude);
      }).toList();

      _controller.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            response.routes![0].bounds.southwest.lat,
            response.routes![0].bounds.southwest.lng,
          ),
          northeast: LatLng(
            response.routes![0].bounds.northeast.lat,
            response.routes![0].bounds.northeast.lng,
          ),
        ),
        100,
      ));

      setState(() {
        _polylines.add(Polyline(
          polylineId: const PolylineId('route'),
          visible: true,
          points: routeCoordinates,
          width: 4,
          color: Colors.blue,
        ));
      });
    } else {
      // Erro ao obter as direções
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Erro'),
            content: const Text('Não foi possível obter as direções.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Widget autoComplete() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.8),
              blurRadius: 8.0,
              spreadRadius: 1,
              offset: const Offset(0, 4)),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TypeAheadFormField<Description?>(
        onSuggestionSelected: (suggestion) {
          setState(() {
            placeController.text =
                suggestion?.structured_formatting?.main_text ?? "";
          });
        },
        getImmediateSuggestions: true,
        keepSuggestionsOnLoading: true,
        textFieldConfiguration: TextFieldConfiguration(
          style: GoogleFonts.lato(),
          controller: placeController,
          decoration: InputDecoration(
            isDense: false,
            fillColor: Colors.transparent,
            filled: false,
            prefixIcon: Icon(CupertinoIcons.search, color: color),
            suffixIcon: InkWell(
              onTap: () {
                setState(() {
                  placeController.clear();
                });
              },
              child: const Icon(Icons.clear, color: Colors.red),
            ),
            hintText: "Onde voce deseja ir?",
            hintStyle: GoogleFonts.lato(),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
          ),
        ),
        itemBuilder: (context, Description? itemData) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: Colors.grey,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${itemData?.structured_formatting?.main_text}",
                      style: const TextStyle(color: Colors.green),
                    ),
                    Text("${itemData?.structured_formatting?.secondary_text}"),
                    const Divider()
                  ],
                ),
              ],
            ),
          );
        },
        noItemsFoundBuilder: (context) {
          return Container();
        },
        suggestionsCallback: (String pattern) async {
          var predictionModel =
              await Repo.placeAutoComplete(placeInput: pattern);
          if (predictionModel != null) {
            return predictionModel.predictions!.where((element) => element
                .description!
                .toLowerCase()
                .contains(pattern.toLowerCase()));
          } else {
            return [];
          }
        },
      ),
    );
  }

  Widget locationsWidget() {
    return Container(
      margin: EdgeInsets.zero,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Colors.grey,
              blurRadius: 10.0,
              spreadRadius: 1,
              offset: Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 15,
                  width: 15,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(
                  width: 8,
                ),
                const Wrap(
                  direction: Axis.vertical,
                  children: [
                    Text(
                      "Localização actual",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Rua Irmãos-Ruby, ISCIM",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(left: 20),
              child: Divider(
                height: 8,
                color: color.withOpacity(0.6),
              ),
            ),
            Row(
              children: [
                Container(
                  height: 15,
                  width: 15,
                  decoration: BoxDecoration(
                      border: Border.all(color: color, width: 4),
                      shape: BoxShape.circle),
                ),
                const SizedBox(
                  width: 8,
                ),
                Wrap(
                  direction: Axis.vertical,
                  children: [
                    const Text(
                      "Destino",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: 300,
                      child: Text(
                        placeController.text.isEmpty
                            ? "Selecionar Destino"
                            : placeController.text,
                        overflow: TextOverflow.visible,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: _currentPosition == null
            ? const Center(child: CircularProgressIndicator()
                //CircularProgressIndicator(),
                )
            : Stack(
                children: [
                  GoogleMap(
                    myLocationButtonEnabled: false,
                    myLocationEnabled: true,
                    zoomControlsEnabled: false,
                    initialCameraPosition:
                        CameraPosition(zoom: 16, target: _currentLatLng),
                    onMapCreated: (controller) async {
                      setState(() {
                        _controller = controller;
                      });
                      String val = "json/google_map_dark_light.json";
                      var c = await rootBundle.loadString(val);
                      _controller.setMapStyle(c);
                    },
                    markers: {
                      Marker(
                          markerId: const MarkerId("1"),
                          // icon: currentLocation!,
                          position: _currentLatLng)
                    },
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 20, right: 20, top: 40),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          autoComplete(),
                          const SizedBox(
                            height: 12,
                          ),
                          locationsWidget(),
                          const Spacer(),
                          confirmButton(),
                        ],
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }

  Widget confirmButton() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: color,
            minimumSize: const Size(double.infinity, 40)),
        onPressed: () {
          // _controller.animateCamera(CameraUpdate.newCameraPosition(
          //     const CameraPosition(target: LatLng(0, 0))));
        },
        child: Text(
          "CONFIRMAR",
          style: GoogleFonts.lato(
            fontSize: 18,
            color: Colors.white,
          ),
        ));
  }
}
