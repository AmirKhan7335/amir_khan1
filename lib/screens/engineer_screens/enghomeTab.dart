import 'package:amir_khan1/controllers/progressTrackingController.dart';
import 'package:amir_khan1/main.dart';
import 'package:amir_khan1/models/user_data.dart';
import 'package:amir_khan1/pages/pageoneofhomescreen.dart';
import 'package:amir_khan1/pages/pagethreeofhomescreen.dart';
import 'package:amir_khan1/pages/pagetwoofhomescreen.dart';
import 'package:amir_khan1/screens/centralBarScreens/documentScreen.dart';
import 'package:amir_khan1/screens/centralBarScreens/projectScreen.dart';
import 'package:amir_khan1/screens/centralBarScreens/TestingTab/testingScreen.dart';
import 'package:amir_khan1/models/activity.dart';
import 'package:amir_khan1/screens/engineer_screens/notificationsscreen.dart';
import 'package:amir_khan1/screens/engineer_screens/takePicture/engproj.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../centralBarScreens/siteCamera/inputRtsp.dart';
import '../centralBarScreens/siteCamera/siteCameraScreen.dart';

class EngineerHomeTab extends StatefulWidget {
  final bool isClient;

  const EngineerHomeTab({super.key, required this.isClient});

  @override
  State<EngineerHomeTab> createState() => _EngineerHomeTabState();
}

class _EngineerHomeTabState extends State<EngineerHomeTab> {
  int currentPage = 0;

  final PageController pageController = PageController();
  final user = FirebaseAuth.instance.currentUser;
  List<Activity> activities = []; // Store activities here

