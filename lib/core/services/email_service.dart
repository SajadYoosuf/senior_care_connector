import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:math';

class EmailService {
  // TODO: Move these to a secure configuration or environment variables
  static const String _smtpEmail = 'novoxcoretech@gmail.com';
  static const String _smtpPassword = 'oegs hres bsbl hhbe';

  final smtpServer = gmail(_smtpEmail, _smtpPassword);

  String generateOtp() {
    return (100000 + Random().nextInt(900000)).toString(); // 6-digit OTP
  }

  Future<bool> sendOtpEmail(String recipientEmail, String otp) async {
    final message = Message()
      ..from = Address(_smtpEmail, 'Senior Care Connect')
      ..recipients.add(recipientEmail)
      ..subject = 'Your Password Reset OTP'
      ..text =
          'Your OTP for password reset is: $otp. It will expire in 10 minutes.';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
      return true;
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
      return false;
    }
  }
}
