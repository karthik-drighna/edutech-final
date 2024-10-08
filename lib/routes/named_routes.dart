// import 'package:drighna_ed_tech/screens/parent/parents_dashboard.dart';
import 'package:drighna_ed_tech/screens/splash_screen.dart';
import 'package:drighna_ed_tech/screens/students/cbse_examination.dart';
import 'package:drighna_ed_tech/screens/students/student_add_leave.dart';
import 'package:drighna_ed_tech/screens/students/student_Issued_books.dart';
import 'package:drighna_ed_tech/screens/students/about_screen.dart';
import 'package:drighna_ed_tech/screens/students/gmeet_live_classes.dart';
import 'package:drighna_ed_tech/screens/students/homework_page.dart';
import 'package:drighna_ed_tech/screens/students/lesson_plan.dart';
import 'package:drighna_ed_tech/screens/students/live_classes.dart';
import 'package:drighna_ed_tech/screens/students/online_course.dart';
import 'package:drighna_ed_tech/screens/students/online_exam.dart';
import 'package:drighna_ed_tech/screens/students/profile_screen.dart';
import 'package:drighna_ed_tech/screens/students/settings_screen.dart';
import 'package:drighna_ed_tech/screens/students/dashboard.dart';
import 'package:drighna_ed_tech/screens/students/student_attendance.dart';
import 'package:drighna_ed_tech/screens/students/student_behaviour_report.dart';
import 'package:drighna_ed_tech/screens/students/student_class_timetable.dart';
import 'package:drighna_ed_tech/screens/students/student_daily_assignment.dart';
import 'package:drighna_ed_tech/screens/students/student_documents.dart';
import 'package:drighna_ed_tech/screens/students/student_downloads.dart';
import 'package:drighna_ed_tech/screens/students/student_edit_assignment.dart';
import 'package:drighna_ed_tech/screens/students/student_exam.dart';
import 'package:drighna_ed_tech/screens/students/student_fees.dart';
import 'package:drighna_ed_tech/screens/students/student_hostel.dart';
import 'package:drighna_ed_tech/screens/students/student_leave.dart';
import 'package:drighna_ed_tech/screens/students/student_notice_board.dart';
import 'package:drighna_ed_tech/screens/students/student_notification_screen.dart';
import 'package:drighna_ed_tech/screens/students/student_syllabus_status.dart';
import 'package:drighna_ed_tech/screens/students/student_tasks.dart';
import 'package:drighna_ed_tech/screens/students/student_teachers_list.dart';
import 'package:drighna_ed_tech/screens/students/student_timeline.dart';
import 'package:drighna_ed_tech/screens/students/student_transport_routes.dart';
import 'package:drighna_ed_tech/screens/students/student_upload_document.dart';
import 'package:drighna_ed_tech/screens/students/student_visitor_book.dart';
import 'package:drighna_ed_tech/screens/students/student_add_assignment.dart';
import 'package:flutter/material.dart';

Map<String, WidgetBuilder> routes={
        '/': (context) =>  const SplashScreen(), // Define the SplashScreen route
        '/home': (context) =>  const DashboardScreen(),
        // '/parentDashboard':(context) => const ParentsDashboard(),
        '/profile': (context) => StudentProfileDetails(),
        '/about': (context) => const AboutSchool(),
        '/settings': (context) => SettingsScreen(),
        '/Homework': (context) => Homework(),
        '/DailyAssignment': (context) => StudentDailyAssignment(),
        '/LessonPlan': (context) => StudentSyllabusTimetableLessonPlan(),
        '/OnlineExamination': (context) => StudentOnlineExam(),
        '/DownloadCenter': (context) => StudentDownloads(),
        '/LiveClasses': (context) => const StudentLiveClasses(),
        '/OnlineCourse': (context) => StudentOnlineCourse(),
        '/GmeetLiveClasses': (context) => StudentGmeetLiveClasses(),
        '/ClassTimetable': (context) => StudentClassTimetable(),
        '/SyllabusStatus': (context) => StudentSyllabusStatus(),
        '/Attendance': (context) => StudentAttendance(),
        '/Exam': (context) => StudentExaminationList(),
        '/Timeline': (context) => StudentTimeline(),
        '/Documents': (context) => StudentDocuments(),
        '/studentUploadDocuments': (context) => StudentUploadDocuments(),
        '/Behaviour': (context) => StudentBehaviourReport(),
        '/CbseExamination': (context) => CbseExamination(),
        '/noticeBoard': (context) => StudentNoticeBoard(),
        '/feesList': (context) => StudentFees(),
        '/studentLeave': (context) => StudentAppyLeave(),
        '/studentAddLeave': (context) => StudentAddLeave(),
        '/studentVisitorBook': (context) => StudentVisitorBook(),
        '/studentTransportRoutes': (context) => StudentTransportRoutes(),
        '/studentHostel': (context) => StudentHostel(),
        '/studentTasks': (context) => StudentTasks(),
        '/library': (context) => StudentLibraryBookIssued(),
        '/studentTeachersList': (context) => StudentTeachersList(),
        '/studentAddAssignment': (context) => StudentAddAssignment(),
        '/editStudentAssignment': (context) => const StudentEditAssignment(),
        '/notificationScreen': (context) =>  StudentNotificationScreen()
      };