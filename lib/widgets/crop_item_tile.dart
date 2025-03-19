import 'package:crop_care_reminder/main.dart';
import 'package:flutter/material.dart';

class CropItemTile extends StatelessWidget {
  const CropItemTile({
    super.key,
    required this.cropName,
    required this.plantingDate,
    required this.ReminderDate,
    required this.task,
  });

  final String cropName;
  final String plantingDate;
  final String ReminderDate;
  final String task;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  cropName,
                  textAlign: TextAlign.start,
                  style: theme.textTheme.headlineLarge!.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Expanded(
                  child: Text(
                    ' :- $task',
                    textAlign: TextAlign.start,
                    style: theme.textTheme.titleMedium!
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Text('Plantation: $plantingDate'),
                SizedBox(width: 16),
                Text('Reminder on: $ReminderDate'),
              ],
            )
          ],
        ),
      ),
    );
  }
}
