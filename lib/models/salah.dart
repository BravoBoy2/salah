enum Salah {
  fajr('Fajr'),
  dhuhr('Dhuhr'),
  asr('Asr'),
  maghrib('Maghrib'),
  isha('Isha');

//to show the salah name when called
  final String displaySalahName;

  const Salah(this.displaySalahName);




  get currentSalah{
    //TODO: fetching the current salah name
  }

  //TODO: should return all the salah name at once.
  static List<Salah> getAllSalah() => Salah.values;
}