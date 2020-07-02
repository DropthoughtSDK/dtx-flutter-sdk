import 'package:bct_dashboard/ViewModels/NPSDetails_ViewModel.dart';
import 'package:get_it/get_it.dart';
import '../ViewModels/MetricsAtLocations_ViewModel.dart';

GetIt serviceLocator = GetIt.instance;

void setupServiceLocator() {
  serviceLocator.registerFactory<MetricsAtLocationsViewModel>(() => MetricsAtLocationsViewModel());
  serviceLocator.registerFactory<NPSDetailsViewModel>(() => NPSDetailsViewModel());
}
