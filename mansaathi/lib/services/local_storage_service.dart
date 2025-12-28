import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

/// Local Storage Service - Replaces Firebase Storage
/// Stores all files locally: images, audio, videos, documents
class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  // Storage directories
  late Directory _appDir;
  late Directory _profilePhotosDir;
  late Directory _meditationAudioDir;
  late Directory _sessionRecordingsDir;
  late Directory _cacheDir;
  late Directory _therapistPhotosDir;
  late Directory _communityImagesDir;

  /// Initialize all storage directories
  Future<void> initialize() async {
    try {
      _appDir = await getApplicationDocumentsDirectory();

      // Create subdirectories
      _profilePhotosDir = Directory(path.join(_appDir.path, 'profile_photos'));
      _meditationAudioDir = Directory(
        path.join(_appDir.path, 'meditation_audio'),
      );
      _sessionRecordingsDir = Directory(
        path.join(_appDir.path, 'session_recordings'),
      );
      _therapistPhotosDir = Directory(
        path.join(_appDir.path, 'therapist_photos'),
      );
      _communityImagesDir = Directory(
        path.join(_appDir.path, 'community_images'),
      );
      _cacheDir = Directory(path.join(_appDir.path, 'cache'));

      // Create all directories if they don't exist
      await Future.wait([
        _profilePhotosDir.create(recursive: true),
        _meditationAudioDir.create(recursive: true),
        _sessionRecordingsDir.create(recursive: true),
        _therapistPhotosDir.create(recursive: true),
        _communityImagesDir.create(recursive: true),
        _cacheDir.create(recursive: true),
      ]);

      debugPrint('✅ Local storage initialized at: ${_appDir.path}');
    } catch (e) {
      debugPrint('❌ Error initializing local storage: $e');
      rethrow;
    }
  }

  /// Save profile photo locally
  Future<String> saveProfilePhoto(String userId, File imageFile) async {
    try {
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = path.join(_profilePhotosDir.path, fileName);

      final savedFile = await imageFile.copy(filePath);
      debugPrint('✅ Profile photo saved: $filePath');

      return savedFile.path;
    } catch (e) {
      debugPrint('❌ Error saving profile photo: $e');
      rethrow;
    }
  }

  /// Save profile photo from bytes (for downloaded images)
  Future<String> saveProfilePhotoFromBytes(
    String userId,
    Uint8List bytes,
  ) async {
    try {
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = path.join(_profilePhotosDir.path, fileName);

      final file = File(filePath);
      await file.writeAsBytes(bytes);
      debugPrint('✅ Profile photo saved from bytes: $filePath');

      return filePath;
    } catch (e) {
      debugPrint('❌ Error saving profile photo from bytes: $e');
      rethrow;
    }
  }

  /// Get profile photo path
  String? getProfilePhotoPath(String userId) {
    try {
      final files = _profilePhotosDir
          .listSync()
          .whereType<File>()
          .where((file) => path.basename(file.path).startsWith(userId))
          .toList();

      if (files.isEmpty) return null;

      // Return the most recent file
      files.sort(
        (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
      );
      return files.first.path;
    } catch (e) {
      debugPrint('❌ Error getting profile photo: $e');
      return null;
    }
  }

  /// Save therapist photo locally
  Future<String> saveTherapistPhoto(String therapistId, File imageFile) async {
    try {
      final fileName =
          '${therapistId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = path.join(_therapistPhotosDir.path, fileName);

      final savedFile = await imageFile.copy(filePath);
      debugPrint('✅ Therapist photo saved: $filePath');

      return savedFile.path;
    } catch (e) {
      debugPrint('❌ Error saving therapist photo: $e');
      rethrow;
    }
  }

  /// Save meditation audio file
  Future<String> saveMeditationAudio(String contentId, File audioFile) async {
    try {
      final fileName =
          '${contentId}_${DateTime.now().millisecondsSinceEpoch}.mp3';
      final filePath = path.join(_meditationAudioDir.path, fileName);

      final savedFile = await audioFile.copy(filePath);
      debugPrint('✅ Meditation audio saved: $filePath');

      return savedFile.path;
    } catch (e) {
      debugPrint('❌ Error saving meditation audio: $e');
      rethrow;
    }
  }

  /// Save meditation audio from URL (download and cache)
  Future<String> downloadAndCacheMeditationAudio(
    String contentId,
    String url,
  ) async {
    try {
      // Check if already cached
      final cachedPath = getMeditationAudioPath(contentId);
      if (cachedPath != null && File(cachedPath).existsSync()) {
        debugPrint('✅ Using cached audio: $cachedPath');
        return cachedPath;
      }

      // Download file
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(url));
      final response = await request.close();

      final fileName = '${contentId}.mp3';
      final filePath = path.join(_meditationAudioDir.path, fileName);
      final file = File(filePath);

      final bytes = await consolidateHttpClientResponseBytes(response);
      await file.writeAsBytes(bytes);

      debugPrint('✅ Audio downloaded and cached: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('❌ Error downloading meditation audio: $e');
      rethrow;
    }
  }

  /// Get meditation audio path
  String? getMeditationAudioPath(String contentId) {
    try {
      final files = _meditationAudioDir
          .listSync()
          .whereType<File>()
          .where((file) => path.basename(file.path).startsWith(contentId))
          .toList();

      if (files.isEmpty) return null;
      return files.first.path;
    } catch (e) {
      debugPrint('❌ Error getting meditation audio: $e');
      return null;
    }
  }

  /// Save session recording locally (with user consent)
  Future<String> saveSessionRecording(
    String sessionId,
    File recordingFile,
  ) async {
    try {
      final fileName =
          'session_${sessionId}_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final filePath = path.join(_sessionRecordingsDir.path, fileName);

      final savedFile = await recordingFile.copy(filePath);
      debugPrint('✅ Session recording saved: $filePath');

      return savedFile.path;
    } catch (e) {
      debugPrint('❌ Error saving session recording: $e');
      rethrow;
    }
  }

  /// Get session recording path
  String? getSessionRecordingPath(String sessionId) {
    try {
      final files = _sessionRecordingsDir
          .listSync()
          .whereType<File>()
          .where((file) => path.basename(file.path).contains(sessionId))
          .toList();

      if (files.isEmpty) return null;
      return files.first.path;
    } catch (e) {
      debugPrint('❌ Error getting session recording: $e');
      return null;
    }
  }

  /// Save community image
  Future<String> saveCommunityImage(String postId, File imageFile) async {
    try {
      final fileName = '${postId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = path.join(_communityImagesDir.path, fileName);

      final savedFile = await imageFile.copy(filePath);
      debugPrint('✅ Community image saved: $filePath');

      return savedFile.path;
    } catch (e) {
      debugPrint('❌ Error saving community image: $e');
      rethrow;
    }
  }

  /// Cache image from URL
  Future<String> cacheImageFromUrl(String url, String identifier) async {
    try {
      final cachedPath = getCachedImagePath(identifier);
      if (cachedPath != null && File(cachedPath).existsSync()) {
        return cachedPath;
      }

      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(url));
      final response = await request.close();

      final fileName = '$identifier.jpg';
      final filePath = path.join(_cacheDir.path, fileName);
      final file = File(filePath);

      final bytes = await consolidateHttpClientResponseBytes(response);
      await file.writeAsBytes(bytes);

      return filePath;
    } catch (e) {
      debugPrint('❌ Error caching image: $e');
      rethrow;
    }
  }

  /// Get cached image path
  String? getCachedImagePath(String identifier) {
    try {
      final filePath = path.join(_cacheDir.path, '$identifier.jpg');
      final file = File(filePath);

      if (file.existsSync()) {
        return filePath;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Delete specific file
  Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('✅ File deleted: $filePath');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error deleting file: $e');
      return false;
    }
  }

  /// Delete all user data (for account deletion)
  Future<void> deleteAllUserData(String userId) async {
    try {
      // Delete profile photos
      final profileFiles = _profilePhotosDir.listSync().whereType<File>().where(
        (file) => path.basename(file.path).startsWith(userId),
      );

      for (final file in profileFiles) {
        await file.delete();
      }

      // Delete session recordings for this user
      final sessionFiles = _sessionRecordingsDir
          .listSync()
          .whereType<File>()
          .where((file) => path.basename(file.path).contains(userId));

      for (final file in sessionFiles) {
        await file.delete();
      }

      debugPrint('✅ All user data deleted for: $userId');
    } catch (e) {
      debugPrint('❌ Error deleting user data: $e');
      rethrow;
    }
  }

  /// Clear cache directory
  Future<void> clearCache() async {
    try {
      if (await _cacheDir.exists()) {
        await _cacheDir.delete(recursive: true);
        await _cacheDir.create();
        debugPrint('✅ Cache cleared');
      }
    } catch (e) {
      debugPrint('❌ Error clearing cache: $e');
      rethrow;
    }
  }

  /// Get total storage used (in bytes)
  Future<int> getTotalStorageUsed() async {
    try {
      int totalSize = 0;

      final directories = [
        _profilePhotosDir,
        _meditationAudioDir,
        _sessionRecordingsDir,
        _therapistPhotosDir,
        _communityImagesDir,
        _cacheDir,
      ];

      for (final dir in directories) {
        if (await dir.exists()) {
          final files = dir.listSync(recursive: true).whereType<File>();
          for (final file in files) {
            totalSize += await file.length();
          }
        }
      }

      return totalSize;
    } catch (e) {
      debugPrint('❌ Error calculating storage: $e');
      return 0;
    }
  }

  /// Get storage used in human-readable format
  Future<String> getStorageUsedFormatted() async {
    final bytes = await getTotalStorageUsed();

    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Check if enough storage available (at least 100MB free)
  Future<bool> hasEnoughStorage() async {
    try {
      final totalUsed = await getTotalStorageUsed();
      final availableSpace = 100 * 1024 * 1024; // 100MB threshold

      // This is simplified - you might want to check actual device storage
      return totalUsed < availableSpace;
    } catch (e) {
      return true; // Assume enough space on error
    }
  }

  // Getters for directory paths
  String get appDirPath => _appDir.path;
  String get profilePhotosDirPath => _profilePhotosDir.path;
  String get meditationAudioDirPath => _meditationAudioDir.path;
  String get sessionRecordingsDirPath => _sessionRecordingsDir.path;
  String get therapistPhotosDirPath => _therapistPhotosDir.path;
  String get communityImagesDirPath => _communityImagesDir.path;
  String get cacheDirPath => _cacheDir.path;
}
