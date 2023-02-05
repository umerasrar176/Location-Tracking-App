import 'package:flutter/material.dart';
import 'package:location_checker_app/HomeScreen.dart';
import 'package:location_checker_app/About.dart';
import 'package:location_checker_app/Profile.dart';
import 'package:location_checker_app/Sources/theming/theme_manager.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider<ThemeNotifier>(
    create: (_) => ThemeNotifier(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
        builder: (context, theme, child) => MaterialApp(
              theme: theme.getTheme(),
              title: 'Flutter Demo',
              //theme: ThemeData.light(),
              //darkTheme: ThemeData.dark(),
              //home: const HomeScreen(),
              home: MyHomePage(),
            ));
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isDarkMode = false;
  int _selectedIndex = 0;

  static final List<String> _pageTitles = [
    'GPS Based Attendance System',
    'About',
    'Profile'
  ];

  final List<Widget> pages = [
    const HomeScreen(),
    const AboutPage(),
    const Profile()
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
        builder: (context, theme, child) => Scaffold(
              appBar: AppBar(
                actions: <Widget>[
                  IconButton(
                      onPressed: () {
                        if (_isDarkMode) {
                          theme.setLightMode();
                          setState(() {
                            _isDarkMode = !_isDarkMode;
                          });
                        } else {
                          theme.setDarkMode();
                          setState(() {
                            _isDarkMode = !_isDarkMode;
                          });
                        }
                      },
                      icon: const Icon(Icons.light_mode_outlined)),
                  /*Switch(
          value: _isDarkMode,
          onChanged: (value) {
            _toggleDarkMode();
          },
        ),*/
                ],
                title: Text(_pageTitles[_selectedIndex]),
                centerTitle: true,
              ),
              body: pages[_selectedIndex],
              bottomNavigationBar: BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.favorite),
                    label: 'About',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
                currentIndex: _selectedIndex,
                selectedItemColor: Colors.blue,
                onTap: (int index) {
                  if (mounted) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  }
                },
              ),
            ));
  }
}
