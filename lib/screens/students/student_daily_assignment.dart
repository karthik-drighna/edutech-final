import 'package:drighna_ed_tech/provider/daily_assignment_provider.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drighna_ed_tech/widgets/daily_assignment_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentDailyAssignment extends ConsumerStatefulWidget {
  const StudentDailyAssignment({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StudentDailyAssignmentState();
}

class _StudentDailyAssignmentState
    extends ConsumerState<StudentDailyAssignment> {
  String loginType = '';

  @override
  void initState() {
    super.initState();

    ref.read(assignmentsProvider.notifier).fetchAssignments();

    checkLoginType();
  }

  checkLoginType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    loginType = prefs.getString(Constants.loginType) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final assignments = ref.watch(assignmentsProvider);

    return Scaffold(
        appBar: CustomAppBar(
          titleText: AppLocalizations.of(context)!.your_daily_assignment,
        ),
        body: assignments.isEmpty
            ? const Center(child: Text("No daily Assignment added"))
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(assignmentsProvider.notifier).fetchAssignments(),
                child: ListView.builder(
                  itemCount: assignments.length,
                  itemBuilder: (context, index) {
                    return AssignmentCard(
                      assignment: assignments[index],
                      onDelete: () async {
                        await ref
                            .read(assignmentsProvider.notifier)
                            .deleteAssignment(
                                assignments[index]['id'].toString())
                            .whenComplete(() =>
                                _showSnackBar("Deleted Successfully", context));
                      },
                    );
                  },
                )),
        floatingActionButton: loginType == "student"
            ? FloatingActionButton(
                onPressed: () async {
                  // Using async-await to wait for Navigator to pop
                  final result = await Navigator.pushNamed(
                      context, '/studentAddAssignment');
                  // Optionally check result and refresh
                  if (result == true) {
                    ref.read(assignmentsProvider.notifier).fetchAssignments();
                  }
                },
                child: const Icon(Icons.add),
                backgroundColor: Theme.of(context).primaryColor,
              )
            : null);
  }

  void _showSnackBar(String message, context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
