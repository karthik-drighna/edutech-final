import 'package:drighna_ed_tech/models/exam_model.dart';
import 'package:drighna_ed_tech/provider/examination_list_provider.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/examination_card_widget.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StudentExaminationList extends ConsumerStatefulWidget {
  const StudentExaminationList({super.key});

  @override
  _StudentExaminationListState createState() => _StudentExaminationListState();
}

class _StudentExaminationListState
    extends ConsumerState<StudentExaminationList> {
  String studentId = '';

  @override
  void initState() {
    super.initState();
    _loadStudentId();
  }

  Future<void> _loadStudentId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      studentId = prefs.getString('studentId') ?? '';
    });
    ref.refresh(examinationListProvider(studentId));
  }

  Future<void> _refreshExams() async {
    ref.refresh(examinationListProvider(studentId));
  }

  @override
  Widget build(BuildContext context) {
    AsyncValue<List<Examination>> exams =
        ref.watch(examinationListProvider(studentId));

    return Scaffold(
      appBar: CustomAppBar(
        titleText: AppLocalizations.of(context)!.examination_list,
      ),
      body: exams.when(
        data: (exams) => exams.isEmpty
            ? const Center(
                child: Text(
                "No Data found",
                style: TextStyle(fontWeight: FontWeight.bold),
              ))
            : RefreshIndicator(
                onRefresh: _refreshExams,
                child: ListView.builder(
                  itemCount: exams.length,
                  itemBuilder: (context, index) {
                    return ExaminationCard(exam: exams[index]);
                  },
                ),
              ),
        loading: () => const Center(child: PencilLoaderProgressBar()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
