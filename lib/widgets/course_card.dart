import 'package:drighna_ed_tech/models/course_model.dart';
import 'package:drighna_ed_tech/screens/students/course_payment_webview.dart';
import 'package:drighna_ed_tech/screens/students/student_course_details.dart';
import 'package:drighna_ed_tech/screens/students/student_course_details_paid_video_play_page.dart';
import 'package:drighna_ed_tech/screens/students/student_start_lesson.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CourseCard extends StatefulWidget {
  final CourseModel course;
  final String imgUrl;

  CourseCard({required this.course, required this.imgUrl});

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  String loginType = '';

  @override
  void initState() {
    super.initState();
    checkLoginType();
  }

  checkLoginType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      loginType = prefs.getString(Constants.loginType) ?? '';
    });
  }

  double calculateDiscountedPrice(double price, double discount) {
    double discountAmount = (discount / 100) * price;
    return price - discountAmount;
  }

  String formatPrice(double price) {
    return price.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    double originalPrice = widget.course.price;
    double discount = widget.course.discount;
    double discountedPrice = calculateDiscountedPrice(originalPrice, discount);
    String formattedPrice = formatPrice(discountedPrice);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                '${widget.imgUrl}uploads/course/course_thumbnail/${widget.course.courseThumbnail}',
                fit: BoxFit.cover,
              ),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(
                  '${widget.imgUrl}uploads/staff_images/${widget.course.image}',
                ),
              ),
              title: Text(widget.course.name),
              subtitle: Text(
                'Last Updated ${DateFormat('dd/MM/yyyy').format(widget.course.updatedDate)}',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                widget.course.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Row(
              children: [
                if (widget.course.freeCourse != "1") ...[
                  if (discount > 0) ...[
                    Text(
                      '₹$formattedPrice',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '₹${widget.course.price}',
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                      ),
                    ),
                  ] else ...[
                    Text(
                      '₹$formattedPrice',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ] else ...[
                  const Chip(
                    label: Text('FREE'),
                    backgroundColor: Colors.green,
                  ),
                ],
                const Spacer(),
                Text(widget.course.totalHourCount.toString()),
              ],
            ),
            Text(widget.course.classInfo),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                widget.course.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Lesson ${widget.course.totalLesson.toString()}"),
                Text("${widget.course.courseProgress.toString()}%"),
              ],
            ),
            LinearProgressIndicator(
              value: widget.course.courseProgress / 100,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.course.courseProgress == 100
                    ? Colors.green
                    : (widget.course.courseProgress > 0
                        ? Colors.yellow
                        : Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (widget.course.paidStatus ||
                        widget.course.freeCourse == "1") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              StudentCourseDetailsPaidVideoPlayPage(
                            courseId: widget.course.id.toString(),
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentCourseDetailPage(
                            courseId: widget.course.id.toString(),
                          ),
                        ),
                      );
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.black),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  child: const Text("Course Details"),
                ),
                if (loginType == 'parent') ...[
                  if (!widget.course.paidStatus &&
                      widget.course.freeCourse != "1") ...[
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CoursePaymentWebView(
                              courseId: widget.course.id.toString(),
                            ),
                          ),
                        );
                      },
                      child: const Text('Buy Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ] else if (loginType != 'parent') ...[
                  if (widget.course.freeCourse == "1" ||
                      widget.course.paidStatus) ...[
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudentStartLesson(
                              courseId: widget.course.id.toString(),
                            ),
                          ),
                        );
                      },
                      child: const Text('Start Lesson'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
