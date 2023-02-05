import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Container(
        color: Theme.of(context).backgroundColor,
        child: Center(
          child: Text('Profile Page', style: TextStyle(
            color: Theme.of(context).textTheme.headline6?.color,
          ),),
        ),
      ),
    );
  }
}
