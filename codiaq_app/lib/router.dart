import 'package:go_router/go_router.dart';

// GoRouter configuration
final _router = GoRouter(
  routes: [GoRoute(path: '/', builder: (context, state) => HomeScreen())],
);
