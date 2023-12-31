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
import 'package:zubizubi/data/models/user.dart';
import 'package:zubizubi/utils/toast.dart';

class AuthServices with ListenableServiceMixin {
  final _navigationService = locator<NavigationService>();

  Client client = Client()
      .setEndpoint('https://appwrite.bishnudevs.in/v1')
      .setProject('658bf6d7d729c67607f5')
      .setSelfSigned(status: true);

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

  checkHiveStatus() async {
    var userBox = Hive.box<User>('userBox');
    log("user in hive with check: ${userBox}");
  }

  handleGoogleLogin(BuildContext context) async {
    if (client == null) {
      showToast("Appwrite Client Initialization Failed");
      return;
    }
    try {
      var userBox = Hive.box<User>('userBox');
      final account = Account(client);

      await account.createOAuth2Session(provider: 'google');

      final res = await account.get();

      final databases = Databases(client);

      final isExist = await databases.listDocuments(
          databaseId: "658ebf7877a5df4a9f60",
          collectionId: "658ec36c61220704a694",
          queries: [Query.equal("email", res.email)]);

      log("isExist: ${isExist.documents[0].data["id"]}");

      if (isExist.documents.isEmpty) {
        final documentId = DateTime.now().millisecondsSinceEpoch.toString();

        final id = documentId;
        final name = res.name;
        final email = res.email;
        final photoUrl =
            "https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png";
        final followers = [];
        final shares = [];
        final createdAt = DateTime.now().millisecondsSinceEpoch.toString();

        final user = User.fromMap(
          {
            "id": id,
            "name": name,
            "email": email,
            "photoUrl": photoUrl,
            "followers": followers,
            "shares": shares,
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
        final shares = isExist.documents[0].data["shares"];
        final createdAt = isExist.documents[0].data["createdAt"];

        final newUser = User.fromMap(
          {
            "id": id,
            "name": name,
            "email": email,
            "photoUrl": photoUrl,
            "followers": followers,
            "shares": shares,
            "createdAt": createdAt,
          },
        );

        log("newUser: ${newUser.name}");

        await userBox.clear();
        await userBox.add(newUser);

        log("user in hive again: ${userBox.getAt(0)?.name}");

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
      routerDelegate.beamToNamed('/shell');
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

  getLocalUser() async {
    try {
      var userBox = Hive.box<User>('userBox');
      User? user = userBox.getAt(0);
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
      var userBox = Hive.box<User>('userBox');
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
          User.fromMap(
            {
              "id": getUser.documents[0].data["id"],
              "name": getUser.documents[0].data["name"],
              "email": getUser.documents[0].data["email"],
              "photoUrl": "https://www.dpforwhatsapp.in/img/no-dp/19.webp",
              "followers": getUser.documents[0].data["followers"],
              "shares": getUser.documents[0].data["shares"],
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
      var userBox = Hive.box<User>('userBox');
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
          User.fromMap(
            {
              "id": getUser.documents[0].data["id"],
              "name": getUser.documents[0].data["name"],
              "email": getUser.documents[0].data["email"],
              "photoUrl": imageurl,
              "followers": getUser.documents[0].data["followers"],
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
      final account = Account(client);
      account.deleteSession(sessionId: 'current');
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
      Beamer.of(context).beamToNamed('/login');
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
}
