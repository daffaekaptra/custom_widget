import 'dart:math';
import 'package:flutter/material.dart';

class CustomCaptcha extends StatefulWidget {
  final double width, height;

  CustomCaptcha({required this.width, required this.height});

  @override
  _CustomCaptchaState createState() => _CustomCaptchaState();
}

class _CustomCaptchaState extends State<CustomCaptcha> {
  var random = Random();
  late String currentColor;
  late int correctAnswer;
  late int correctAnswerDiamond;
  TextEditingController answerController = TextEditingController();
  bool isAnswered = false;

  @override
  void initState() {
    super.initState();
    generateQuestion();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: widget.width,
          height: widget.height,
          child: CustomPaint(
            painter: CaptchaPainter(currentColor, correctAnswer, correctAnswerDiamond),
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Berapa jumlah titik atau bujursangkar warna $currentColor?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, height: 2),
        ),
        SizedBox(height: 20),
        TextField(
          controller: answerController,
          keyboardType: TextInputType.number,
          enabled: !isAnswered,
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: isAnswered ? null : periksaJawaban,
          child: Text('Submit'),
        ),
      ],
    );
  }

  void generateQuestion() {
    setState(() {
      currentColor = ['merah', 'hijau', 'hitam', 'biru'][random.nextInt(4)];
      correctAnswer = random.nextInt(10) + 1;
      isAnswered = false;
      answerController.text = '';

      if (currentColor == 'biru') {
        correctAnswerDiamond = random.nextInt(5) + 1;
      } else {
        correctAnswerDiamond = 0;
      }
    });
  }

  void periksaJawaban() {
    int jawabanPengguna = int.tryParse(answerController.text) ?? 0;

    setState(() {
      isAnswered = true;

      if (jawabanPengguna == correctAnswer) {
        answerController.text = 'BENAR';
      } else {
        answerController.text = 'SALAH. Coba lagi.';
        generateQuestion();
      }
    });
  }
}

class CaptchaPainter extends CustomPainter {
  final String color;
  final int numberOfPoints;
  final int numberOfDiamonds;
  var random = Random();

  CaptchaPainter(this.color, this.numberOfPoints, this.numberOfDiamonds);

  @override
  void paint(Canvas canvas, Size size) {
    var framePaint = Paint()
      ..color = Color(0xFF000000)
      ..style = PaintingStyle.stroke;
    canvas.drawRect(Offset(0, 0) & size, framePaint);

    canvas.clipRect(Offset(0, 0) & size);
    canvas.drawRect(Offset(0, 0) & size, Paint()..color = Colors.white);

    // Menggambar bujursangkar
    if (numberOfDiamonds > 0) {
      var diamondPaint = Paint()
        ..color = getColor(color)
        ..style = PaintingStyle.fill;

      for (var i = 0; i < numberOfDiamonds; i++) {
        drawDiamond(canvas, size, diamondPaint, i);
      }

      if (color == 'biru') {
        TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: numberOfDiamonds.toString(),
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset((size.width - textPainter.width) / 2, (size.height - textPainter.height) / 2),
        );
      }
    }

    if (numberOfPoints > 0) {
      var pointPaint = Paint()
        ..color = getColor(color)
        ..style = PaintingStyle.fill;

      for (var i = 0; i < numberOfPoints; i++) {
        drawPoint(canvas, size, pointPaint);
      }
    }
  }

  void drawDiamond(Canvas canvas, Size size, Paint paint, int index) {
    double angle = (index * 360 / numberOfDiamonds) * (pi / 180);
    double centerX = size.width / 2;
    double centerY = size.height / 2;
    double radius = min(size.width, size.height) / 3;

    Path path = Path();
    path.moveTo(centerX + radius * cos(angle), centerY + radius * sin(angle));
    path.lineTo(centerX + radius * cos(angle + pi / 2), centerY + radius * sin(angle + pi / 2));
    path.lineTo(centerX + radius * cos(angle + pi), centerY + radius * sin(angle + pi));
    path.lineTo(centerX + radius * cos(angle + 3 * pi / 2), centerY + radius * sin(angle + 3 * pi / 2));
    path.close();

    canvas.drawPath(path, paint);
  }

  void drawPoint(Canvas canvas, Size size, Paint paint) {
    canvas.drawCircle(
      Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      ),
      6,
      paint,
    );
  }

  Color getColor(String color) {
    switch (color) {
      case 'merah':
        return Color(0xa9ec1c1c);
      case 'hijau':
        return Color(0xa922b900);
      case 'hitam':
        return Color(0xa9000000);
      case 'biru':
        return Color(0xa90000FF);
      default:
        return Colors.black;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
