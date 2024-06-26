import 'package:amir_khan1/components/my_button.dart';
import 'package:amir_khan1/components/mytextfield.dart';
// import 'package:amir_khan1/screens/consultant_screens/consultantHome.dart';
import 'package:amir_khan1/screens/consultant_screens/cnsltSplash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'cnslt office google maps screen/googlemapsscreen.dart';
import 'cnslt office text field/cnsltofficetxtfield.dart';

class CnsltCompanyInfo extends StatefulWidget {
  const CnsltCompanyInfo({super.key});

  @override
  State<CnsltCompanyInfo> createState() => _CompanyInfoState();
}

class _CompanyInfoState extends State<CnsltCompanyInfo> {
  final _formKey = GlobalKey<FormState>();
  bool isloading = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController chairController = TextEditingController();
  // TextEditingController typeController = TextEditingController();
  // TextEditingController emailController = TextEditingController();
  TextEditingController officeController = TextEditingController();
  String? selectedLocation;

  @override
  void dispose() {
    nameController.dispose();
    chairController.dispose();
    // typeController.dispose();
    // emailController.dispose();
    officeController.dispose();
    super.dispose();
  }

  // Method to open Google Maps
  Future<void> launchGoogleMaps() async {
    const String googleMapsUrl = "https://www.google.com/maps";
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not launch $googleMapsUrl';
    }
  }

  // Method to handle navigation back from Google Maps with selected location
  Future<void> navigateBackFromGoogleMaps(String location) async {
    // Update the selected location
    setState(() {
      selectedLocation = location;
    });

    // Navigate back to the app with the selected location
    Navigator.pop(context, location);
  }

  // Method to handle confirmation and navigation to next screen
  void confirmAndNavigate() {
    if (nameController.text.isNotEmpty &&
        chairController.text.isNotEmpty &&
        selectedLocation != null) {
      setState(() {
        isloading = true;
      });

      // Add data to Firestore
      addDatatoDatabase();

      setState(() {
        isloading = false;
      });

      // Navigate to the next screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ConsultantSplash()),
      );
    } else {
      Get.snackbar('Sorry', 'Please Fill All the Fields and Select Location', backgroundColor: Colors.white, colorText: Colors.black);
    }
  }

  addDatatoDatabase() async {
    try {
      final email = FirebaseAuth.instance.currentUser!.email;
      await FirebaseFirestore.instance.collection("users").doc(email).update({
        'companyName': nameController.text,
        'chairman': chairController.text,
        'office': selectedLocation ?? officeController.text,
      });
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.white, colorText: Colors.black);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 25.0,
                top: 25.0,
                right: 25.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    const CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage('assets/images/logo1.png'),
                      backgroundColor: Colors.transparent,
                    ),

                    const SizedBox(height: 20),

                    const SizedBox(
                      height: 30,
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          'Company Info',
                          style: TextStyle(fontSize: 21.0, color: Colors.black),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(
                      height: 25,
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(left: 6.0),
                        child: Text(
                          'Company Name',
                          style:
                              TextStyle(fontSize: 18.0, color: Colors.blueGrey),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    MyTextField(
                      hintText: 'ARCO',
                      obscureText: false,
                      controller: nameController,
                      icon: Icons.title,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(
                      height: 25,
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(left: 6.0),
                        child: Text(
                          'Project Director',
                          style:
                              TextStyle(fontSize: 18.0, color: Colors.blueGrey),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    MyTextField(
                      hintText: 'Amir Khan',
                      obscureText: false,
                      controller: chairController,
                      icon: Icons.person_2,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 20),
                    // const SizedBox(
                    //   height: 25,
                    //   width: double.infinity,
                    //   child: Padding(
                    //     padding: EdgeInsets.only(left: 6.0),
                    //     child: Text(
                    //       'Type',
                    //       style:
                    //           TextStyle(fontSize: 18.0, color: Colors.blueGrey),
                    //       textAlign: TextAlign.left,
                    //     ),
                    //   ),
                    // ),
                    // MyTextField(
                    //   hintText: 'A6',
                    //   obscureText: false,
                    //   controller:typeController,
                    //   icon: Icons.space_bar,
                    //   keyboardType: TextInputType.text,
                    // ),
                    // const SizedBox(height: 20),
                    // const SizedBox(
                    //   height: 25,
                    //   width: double.infinity,
                    //   child: Padding(
                    //     padding: EdgeInsets.only(left: 6.0),
                    //     child: Text(
                    //       'Email',
                    //       style:
                    //           TextStyle(fontSize: 18.0, color: Colors.blueGrey),
                    //       textAlign: TextAlign.left,
                    //     ),
                    //   ),
                    // ),
                    // MyTextField(
                    //   hintText: 'arco@gmail.com',
                    //   obscureText: false,
                    //   controller: emailController,
                    //   icon: Icons.email,
                    //   keyboardType: TextInputType.text,
                    // ),
                    // const SizedBox(height: 20),
                    const SizedBox(
                      height: 25,
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(left: 6.0),
                        child: Text(
                          'Office',
                          style:
                              TextStyle(fontSize: 18.0, color: Colors.blueGrey),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    MyTextFieldConsultant(
                      hintText: 'F7 Islamabad',
                      controller: officeController,
                      icon: Icons.location_searching,
                      onTapIcon: () async {
                        final String? selectedLocation =
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GoogleMapsScreen(),
                          ),
                        );
                        if (selectedLocation != null) {
                          officeController.text = selectedLocation;
                        }
                      },
                      keyboardType: TextInputType.text,
                    ),

                    const SizedBox(height: 50),
                    MyButton(
                      text: 'Confirm',
                      bgColor: Colors.green,
                      textColor: Colors.black,
                      onTap: () {
                        if (nameController.text.isNotEmpty &&
                            chairController.text.isNotEmpty &&
                            officeController.text.isNotEmpty) {
                          setState(() {
                            isloading = true;
                          });
                          addDatatoDatabase();
                          setState(() {
                            isloading = false;
                          });
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ConsultantSplash()));
                        } else {
                          Get.snackbar('Sorry', 'Please Fill All the Fields', backgroundColor: Colors.white, colorText: Colors.black);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: isloading,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}





