import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:maplibre_gl_example/page.dart';
import 'package:path_provider/path_provider.dart';

class OfflineMBTilesPage extends ExamplePage {
  const OfflineMBTilesPage({super.key})
      : super(const Icon(Icons.wifi_off), 'Offline MBTiles');

  @override
  Widget build(BuildContext context) {
    return const OfflineMBTiles();
  }
}

class OfflineMBTiles extends StatefulWidget {
  const OfflineMBTiles({super.key});

  @override
  State<OfflineMBTiles> createState() => _OfflineMBTilesPageState();
}

class _OfflineMBTilesPageState extends State<OfflineMBTiles> {
  MapLibreMapController? mapController;

  // location set to the ocean around Mobile, Alabama. with initial zoom level 10.
  final CameraPosition __initialCameraPosition = const CameraPosition(
    target: LatLng(30.121039, -86.782981),
    zoom: 10,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        MapLibreMap(
          onMapCreated: __onMapCreated,
          onStyleLoadedCallback: __loadOfflineMBTiles,
          initialCameraPosition: __initialCameraPosition,
        ),
        Positioned(
          right: 10,
          bottom: 10,
          child: Column(
            children: [
              GestureDetector(
                onTap: __zoomIn,
                child: Container(
                  height: 54,
                  width: 54,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple
                        .withAlpha(0.5 * 255 ~/ Colors.deepPurple.a),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.zoom_in,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: __zoomOut,
                child: Container(
                  height: 54,
                  width: 54,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple
                        .withAlpha(0.5 * 255 ~/ Colors.deepPurple.a),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.zoom_out,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  // MapLibreMapController to control the map.
  void __onMapCreated(MapLibreMapController c) => mapController = c;

  // zoom in the map with "1" level.
  void __zoomIn() => mapController?.animateCamera(CameraUpdate.zoomIn());

  // zoom out the map with "1" level.
  void __zoomOut() => mapController?.animateCamera(CameraUpdate.zoomOut());

  // load the offline mbtiles file from the assets and add it to the map.
  Future<void> __loadOfflineMBTiles() async {
    final offlineMBTilesFile = await __createFileAndGetDataFromAssets();

    // check if the file exists then add the source and layer to the map.
    if (offlineMBTilesFile.existsSync()) {
      mapController!.addSource(
        'offline_mbtile_source_id',
        RasterSourceProperties(
          tiles: ['mbtiles://${offlineMBTilesFile.path}'],
          tileSize: 256,
        ),
      );
      mapController!.addLayer(
        'offline_mbtile_source_id',
        'offline_mbtile_layer_id',
        const RasterLayerProperties(),
      );

      setState(() {});
    }
  }

  // create accessible file copy of the mbtiles file stored in the assets.
  Future<File> __createFileAndGetDataFromAssets() async {
    final dir = await getApplicationDocumentsDirectory();
    final newFile = '${dir.path}/synthetic.mbtiles';

    // if file is not exists then create new file.
    if (!File(newFile).existsSync()) {
      // use rootBundle to load the asset file.
      final data = await rootBundle.load('assets/synthetic.mbtiles');

      // convert buffer data to uint8list to write in the file.
      final bytes = data.buffer.asUint8List();
      await File(newFile).writeAsBytes(bytes);
    }
    return File(newFile);
  }
}
