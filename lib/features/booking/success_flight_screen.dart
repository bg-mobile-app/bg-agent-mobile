import 'package:flutter/material.dart';

import 'my_booking_screen.dart';

class SuccessFlightScreen extends StatelessWidget {
  const SuccessFlightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyBookingScreen(
      currentHref: '/dashboard/booking/my/success-file',
      breadcrumbCurrent: 'Success Flight',
      pageTitle: 'Success Flight',
      initialStatus: 'SUCCESS_FLIGHT',
      availableStatuses: ['SUCCESS_FLIGHT'],
      hideStatusDropdown: true,
    );
  }
}
