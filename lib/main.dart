import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'common/theme/app_palette.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: AppPalette.brandBlue,
      systemNavigationBarDividerColor: AppPalette.brandBlue,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const BideshgamiApp());
}
