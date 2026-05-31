import 'package:fui_kit/fui_kit.dart';

class NavLinkItem {
  const NavLinkItem({
    required this.name,
    required this.href,
    required this.icon,
  });

  final String name;
  final String href;
  final dynamic icon;
}

class CountryItem {
  const CountryItem({
    required this.id,
    required this.name,
    required this.code,
    required this.flag,
    this.unicodeFlag = '',
  });

  final int id;
  final String name;
  final String code;
  final String flag;
  final String unicodeFlag;
}

class WorkPermitItem {
  const WorkPermitItem({
    this.id,
    required this.title,
    required this.slug,
    required this.image,
    required this.customerPrice,
    required this.agentPrice,
    required this.countryName,
    required this.countryFlag,
    required this.workType,
    required this.selectionType,
    required this.createdAt,
  });

  factory WorkPermitItem.getDummy() {
    return WorkPermitItem(
      title: 'Dummy Work Permit Title For Loading',
      slug: 'dummy-slug',
      image: '',
      customerPrice: 150000,
      agentPrice: 120000,
      countryName: 'Dummy Country',
      countryFlag: '',
      workType: 'General Work',
      selectionType: 'Direct',
      createdAt: DateTime.now(),
    );
  }

  final String title;
  final int? id;
  final String slug;
  final String image;
  final int customerPrice;
  final int agentPrice;
  final String countryName;
  final String countryFlag;
  final String workType;
  final String selectionType;
  final DateTime createdAt;
}

class WorkTypeItem {
  const WorkTypeItem({
    required this.id,
    required this.name,
    required this.nameBn,
    required this.icon,
    required this.serial,
    required this.totalAds,
  });

  final int id;
  final String name;
  final String nameBn;
  final String icon;
  final int serial;
  final int totalAds;
}

const List<NavLinkItem> navLinkData = [
  NavLinkItem(name: 'Home', href: '/', icon: RegularRounded.HOME),
  NavLinkItem(name: 'Flight Booking', href: '', icon: RegularRounded.PLANE),
  NavLinkItem(name: 'Work Abroad', href: '/search', icon: RegularRounded.BRIEFCASE),
  NavLinkItem(name: 'Study Abroad', href: '', icon: RegularRounded.BOOK),
  NavLinkItem(name: 'Hajj & Umrah', href: '', icon: RegularRounded.PYRAMID),
  NavLinkItem(name: 'Visa Services', href: '', icon: RegularRounded.ID_BADGE),
  NavLinkItem(name: 'Tour Packages', href: '', icon: RegularRounded.GLOBE),
  NavLinkItem(name: 'Hotel Booking', href: '', icon: RegularRounded.BUILDING),
];
