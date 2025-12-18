import 'package:comecomepay/l10n/app_localizations.dart' show AppLocalizations;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:comecomepay/models/notification_model.dart';

class NotificationDetailScreen extends StatelessWidget {
  final NotificationModel notification;

  const NotificationDetailScreen({Key? key, required this.notification}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format the date from notification
    final formattedDate = _formatDate(notification.createdAt);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title:  Text(
          AppLocalizations.of(context)!.messageDetail,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final padding = EdgeInsets.all(constraints.maxWidth * 0.04); // Responsif padding
          final fontScale = constraints.maxWidth / 400; // Skala font berdasarkan lebar layar

          return SingleChildScrollView(
            child: Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14 * (fontScale > 1 ? 1 : fontScale),
                    ),
                  ),
                  SizedBox(height: 16 * (fontScale > 1 ? 1 : fontScale)),
                   Text(
                    AppLocalizations.of(context)!.dearUser,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8 * (fontScale > 1 ? 1 : fontScale)),
                  Text(
                    '${AppLocalizations.of(context)!.subject}: ${notification.title}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8 * (fontScale > 1 ? 1 : fontScale)),
                  Text(
                    notification.status == 'unread' ? 'Unread' : 'Read',
                    style: TextStyle(
                      fontSize: 16,
                      color: notification.status == 'unread' ? Colors.red : Colors.green,
                    ),
                  ),
                  SizedBox(height: 16 * (fontScale > 1 ? 1 : fontScale)),
                  Text(
                    notification.body,
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 16 * (fontScale > 1 ? 1 : fontScale)),
                   Text(
                    '${AppLocalizations.of(context)!.details}:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8 * (fontScale > 1 ? 1 : fontScale)),
                  _buildDetailItem('• ${AppLocalizations.of(context)!.id}: ${notification.id}', fontScale),
                  _buildDetailItem('• ${AppLocalizations.of(context)!.status}: ${notification.status}', fontScale),
                  if (notification.readAt != null)
                    _buildDetailItem('• ${AppLocalizations.of(context)!.readAt}: ${_formatDate(notification.readAt!)}', fontScale),
                  SizedBox(height: 16 * (fontScale > 1 ? 1 : fontScale)),
                   Text(
                    AppLocalizations.of(context)!.thankYouForUsingComeComePay,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString).toLocal();
      return DateFormat('dd-MM-yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildDetailItem(String text, double fontScale) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4 * (fontScale > 1 ? 1 : fontScale)),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14 * (fontScale > 1 ? 1 : fontScale),
        ),
      ),
    );
  }
}
