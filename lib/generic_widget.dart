import 'package:flutter/material.dart';

Center emptyBackgroundTextMessage(String text) {
  return Center(
    child: Text(
      text,
      style: TextStyle(
        fontSize: 30,
        color: Colors.grey,
      ),
    ),
  );
}
