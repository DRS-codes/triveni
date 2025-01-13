import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class ProductServices {
  bool isLoading = false;
  final picker = ImagePicker();
  String imageUrl = '';
  Future<List<Map<String, dynamic>>> getAllDocuments(
      String collectionName) async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection(collectionName).get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error getting documents: $e');
      return [];
    }
  }

  Future<void> addData(String collectionName, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance.collection(collectionName).add(data);
      print("Data added successfully!");
    } catch (e) {
      print("Error adding data: $e");
    }
  }

  // Function to upload image to GitHub
  // Future<void> uploadImage() async {
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     final imageFile = File(pickedFile.path);
  //     final imageName = imageFile.path.split('/').last;

  //     final base64Image = base64Encode(imageFile.readAsBytesSync());
  //     final url =
  //         "https://api.github.com/repos/${ImageStorageCredentials.repo}/contents/$imageName";

  //     try {
  //       isLoading = true; // Start loading

  //       final response = await http.put(
  //         Uri.parse(url),
  //         headers: {
  //           "Authorization": "Bearer ${ImageStorageCredentials.token}",
  //           "Content-Type": "application/json",
  //         },
  //         body: jsonEncode({
  //           "message": "Upload image: $imageName",
  //           "content": base64Image,
  //           "branch": ImageStorageCredentials.branch,
  //         }),
  //       );

  //       if (response.statusCode == 201) {
  //         final responseBody = jsonDecode(response.body);
  //         final downloadUrl = responseBody["content"]["download_url"];

  //         imageUrl = downloadUrl; // Set image URL after upload
  //         isLoading = false; // Stop loading

  //         print("Image uploaded successfully! URL: $downloadUrl");
  //       } else {
  //         isLoading = false; // Stop loading on failure

  //         print("Failed to upload image. ${response.body}");
  //       }
  //     } catch (e) {
  //       isLoading = false; // Stop loading on error

  //       print("Error uploading image: $e");
  //     }
  //   } else {
  //     print("No image selected.");
  //   }
  // }

  Future<void> deleteDocument(String collectionPath, String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection(collectionPath)
          .doc(docId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }
}
