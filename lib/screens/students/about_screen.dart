import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drighna_ed_tech/provider/about_School_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AboutSchool extends ConsumerStatefulWidget {
  const AboutSchool({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutSchool> {
  String imgLogoUrl = "";
  String imgLogo = "";

  @override
  void initState() {
    super.initState();

    fetchData();
  }

  void fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    imgLogoUrl = prefs.getString(Constants.imagesUrl) ?? "";

    await ref.read(aboutSchoolProvider.notifier).fetchAboutSchoolData();
  }

  @override
  Widget build(BuildContext context) {
    final aboutSchoolData = ref.watch(aboutSchoolProvider);

    if (aboutSchoolData?.imageUrl != null) {
      imgLogo = imgLogoUrl +
          "uploads/school_content/logo/" +
          aboutSchoolData!.imageUrl;
    }

    // Handle the UI rendering based on the state of aboutSchoolData
    return Scaffold(
      appBar: CustomAppBar(
        titleText: AppLocalizations.of(context)!.about_school,
      ),
      body: aboutSchoolData == null
          ? const Center(
              child:
                  PencilLoaderProgressBar()) // Show a loading indicator while data is null
          : SingleChildScrollView(
              // Once data is not null, render your UI
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  aboutSchoolData.imageUrl.isNotEmpty && imgLogo != null
                      ? Center(
                          child: Column(
                            children: [
                              CachedNetworkImage(
                                imageUrl: imgLogo,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const SizedBox(),
                                errorWidget: (context, url, error) =>
                                    const SizedBox(),
                              ),
                              Text(
                                aboutSchoolData.name,
                                style: const TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        )
                      : const SizedBox(),
                  const SizedBox(
                    height: 10,
                  ),
                  // buildDataRow('Name', aboutSchoolData.name),
                  buildDataRow('Address', aboutSchoolData.address),
                  buildDataRow('Phone', aboutSchoolData.phone),
                  buildDataRow('Email', aboutSchoolData.email),
                  buildDataRow('School Code', aboutSchoolData.schoolCode),
                  buildDataRow(
                      'Current Session', aboutSchoolData.currentSession),
                  buildDataRow(
                      'Session Start Month', aboutSchoolData.sessionStartMonth),
                  // Add more ListTiles for additional information as needed
                ],
              ),
            ),
    );
  }

  Widget buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 30.0),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
              ),
              // overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
