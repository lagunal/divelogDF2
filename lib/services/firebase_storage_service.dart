import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logging/logging.dart';

class FirebaseStorageService {
  static final Logger _log = Logger('FirebaseStorageService');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadProfilePhoto(File imageFile, String userId) async {
    try {
      final path = 'users/$userId/profile.jpg';
      final ref = _storage.ref().child(path);

      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      _log.info('Profile photo uploaded successfully. URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      _log.severe('Error uploading profile photo', e);
      return null;
    }
  }
}
