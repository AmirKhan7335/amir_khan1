import 'package:amir_khan1/components/my_drawer.dart';
import 'package:amir_khan1/controllers/navigationController.dart';
import 'package:amir_khan1/screens/engineer_screens/chatscreen.dart';
import 'package:amir_khan1/screens/engineer_screens/enghomeTab.dart';
import 'package:amir_khan1/screens/engineer_screens/notificationsscreen.dart';
import 'package:amir_khan1/screens/engineer_screens/scheduleScreen/schedulescreen.dart';
import 'package:amir_khan1/screens/engineer_screens/takePicture/takePicture.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EngineerHomePage extends StatefulWidget {
  const EngineerHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<EngineerHomePage> {
  // Index of the selected tab

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    return 
       Scaffold(
        drawer: const MyDrawer(),

        body: Obx(() => controller.engCurrentIndex.value == 1
            ? const ChatScreen()
            : controller.engCurrentIndex.value== 2
                ? TakePicture()
                : controller.engCurrentIndex.value == 0
                    ?
                    //Placeholder()
                     const EngineerHomeTab()
                    : controller.engCurrentIndex.value == 3
                        ? const ScheduleScreen()
                        : const NotificationsScreen(),),
        bottomNavigationBar: Obx(()
          => BottomNavigationBar(
             selectedIconTheme:
                const IconThemeData(color: Color(0xFF3EED88), ),

            unselectedIconTheme: const IconThemeData(color: Colors.black, size: 22.5),
            unselectedLabelStyle: const TextStyle(color: Colors.black),
            backgroundColor:  Colors.white,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color.fromARGB(255, 47, 235, 125),
            unselectedItemColor: Colors.black,
            currentIndex: controller.engCurrentIndex.value,
            onTap: (int index) {
              
                controller.engCurrentIndex.value = index;
        
            },
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.chat),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 60.0,
                      height: 38.0,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                      child: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 40.0),
                    ),
                  ),
                ),
                label: '',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.schedule),
                label: 'Schedule',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.currency_bitcoin),
                label: 'Finanace',
              ),
            ],
            iconSize: 20.0,
          ),
        ),
      );
    
  }
}
