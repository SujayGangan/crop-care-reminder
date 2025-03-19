import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crop_care_reminder/models/crop.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class AddCropScreen extends StatefulWidget {
  const AddCropScreen({super.key});

  @override
  State<AddCropScreen> createState() {
    return _AddCropScreenState();
  }
}

class _AddCropScreenState extends State<AddCropScreen> {
  final TextEditingController cropController = TextEditingController();
  DateTime? _plantingDate;
  DateTime? _reminderDate;
  TimeOfDay? _selectedTime;
  Task _selectedTask = Task.watering;

  @override
  void dispose() {
    cropController.dispose();
    super.dispose();
  }

  void _save() async {
    final DateTime taskReminderDate = getCombinedDateTime();

    try {
      final task = _selectedTask.name;

      schedulePushNotification(
        "Crop Care Reminder",
        "Reminder for: $task (${cropController.text})",
        taskReminderDate,
      );

      await FirebaseFirestore.instance
          .collection('crops_collection')
          .doc(cropController.text)
          .set({
        'Crop name': cropController.text,
        'Crop planting date': _plantingDate,
        'Task Reminder date': taskReminderDate,
        'Crop task': task,
      });
    } on FirebaseException catch (e) {
      print('Error adding document: ${e.message}');
    } catch (e, stacktrace) {
      print('General error: $e');
      print('Stacktrace: $stacktrace');
    }
  }

  Future<void> _selectReminderDate(BuildContext context) async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _reminderDate = date);
      if (_reminderDate!.isBefore(_plantingDate!)) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reminder date must be after Planting date'),
          ),
        );
        setState(() {
          _reminderDate = null;
        });
        return;
      }
    }
  }

  Future<void> _selectReminderTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      if (_reminderDate == null) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Select reminder date first.'),
          ),
        );
        return;
      }
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  DateTime getCombinedDateTime() {
    if (_reminderDate != null && _selectedTime != null) {
      return DateTime(
        _reminderDate!.year,
        _reminderDate!.month,
        _reminderDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
    }
    return DateTime.now();
  }

  Future<void> schedulePushNotification(
      String title, String body, DateTime scheduledTime) async {
    String? token = await FirebaseMessaging.instance.getToken();

    await FirebaseFirestore.instance.collection('notifications').add({
      'title': title,
      'body': body,
      'scheduledTime': scheduledTime.toUtc().toIso8601String(),
      'token': token,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Crop')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: cropController,
              decoration: InputDecoration(labelText: 'Enter Crop Name'),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField(
                    value: _selectedTask,
                    items: [
                      for (final task in Task.values)
                        DropdownMenuItem(
                          value: task,
                          child: Text(task.name),
                        ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedTask = value!;
                      });
                    },
                  ),
                ),
                SizedBox(width: 20),
                // Planting Date
                TextButton(
                  onPressed: () async {
                    DateTime? date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2022),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _plantingDate = date);
                    }
                  },
                  child: Text(_plantingDate == null
                      ? 'Planting Date'
                      : '${_plantingDate!.toLocal()}'.split(' ')[0]),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                // Reminder Date
                TextButton(
                  onPressed: () async {
                    if (_plantingDate == null) {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Select planting date first.'),
                        ),
                      );
                      return;
                    }
                    _selectReminderDate(context);
                  },
                  child: Text(_reminderDate == null
                      ? 'Reminder Date'
                      : '${_reminderDate!.toLocal()}'.split(' ')[0]),
                ),
                SizedBox(width: 16),
                // Reminder Time
                TextButton(
                  onPressed: () async {
                    if (_reminderDate == null) {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Select reminder date first.'),
                        ),
                      );
                      return;
                    }
                    _selectReminderTime(context);
                  },
                  child: Text(_selectedTime == null
                      ? 'Reminder Time'
                      : _selectedTime!.format(context)),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (cropController.text.isEmpty ||
                    _plantingDate == null ||
                    _reminderDate == null ||
                    _selectedTime == null) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Fill all the fields.'),
                    ),
                  );
                  return;
                }

                _save();
                Navigator.of(context).pop();

                // Save crop details
                // Navigator.of(context).pop(Crop(
                //   cropName: cropController.text,
                //   plantingDate: _plantingDate!,
                //   harvestDate: _harvestDate!,
                //   task: _selectedTask,
                // ));
              },
              child: Text('Save Crop'),
            ),
          ],
        ),
      ),
    );
  }
}
