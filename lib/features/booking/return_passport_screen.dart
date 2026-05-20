import 'package:flutter/material.dart';

import 'my_booking_screen.dart';

class ReturnPassportScreen extends StatelessWidget {
  const ReturnPassportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyBookingScreen(
      currentHref: '/dashboard/booking/my/return-passport',
      breadcrumbCurrent: 'Return Passport',
      pageTitle: 'Return Passport',
      initialStatus: 'RETURN_REQUEST',
      availableStatuses: [
        'RETURN_REQUEST',
        'RETURN_ACCEPTED',
        'RETURN_PP_SENT_TO_BG',
        'BG_COLLECT_RETURN_PP',
        'BG_HANDOVER_PP_TO_CUSTOMER',
        'REJECT_FILE',
      ],
    );
  }
}
