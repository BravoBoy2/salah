import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salah/models/salah.dart';

class HomeScreen extends StatelessWidget {


  const HomeScreen({super.key});

  final String appTitle = "Salah App";

  @override
  Widget build(BuildContext context) {
    //TODO: showing salah name on the home page

    final salahName = Salah.asr.name; // temporary

    return Focus(
        autofocus: true,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(salahName),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: _salahTime(context),
            ),

            SliverFillRemaining(
              child: _upcomingSalah(context),
            )
          ],
        )
    );
  }

  Widget _salahTime(BuildContext context) {
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
                  _buildTimeCard(context, '04:32:40 PM'), //Temporary placement
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
                    _buildTimeCard(context, '05:32:40 PM'),
                    //Temporary placement
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

  Widget _buildTimeCard(BuildContext context, String time) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    decoration: BoxDecoration(
        color: Theme
            .of(context)
            .colorScheme
            .onSecondary,
        borderRadius: BorderRadius.circular(25)
    ),

    child: Center(
      child: Text(
          time,
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
            textStyle: Theme
                .of(context)
                .textTheme
                .bodyMedium,
            color: Theme
                .of(context)
                .colorScheme
                .onSurface
        ),
      ),
    ),
  );
  }


  /*
  TODO: needs to implement a list of upcoming salahs, based on the current Salah

   */

  Widget _upcomingSalah(BuildContext context) {
     List<Salah> salahList() => Salah.values;

     final theme = Theme.of(context);
    return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
            color: theme.colorScheme.surfaceContainer
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            for(final salah in salahList())...[
              _buildSalahRow(context, salah, '06:32:40 PM'),

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

  Widget _buildSalahRow(BuildContext context, Salah salah, String time) {
    final theme = Theme.of(context);

    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Padding(padding: EdgeInsets.symmetric(),
          child: Text(salah.displaySalahName,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurfaceVariant
            ),
          ),
          ),


          const Spacer(),

          Text(time,
            style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurfaceVariant
          ),
          )

        ],
      ),
    );
  }
}