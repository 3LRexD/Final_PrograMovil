import 'package:flutter_test/flutter_test.dart';

import 'package:final_moviles/app/routes/app_routes.dart';

void main() {
  test('rutas básicas declaradas', () {
    expect(AppRoutes.home, '/');
    expect(AppRoutes.firstAid, '/primeros-auxilios');
  });
}
