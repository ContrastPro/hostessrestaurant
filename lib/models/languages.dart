class Item {
  const Item(this.title, this.language, this.icon);

  final String title;
  final String language;
  final String icon;
}

List<Item> languages = <Item>[
  const Item('Русский', 'ru', 'ru.png'),
  const Item('Українська', 'ua', 'ua.png'),
  const Item('English', 'en', 'en.png'),
];
