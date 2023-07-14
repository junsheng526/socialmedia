// return a formmated data as a string

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:intl/intl.dart';

String formatDateTime(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();

  // Format the date
  String formattedDate = DateFormat('dd MMMM yyyy').format(dateTime);

  // Format the time
  String formattedTime = DateFormat('hh:mm a').format(dateTime);

  // Combine the formatted date and time
  String formattedDateTime = '$formattedDate $formattedTime';

  return formattedDateTime;
}
