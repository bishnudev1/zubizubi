import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:zubizubi/app/app.locator.dart';
import 'package:zubizubi/app/routes.dart';
import 'package:zubizubi/data/models/user.dart' as UserModel;
import 'package:zubizubi/utils/toast.dart';

class AuthServices with ListenableServiceMixin {
  final _navigationService = locator<NavigationService>();

  Client client = Client()
      .setEndpoint('https://appwrite.bishnudevs.in/v1')
      .setProject('658bf6d7d729c67607f5')
      .setSelfSigned(status: true);

  bool isSignedIn() {
    final userBox = Hive.box<UserModel.User>('userBox');

    if (userBox.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  handleFacebookLogin() async {
    if (client == null) {
      showToast("Appwrite Client Initialization Failed");
      return;
    }
    try {
      final account = Account(client);
      await account.createOAuth2Session(
        provider: 'facebook',
      );
      notifyListeners();
    } on PlatformException catch (e) {
      showToast(e.message.toString());
      log('PlatformException: $e');
    } on AppwriteException catch (e) {
      showToast(e.message.toString());
      log('AppwriteException: $e');
    } finally {
      routerDelegate.beamToNamed('/shell');
    }
//     final LoginResult result = await FacebookAuth.instance
//         .login(); // by default we request the email and the public profile
// // or FacebookAuth.i.login()
//     if (result.status == LoginStatus.success) {
//       // you are logged
//       final AccessToken accessToken = result.accessToken!;
//       log(accessToken.toString());
//     } else {
//       log(result.status.toString());
//       log(result.message.toString());
//     }
  }

  // checkHiveStatus() async {
  //   var userBox = Hive.box<User>('userBox');
  //   log("user in hive with check: ${userBox}");
  // }

  handleGoogleLogin(BuildContext context) async {
    if (client == null) {
      showToast("Appwrite Client Initialization Failed");
      return;
    }
    try {
      var userBox = Hive.box<UserModel.User>('userBox');
      final account = Account(client);

      await account.createOAuth2Session(provider: 'google');

      final res = await account.get();

      log("res: ${res.email.toString()}");

      final databases = Databases(client);

      final isExist = await databases.listDocuments(
          databaseId: "658ebf7877a5df4a9f60",
          collectionId: "658ec36c61220704a694",
          queries: [Query.equal("email", res.email)]);

      // log("isExist: ${isExist.documents[0].data["id"]}");

      if (isExist.documents.isEmpty) {
        final documentId = DateTime.now().millisecondsSinceEpoch.toString();

        final id = documentId;
        final name = res.name;
        final email = res.email;
        final photoUrl =
            "https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png";
        final followers = [];
        final shares = [];
        final guest = false;
        final bio = "I am a Zubizubi User";
        final createdAt = DateTime.now().millisecondsSinceEpoch.toString();

        final user = UserModel.User.fromMap(
          {
            "id": id,
            "name": name,
            "email": email,
            "photoUrl": photoUrl,
            "followers": followers,
            "guest": guest,
            "shares": shares,
            "bio": bio,
            "createdAt": createdAt,
          },
        );

        await userBox.clear();
        await userBox.add(user);

        Map<String, dynamic> userData = user.toMap();

        final doc = await databases.createDocument(
            documentId: documentId,
            databaseId: "658ebf7877a5df4a9f60",
            collectionId: "658ec36c61220704a694",
            data: userData);
        notifyListeners();
        log("doc: ${doc.toString()}");
      }

      // log("Email aka LOL: ${isExist.documents[0].data['email']}");
      else {
        final id = isExist.documents[0].data["id"];
        final name = isExist.documents[0].data["name"];
        final email = isExist.documents[0].data["email"];
        final photoUrl = isExist.documents[0].data["photoUrl"];
        final followers = isExist.documents[0].data["followers"];
        final guest = isExist.documents[0].data["guest"];
        final bio = isExist.documents[0].data["bio"];
        final shares = isExist.documents[0].data["shares"];
        final createdAt = isExist.documents[0].data["createdAt"];

        final newUser = UserModel.User.fromMap(
          {
            "id": id,
            "name": name,
            "email": email,
            "photoUrl": photoUrl,
            "followers": followers,
            "guest": guest,
            "shares": shares,
            "bio": bio,
            "createdAt": createdAt,
          },
        );

        log("newUser: ${newUser.name}");

        await userBox.clear();
        await userBox.add(newUser);

        // log("user in hive again: ${userBox.getAt(0)?.name}");

        showToast("Welcome ${res.name}");
        notifyListeners();
      }
    } on PlatformException catch (e) {
      showToast(e.message.toString());
      log('PlatformException: $e');
    } on AppwriteException catch (e) {
      showToast(e.message.toString());
      log('AppwriteException: $e');
    } catch (e) {
      log(e.toString());
    } finally {
      routerDelegate.beamToNamed('/home');
    }
  }

  // getCurrentUser() async {
  //   try {
  //     var userBox = Hive.box<User>('userBox');
  //     User? user = userBox.getAt(0);
  //     log("user in hive: ${user?.name}");
  //     return user;
  //   } on PlatformException catch (e) {
  //     return null;
  //   } on AppwriteException catch (e) {
  //     return null;
  //   } catch (e) {
  //     return null;
  //   }
  // }

  getUser() async {
    if (client == null) {
      showToast("Appwrite Client Initialization Failed");
      return null;
    }
    try {
      final account = Account(client);
      final res = await account.get();
      final databases = Databases(client);
      final currentUser = await databases.listDocuments(
          databaseId: "658ebf7877a5df4a9f60",
          collectionId: "658ec36c61220704a694",
          queries: [Query.equal("email", res.email)]);
      notifyListeners();
      return currentUser.documents.first.data;
    } on PlatformException catch (e) {
      return null;
    } on AppwriteException catch (e) {
      return null;
    } catch (e) {
      return null;
    }
  }

  getLocalUser() async {
    try {
      var userBox = Hive.box<UserModel.User>('userBox');
      UserModel.User? user = userBox.getAt(0);
      log("user in hive: ${user?.name}");
      return user;
    } on PlatformException catch (e) {
      return null;
    } on AppwriteException catch (e) {
      return null;
    } catch (e) {
      return null;
    }
  }

  deleteProfileImage(BuildContext context) async {
    if (client == null) {
      showToast("Appwrite Client Initialization Failed");
      return;
    }
    try {
      var userBox = Hive.box<UserModel.User>('userBox');
      final account = Account(client);
      final res = await account.get();

      final databases = Databases(client);

      final getUser = await databases.listDocuments(
          databaseId: "658ebf7877a5df4a9f60",
          collectionId: "658ec36c61220704a694",
          queries: [Query.equal("email", res.email)]);

      final doc = await databases.updateDocument(
          documentId: getUser.documents[0].$id,
          databaseId: "658ebf7877a5df4a9f60",
          collectionId: "658ec36c61220704a694",
          data: {
            "photoUrl": "https://www.dpforwhatsapp.in/img/no-dp/19.webp",
          });

      log("doc: ${doc.toString()}");

      await userBox.put(
          0,
          UserModel.User.fromMap(
            {
              "id": getUser.documents[0].data["id"],
              "name": getUser.documents[0].data["name"],
              "email": getUser.documents[0].data["email"],
              "photoUrl": "https://www.dpforwhatsapp.in/img/no-dp/19.webp",
              "followers": getUser.documents[0].data["followers"],
              "shares": getUser.documents[0].data["shares"],
              "bio": getUser.documents[0].data["bio"],
              "createdAt": getUser.documents[0].data["createdAt"],
            },
          ));

      notifyListeners();
      showToast("Profile Image Deleted");
      log('Current User: ${res.toString()}');
      log("Current User Email: ${res.email}");
    } on PlatformException catch (e) {
      showToast(e.message.toString());
      log('PlatformException: $e');
    } on AppwriteException catch (e) {
      showToast(e.message.toString());
      log('AppwriteException: $e');
    } catch (e) {
      log(e.toString());
    } finally {
      Navigator.pop(context);
    }
  }

  updateProfileImage(BuildContext context, File image, String id) async {
    if (client == null) {
      showToast("Appwrite Client Initialization Failed");
      return;
    }
    try {
      var userBox = Hive.box<UserModel.User>('userBox');
      final account = Account(client);
      final res = await account.get();

      final storage = Storage(client);

      final imageId = DateTime.now().millisecondsSinceEpoch.toString();

      await storage.createFile(
          bucketId: "658fafe9b0bc0ad6a9c5",
          fileId: imageId,
          file: InputFile.fromPath(path: image.path));

      // final imageurl = await storage.getFilePreview(
      //     bucketId: "658fafe9b0bc0ad6a9c5", fileId: imageId);

      final imageurl =
          "https://appwrite.bishnudevs.in/v1/storage/buckets/658fafe9b0bc0ad6a9c5/files/${imageId}/view?project=658bf6d7d729c67607f5";

      log("imageurl: $imageurl");

      final databases = Databases(client);

      final getUser = await databases.listDocuments(
          databaseId: "658ebf7877a5df4a9f60",
          collectionId: "658ec36c61220704a694",
          queries: [Query.equal("email", res.email)]);

      final doc = await databases.updateDocument(
          documentId: id,
          databaseId: "658ebf7877a5df4a9f60",
          collectionId: "658ec36c61220704a694",
          data: {
            "photoUrl": imageurl,
          });

      log("doc: ${doc.toString()}");

      await userBox.put(
          0,
          UserModel.User.fromMap(
            {
              "id": getUser.documents[0].data["id"],
              "name": getUser.documents[0].data["name"],
              "email": getUser.documents[0].data["email"],
              "photoUrl": imageurl,
              "followers": getUser.documents[0].data["followers"],
              "bio": getUser.documents[0].data["bio"],
              "shares": getUser.documents[0].data["shares"],
              "createdAt": getUser.documents[0].data["createdAt"],
            },
          ));

      notifyListeners();
      showToast("Profile Image Updated");
      log('Current User: ${res.toString()}');
      log("Current User Email: ${res.email}");
    } on PlatformException catch (e) {
      showToast(e.message.toString());
      log('PlatformException: $e');
    } on AppwriteException catch (e) {
      showToast(e.message.toString());
      log('AppwriteException: $e');
    } catch (e) {
      log(e.toString());
    } finally {
      Navigator.pop(context);
    }
  }

  logoutUser(BuildContext context) async {
    if (client == null) {
      showToast("Appwrite Client Initialization Failed");
      return;
    }
    try {
      final userBox = Hive.box<UserModel.User>('userBox');
      final account = Account(client);
      account.deleteSession(sessionId: 'current');
      userBox.clear();
      showToast("Logout Successful");
      notifyListeners();
    } on PlatformException catch (e) {
      showToast(e.message.toString());
      log('PlatformException: $e');
    } on AppwriteException catch (e) {
      showToast(e.message.toString());
      log('AppwriteException: $e');
    } catch (e) {
      log(e.toString());
    } finally {
      Beamer.of(context).beamToNamed('/home');
    }
  }

  getUserVideos(String creator) async {
    log("Current Creator Name: ${creator}");
    if (client == null) {
      showToast("Appwrite Client Initialization Failed");
      return null;
    }
    try {
      final databases = Databases(client);

      final isExist = await databases.listDocuments(
          databaseId: "658ebf7877a5df4a9f60",
          collectionId: "658ebf9654ca69759383",
          queries: [Query.equal("creator", creator)]);
      log("isExist: ${isExist.documents.length}");
      return isExist.documents;
    } on PlatformException catch (e) {
      log(e.toString());
    } on AppwriteException catch (e) {
      log(e.toString());
    } catch (e) {
      log(e.toString());
    }
  }

  getAllUsers() async {
    if (client == null) {
      showToast("Appwrite Client Initialization Failed");
      return null;
    }
    try {
      final databases = Databases(client);

      final isExist = await databases.listDocuments(
          databaseId: "658ebf7877a5df4a9f60",
          collectionId: "658ec36c61220704a694");
      log("isExist: ${isExist.documents.length}");
      return isExist.documents;
    } on PlatformException catch (e) {
      log(e.toString());
    } on AppwriteException catch (e) {
      log(e.toString());
    } catch (e) {
      log(e.toString());
    }
  }

  followUser(String email, List followers, String id) async {
    log("User id: ${id}");
    if (client == null) {
      showToast("Appwrite Client Initialization Failed");
      return null;
    }
    final userBox = Hive.box<UserModel.User>('userBox');
    try {
      final databases = Databases(client);

      followers.add(email);
      notifyListeners();

      final newUser = UserModel.User.fromMap(
        {
          "id": userBox.getAt(0)?.id,
          "name": userBox.getAt(0)?.name,
          "email": userBox.getAt(0)?.email,
          "photoUrl": userBox.getAt(0)?.photoUrl,
          "followers": followers,
          "guest": userBox.getAt(0)?.guest,
          "bio": userBox.getAt(0)?.bio,
          "shares": userBox.getAt(0)?.shares,
          "createdAt": userBox.getAt(0)?.createdAt,
        },
      );

      log("newUser: ${newUser.name}");

      userBox.put(0, newUser);

      notifyListeners();

      log("followers is auth: ${followers}");

      final resp1 = await databases.updateDocument(
          documentId: id,
          databaseId: "658ebf7877a5df4a9f60",
          collectionId: "658ec36c61220704a694",
          data: {"followers": followers});

      log("resp1: ${resp1.toString()}");
    } on PlatformException catch (e) {
      log(e.toString());
    } on AppwriteException catch (e) {
      log(e.toString());
    } catch (e) {
      log(e.toString());
    }
  }

  unfollowUser(String email, List followers, String id) async {
    log("User id: ${id}");
    if (client == null) {
      showToast("Appwrite Client Initialization Failed");
      return null;
    }
    final userBox = Hive.box<UserModel.User>('userBox');
    try {
      final databases = Databases(client);

      followers.remove(email);
      notifyListeners();

      userBox.put(
          0,
          UserModel.User.fromMap(
            {
              "id": userBox.getAt(0)?.id,
              "name": userBox.getAt(0)?.name,
              "email": userBox.getAt(0)?.email,
              "photoUrl": userBox.getAt(0)?.photoUrl,
              "followers": followers,
              "guest": userBox.getAt(0)?.guest,
              "bio": userBox.getAt(0)?.bio,
              "shares": userBox.getAt(0)?.shares,
              "createdAt": userBox.getAt(0)?.createdAt,
            },
          ));

      // userBox.put(
      //     0,
      //     UserModel.User.fromMap({"followers": followers}).toMap()
      //         as UserModel.User);
      // notifyListeners();

      await databases.updateDocument(
          documentId: id,
          databaseId: "658ebf7877a5df4a9f60",
          collectionId: "658ec36c61220704a694",
          data: {"followers": followers});
    } on PlatformException catch (e) {
      log(e.toString());
    } on AppwriteException catch (e) {
      log(e.toString());
    } catch (e) {
      log(e.toString());
    }
  }

  getAllUserFollowers(String email) async {
    if (client == null) {
      showToast("Appwrite Client Initialization Failed");
      return null;
    }
    try {
      final databases = Databases(client);

      final isExist = await databases.listDocuments(
          databaseId: "658ebf7877a5df4a9f60",
          collectionId: "658ec36c61220704a694",
          queries: [Query.equal("email", email)]);

      log("isExist: ${isExist.documents.length}");
      var user = isExist.documents[0].data;

      return user["followers"];
    } on PlatformException catch (e) {
      log(e.toString());
    } on AppwriteException catch (e) {
      log(e.toString());
    } catch (e) {
      log(e.toString());
    }
  }

  editProfileBio(String bio, String userId) async {
    if (client == null) {
      showToast("Appwrite Client Initialization Failed");
      return null;
    }
    try {
      final userBox = Hive.box<UserModel.User>('userBox');
      final databases = Databases(client);

      userBox.put(
          0,
          UserModel.User.fromMap(
            {
              "id": userBox.getAt(0)?.id,
              "name": userBox.getAt(0)?.name,
              "email": userBox.getAt(0)?.email,
              "photoUrl": userBox.getAt(0)?.photoUrl,
              "followers": userBox.getAt(0)?.followers,
              "bio": bio,
              "shares": userBox.getAt(0)?.shares,
              "createdAt": userBox.getAt(0)?.createdAt,
            },
          ));
      notifyListeners();

      await databases.updateDocument(
          documentId: userId,
          databaseId: "658ebf7877a5df4a9f60",
          collectionId: "658ec36c61220704a694",
          data: {"bio": bio});
    } on PlatformException catch (e) {
      log(e.toString());
    } on AppwriteException catch (e) {
      log(e.toString());
    } catch (e) {
      log(e.toString());
    }
  }
}
