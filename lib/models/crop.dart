class Crop {
  const Crop({
    required this.cropName,
    required this.plantingDate,
    required this.reminderDate,
    required this.task,
  });

  final String cropName;
  final DateTime plantingDate;
  final DateTime reminderDate;
  final Task task;
}

enum Task {
  watering,
  fertilizing,
  pestControl,
  harvesting,
}
