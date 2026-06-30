import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const SalahApp());
}

class SalahApp extends StatelessWidget {

  const SalahApp({super.key});

  @override
  Widget build(BuildContext context) {
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
        body: Center(
          child: 
          Text('Salah Name goes here...'),
        ) ,
      ),
    );
  }
}


// Returns Salah names with names and etc...

class SalahInfo extends StatelessWidget{


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }


}
