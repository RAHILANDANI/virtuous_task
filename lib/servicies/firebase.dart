import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/student_record.dart';

class FirebaseService {
  final CollectionReference favoriteCollection =
  FirebaseFirestore.instance.collection('favorites');

  Future<void> addFavoriteList(Record record) async {
    await favoriteCollection.doc(record.id.toString()).set(record.toMap());
  }

  Future<void> removeFavoriteList(int id) async {
    await favoriteCollection.doc(id.toString()).delete();
  }
  Future<void> updateFavoriteList(Record record) async {
    await favoriteCollection.doc(record.id.toString()).update(record.toMap());
  }
}
