import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hostessrestaurant/api/categories_api.dart';
import 'package:hostessrestaurant/api/food_api.dart';
import 'package:hostessrestaurant/api/profile_api.dart';
import 'package:hostessrestaurant/global/colors.dart';
import 'package:hostessrestaurant/models/categories.dart';
import 'package:hostessrestaurant/models/languages.dart';
import 'package:hostessrestaurant/models/profile.dart';
import 'package:hostessrestaurant/notifier/auth_notifier.dart';
import 'package:hostessrestaurant/notifier/categories_notifier.dart';
import 'package:hostessrestaurant/notifier/food_notifier.dart';
import 'package:hostessrestaurant/notifier/profile_notifier.dart';
import 'package:hostessrestaurant/screens/food_form_screen.dart';
import 'package:hostessrestaurant/screens/profile_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Categories _categories;
  Item _selectedLanguage;
  TextEditingController _categoryController;
  TextEditingController _addressController;

  String _uid;
  String _addressId;
  String _category;
  String _language;
  int _selectedIndex = 0;
  bool _addAddress = false;
  List _subLanguages = [];

  @override
  void initState() {
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    setState(() => _uid = authNotifier.user.uid);
    _categories = Categories();
    _categoryController = TextEditingController();
    _addressController = TextEditingController();
    super.initState();
  }

  _setCategory(String category) {
    setState(() => _category = category);
  }

  _onSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    AuthNotifier authNotifier = Provider.of<AuthNotifier>(context);
    ProfileNotifier profileNotifier = Provider.of<ProfileNotifier>(context);
    CategoriesNotifier categoriesNotifier =
        Provider.of<CategoriesNotifier>(context);
    FoodNotifier foodNotifier = Provider.of<FoodNotifier>(context);

    Future<void> _refreshList(String category) async {
      getFoods(foodNotifier, _uid, _addressId, _language, category);
    }

    String _titleLanguage(String subLanguages) {
      switch (subLanguages) {
        case "ru":
          return "Русский";

          break;

        case "ua":
          return "Українська";

          break;

        default:
          return "English";

          break;
      }
    }

    _showLanguageDialog() {
      showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              title: Text('Доступные языки'),
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount:
                          profileNotifier.profileList[0].subLanguages.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () {
                            setState(() {
                              _language = profileNotifier
                                  .profileList[0].subLanguages[index];
                            });
                            getCategories(categoriesNotifier, _uid, _addressId,
                                _language);
                            Navigator.pop(context);
                          },
                          leading: Container(
                            width: 30,
                            height: 30,
                            child: Image.asset(
                                'assets/languages/${profileNotifier.profileList[0].subLanguages[index]}.png'),
                          ),
                          title: Text(
                            _titleLanguage(profileNotifier
                                .profileList[0].subLanguages[index]),
                          ),
                        );
                      }),
                ),
              ],
            );
          });
    }

    String _parsePrice(subPrice) {
      List<String> splitRes = subPrice.split('#');
      String splitPrice = splitRes[1];
      return splitPrice;
    }

    _saveCategory(String categoryText) async {
      await addCategory(_categories, _uid, _addressId, _language, categoryText);
      getCategories(categoriesNotifier, _uid, _addressId, _language);
      Navigator.pop(context);
    }

    _addCategoryDialog() {
      showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              title: Text("Введите новую категорию"),
              titlePadding: EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
              contentPadding: EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 10.0),
              children: <Widget>[
                TextField(
                  controller: _categoryController,
                  maxLength: 50,
                  maxLines: 1,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 16, color: t_primary),
                  decoration: InputDecoration(labelText: 'Название'),
                ),
                SizedBox(height: 16),
                FlatButton(
                  color: c_secondary,
                  textColor: Colors.white,
                  child: Text("Создать"),
                  onPressed: () {
                    if (_categoryController.text.trim().length > 1) {
                      _saveCategory(_categoryController.text.trim());
                      _categoryController.clear();
                    }
                  },
                )
              ],
            );
          });
    }

    _showCreateDialog() {
      showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              title: Text("Что бы вы хотели добавить?"),
              titlePadding: EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
              contentPadding: EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 10.0),
              children: <Widget>[
                SizedBox(height: 16),
                ButtonBar(
                  alignment: MainAxisAlignment.center,
                  children: <Widget>[
                    OutlineButton(
                      child: Text('Категорию'),
                      onPressed: () {
                        Navigator.pop(context);
                        _addCategoryDialog();
                      },
                    ),
                    categoriesNotifier.categoriesList.isNotEmpty
                        ? FlatButton(
                            color: c_secondary,
                            child: Text('Блюдо'),
                            onPressed: () async {
                              Navigator.pop(context);
                              if (_selectedIndex == 0) {
                                _setCategory(
                                    categoriesNotifier.categoriesList[0].title);
                              }
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FoodForm(
                                    isUpdating: false,
                                    uid: _uid,
                                    address: _addressId,
                                    language: _language,
                                    category: _category,
                                  ),
                                ),
                              );
                              _refreshList(categoriesNotifier
                                  .categoriesList[_selectedIndex].title);
                            },
                          )
                        : SizedBox(),
                  ],
                ),
              ],
            );
          });
    }

    Widget _chipItem(int index) {
      return FilterChip(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        label: Text(
          categoriesNotifier.categoriesList[index].title,
          style: TextStyle(
            fontSize: 16.0,
            color: _selectedIndex != null && _selectedIndex == index
                ? c_background
                : t_primary.withOpacity(0.4),
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: _selectedIndex != null && _selectedIndex == index
            ? c_secondary
            : Colors.white.withOpacity(0),
        elevation:
            _selectedIndex != null && _selectedIndex == index ? 0.0 : 2.0,
        pressElevation: 0.0,
        onSelected: (bool value) {
          _onSelected(index);
          if (_selectedIndex != 0) {
            _refreshList(categoriesNotifier.categoriesList[index].title);
            _setCategory(categoriesNotifier.categoriesList[index].title);
          }
        },
      );
    }

    Widget _setMenu() {
      return ListView.builder(
        padding: EdgeInsets.only(
          left: 25.0,
          top: 0.0,
          right: 30.0,
          bottom: 60.0,
        ),
        itemCount: foodNotifier.foodList.length,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Container(
            color: c_background,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Container(
                height: 100,
                child: InkWell(
                  onTap: () async {
                    foodNotifier.currentFood = foodNotifier.foodList[index];
                    if (_selectedIndex == 0) {
                      _setCategory(categoriesNotifier.categoriesList[0].title);
                    }

                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FoodForm(
                          isUpdating: true,
                          uid: _uid,
                          address: _addressId,
                          language: _language,
                          category: _category,
                        ),
                      ),
                    );
                    _refreshList(categoriesNotifier
                        .categoriesList[_selectedIndex].title);
                  },
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 80,
                        height: 80,
                        child: Card(
                          semanticContainer: true,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: foodNotifier.foodList[index].imageLow != null
                              ? CachedNetworkImage(
                                  imageUrl:
                                      foodNotifier.foodList[index].imageLow,
                                  fit: BoxFit.cover,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: CircularProgressIndicator(
                                        value: downloadProgress.progress),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                )
                              : Image.asset('assets/placeholder_200.png',
                                  fit: BoxFit.cover),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(10.0, 2.0, 5.0, 2.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                foodNotifier.foodList[index].title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: t_primary,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                foodNotifier.foodList[index].description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: t_secondary,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              '₴',
                              style: TextStyle(
                                color: t_primary,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 2),
                            Text(
                              _parsePrice(
                                  foodNotifier.foodList[index].subPrice[0]),
                              style: TextStyle(
                                color: t_primary,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    Widget _drawerHeader() {
      return _addressId != null
          ? Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.35,
              color: c_primary,
              child: Stack(
                children: [
                  profileNotifier.profileList[0].image != null &&
                          profileNotifier.profileList.isNotEmpty
                      ? Container(
                          width: double.infinity,
                          height: double.infinity,
                          child: CachedNetworkImage(
                            imageUrl: profileNotifier.profileList[0].image,
                            fit: BoxFit.cover,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) {
                              return Center(
                                child: CircularProgressIndicator(
                                  backgroundColor: Colors.white,
                                  value: downloadProgress.progress,
                                  strokeWidth: 6,
                                ),
                              );
                            },
                            errorWidget: (context, url, error) => Image.asset(
                              'assets/placeholder_1024.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : SizedBox(),
                  profileNotifier.profileList[0].image != null
                      ? Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.80,
                          alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                Colors.black.withAlpha(0),
                                Colors.black12,
                                Colors.black87,
                              ],
                            ),
                          ),
                        )
                      : SizedBox(),
                  SafeArea(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: ListTile(
                        title: Text(
                          authNotifier.user.displayName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          profileNotifier.profileList[0].address,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          color: Colors.white,
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileScreen(),
                              ),
                            );
                            getProfile(profileNotifier, _uid, _addressId);
                          },
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          : Container(
              color: c_primary,
              child: SafeArea(
                child: ListTile(
                  title: Text(
                    authNotifier.user.displayName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Выберите адрес',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
    }

    Widget _drawerAddresses(DocumentSnapshot document) {
      return ListTile(
        onTap: () async {
          await getProfile(profileNotifier, _uid, document.data['id']);
          setState(() {
            _addressId = document.data['id'];
            _language = profileNotifier.profileList[0].subLanguages[0];
          });
          getCategories(categoriesNotifier, _uid, _addressId, _language);
          if (_addAddress == true) {
            setState(() => _addAddress = !_addAddress);
            Navigator.pop(context);
          }
        },
        title: Text(
          document.data['address'],
          style: TextStyle(
            color: t_primary,
            fontWeight: FontWeight.normal,
          ),
        ),
      );
    }

    Widget _setDrover() {
      return Drawer(
        child: Column(
          children: [
            _drawerHeader(),
            StreamBuilder(
              stream: Firestore.instance
                  .collection(_uid)
                  .orderBy("createdAt", descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Something went wrong'));
                }

                if (!snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50),
                    child: CircularProgressIndicator(strokeWidth: 6),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 0.0),
                  itemCount: snapshot.data.documents.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return _drawerAddresses(snapshot.data.documents[index]);
                  },
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text(
                'Добавить адрес',
                style: TextStyle(color: t_primary),
              ),
              onTap: () {
                if (_addAddress == false) {
                  setState(() => _addAddress = !_addAddress);
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }

    Widget _setHomePage() {
      return CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate(
              <Widget>[
                _addAddress == false
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20),
                          Container(
                            height: 80,
                            child: ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                scrollDirection: Axis.horizontal,
                                itemCount:
                                    categoriesNotifier.categoriesList.length,
                                itemBuilder: (context, index) {
                                  if (_selectedIndex == 0) {
                                    _refreshList(categoriesNotifier
                                        .categoriesList[0].title);
                                  }
                                  return Padding(
                                    padding: EdgeInsets.all(5.0),
                                    child: _chipItem(index),
                                  );
                                }),
                          ),
                          categoriesNotifier.categoriesList.isNotEmpty
                              ? _setMenu()
                              : Column(
                                  children: [
                                    SizedBox(height: 40.0),
                                    Image.asset(
                                      'assets/empty_search.png',
                                      fit: BoxFit.cover,
                                    ),
                                    SizedBox(height: 40.0),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: Text(
                                        profileNotifier.profileList.isNotEmpty
                                            ? categoriesNotifier
                                                    .categoriesList.isEmpty
                                                ? 'Меню слишком пустое'
                                                : 'Категория пустует'
                                            : "Адрес не выбран",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: t_primary,
                                          fontSize: 22.0,
                                          letterSpacing: 1.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20.0, 10.0, 20.0, 0.0),
                                      child: Text(
                                        profileNotifier.profileList.isNotEmpty
                                            ? categoriesNotifier
                                                    .categoriesList.isEmpty
                                                ? 'Похоже вы еще ничего не добавили. Давайте это исправим! Попробуйте добавить категорию.'
                                                : 'Похоже вы еще ничего не добавили. Давайте это исправим! Попробуйте добавить блюдо.'
                                            : "Чтобы начать редактировать меню, выберите необходимый адрес",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black38,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30.0,
                          vertical: 35.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Шаг 1:\t",
                                  style: TextStyle(
                                      color: t_primary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 16),
                                AutoSizeText(
                                  'Выберите основной язык меню',
                                  maxLines: 1,
                                  minFontSize: 14,
                                  style: TextStyle(
                                      color: t_primary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            DropdownButton<Item>(
                              isExpanded: true,
                              hint: Text(
                                "Основной язык",
                                style: TextStyle(fontSize: 18),
                              ),
                              value: _selectedLanguage,
                              onChanged: (Item value) {
                                _subLanguages.clear();
                                setState(() {
                                  _selectedLanguage = value;
                                  _subLanguages.add(_selectedLanguage.language);
                                });
                              },
                              items: languages.map((Item lang) {
                                return DropdownMenuItem<Item>(
                                  value: lang,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      CircleAvatar(
                                        radius: 12,
                                        backgroundImage: AssetImage(
                                            'assets/languages/${lang.icon}'),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        lang.title,
                                        style: TextStyle(color: t_primary),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 35),
                            Row(
                              children: [
                                Text(
                                  "Шаг 2:\t",
                                  style: TextStyle(
                                      color: t_primary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 16),
                                AutoSizeText(
                                  'Введите новый адрес заведения',
                                  maxLines: 1,
                                  minFontSize: 14,
                                  style: TextStyle(
                                      color: t_primary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                            TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'Новый адрес'),
                              maxLength: 50,
                              maxLines: 1,
                              keyboardType: TextInputType.text,
                              style: TextStyle(fontSize: 18, color: t_primary),
                              onChanged: (String value) {
                                _addressController.text = value;
                              },
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          )
        ],
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor:
          foodNotifier.foodList.isNotEmpty ? c_background : Colors.white,
      appBar: AppBar(
        backgroundColor: c_primary,
        title: Text(_addAddress == false ? 'Меню' : 'Новый адрес'),
        centerTitle: true,
        actions: [
          _language != null && _addAddress != true
              ? Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () => _showLanguageDialog(),
                    child: CircleAvatar(
                      maxRadius: 18,
                      minRadius: 18,
                      child: Text(
                        '$_language'.toUpperCase(),
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      backgroundColor: Colors.deepOrange[900],
                    ),
                  ),
                )
              : SizedBox(),
        ],
      ),
      drawer: _setDrover(),
      body: _setHomePage(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _addAddress != true
          ? Visibility(
              visible:
                  profileNotifier.profileList.isNotEmpty && _addressId != null
                      ? true
                      : false,
              child: FloatingActionButton.extended(
                backgroundColor: c_secondary,
                elevation: 4.0,
                icon: const Icon(Icons.add),
                label: const Text(
                  'ДОБАВИТЬ',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => _showCreateDialog(),
              ),
            )
          : FloatingActionButton.extended(
              backgroundColor: c_secondary,
              elevation: 4.0,
              icon: const Icon(Icons.add),
              label: const Text(
                'СОЗДАТЬ',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                if (_addressController.text.trim().length > 3 &&
                    _selectedLanguage != null) {
                  Profile profile = Profile();
                  addAddress(
                    profile,
                    authNotifier.user.uid,
                    authNotifier.user.displayName,
                    _addressController.text.trim(),
                    _subLanguages,
                  );
                  _addressController.clear();
                }
              },
            ),
    );
  }
}
