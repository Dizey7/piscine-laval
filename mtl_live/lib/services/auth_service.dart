import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

/// Service d'authentification (Google + Apple Sign-In)
class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final GoogleSignIn _googleSignIn;

  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Connexion avec Google
  Future<User?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final result = await _auth.signInWithCredential(credential);
    if (result.user != null) {
      await _createOrUpdateUser(result.user!);
    }
    return result.user;
  }

  /// Connexion avec Apple
  Future<User?> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final result = await _auth.signInWithCredential(oauthCredential);
    if (result.user != null) {
      await _createOrUpdateUser(result.user!);
    }
    return result.user;
  }

  /// Déconnexion
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// Crée ou met à jour le profil utilisateur dans Firestore
  Future<void> _createOrUpdateUser(User user) async {
    final ref = _db.collection(AppConstants.usersCollection).doc(user.uid);
    final doc = await ref.get();

    if (!doc.exists) {
      final appUser = AppUser(
        uid: user.uid,
        displayName: user.displayName,
        email: user.email,
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
      );
      await ref.set(appUser.toFirestore());
    } else {
      await ref.update({
        'displayName': user.displayName,
        'photoUrl': user.photoURL,
      });
    }
  }

  /// Récupère le profil utilisateur
  Future<AppUser?> getUserProfile() async {
    if (currentUser == null) return null;
    final doc = await _db
        .collection(AppConstants.usersCollection)
        .doc(currentUser!.uid)
        .get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  /// Toggle favori
  Future<void> toggleFavorite(String eventId) async {
    if (currentUser == null) return;
    final ref = _db.collection(AppConstants.usersCollection).doc(currentUser!.uid);
    final doc = await ref.get();
    final favorites = List<String>.from(doc.data()?['favoriteIds'] ?? []);

    if (favorites.contains(eventId)) {
      favorites.remove(eventId);
    } else {
      favorites.add(eventId);
    }

    await ref.update({'favoriteIds': favorites});
  }

  /// Vérifie si un événement est en favoris
  Future<bool> isFavorite(String eventId) async {
    if (currentUser == null) return false;
    final doc = await _db
        .collection(AppConstants.usersCollection)
        .doc(currentUser!.uid)
        .get();
    final favorites = List<String>.from(doc.data()?['favoriteIds'] ?? []);
    return favorites.contains(eventId);
  }
}
