import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main(List<String> args) {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationProvider: s.routeInformationProvider,
      routeInformationParser: s.routeInformationParser,
      debugShowCheckedModeBanner: false,
      routerDelegate: s.routerDelegate,
      // theme: ThemeData(
      //   fontFamily: $styles.text.body.fontFamily,
      //   useMaterial3: true,
      //   brightness: Brightness.dark,
      // ),
      //
    );
  }

  static GlobalKey<NavigatorState> main = GlobalKey<NavigatorState>();
  static GlobalKey<NavigatorState> sub = GlobalKey<NavigatorState>();

  static final s = GoRouter(
    // navigatorKey: main,
    initialLocation: "/home",
    routes: [
      ShellRoute(
        navigatorKey: main,
        builder: (context, state, child) => Scaffold(
          body: child,
        ),
        routes: [
          GoRoute(
            path: "/home",
            builder: (context, state) => const Second(
              iconData: Icons.home,
            ),
          ),
          GoRoute(
            path: "/second_page",
            builder: (context, state) => const Second(
              iconData: Icons.access_alarm,
            ),
          ),
          ShellRoute(
              navigatorKey: sub,
              builder: (ctxt, state, child) {
                return Container(
                  height: 600,
                  width: double.infinity,
                  color: Colors.black,
                  child: child,
                );
              },
              routes: [
                GoRoute(
                  parentNavigatorKey: sub,
                  path: "/third_page",
                  builder: (context, state) {
                    print("context");
                    return const Second(iconData: Icons.file_copy);
                  },
                ),
              ]),
        ],
      ),
    ],
  );
}

class Second extends StatelessWidget {
  final IconData iconData;
  const Second({super.key, required this.iconData});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print("object");
        GoRouter.of(MyApp.main.currentContext!).push("/third_page");
      },
      child: Center(
        child: Icon(
          iconData,
          size: 150,
        ),
      ),
    );
  }
}
