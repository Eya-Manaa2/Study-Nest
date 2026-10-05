import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ─── Storage Service (Firebase Cloud Storage) ─────────────────────────────

class StorageService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Obtenir l'ID de l'utilisateur courant
  String? get _userId => _auth.currentUser?.uid;

  // ─── Upload de fichier vers Firebase Storage ─────────────────────────────

  Future<String> uploadFile({
    required String fileName,
    required String subjectId,
    required File fileToUpload,
    Function(double)? onProgress,
  }) async {
    final userId = _userId;
    if (userId == null) throw Exception('Utilisateur non connecté');
    
    try {
      // Créer une référence dans Firebase Storage
      final storageRef = _storage
          .ref()
          .child('users')
          .child(userId)
          .child('documents')
          .child(subjectId)
          .child(fileName);
      
      // Upload du fichier avec progression
      final uploadTask = storageRef.putFile(fileToUpload);
      
      // Écouter la progression
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });
      
      // Attendre la fin de l'upload
      final snapshot = await uploadTask;
      
      if (snapshot.state == TaskState.success) {
        // Obtenir l'URL de téléchargement
        final downloadUrl = await storageRef.getDownloadURL();
        return downloadUrl;
      } else {
        throw Exception('Échec de l\'upload');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'upload: $e');
    }
  }

  // ─── Téléchargement de fichier depuis Firebase Storage ───────────────────────

  Future<String> getDownloadUrl({
    required String subjectId,
    required String fileName,
  }) async {
    final userId = _userId;
    if (userId == null) throw Exception('Utilisateur non connecté');
    
    try {
      final storageRef = _storage
          .ref()
          .child('users')
          .child(userId)
          .child('documents')
          .child(subjectId)
          .child(fileName);
      
      final downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Erreur lors du téléchargement: $e');
    }
  }

  // ─── Suppression de fichier de Firebase Storage ─────────────────────────────

  Future<void> deleteFile({
    required String subjectId,
    required String fileName,
  }) async {
    final userId = _userId;
    if (userId == null) throw Exception('Utilisateur non connecté');
    
    try {
      final storageRef = _storage
          .ref()
          .child('users')
          .child(userId)
          .child('documents')
          .child(subjectId)
          .child(fileName);
      
      await storageRef.delete();
    } catch (e) {
      // Ignorer l'erreur si le fichier n'existe pas (404)
      // Cela arrive quand un document existe dans Firestore mais pas dans Storage
      if (e.toString().contains('404') || e.toString().contains('Not Found')) {
        return;
      }
      throw Exception('Erreur lors de la suppression: $e');
    }
  }

  // ─── Lister les fichiers d'une matière (Firebase Storage) ───────────────────────

  Future<List<String>> listFiles(String subjectId) async {
    final userId = _userId;
    if (userId == null) throw Exception('Utilisateur non connecté');
    
    try {
      final storageRef = _storage
          .ref()
          .child('users')
          .child(userId)
          .child('documents')
          .child(subjectId);
      
      final result = await storageRef.listAll();
      return result.items.map((ref) => ref.name).toList();
    } catch (e) {
      throw Exception('Erreur lors du listage: $e');
    }
  }
}

// ─── Providers ─────────────────────────────────────────────────────────────────

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});
