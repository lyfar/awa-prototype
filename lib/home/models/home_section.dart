enum HomeSection {
  home,
  streaks,
  units,
  missions,
  history,
  saved,
  donations,
  faq,
}

extension HomeSectionDisplay on HomeSection {
  String get label {
    switch (this) {
      case HomeSection.home:
        return 'Home';
      case HomeSection.streaks:
        return 'AWAWAY';
      case HomeSection.units:
        return 'Lumens';
      case HomeSection.missions:
        return 'Missions';
      case HomeSection.history:
        return 'Insider';
      case HomeSection.saved:
        return 'Favourites';
      case HomeSection.donations:
        return 'Support';
      case HomeSection.faq:
        return 'FAQ';
    }
  }

  String get description {
    switch (this) {
      case HomeSection.home:
        return 'Globe and practice entry.';
      case HomeSection.streaks:
        return 'Keep the daily light streak alive.';
      case HomeSection.units:
        return 'Track, earn, and spend your Lumens.';
      case HomeSection.missions:
        return 'Collective goals guided by AWA Souls.';
      case HomeSection.history:
        return 'Recaps, reactions, and favourite moments.';
      case HomeSection.saved:
        return 'Favourite sessions and personal picks.';
      case HomeSection.donations:
        return 'Support the collective mission.';
      case HomeSection.faq:
        return 'Answers about practices, masters, and support.';
    }
  }

  bool get isPaidFeature {
    switch (this) {
      case HomeSection.saved:
      case HomeSection.donations:
        return true;
      case HomeSection.faq:
      case HomeSection.units:
        return false;
      default:
        return false;
    }
  }
}
