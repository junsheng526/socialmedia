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

String returnAgos(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  DateTime now = DateTime.now();
  Duration difference = now.difference(dateTime);

  if (difference.inSeconds < 60) {
    return 'just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} m';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} h';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} d';
  } else {
    int weeks = (difference.inDays / 7).floor();
    return '$weeks w';
  }
}
