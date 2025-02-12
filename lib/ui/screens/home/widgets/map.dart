import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import 'package:geolocator/geolocator.dart' as gl;
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String data = "";

  mp.MapboxMap? MapboxMapController;

  StreamSubscription? userPositionStream;

  mp.PolygonAnnotation? polygonAnnotation;
  mp.PolygonAnnotationManager? polygonAnnotationManager;
  mp.PointAnnotationManager? pointAnnotationManager;
  int styleIndex = 4;
  mp.PointAnnotation? pointerAnnotation;
  mp.PolylineAnnotationManager? polylineAnnotationManager;
  mp.PolylineAnnotation? polylineAnnotation;

  bool isMeasuring = false;
  List<mp.Point> polygonPoints = [];
  List<mp.PointAnnotation> pointAnnotations = [];
  List<mp.PolygonAnnotation> savedPolygons = [];


  @override
  void initState() {
    super.initState();
    _setupPositionTracking();
    _getActivatedFields();
  }

  Future<void> _getActivatedFields() async {
    final url = Uri.parse('https://sat-sentinal-api.azurewebsites.net/api/v1/getUserFields?userId=67a5e434ae64dd1853d9d29f');
    try {
      final response = await http.get(url);
      print('response: ${response.body}');
      if (response.statusCode == 200) {
        setState(() {
          final responseData = jsonDecode(response.body)["data"];
          createMultipleAnnotations(responseData);
        });
      } else {
        setState(() {
          data = "Error loading data";
        });
      }
    } catch (e) {
      setState(() {
        data = "Error: $e";
      });
    }
  }

  @override
  void dispose() {
    userPositionStream?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [
          mp.MapWidget(
            onMapCreated: _onMapCreated,
            styleUri: mp.MapboxStyles.SATELLITE_STREETS,
            mapOptions: mp.MapOptions(
              pixelRatio: 2,
              size: mp.Size(width: 400, height: 600),
              glyphsRasterizationOptions: mp.GlyphsRasterizationOptions(
                rasterizationMode: mp.GlyphsRasterizationMode.NO_GLYPHS_RASTERIZED_LOCALLY,
              ),
            ),
            cameraOptions: mp.CameraOptions(
              center: mp.Point(
                coordinates: mp.Position(78.9629, 20.5937),
              ),
              zoom: 4.5,
              bearing: 0,
              pitch: 0,
            ),
            onTapListener: _onTapMap,
          ),
          
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: PopupMenuTheme(
              data: PopupMenuThemeData(
                color: const Color.fromRGBO(
                    32, 29, 29, 0.40),
                    menuPadding: EdgeInsets.symmetric(horizontal: 2)
              ),
              child: PopupMenuButton(
                offset: Offset(20,-40),
                itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                  PopupMenuItem(
                    child: InkWell(
                      onTap: (){
                        isMeasuring = !isMeasuring;
                      },
                      child: Row(
                        children: [
                          Icon(Icons.location_on,
                              color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Marking',
                            style: TextStyle(
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                child: Builder(
                  builder: (BuildContext context) {
                    return ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                          const Color.fromARGB(255, 37, 170, 109)
                          ),
                      ),
                      onPressed: null,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: Colors.white),
                          SizedBox(width: 10),
                          const Text('Create',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            )
          ),
          // Positioned(
          //   bottom: 20,
          //   right: 20,
          //   child: FloatingActionButton(
          //     onPressed: () {
          //       setState(() {
          //         isMeasuring = !isMeasuring;
          //         if (!isMeasuring) {
          //           _clearMeasurements();
          //         }
          //       });
          //     },
          //     backgroundColor: isMeasuring ? Colors.red : Colors.blue,
          //     child: Icon(isMeasuring ? Icons.cancel : Icons.straighten),
          //   ),
          // ),
          // Positioned(
          //   bottom: 80,
          //   right: 20,
          //   child: ElevatedButton(
          //     onPressed: _saveGeoJson,
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: Colors.green,
          //       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          //     ),
          //     child: Text("Save GeoJSON", style: TextStyle(color: Colors.white)),
          //   ),
          // ),
          // Positioned(
          //   bottom: 140,
          //   right: 20,
          //   child: FloatingActionButton(
          //     onPressed: _clearAllPolygons,
          //     backgroundColor: Colors.orange,
          //     child: Icon(Icons.delete),
          //   ),
          // ),
        ],
      )
    );
  }

  void _onMapCreated(mp.MapboxMap controller) async {
    setState(() {
      MapboxMapController = controller;
    });

    MapboxMapController?.location.updateSettings(
      mp.LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
      )
    );

    polygonAnnotationManager = await controller.annotations.createPolygonAnnotationManager();
    pointAnnotationManager = await controller.annotations.createPointAnnotationManager();
    polylineAnnotationManager = await controller.annotations.createPolylineAnnotationManager();

      
  }
   
  Future<void> _setupPositionTracking() async{
    bool serviceEnabled;
    gl.LocationPermission permission;

    serviceEnabled = await gl.Geolocator.isLocationServiceEnabled();

    if(!serviceEnabled){
      return Future.error('Location services are disabled.');
    }

    permission = await gl.Geolocator.checkPermission();

    if(permission == gl.LocationPermission.denied) {
      permission = await gl.Geolocator.requestPermission();
      if(permission == gl.LocationPermission.denied) {
        return Future.error('Location permission are denied');
      }
    }

    if(permission == gl.LocationPermission.deniedForever){
      return Future.error(
        'Location permission are permanently denied, we cannot request permission'
      );
    }

    gl.LocationSettings locationSettings = gl.LocationSettings(
      accuracy: gl.LocationAccuracy.high,
      distanceFilter: 100,
    );

    userPositionStream?.cancel();
    userPositionStream = 
      gl.Geolocator.getPositionStream(locationSettings: locationSettings)
      .listen(
        (
          gl.Position? position,
        ) {
          // if (position != null && MapboxMapController != null){
          //   MapboxMapController?.setCamera(
          //     mp.CameraOptions(
          //       zoom: 15,
          //       center: mp.Point(
          //         coordinates: mp.Position(
          //         position.longitude,
          //          position.latitude
          //          ),
          //       ),
          //     ),
          //   );
          // }
        },
      );

  }

  void _onTapMap(mp.MapContentGestureContext context) async {
    if (!isMeasuring) return;

    print("Tap detected");

    mp.Position tappedPosition = mp.Position(
      context.point.coordinates.lng,
      context.point.coordinates.lat,
    );
    mp.Point newPoint = mp.Point(coordinates: tappedPosition);
    polygonPoints.add(newPoint);
    _addPointMarker(newPoint);
    _drawPolyLine();
  }

  void _drawPolyLine() {
  if (polygonPoints.length >= 2) {

    mp.Point firstPoint = polygonPoints[0];
    mp.Point lastPoint = polygonPoints[polygonPoints.length - 1];
    mp.Point secondLastPoint = polygonPoints[polygonPoints.length - 2];

    print('linePoint ${secondLastPoint.coordinates.lng} ${secondLastPoint.coordinates.lat}');
    print('linePoint ${lastPoint.coordinates.lng} ${lastPoint.coordinates.lat}');
    
    polylineAnnotationManager
        ?.create(mp.PolylineAnnotationOptions(
            geometry: mp.LineString(coordinates: [
              mp.Position(secondLastPoint.coordinates.lng, secondLastPoint.coordinates.lat),
              mp.Position(lastPoint.coordinates.lng, lastPoint.coordinates.lat)
            ]),
            lineColor: 0xFF96FFB7,
            lineWidth: 1))
        .then((value) {
          polylineAnnotation = value;
          print("Polyline created successfully");
        })
        .catchError((error) {
          print("Error creating polyline: $error");
        });
      if (polygonPoints.length >= 3 && (_arePointsAlmostTheSame(firstPoint, lastPoint, 0.0001) || _arePointsExactlyTheSame(firstPoint, lastPoint))) {
        _drawPolygon();
      }
  }
}

bool _arePointsAlmostTheSame(mp.Point p1, mp.Point p2, double tolerance) {
  double lngDiff = (p1.coordinates.lng - p2.coordinates.lng).abs().toDouble();
  double latDiff = (p1.coordinates.lat - p2.coordinates.lat).abs().toDouble();
  return lngDiff < tolerance && latDiff < tolerance;
}
bool _arePointsExactlyTheSame(mp.Point firstPoint, mp.Point lastPoint) {
  return firstPoint.coordinates.lng == lastPoint.coordinates.lng &&
         firstPoint.coordinates.lat == lastPoint.coordinates.lat;
}
  void _addPointMarker(mp.Point point) async {
    final ByteData bytes = await rootBundle.load('assets/icons/pointer.png');
    final Uint8List list = bytes.buffer.asUint8List();

    final annotation = await pointAnnotationManager?.create(mp.PointAnnotationOptions(
      geometry: point,
      iconSize: 1,
      symbolSortKey: -1,
      // iconOffset: [0.0, -15.0],
      image: list,
    ));

    if (annotation != null) {
      pointAnnotations.add(annotation);
    }
  }

  void _drawPolygon() {
    if (polygonPoints.length < 3) return;

    print('polygonPoints: $polygonPoints');

    if (polygonPoints.first.coordinates != polygonPoints.last.coordinates) {
      polygonPoints.add(polygonPoints.first);
    }

    polygonAnnotationManager?.create(
      mp.PolygonAnnotationOptions(
        geometry: mp.Polygon(coordinates: [polygonPoints.map((p) => p.coordinates).toList()]),
        fillColor: 0x6696FFB7,
        fillOutlineColor: 0xFF96FFB7,
      ),
    ).then((polygon) {
      if (polygon != null) {
        savedPolygons.add(polygon);
        _clearMeasurements();
      }
    });
  }

  void _clearMeasurements() {
    polygonPoints.clear();
    pointAnnotations.forEach((annotation) {
      pointAnnotationManager?.delete(annotation);
    });
    pointAnnotations.clear();
    _clearPolyLines();
  }

  void _clearPolyLines() {
  if (polylineAnnotation != null && polylineAnnotation is List) {
    List annotations = polylineAnnotation as List;
    annotations.forEach((annotation) {
      polylineAnnotationManager?.delete(annotation);
    });
    polylineAnnotation = null;
    print("All polyline annotations cleared");
  } else {
    print("No polyline annotations to clear");
  }
}


  void _clearAllPolygons() {
  // Clears all saved polygons
    for (var polygon in savedPolygons) {
      polygonAnnotationManager?.delete(polygon);
    }
    savedPolygons.clear();
  }
  
  void _saveGeoJson() {
  if (savedPolygons.isEmpty) return;

  List<Map<String, dynamic>> features = savedPolygons.map((polygon) {
  return {
    "type": "Feature",
    "geometry": {
      "type": "Polygon",
      "coordinates": polygon.geometry.coordinates.map((ring) {
        List<List<double>> formattedRing = ring.map((p) => [p.lng.toDouble(), p.lat.toDouble()]).toList();
        
        // Ensure the first and last coordinate are the same
        if (formattedRing.isNotEmpty && 
            (formattedRing.first[0] != formattedRing.last[0] || formattedRing.first[1] != formattedRing.last[1])) {
          formattedRing.add(formattedRing.first);
        }

        return formattedRing;
      }).toList(),
    },
    "properties": {},
  };
}).toList();



  Map<String, dynamic> geoJson = {
    "type": "FeatureCollection",
    "features": features,
  };

  String geoJsonString = jsonEncode(geoJson);
  print("Saved GeoJSON: $geoJsonString");
}




 void createMultipleAnnotations(List<dynamic> fields) {
  if (polygonAnnotationManager == null) {
    print("polygonAnnotationManager is null!");
    return;
  }

  List<List<mp.Position>> polygons = [];

  for (var field in fields) {
    var coordinates = field["coordinates"];
    List<mp.Position> polygonCoordinates = [];
    for (var coordinate in coordinates) {
      // Add each coordinate as Position(lat, lng)
      polygonCoordinates.add(mp.Position(coordinate[0], coordinate[1])); // lat, lng
    }

    // Ensure the polygon is closed by checking the first and last coordinate
    if (polygonCoordinates.isNotEmpty && polygonCoordinates.first != polygonCoordinates.last) {
      polygonCoordinates.add(polygonCoordinates.first);
    }

    polygons.add(polygonCoordinates);
  }

  print('polygons $polygons');

  // Ensure polygons are not empty before creating annotations
  if (polygons.isEmpty) {
    print('No polygons to create!');
    return;
  }

  // Create polygons on the map
  for (var polygon in polygons) {
    // Check the structure of the polygon coordinates
    print("Creating polygon with coordinates: $polygon");

    // Ensure that the geometry is valid
    final polygonAnnotationOptions = mp.PolygonAnnotationOptions(
      geometry: mp.Polygon(coordinates: [polygon]), // Make sure this is correct
      fillColor: 0x0096FFB7, // ARGB format
      fillOutlineColor: 0xFF96FFB7,
    );

    polygonAnnotationManager
        ?.create(polygonAnnotationOptions)
        .then((value) {
          print("Polygon created: ${value.id}");
          MapboxMapController?.setCamera(
            mp.CameraOptions(
              zoom: 15,
              center: mp.Point(
                coordinates: mp.Position(79.4032481, 10.8183293),
              ),
            ),
          );
        }).catchError((error) {
          print("Error creating polygon: $error");
        });
  }
}

    void _loadGeoJson(String geoJsonString) {
    Map<String, dynamic> geoJson = jsonDecode(geoJsonString);

    if (geoJson["features"] != null) {
      for (var feature in geoJson["features"]) {
        var coordinates = feature["geometry"]["coordinates"][0].map<mp.Position>(
          (coord) => mp.Position(coord[0], coord[1]),
        ).toList();

        // Create a polygon annotation using the loaded coordinates
        polygonAnnotationManager?.create(
          mp.PolygonAnnotationOptions(
            geometry: mp.Polygon(coordinates: [coordinates]),
            fillColor: 0x6696FFB7, // Set your desired color
            fillOutlineColor: 0xFF96FFB7,
          ),
        ).then((polygon) {
          if (polygon != null) {
            savedPolygons.add(polygon); // Save the polygon
          }
        });
      }
    }
  }



}
