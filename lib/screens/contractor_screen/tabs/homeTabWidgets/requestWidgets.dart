import 'package:amir_khan1/components/my_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ContrPendingRequest extends StatefulWidget {
  ContrPendingRequest(
      {required this.name,
      required this.projectDataList,
      required this.engEmail,
      super.key});
  String name;
  List projectDataList;
  String engEmail;
  @override
  State<ContrPendingRequest> createState() => _PendingRequestState();
}

class _PendingRequestState extends State<ContrPendingRequest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Pending Requests'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            RequestBody(
                name: widget.name,
                projectDataList: widget.projectDataList,
                engEmail: widget.engEmail),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyButton(
                    text: 'Confirm',
                    bgColor: Colors.yellow,
                    textColor: Colors.black,
                    icon: Icons.cloud_done_rounded,
                    onTap: () async {
                      var activitiesSnapshot = await FirebaseFirestore.instance
                          .collection('engineers')
                          .doc('${widget.engEmail}')
                          .update({'reqAccepted': true});
                      Navigator.pop(context);
                      setState(() {});
                      Get.snackbar('Request Accepted',
                          'Engineer has been added to the project');
                    },
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  MyButton(
                    text: 'Reject',
                    bgColor: Colors.red,
                    textColor: Colors.black,
                    icon: Icons.cancel,
                    onTap: () async {
                      var activitiesSnapshot = await FirebaseFirestore.instance
                          .collection('engineers')
                          .doc('${widget.engEmail}')
                          .delete(
                        //FieldPath(['reqAccepted']): FieldValue.delete(),
                      );
                       await FirebaseFirestore.instance
                      .collection('Projects')
                      .doc(widget.projectDataList[3])
                      .update({'isSelected': false});

                      Navigator.pop(context);
                      setState(() {});
                      Get.snackbar('Request Rejected', '');
                    },
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}

class ContrApprovedRequest extends StatefulWidget {
  ContrApprovedRequest(
      {required this.name,
      required this.projectDataList,
      required this.engEmail,
      super.key});
  String name;
  List projectDataList;
  String engEmail;
  @override
  State<ContrApprovedRequest> createState() => _ApprovedRequestState();
}

class _ApprovedRequestState extends State<ContrApprovedRequest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Approved Requests'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            RequestBody(
              name: widget.name,
              projectDataList: widget.projectDataList,
              engEmail: widget.engEmail,
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: MyButton(
                text: 'Delete',
                bgColor: Colors.red,
                textColor: Colors.black,
                icon: Icons.delete,
                onTap: () async {
                  var activitiesSnapshot = await FirebaseFirestore.instance
                      .collection('engineers')
                      .doc('${widget.engEmail}')
                      .delete();
                  await FirebaseFirestore.instance
                      .collection('Projects')
                      .doc(widget.projectDataList[3])
                      .update({'isSelected': false});

                  Navigator.pop(context);
                  setState(() {});
                  Get.snackbar('Engineer Deleted', '');
                },
              ),
            ),
          ],
        ));
  }
}

class RequestBody extends StatefulWidget {
  RequestBody(
      {required this.name,
      required this.projectDataList,
      required this.engEmail,
      super.key});
  String name;
  List projectDataList;
  String engEmail;

  @override
  State<RequestBody> createState() => _RequestBodyState();
}

class _RequestBodyState extends State<RequestBody> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.yellow,
                  radius: 30,
                  child: Icon(Icons.person),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  '${widget.name}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 32, left: 32),
            child: Container(
              height: 1.5,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 50,
                          ),
                          Text(
                            'Email:  ',
                          ),
                          Text(
                            '${widget.engEmail}',
                            softWrap: true,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 50,
                          ),
                          Text(
                            'Role:  ',
                          ),
                          Text(
                            'Engineer',
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 50,
                          ),
                          Text(
                            'Project :  ',
                          ),
                          Text(
                            '${widget.projectDataList[0]}',
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 50,
                          ),
                          Text(
                            'Start Date:  ',
                          ),
                          Text(
                            '${DateFormat('dd-MM-yyyy').format(widget.projectDataList[1].toDate())}',
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 50,
                          ),
                          Text(
                            'End Date:  ',
                          ),
                          Text(
                            '${DateFormat('dd-MM-yyyy').format(widget.projectDataList[2].toDate())}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}