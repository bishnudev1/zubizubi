import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:zubizubi/services/appwrite_services.dart';

@StackedApp(routes: [], dependencies: [
  LazySingleton(classType: AppwriteServices),
  LazySingleton(classType: NavigationService),
])
class AppSetup {
  /** Serves no purpose besides having an annotation attached to it */
}
