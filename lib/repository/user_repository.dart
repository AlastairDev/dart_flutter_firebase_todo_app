import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserRepository {
  final GoogleSignIn googleSignIn = new GoogleSignIn(
    scopes: ['email',],
  );
  FirebaseUser user;
  GoogleSignInAccount googleAccount;
  GoogleSignInAuthentication googleAuth;
  String uid;
  String email;
  String userName;
  String imageUrl;

  Future<bool> logIn() async {
    googleAccount = await googleSignIn.signIn();
    if(googleAccount == null){
      return false;
    }
    googleAuth = await googleAccount.authentication;
    bool isUserInitCompleted = false;
    user = await FirebaseAuth.instance.currentUser();
    if (user != null) {
      isUserInitCompleted = true;
    }else{
      await FirebaseAuth.instance.signInWithGoogle(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
    }
    uid = user.uid;
    email = user.email;
    userName = user.displayName;
    imageUrl = user.photoUrl;
    return isUserInitCompleted;
  }

  Future<bool> logOut() async {
    await googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
    return true;
  }
}
