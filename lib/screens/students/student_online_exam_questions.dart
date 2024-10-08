import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drighna_ed_tech/models/online_exam_model.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class StudentOnlineExamQuestionsNew extends StatefulWidget {
  final onlineExamId;
  final duration;
  final onlineExamStudentId;

  const StudentOnlineExamQuestionsNew({
    super.key,
    required this.onlineExamId,
    required this.duration,
    required this.onlineExamStudentId,
  });

  @override
  _StudentOnlineExamQuestionsNewState createState() =>
      _StudentOnlineExamQuestionsNewState();
}

class _StudentOnlineExamQuestionsNewState
    extends State<StudentOnlineExamQuestionsNew> {
  bool isLoading = false;
  bool? answer;
  late int remainingTime;
  Timer? _timer;
  List<Question> questions = [];
  List<Map<String, dynamic>> singleChoiceQuestions = [];
  List<Map<String, dynamic>> multipleChoiceQuestions = [];
  int currentQuestionIndex = 0;
  Question? currentQuestion;

  Map<String, dynamic> answers = {};
  Set<String> mulchoiceAnswersSet = {};
  String selectedAnswer = '';
  List<Map<String, dynamic>> answerList = [];
  Map<String, dynamic> examData = {};
  List<Map<String, dynamic>> dList = [];
  Map<String, dynamic> jsonObject = {};
  Map<String, dynamic> attachment = {};
  List<Map<String, dynamic>> jsonArray = [];

  @override
  void initState() {
    super.initState();
    startTimer();
    getDataFromApi();
  }

  void startTimer() {
    var durationParts = widget.duration.split(':');
    if (durationParts.length == 3) {
      int hours = int.parse(durationParts[0]);
      int minutes = int.parse(durationParts[1]);
      int seconds = int.parse(durationParts[2]);
      remainingTime =
          hours * 3600 + minutes * 60 + seconds; // Convert duration to seconds

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (remainingTime > 0) {
          setState(() {
            remainingTime--;
          });
        } else {
          timer.cancel();
          submitExam();
        }
      });
    } else {}
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  getDataFromApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var apiUrl = prefs.getString('apiUrl') ?? '';
    var studentId = prefs.getString('studentId') ?? '';
    var userId = prefs.getString('userId') ?? '';
    var accessToken = prefs.getString('accessToken') ?? "";
    var url = Uri.parse('$apiUrl${Constants.getOnlineExamQuestionUrl}');

    var headers = {
      'Client-Service': Constants.clientService,
      'Auth-Key': Constants.authKey,
      'Content-Type': Constants.contentType,
      'User-ID': userId,
      'Authorization': accessToken,
    };

    Map<String, String> params = {
      'student_id': studentId,
      'online_exam_id': widget.onlineExamId,
    };

    String body = json.encode(params);

    try {
      var response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        var result = json.decode(response.body);

        setState(() {
          examData = result['exam'];
          singleChoiceQuestions =
              List<Map<String, dynamic>>.from(result['exam']['questions']);
          multipleChoiceQuestions =
              List<Map<String, dynamic>>.from(result['exam']['questions']);
          questions = (result['exam']['questions'] as List)
              .map((questionJson) => Question.fromJson(questionJson))
              .toList();
          if (questions.isNotEmpty) {
            currentQuestion = questions[currentQuestionIndex];
          } else {
            currentQuestion = null;
          }
        });
      } else {
        throw Exception('Failed to load exam questions');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // Commented out the previous question functionality
  // void previousQuestion() {
  //   mulchoiceAnswersSet.clear();
  //   if (currentQuestionIndex > 0) {
  //     setState(() {
  //       currentQuestionIndex--;
  //       currentQuestion = questions[currentQuestionIndex];
  //     });
  //   }
  // }

  void nextQuestion() {
    mulchoiceAnswersSet.clear();
    if (selectedAnswer.isNotEmpty) {}

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        currentQuestion = questions[currentQuestionIndex];
        selectedAnswer = "";
      });
    } else {
      print("No more questions to display.");
    }
  }

  Future<void> submitExam() async {
    setState(() {
      isLoading = true;
    });

    attachment['attachment'] = '';
    dList = jsonArray;
    Set stationCodes = {};
    List<Map<String, dynamic>> tempArray = [];

    for (var i = 0; i < dList.length; i++) {
      String stationCode = dList[i]['onlineexam_question_id'];
      if (!stationCodes.contains(stationCode)) {
        stationCodes.add(stationCode);
        tempArray.add(dList[i]);
      }
    }

    dList = tempArray;

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String apiUrl =
          "${prefs.getString("apiUrl") ?? ""}${Constants.saveOnlineExamUrl}";
      var uri = Uri.parse(apiUrl);

      var request = http.MultipartRequest('POST', uri)
        ..headers.addAll({
          'Client-Service': Constants.clientService,
          'Auth-Key': Constants.authKey,
          'User-ID': prefs.getString(Constants.userId) ?? "",
          'Authorization': prefs.getString("accessToken") ?? "",
          'Content-Type': 'multipart/form-data'
        })
        ..fields['onlineexam_student_id'] = widget.onlineExamStudentId
        ..fields['rows'] = jsonEncode(dList);

      try {
        var response = await request.send();
        if (response.statusCode == 200) {
          showSnackbar(context);
        } else {
          print(
              'Failed to submit exam with status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error occurred while submitting exam: $e');
      }
    } else {
      print('No internet connection');
    }

    setState(() {
      isLoading = false;
    });
  }

  void showSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Successfully Submitted'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pop(context);
  }

  Future<bool> showSubmitConfirmationDialog() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm'),
            content: const Text('Do you want to submit the exam?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  Widget trueFalseQuestion(parsedString) {
    return Column(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              parsedString,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Marks: ${currentQuestion!.marks}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Negative Marks: ${currentQuestion!.negMarks}',
              style: const TextStyle(fontSize: 16),
            ),
            if (currentQuestion!.questionType == 'true_false')
              ...[true, false].map((bool answer) {
                return RadioListTile<bool>(
                  title: Text(answer ? 'True' : 'False'),
                  value: answer,
                  groupValue: answers[currentQuestion!.id],
                  onChanged: (bool? value) {
                    setState(() {
                      answers[currentQuestion!.id] = value;
                      selectedAnswer = value.toString();
                      jsonObject = {
                        'onlineexam_student_id': widget.onlineExamStudentId,
                        'question_type': currentQuestion!.questionType,
                        'onlineexam_question_id': currentQuestion!.id,
                        'select_option': selectedAnswer,
                      };
                      jsonArray.add(jsonObject);
                      Map<String, dynamic> newList = {
                        'question': currentQuestion!.question,
                        'selected_answer': selectedAnswer,
                      };
                      answerList.add(newList);
                    });
                  },
                );
              }),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // if (currentQuestionIndex > 0)
            //   TextButton(
            //     onPressed: previousQuestion,
            //     child: Text('Previous'),
            //   ),
            const Spacer(),
            if (currentQuestionIndex < questions.length - 1)
              TextButton(
                onPressed: nextQuestion,
                child: const Text('Next'),
              ),
            if (currentQuestionIndex == questions.length - 1)
              ElevatedButton(
                onPressed: () async {
                  bool confirm = await showSubmitConfirmationDialog();
                  if (confirm) {
                    await submitExam();
                  }
                },
                child: const Text('Submit'),
              ),
          ],
        ),
      ],
    );
  }

  Widget singleChoice(parsedString) {
    return Column(
      children: <Widget>[
        Text(
          parsedString,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ...['opt_a', 'opt_b', 'opt_c', 'opt_d', 'opt_e'].map((option) {
          if (singleChoiceQuestions[currentQuestionIndex][option].isEmpty) {
            return const SizedBox.shrink();
          }
          return ListTile(
            title:
                Html(data: singleChoiceQuestions[currentQuestionIndex][option]),
            leading: Radio<String>(
              value: option,
              groupValue: answers[currentQuestion!.id],
              onChanged: (String? value) {
                setState(() {
                  answers[currentQuestion!.id] = value!;
                  selectedAnswer = value.toString();
                  jsonArray.add({
                    'onlineexam_student_id': widget.onlineExamStudentId,
                    'question_type': currentQuestion!.questionType,
                    'onlineexam_question_id': currentQuestion!.id,
                    'select_option': selectedAnswer,
                  });
                  Map<String, dynamic> newList = {
                    'question': currentQuestion!.question,
                    'selected_answer': selectedAnswer,
                  };
                  answerList.add(newList);
                });
              },
            ),
          );
        }),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // if (currentQuestionIndex > 0)
            //   TextButton(
            //     onPressed: previousQuestion,
            //     child: Text('Previous'),
            //   ),
            const Spacer(),
            if (currentQuestionIndex < questions.length - 1)
              TextButton(
                onPressed: nextQuestion,
                child: const Text('Next'),
              ),
            if (currentQuestionIndex == questions.length - 1)
              ElevatedButton(
                onPressed: () async {
                  bool confirm = await showSubmitConfirmationDialog();
                  if (confirm) {
                    await submitExam();
                  }
                },
                child: const Text('Submit'),
              ),
          ],
        ),
      ],
    );
  }

  Widget multipleChoice(parsedString) {
    return Column(
      children: <Widget>[
        Text(
          parsedString,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ...['opt_a', 'opt_b', 'opt_c', 'opt_d', 'opt_e'].map((option) {
          if (multipleChoiceQuestions[currentQuestionIndex][option].isEmpty) {
            return const SizedBox.shrink();
          }
          return CheckboxListTile(
            title: Html(
                data: multipleChoiceQuestions[currentQuestionIndex][option]),
            value: answers[currentQuestion!.id] != null &&
                answers[currentQuestion!.id].contains(option),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  if (answers[currentQuestion!.id] == null) {
                    answers[currentQuestion!.id] = [option];
                  } else {
                    answers[currentQuestion!.id].add(option);
                  }
                  mulchoiceAnswersSet.add(option);
                } else {
                  answers[currentQuestion!.id].remove(option);
                  if (answers[currentQuestion!.id].isEmpty) {
                    answers.remove(currentQuestion!.id);
                  }
                  mulchoiceAnswersSet.remove(option);
                }

                jsonArray.removeWhere((item) =>
                    item['onlineexam_question_id'] == currentQuestion!.id);

                List<String> mulchoiceAnswersList =
                    mulchoiceAnswersSet.toList();
                mulchoiceAnswersList.sort();

                jsonArray.add({
                  'onlineexam_student_id': widget.onlineExamStudentId,
                  'question_type': currentQuestion!.questionType,
                  'onlineexam_question_id': currentQuestion!.id,
                  'select_option':
                      jsonEncode(mulchoiceAnswersList).replaceAll(' ', ''),
                });

                Map<String, dynamic> newList = {
                  'question': currentQuestion!.question,
                  'selected_answer': answers[currentQuestion!.id].join(', '),
                };
                answerList.add(newList);
              });
            },
          );
        }).toList(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // if (currentQuestionIndex > 0)
            //   TextButton(
            //     onPressed: previousQuestion,
            //     child: Text('Previous'),
            //   ),
            const Spacer(),
            if (currentQuestionIndex < questions.length - 1)
              TextButton(
                onPressed: nextQuestion,
                child: const Text('Next'),
              ),
            if (currentQuestionIndex == questions.length - 1)
              ElevatedButton(
                onPressed: () async {
                  bool confirm = await showSubmitConfirmationDialog();
                  if (confirm) {
                    await submitExam();
                  }
                },
                child: const Text('Submit'),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var document = currentQuestion != null
        ? parse(currentQuestion!.question)
        : parse('<p>Loading question...</p>');

    String parsedString = document.body!.text;

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            examData['exam'].toString(),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Center(
                child: Text(
                  formatDuration(Duration(seconds: remainingTime)),
                  style: const TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
          // flexibleSpace: Container(
          //   decoration: BoxDecoration(
          //     gradient: LinearGradient(
          //       colors: [Colors.blue, Colors.purple],
          //       begin: Alignment.topLeft,
          //       end: Alignment.bottomRight,
          //     ),
          //   ),
          // ),
        ),
        body: isLoading
            ? const Center(child: PencilLoaderProgressBar())
            : questions.isEmpty
                ? const Center(child: PencilLoaderProgressBar())
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: questions[currentQuestionIndex].questionType ==
                                  "singlechoice"
                              ? singleChoice(parsedString)
                              : questions[currentQuestionIndex].questionType ==
                                      "multichoice"
                                  ? multipleChoice(parsedString)
                                  : trueFalseQuestion(parsedString),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
