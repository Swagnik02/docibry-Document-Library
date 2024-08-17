import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:docibry/constants/string_constants.dart';
import 'package:flutter/material.dart';

class DocModel {
  final int uid;
  final String docName;
  final String docCategory;
  final String docId;
  final String holdersName;
  final DateTime dateAdded;
  final String docFile;

  DocModel({
    required this.uid,
    required this.docName,
    required this.docCategory,
    required this.docId,
    required this.holdersName,
    required this.dateAdded,
    required this.docFile,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'docName': docName,
      'docCategory': docCategory,
      'docId': docId,
      'holdersName': holdersName,
      'dateAdded': dateAdded.millisecondsSinceEpoch,
      'docFile': docFile,
    };
  }

  factory DocModel.fromMap(Map<String, dynamic> map) {
    return DocModel(
      uid: map['uid'],
      docName: map['docName'],
      docCategory: map['docCategory'],
      docId: map['docId'],
      holdersName: map['holdersName'],
      dateAdded: DateTime.fromMillisecondsSinceEpoch(map['dateAdded']),
      docFile: map['docFile'],
    );
  }

  // Helper method to convert a file to a Base64 string
  static Future<String> fileToBase64(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  // Helper method to convert a Base64 string to a file
  static Image base64ToImage(String base64String) {
    final decodedBytes = base64Decode(base64String);
    log('message' + decodedBytes.toString());

    return Image.memory(decodedBytes);
  }
}

// Sample documents for testing
DocModel doc1 = DocModel(
  uid: 001,
  docName: 'Aadhaar',
  docCategory: StringDocCategory.identity,
  docId: '123456',
  holdersName: 'Swagnik',
  dateAdded: DateTime(2024, 1, 15),
  docFile: 'docFile',
);

DocModel doc2 = DocModel(
  uid: 002,
  docName: 'Marksheet',
  docCategory: StringDocCategory.education,
  docId: '12',
  holdersName: 'Swagnik',
  dateAdded: DateTime(2023, 12, 22),
  docFile: 'docFile',
);

DocModel doc3 = DocModel(
  uid: 003,
  docName: 'Health Card',
  docCategory: StringDocCategory.health,
  docId: '12',
  holdersName: 'Swagnik',
  dateAdded: DateTime(2024, 2, 5),
  docFile: 'docFile',
);
