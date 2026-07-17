import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/screening_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Membuat atau memperbarui dokumen user saat login
  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(
          user.toMap(),
          SetOptions(merge: true), // Menggunakan merge agar data skrining lama tidak terhapus
        );
  }

  // Mengambil data spesifik user berdasarkan UID
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }
  
  Future<void> saveScreeningResult(String uid, ScreeningModel screening) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('screenings') // Menyimpan ke dalam riwayat user terkait
        .add(screening.toMap());  // Pastikan screening_model.dart kamu punya fungsi toMap()
  }

}