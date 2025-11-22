import 'package:caffinet_app_flutter/features/discover/domain/usecases/route_preferences.dart';

import '../entities/optimal_route_result.dart';

abstract class DiscoverRepository {

  Future<OptimalRouteResult> calculateOptimalRoute(RoutePreferences preferences);
}