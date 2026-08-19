import 'package:flutter/widgets.dart';

import 'app/app_controller.dart';
import 'app/unitflow_app.dart';
import 'core/persistence/user_state_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final appController = AppController(
    repository: SharedPreferencesUserStateRepository(),
  );
  runApp(UnitFlowApp(appController: appController));
}
