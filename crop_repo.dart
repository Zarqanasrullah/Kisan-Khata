
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../models/crop.dart';

const dummyCropImages = {
  'Wheat'   : 'https://upload.wikimedia.org/wikipedia/commons/6/6b/Vandenberg_Village_wheatfield_%28Unsplash%29.jpg',
  'Rice'    : 'https://upload.wikimedia.org/wikipedia/commons/e/e8/Rice_plant_01.jpg',
  'Maize'   : 'https://upload.wikimedia.org/wikipedia/commons/e/e0/Corn_cob.jpg',
  'Sugarcane': 'https://upload.wikimedia.org/wikipedia/commons/e/ed/Sugarcane_field.jpg',
  'Cotton'  : 'https://upload.wikimedia.org/wikipedia/commons/c/c4/COTTON_BOLL_AND_BLOOM_close_up_%2849168276928%29.jpg',
  'Potato'  : 'https://upload.wikimedia.org/wikipedia/commons/b/b9/Potato_flowers.jpg',
  'Tomato'  : 'https://upload.wikimedia.org/wikipedia/commons/e/e4/Tomato_plant_01.JPG',
};

class CropRepo {
  final _fs = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;

  Future<String?> _uploadImage(XFile file) async {
    final uid = _auth.currentUser!.uid;
    final ref = _storage.ref().child('crops').child(uid).child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(File(file.path));
    return await ref.getDownloadURL();
  }

  Stream<List<Crop>> myCropsStream() {
    final uid = _auth.currentUser!.uid;
    return _fs.collection('crops')
      .where('ownerId', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => Crop.fromDoc(d)).toList());
  }

  Stream<List<Crop>> pendingCropsStream() {
    return _fs.collection('crops')
      .where('status', isEqualTo: 'pending')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => Crop.fromDoc(d)).toList());
  }

  Stream<List<Crop>> approvedCropsStream() {
    return _fs.collection('crops')
      .where('status', isEqualTo: 'approved')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => Crop.fromDoc(d)).toList());
  }

  Future<void> addCrop({
    required String name,
    required String type,
    required double pricePerUnit,
    required String unit,
    required File imageFile,
  }) async {
    final uid = _auth.currentUser!.uid;
    // final imgRef = _storage.ref().child('crops').child(uid).child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    // await imgRef.putFile(imageFile);
    // final url = await imgRef.getDownloadURL();
    await _fs.collection('crops').add({
      'ownerId': uid,
      'name': name,
      'type': type,
      'pricePerUnit': pricePerUnit,
      'unit': unit,
      'imageUrl': 'url',
      'status': 'pending',
      'adminNote': null,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> approve(String cropId, {String? note}) async {
    await _fs.collection('crops').doc(cropId).update({'status': 'approved', 'adminNote': note ?? ''});
  }
  Future<void> reject(String cropId, {String? note}) async {
    await _fs.collection('crops').doc(cropId).update({'status': 'rejected', 'adminNote': note ?? ''});
  }

  // Transactions
  Stream<List<Map<String, dynamic>>> transactionsStream(String cropId) {
    return _fs.collection('crops').doc(cropId).collection('transactions')
      .orderBy('date', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Future<void> addTransaction({
    required String cropId,
    required String buyerName,
    required double quantity,
    required double totalPrice,
    required DateTime date,
  }) async {
    await _fs.collection('crops').doc(cropId).collection('transactions').add({
      'buyerName': buyerName,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'date': Timestamp.fromDate(date),
    });
  }

  Future<void> reviewCrop(String cropId, {required bool approve, String? note}) async {
    await _fs.collection('crops').doc(cropId).update({
      'status': approve ? 'approved' : 'rejected',
      'adminNote': note,
    });
  }

}
