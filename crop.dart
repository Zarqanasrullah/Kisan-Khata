
import 'package:cloud_firestore/cloud_firestore.dart';

enum CropStatus { pending, approved, rejected }

class Crop {
  final String id;
  final String ownerId;
  final String name;
  final String type;
  final double pricePerUnit;
  final String unit;
  final String imageUrl;
  final CropStatus status;
  final String? adminNote;
  final Timestamp createdAt;

  Crop({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.type,
    required this.pricePerUnit,
    required this.unit,
    required this.imageUrl,
    required this.status,
    required this.createdAt,
    this.adminNote,
  });

  factory Crop.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Crop(
      id: doc.id,
      ownerId: d['ownerId'] as String,
      name: d['name'] as String,
      type: d['type'] as String,
      pricePerUnit: (d['pricePerUnit'] as num).toDouble(),
      unit: (d['unit'] as String?) ?? 'Per Kg',
      imageUrl: d['imageUrl'] as String,
      status: CropStatus.values.firstWhere((e) => e.name == (d['status'] as String)),
      adminNote: d['adminNote'] as String?,
      createdAt: d['createdAt'] as Timestamp,
    );
  }

  Map<String, dynamic> toMap() => {
    'ownerId': ownerId,
    'name': name,
    'type': type,
    'pricePerUnit': pricePerUnit,
    'unit': unit,
    'imageUrl': imageUrl,
    'status': status.name,
    'adminNote': adminNote,
    'createdAt': createdAt,
  };
}
