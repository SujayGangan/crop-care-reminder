import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:crop_care_reminder/main.dart';
// import 'package:crop_care_reminder/models/crop.dart';
import 'package:crop_care_reminder/widgets/crop_item_tile.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'add_crop_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // final List<Crop> cropsList = [];

  void setupPushNotification() async {
    final fcm = FirebaseMessaging.instance;

    await fcm.requestPermission();

    // final token = await fcm.getToken();      // Used when sending notifications to individual device.
    // print('token :- $token');
  }

  @override
  void initState() {
    super.initState();

    setupPushNotification();
  }

  @override
  Widget build(BuildContext context) {
    // Widget contentBody = Center(
    //   child: Text(
    //     'No crops added yet.',
    //     style: Theme.of(context).textTheme.bodyLarge!.copyWith(
    //           color: Theme.of(context).colorScheme.onSurface,
    //         ),
    //   ),
    // );

    // if (cropsList.isNotEmpty) {
    //   contentBody = ListView.builder(
    //     itemCount: cropsList.length,
    //     itemBuilder: (context, index) => CropItemTile(crop: cropsList[index]),
    //   );
    // }

    Widget contentBody = StreamBuilder(
      stream:
          FirebaseFirestore.instance.collection('crops_collection').snapshots(),
      builder: (ctx, cropDataSnapshots) {
        if (cropDataSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!cropDataSnapshots.hasData ||
            cropDataSnapshots.data!.docs.isEmpty) {
          return const Center(
            child: Text('No crops added yet.'),
          );
        }

        if (cropDataSnapshots.hasError) {
          return const Center(
            child: Text('Something went wrong...'),
          );
        }

        final loadedCrops = cropDataSnapshots.data!.docs;

        return ListView.builder(
          itemCount: loadedCrops.length,
          itemBuilder: (ctx, index) {
            final cropData = loadedCrops[index].data();

            DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
                cropData['Crop planting date'].seconds * 1000);
            String formattedPlantingDate =
                DateFormat('yyyy-MM-dd').format(dateTime);

            dateTime = DateTime.fromMillisecondsSinceEpoch(
                cropData['Task Reminder date'].seconds * 1000);
            String formattedHarvestDate =
                DateFormat('yyyy-MM-dd').format(dateTime);

            return CropItemTile(
              cropName: cropData['Crop name'],
              plantingDate: formattedPlantingDate,
              ReminderDate: formattedHarvestDate,
              task: cropData['Crop task'],
            );
          },
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
          title: Text(
        'Crop Care Reminder',
        style: Theme.of(context)
            .textTheme
            .titleLarge!
            .copyWith(fontWeight: FontWeight.bold),
      )),
      body: contentBody,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // final Crop crop = await Navigator.of(context).push(
          //   MaterialPageRoute(builder: (context) => AddCropScreen()),
          // );

          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddCropScreen()),
          );

          // setState(() {
          //   cropsList.add(crop);
          // });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
