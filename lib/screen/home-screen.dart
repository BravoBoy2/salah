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
              child: Text('Salah App',
              style: TextStyle(
                fontSize: 32,
                letterSpacing: 32 * 0.17,
                color: Color(0xFF32BB56),
              ),
              ),
            ),
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
            child: Center(
          child: Padding(
              padding: EdgeInsets.all(16),
        child: Text('${salahName}',
          style: TextStyle(
              fontSize: 20,
              letterSpacing: 20 * 0.17
          ),
        ),
      )
            ),

    ),
              SliverToBoxAdapter(
                child: _salahTime()
              ),
              SliverFillRemaining(
                  child: _upcomingSalah()
              ),
            ],
          )


      ),
    );

  }

  Widget _salahTime(){
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      padding: EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Expanded(
                child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                const Text(
                    'Start Time',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    fontSize: 14,
                  ),
                ),

                  const SizedBox(height: 8),
                  _buildTimeCard('04:32:40 PM'), //Temporary placement
          ],
            ),
            ),

            const SizedBox(width: 20),

            Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Time Left',
                      style: TextStyle(
                        color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                        fontSize: 14
                      ),
                    ),

                    const SizedBox(height: 8),
                    _buildTimeCard('05:32:40 PM'), //Temporary placement
                  ],
                ),
            ),
          ],
        ),

      ),
    );
  }


  //*!! temporary placeholders !!*//

  /*
  TODO: needs to implement a countdown timer from the start time to the end time

   */

  Widget _buildTimeCard(String time) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    decoration: BoxDecoration(
      color: Colors.purple,
        borderRadius: BorderRadius.circular(25)
    ),

    child: Center(
      child: Text(
          time,
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Colors.black87
        ),
      ),
    ),
  );
  }


  /*
  TODO: needs to implement a list of upcoming salahs, based on the current Salah

   */

  Widget _upcomingSalah(){
     List<Salah> salahList() => Salah.values;
    return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            for(final salah in salahList())...[
              _buildSalahRow(salah, '06:32:40 PM'),

            ]
          ],
        ),
      ),

    )
    );
  }


  /*
  Shows a list of salahs with their times and names
   */

  Widget _buildSalahRow(Salah salah, String time){
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Padding(padding: EdgeInsets.symmetric(),
          child: Text(salah.displaySalahName,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black
            ),
          ),
          ),


          const Spacer(),

          Text(time,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black
          ),
          )

        ],
      ),
    );
  }
}