  Future<List> fetchProject() async {
//..
    try {
      final collectionData = widget.isClient
          ? await FirebaseFirestore.instance
              .collection('clients')
              .doc(user!.email)
              .get()
          : await FirebaseFirestore.instance
              .collection('engineers')
              .doc(user!.email)
              .get();

      final projectId = await collectionData.data()!['projectId'];
      final projectCollection = await FirebaseFirestore.instance
          .collection('Projects')
          .doc(projectId)
          .get();
      final data = await projectCollection.data();
      final projectData = [
        data!['title'],
        data['budget'],
        data['funding'],
        data['startDate'],
        data['endDate'],
        data['location'],
        data['creationDate'],
        data['retMoney'],
        projectId,
        data['receivedMoney'].toString()
      ];
      return projectData;
//..
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.white, colorText: Colors.black);
      return [];
    }
  }

  int calculatePercentComplete(String startDate, String finishDate) {
    try {
      DateTime today = DateTime.now();
      DateTime parsedStartDate = parseDate(startDate);
      DateTime parsedFinishDate = parseDate(finishDate);

      int totalDuration =
          parsedFinishDate.difference(parsedStartDate).inDays + 1;
      int timeElapsed = today.difference(parsedStartDate).inDays;
      if (totalDuration <= 0) {
        return 0; // Return 0 if total duration is non-positive
      }

      double percentComplete = (timeElapsed / totalDuration) * 100;
      // Round the percentComplete to the nearest integer
      return percentComplete
          .round()
          .clamp(0, 100); // Ensure the result is within [0, 100] range
    } catch (e) {
      return -1; // Return a default value or error code in case of any error
    }
  }

  Future<String> fetchUsername() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.email)
          .get();
      if (userSnapshot.exists) {
        return userSnapshot['username'];
      } else {
        return 'Guest'; // Default username for guests
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching username: $e');
      }
      return 'Error';
    }
  }

  Future<List<Activity>> fetchActivities() async {
    try {
      var email = user?.email;
      if (email == null) {
        return [];
      }
      //---------------------------------------For Client-------------------------
      var projIdForClient = await FirebaseFirestore.instance
          .collection('clients')
          .doc(email)
          .get();
      var clientProjectId =
          projIdForClient.data()?['projectId']; // Add null check here
      var sameEngineer = await FirebaseFirestore.instance
          .collection('engineers')
          .where('projectId', isEqualTo: clientProjectId)
          .get();
      var engEmails = sameEngineer.docs.map((e) => e.id).toList();
      var activitiesSnapshot = widget.isClient
          ? await FirebaseFirestore.instance
              .collection('engineers')
              .doc(engEmails[0])
              .collection('activities')
              .get()
          //----------------------------------------------------------------------
          : await FirebaseFirestore.instance
              .collection('engineers')
              .doc(email)
              .collection('activities')
              .get();

      // Convert documents to Activity objects
      var activities = activitiesSnapshot.docs.map((doc) {
        return Activity(
          id: doc['id'],
          name: doc['name'],
          startDate: DateFormat('dd/MM/yyyy').format(doc['startDate'].toDate()),
          finishDate:
              DateFormat('dd/MM/yyyy').format(doc['finishDate'].toDate()),
          order: doc['order'],
        );
      }).toList();

      return activities;
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.white, colorText: Colors.black);
      return [];
    }
  }

  Activity? findTodaysActivity(List<Activity> activities) {
    DateTime today = DateTime.now();
    String formattedToday =
        DateFormat('dd/MM/yyyy').format(today); // Format current date

    try {
      DateTime todayDate = DateFormat('dd/MM/yyyy')
          .parse(formattedToday); // Convert formattedToday to DateTime
      return activities.firstWhere((activity) {
        // Parse activity dates
        DateTime startDate = parseDate(activity.startDate);
        DateTime finishDate = parseDate(activity.finishDate);

        // Compare todayDate with activity dates
        return startDate.isBefore(todayDate) && finishDate.isAfter(todayDate) ||
            startDate.isAtSameMomentAs(todayDate) ||
            finishDate.isAtSameMomentAs(todayDate);
      });
    } catch (e) {
      return null;
    }
  }

  Activity? findUpcomingActivity(List<Activity> activities) {
    DateTime today = DateTime.now();
    Activity? upcomingActivity;

    try {
      upcomingActivity = activities
          .where((activity) => parseDate(activity.startDate).isAfter(today))
          .reduce((a, b) =>
              parseDate(a.startDate).isBefore(parseDate(b.startDate)) ? a : b);
    } catch (e) {
      // Handle the case where no upcoming activity is found
      upcomingActivity = Activity(
        id: 'dummy',
        name: 'No Upcoming Activity',
        startDate: 'N/A',
        finishDate: 'N/A',
        order: 0,
      );
    }

    return upcomingActivity;
  }

  int calculateDaysLeft(String finishDate) {
    try {
      DateTime parsedFinishDate = parseDate(finishDate);
      DateTime today = DateTime.now();

      // Calculate the difference in days
      int daysDifference = parsedFinishDate.difference(today).inDays + 1;

      // if (today.hour < 12) {
      //   daysDifference += 1;
      // }

      if (daysDifference < 0) {
        return 0; // The finish date is in the past, no days left
      } else {
        return daysDifference; // Add 1 to include the due date
      }
    } catch (e) {
      return -1; // Return a default value or handle the error accordingly
    }
  }

  DateTime parseDate(String dateStr) {
    try {
      // Try parsing with "dd/MM/yyyy" format
      final List<String> parts = dateStr.split('/');
      if (parts.length == 3) {
        final int? day = int.tryParse(parts[0]);
        final int? month = int.tryParse(parts[1]);
        final int? year = int.tryParse(parts[2]);
        if (day != null && month != null && year != null) {
          return DateTime(year, month, day);
        }
      }

      // Try parsing with "dd-MM-yyyy" format
      final List<String> parts2 = dateStr.split('-');
      if (parts2.length == 3) {
        final int? day = int.tryParse(parts2[0]);
        final int? month = int.tryParse(parts2[1]);
        final int? year = int.tryParse(parts2[2]);
        if (day != null && month != null && year != null) {
          return DateTime(year, month, day);
        }
      }

      // If parsing fails, return a default value (e.g., current date)
      return DateTime.now();
    } catch (e) {
      // Handle the parsing error here, such as logging an error message
      // Return a default value
      return DateTime.now();
    }
  }

  Future fetchData() async {
    final username = await fetchUsername();
    final profilePicUrl = await fetchProfilePicUrl();
    final activities = await fetchActivities();
    final projectData = await fetchProject();
    return [
      UserData(
        username: username,
        profilePicUrl: profilePicUrl,
        activities: activities,
      ),
      projectData
    ];
  }

  Future<String?> fetchProfilePicUrl() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.email)
          .get();
      if (userSnapshot['profilePic'] != null &&
          userSnapshot['profilePic'].isNotEmpty) {
        print("profile pic url = " + userSnapshot['profilePic']);
        return userSnapshot['profilePic'];
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching profile picture: $e');
      }
      return 'https://t4.ftcdn.net/jpg/00/65/77/27/360_F_65772719_A1UV5kLi5nCEWI0BNLLiFaBPEkUbv5Fv.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    var data = fetchData();
    final controller = Get.put(ProjectProgressController());
    return SafeArea(
      minimum: const EdgeInsets.only(top: 16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder(
                // Fetch the username asynchronously
                future: data,

                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.blue));
                  } else if (!snapshot.hasData) {
                    return const Center(
                        child: Text(
                      'No Data Found',
                      style: TextStyle(color: Colors.black),
                    ));
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    final userData = snapshot.data![0];
                    final snapshotData = userData.activities;
                    List<Activity> activities = snapshotData ?? [];
                    // Find today's and upcoming activities
                    Activity? todayActivity = findTodaysActivity(activities);
                    Activity? upcomingActivity =
                        findUpcomingActivity(activities);
                    // overAllPercent = calculatePercentComplete();----------------Causes blunder in Release mode
                    final projData = snapshot.data[1];
                    controller.calculateOverallPercent(activities);
                    return
                        //   Center(
                        //   child: Text('Data is Present',style: TextStyle(color: Colors.black),),
                        // );
                        Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User information
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                Scaffold.of(context).openDrawer();
                              },
                              child: CircleAvatar(
                                backgroundImage: snapshot
                                            .data?[0].profilePicUrl !=
                                        null
                                    ? NetworkImage(
                                        snapshot.data![0].profilePicUrl!)
                                    : const NetworkImage(
                                        'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png'),
                                radius: 30,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Welcome Back!",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.green),
                                ),
                                const SizedBox(height: 0),
                                Text(
                                  snapshot.data?[0].username ?? 'Guest',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            IconButton(
                                onPressed: () {
                                  setState(() {});
                                },
                                icon: const Icon(
                                  Icons.refresh,
                                  color: Colors.black,
                                )),
                            // IconButton(
                            //     onPressed: () {
                            //       Navigator.push(
                            //           context,
                            //           MaterialPageRoute(
                            //               builder: (context) => const Scaffold(
                            //                   body: NotificationsScreen())));
                            //     },
                            //     icon: const Icon(
                            //       Icons.notifications,
                            //       color: Colors.black,
                            //     ))
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Search bar
                        const SizedBox(height: 10),
                        // Page view with indicators
                        StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                            return SizedBox(
                              height: 250,
                              width: double.infinity,
                              child: Stack(
                                children: [
                                  PageView(
                                    physics: const BouncingScrollPhysics(),
                                    controller: pageController,
                                    onPageChanged: (index) {
                                      setState(() {
                                        currentPage = index;
                                      });
                                    },
                                    children: [
                                      Obx(
                                        () => Card(
                                          color: Colors.transparent,
                                          elevation: 10,
                                          child: PageOne(
                                              startDate: DateFormat('dd/MM/yy').format(projData[3].toDate()), // Fix here
                                              endDate: DateFormat('dd/MM/yy').format(projData[4].toDate()),
                                              activityProgress: controller
                                                  .overAllPercent1.value,
                                              title: projData[0]),
                                        ),
                                      ),
                                      Card(
                                        color: Colors.transparent,
                                        elevation: 10,
                                        child: PageTwo(
                                          total: projData[1],
                                          retMoney: projData[7],
                                          receivedMoney: projData[9], ),
                                      ),
                                      const Card(
                                          color: Colors.transparent,
                                          elevation: 10,
                                          child: PageThree()),
                                    ],
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    left: 0,
                                    right: 0,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        for (int i = 0; i < 3; i++)
                                          buildIndicator(i, currentPage),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 10),
                        // Today's activity
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DocumentScreen(
                                            isClient: widget.isClient))),
                                child: Card(
                                  elevation: 5,
                                  color: Colors.transparent,
                                  child: Container(
                                    height: 70,
                                    width: 65,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          const Icon(
                                            Icons.file_copy,
                                            color: Colors.black,
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            height: 1.5,
                                            width: 45,
                                            color: Colors.black,
                                          ),
                                          const SizedBox(
                                            height: 2.5,
                                          ),
                                          const Text(
                                            'Documents',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.black,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SiteCamera()),
                                  ); // Replace with your actual function call
                                },
                                child: Card(
                                  elevation: 5,
                                  color: Colors.transparent,
                                  child: Container(
                                    height: 70,
                                    width: 65,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          const Icon(
                                            Icons.video_call,
                                            color: Colors.black,
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            height: 1.5,
                                            width: 45,
                                            color: Colors.black,
                                          ),
                                          const SizedBox(
                                            height: 2.5,
                                          ),
                                          const Text(
                                            'Site',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.black,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProjectScreen1(
                                              isCnslt: false,
                                            ))),
                                child: Card(
                                  color: Colors.transparent,
                                  elevation: 5,
                                  child: Container(
                                    height: 70,
                                    width: 65,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          const Icon(
                                            Icons.calendar_month,
                                            color: Colors.black,
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            height: 1.5,
                                            width: 45,
                                            color: Colors.black,
                                          ),
                                          const SizedBox(
                                            height: 2.5,
                                          ),
                                          const Text(
                                            'Projects',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.black,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => TestingScreen(
                                              isClient: widget.isClient,
                                              projId: projData[8],
                                              isCnslt: false,
                                            ))),
                                child: Card(
                                  color: Colors.transparent,
                                  elevation: 5,
                                  child: Container(
                                    height: 70,
                                    width: 65,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          const Icon(Icons.checklist,
                                              color: Colors.black),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            height: 1.5,
                                            width: 45,
                                            color: Colors.black,
                                          ),
                                          const SizedBox(
                                            height: 2.5,
                                          ),
                                          const Text(
                                            'Testing',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.black,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Today's activity",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Card(
                          elevation: 10,
                          color: Colors.transparent,
                          child: Container(
                            padding: const EdgeInsets.only(
                                left: 8.0, top: 10, bottom: 16, right: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        todayActivity?.name ?? 'No Activity',
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    // const SizedBox(width: 80),
                                    Container(
                                      width: 80,
                                      padding: const EdgeInsets.all(3.0),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Center(
                                        child: Text(
                                          activities.isNotEmpty
                                              ? (todayActivity != null
                                                  ? (calculateDaysLeft(
                                                              todayActivity
                                                                  .finishDate) ==
                                                          1
                                                      ? 'Last Day'
                                                      : '${calculateDaysLeft(todayActivity.finishDate)} Days left')
                                                  : 'No Activity')
                                              : '',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(
                                      activities.isNotEmpty
                                          ? 'Due: ${todayActivity?.finishDate ?? "No Due Date"}'
                                          : 'No Due Date',
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black),
                                    ),
                                    const SizedBox(width: 45),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: SizedBox(
                                        width: 140,
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    todayActivity?.finishDate !=
                                                            null
                                                        ? "Completed"
                                                        : "",
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14)),
                                                Text(
                                                  todayActivity?.finishDate !=
                                                          null
                                                      ? '${calculatePercentComplete(todayActivity?.startDate ?? "", todayActivity?.finishDate ?? "")}%'
                                                      : '0%',
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 146,
                                              child: LinearProgressIndicator(
                                                value: todayActivity
                                                            ?.finishDate !=
                                                        null
                                                    ? (calculatePercentComplete(
                                                            todayActivity
                                                                    ?.startDate ??
                                                                "",
                                                            todayActivity
                                                                    ?.finishDate ??
                                                                "") /
                                                        100)
                                                    : 0,
                                                backgroundColor: Colors.grey,
                                                valueColor:
                                                    const AlwaysStoppedAnimation<
                                                        Color>(Colors.blue),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Upcoming activity
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Upcoming activity",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Card(
                          color: Colors.transparent,
                          elevation: 10,
                          child: Container(
                            padding: const EdgeInsets.only(
                                left: 16.0, right: 16, top: 10, bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  upcomingActivity?.name ??
                                      'No Upcoming Activity',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(
                                      activities.isNotEmpty
                                          ? 'Starts: ${upcomingActivity?.startDate ?? "No Start Date"}'
                                          : 'No Start Date',
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const Text('Nothing');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
