import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'registration_screen.dart';

class SearchService {
  searchByName(String searchField ) {
    return Firestore.instance
        .collection('users')
        .where('searchKey',
        isEqualTo: searchField.substring(0, 1).toLowerCase())
        .getDocuments();
  }
}