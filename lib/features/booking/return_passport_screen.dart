import 'package:flutter/material.dart';

import 'my_booking_screen.dart';

class ReturnPassportScreen extends StatelessWidget {
  const ReturnPassportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Pass the combined return statuses as a comma-separated string so the API
    // returns all return-related bookings in a single request without filtering
    // by a single status. hideStatusDropdown removes the dropdown entirely.
    return const MyBookingScreen(
      currentHref: '/dashboard/booking/my/return-passport',
      breadcrumbCurrent: 'Return Passport',
      pageTitle: 'Return Passport',
      initialStatus:
          'RETURN_REQUEST,RETURN_ACCEPTED,RETURN_PP_SENT_TO_BG,BG_COLLECT_RETURN_PP,BG_HANDOVER_PP_TO_CUSTOMER,REJECT_FILE',
      availableStatuses: [
        'RETURN_REQUEST,RETURN_ACCEPTED,RETURN_PP_SENT_TO_BG,BG_COLLECT_RETURN_PP,BG_HANDOVER_PP_TO_CUSTOMER,REJECT_FILE',
      ],
      hideStatusDropdown: true,
    );
  }
}
