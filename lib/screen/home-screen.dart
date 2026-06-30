import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salah/models/salah.dart';

class HomeScreen extends StatelessWidget {

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //TODO: showing salah name on the home page

    final salahName = Salah.asr.name; // temporary

    return MaterialApp(
      theme: ThemeData(
          textTheme: GoogleFonts.juliusSansOneTextTheme()
      ),
      home: Scaffold(
          appBar: AppBar(
            title: Center(
              child: Text('Salah App'),
            ),
          ),
          body: Column(
            children: [
              Center(
                child:
                Text('${salahName}'),
              ),
            ],
          )
      ),
    );

  }
  
}