import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drighna_ed_tech/provider/user_data_provider.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/utils/date_format_converter.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/gaurdian_details.dart';
import 'package:drighna_ed_tech/widgets/parent_details_card.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:drighna_ed_tech/widgets/student_personal_details_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StudentProfileDetails extends ConsumerStatefulWidget {
  const StudentProfileDetails({super.key});

  @override
  _StudentProfileDetailsState createState() => _StudentProfileDetailsState();
}

class _StudentProfileDetailsState extends ConsumerState<StudentProfileDetails>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String userName = "";
  String domainUrl = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    prepareData();
  }

  void prepareData() async {
    if (await isConnectingToInternet()) {
      final prefs = await SharedPreferences.getInstance();
      String apiUrl = prefs.getString("apiUrl") ?? "";

      userName = prefs.getString(Constants.userName) ?? "";
      domainUrl = prefs.getString(Constants.appDomain) ?? "";
      final body = jsonEncode({
        "student_id": prefs.getString("studentId"),
      });
      ref
          .read(studentProfileProvider.notifier)
          .fetchStudentProfile(apiUrl, body);
    } else {
      print("No internet connection");
    }
  }

  Future<bool> isConnectingToInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentProfile = ref.watch(studentProfileProvider);

    final studentImage = "$domainUrl/${studentProfile?.imgUrl}";
    final fatherImage = "$domainUrl/${studentProfile?.fatherPic}";
    final motherImage = "$domainUrl/${studentProfile?.motherPic}";
    final guardianImage = "$domainUrl/${studentProfile?.guardianPic}";

    final barcodeImage = "$domainUrl${studentProfile?.barcodeUrl}";
    List<Widget> studentPersonalDetails = [];
    List<ParentDetailCard> studentParentDetails = [];
    List<Widget> studentOtherDetails = [];

    if (studentProfile != null) {
      studentPersonalDetails = [
        StudentDetailCard(
          leading: "Admission Date",
          trailing: DateUtilities.formatStringDate(
              studentProfile.admissionDate.toString()),
        ),
        StudentDetailCard(
          leading: "Date Of Birth",
          trailing:
              DateUtilities.formatStringDate(studentProfile.dob.toString()),
        ),
        StudentDetailCard(
          leading: "Gender",
          trailing: studentProfile.gender.toString(),
        ),
        StudentDetailCard(
          leading: "Category",
          trailing: studentProfile.category.toString(),
        ),
        StudentDetailCard(
          leading: "Mobile Number",
          trailing: studentProfile.mobileNo.toString(),
        ),
        StudentDetailCard(
          leading: "Caste",
          trailing: studentProfile.cast.toString(),
        ),
        StudentDetailCard(
          leading: "Religion",
          trailing: studentProfile.religion.toString(),
        ),
        StudentDetailCard(
          leading: "Email",
          trailing: studentProfile.email.toString(),
        ),
        StudentDetailCard(
          leading: "Current Address",
          trailing: studentProfile.currentAddress.toString(),
          isAddress: true,
        ),
        StudentDetailCard(
          leading: "Permanent Address",
          trailing: studentProfile.permanentAddress.toString(),
          isAddress: true,
        ),
        StudentDetailCard(
          leading: "Blood Group",
          trailing: studentProfile.bloodGroup.toString(),
        ),
        StudentDetailCard(
          leading: "Height",
          trailing: studentProfile.height.toString(),
        ),
        StudentDetailCard(
          leading: "Weight",
          trailing: studentProfile.weight.toString(),
        ),
        StudentDetailCard(
          leading: "Note",
          trailing: studentProfile.note.toString(),
        ),
      ];
      studentParentDetails = [
        ParentDetailCard(
          title: 'Father',
          name: studentProfile.fatherName.toString(),
          contact: studentProfile.fatherPhone.toString(),
          occupation: studentProfile.fatherOccupation.toString(),
          imagePath: fatherImage,
        ),
        ParentDetailCard(
          title: 'Mother',
          name: studentProfile.motherName.toString(),
          contact: studentProfile.motherPhone.toString(),
          occupation: studentProfile.motherOccupation.toString(),
          imagePath: motherImage,
        ),
      ];
      studentOtherDetails = [
        StudentDetailCard(
          leading: "Previous School",
          trailing: studentProfile.previousSchool.toString(),
        ),
        StudentDetailCard(
          leading: "National ID Number",
          trailing: studentProfile.adharNo.toString(),
        ),
        StudentDetailCard(
          leading: "Local ID Number",
          trailing: studentProfile.samagraId.toString(),
        ),
        StudentDetailCard(
          leading: "Bank Account Number",
          trailing: studentProfile.bankAccountNo.toString(),
        ),
        StudentDetailCard(
          leading: "Bank Name",
          trailing: studentProfile.bankName.toString(),
        ),
        StudentDetailCard(
          leading: "IFSC Code",
          trailing: studentProfile.ifscCode.toString(),
        ),
        StudentDetailCard(
          leading: "RTE",
          trailing: studentProfile.rte.toString(),
        ),
      ];
    }
    print(studentImage);
    print(barcodeImage);
    return Scaffold(
      appBar: CustomAppBar(
        titleText: AppLocalizations.of(context)!.profile,
      ),
      body: studentProfile != null
          ? Column(
              children: [
                Text("User : ${userName}",
                    style: const TextStyle(
                        fontSize: 25, fontWeight: FontWeight.bold)),
                const SizedBox(
                  height: 6,
                ),
                const Text("Student details",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(studentProfile.name,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            Text(studentProfile.classInfo),
                            Text("Adm. No.  " + studentProfile.admissionNo),
                            Text("Roll Number  " + studentProfile.rollNo),
                            Text('Behaviour Score : ' +
                                (studentProfile.behaviourScore ?? 'N/A')),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: studentImage,
                              height: 100,
                              width: 100,
                              placeholder: (context, url) => CircleAvatar(
                                radius: 35,
                                child:
                                    Image.asset("assets/placeholder_user.png"),
                              ),
                              errorWidget: (context, url, error) => Image.asset(
                                'assets/placeholder_user.png',
                                height: 55,
                                width: 55,
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              CachedNetworkImage(
                                imageUrl: barcodeImage,
                                placeholder: (context, url) => const Row(
                                  children: [
                                    Text("Barcode"),
                                  ],
                                ),
                                errorWidget: (context, url, error) => const Row(
                                  children: [
                                    Text("Barcode not generated"),
                                    Icon(Icons.error),
                                  ],
                                ),
                                fit: BoxFit.cover,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'PERSONAL'),
                    Tab(text: 'PARENTS'),
                    Tab(text: 'OTHER'),
                  ],
                ),
                Expanded(
                    child: TabBarView(
                  controller: _tabController,
                  children: [
                    ListView(
                      children: [...studentPersonalDetails],
                    ),
                    ListView(
                      children: [
                        ...studentParentDetails,
                        GuardianDetailCard(
                          title: 'Guardian',
                          name: studentProfile.guardianName.toString(),
                          contact: studentProfile.guardianPhone.toString(),
                          occupation:
                              studentProfile.guardianOccupation.toString(),
                          imagePath: guardianImage,
                          relation: studentProfile.guardianRelation.toString(),
                          email: studentProfile.guardianEmail.toString(),
                          address: studentProfile.guardianAddress.toString(),
                        ),
                      ],
                    ),
                    ListView(
                      children: [...studentOtherDetails],
                    ),
                  ],
                ))
              ],
            )
          : const Center(child: PencilLoaderProgressBar()),
    );
  }
}
