enum Salah {
  fajr('Fajr'),
  dhuhr('Dhuhr'),
  asr('Asr'),
  maghrib('Maghrib'),
  isha('Isha');

  //to show the salah name when called
  final String displaySalahName;

  const Salah(this.displaySalahName);

  //
  //  Future<Salah> currentSalah {
  //   //TODO: fetching the current salah name
  // }

  //TODO: should return all the salah name at once.
  static List<Salah> getAllSalah() => Salah.values;

  static Salah? fromString(String? name) {
    if (name == null) return null;
    final cleaned = name.trim().toLowerCase();
    switch (cleaned) {
      case 'fajr':
        return Salah.fajr;

      case 'zuhr'
          'dhuhr'
          'dhuhr':
        return Salah.dhuhr;

      case 'asr':
        return Salah.asr;

      case 'maghrib':
        return Salah.maghrib;

      case 'isha':
        return Salah.isha;

      default:
        return null;
    }
  }

  static Salah getCurrentSalah({
    required DateTime now,
    required DateTime fajrTime,
    required DateTime dhuhrTime,
    required DateTime asrTime,
    required DateTime maghribTime,
    required DateTime ishaTime,
  }) {
    if (now.isAfter(ishaTime) || now.isBefore(fajrTime)) {
      return Salah.isha; // After Isha or before Fajr (Isha period)
    } else if (now.isAfter(maghribTime)) {
      return Salah.maghrib;
    } else if (now.isAfter(asrTime)) {
      return Salah.asr;
    } else if (now.isAfter(dhuhrTime)) {
      return Salah.dhuhr;
    } else {
      return Salah.fajr;
    }
  }
}
