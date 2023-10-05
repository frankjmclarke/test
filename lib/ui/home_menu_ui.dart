import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';
import 'components/form_vertical_spacing.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class Avatar extends StatelessWidget {
  final UserModel user;

  Avatar(this.user);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 50.sp,
      backgroundImage:  user.photoUrl.isNotEmpty
          ? NetworkImage(user.photoUrl)
          : AssetImage('assets/images/default.png') as ImageProvider, // Cast AssetImage to ImageProvider
    );
  }
}

class HomeMenuUI extends StatelessWidget {
  final AuthController authController = Get.find();

  _changeImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      final Reference storageRef = FirebaseStorage.instance.ref().child('avatar').child(authController.firebaseUser.value!.uid);

      try {
        final compressedImageFile = await compressImage(imageFile);

        final TaskSnapshot taskSnapshot = await storageRef.putFile(compressedImageFile);
        final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        final UserModel updatedUser = authController.firestoreUser.value!.copyWith(photoUrl: downloadUrl);

        authController.updateUserFirestore(updatedUser, authController.firebaseUser.value!);

        // Update the user's avatar in the UI
        authController.firestoreUser.value = updatedUser;
      } catch (error) {
        print('🟥Error uploading avatar: $error');
      }
    }
  }


  Future<File> compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;
    final targetPath = '$tempPath/${DateTime.now().millisecondsSinceEpoch}.jpg';

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70, // Adjust the image quality as needed (0-100)
    );

    return compressedFile!;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      init: AuthController(),
      builder: (controller) {
        if (controller.firestoreUser.value == null) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return Scaffold(
            body: Center(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 10.h),
                  GestureDetector(
                    onTap: _changeImage,
                    child: Avatar(controller.firestoreUser.value!),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      FormVerticalSpace(),
                      Text(
                        'home.uidLabel'.tr +
                            ': ' +
                            controller.firestoreUser.value!.uid,
                        style: TextStyle(fontSize: 16.sp),
                      ),
                      FormVerticalSpace(),
                      Text(
                        'home.nameLabel'.tr +
                            ': ' +
                            controller.firestoreUser.value!.name,
                        style: TextStyle(fontSize: 16.sp),
                      ),
                      FormVerticalSpace(),
                      Text(
                        'home.emailLabel'.tr +
                            ': ' +
                            controller.firestoreUser.value!.email,
                        style: TextStyle(fontSize: 16.sp),
                      ),
                      FormVerticalSpace(),
                      Text(
                        'home.adminUserLabel'.tr +
                            ': ' +
                            controller.admin.value.toString(),
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}