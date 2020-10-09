import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hostessrestaurant/api/categories_api.dart';
import 'package:hostessrestaurant/api/food_api.dart';
import 'package:hostessrestaurant/api/profile_api.dart';
import 'package:hostessrestaurant/global/colors.dart';
import 'package:hostessrestaurant/models/categories.dart';
import 'package:hostessrestaurant/notifier/auth_notifier.dart';
import 'package:hostessrestaurant/notifier/categories_notifier.dart';
import 'package:hostessrestaurant/notifier/food_notifier.dart';
import 'package:hostessrestaurant/notifier/profile_notifier.dart';
import 'package:hostessrestaurant/screens/food_form_screen.dart';
import 'package:hostessrestaurant/screens/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _uid;
  String _addressId;
  String _category;
  String _language;
  int _selectedIndex = 0;
  int _addressIndex = 0;
  bool _isUploading = false;

  TextEditingController _categoryController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    setState(() => _uid = authNotifier.user.uid);
    _scrollController.addListener(() => setState(() {}));
    super.initState();
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
                              _selectedIndex = 0;
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
      Categories categories = Categories();
      await addCategory(categories, _uid, _addressId, _language, categoryText);
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
                  onPressed: () async {
                    if (_categoryController.text.trim().length > 1) {
                      setState(() => _isUploading = !_isUploading);
                      await _saveCategory(_categoryController.text.trim());
                      _categoryController.clear();
                      setState(() => _isUploading = !_isUploading);
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

    _onPageChange(DocumentSnapshot document) async {
      await getProfile(profileNotifier, _uid, document.data['id']);
      setState(() {
        _addressId = document.data['id'];
        _language = profileNotifier.profileList[0].subLanguages[0];
      });
      getCategories(categoriesNotifier, _uid, _addressId, _language);
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
            ? c_primary
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

    Widget _itemFeedback() {
      return Card(
        elevation: 10,
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        margin: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Обратная связь',
              style: TextStyle(
                color: t_primary,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Icon(Icons.question_answer, color: Colors.deepOrange[900]),
          ],
        ),
      );
    }

    Widget _headerAddresses(DocumentSnapshot document) {
      return Card(
        elevation: 10,
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        margin: EdgeInsets.symmetric(vertical: 20),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              child: document.data['image'] != null
                  ? CachedNetworkImage(
                      imageUrl: document.data['image'],
                      fit: BoxFit.cover,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) => Center(
                        child: CircularProgressIndicator(
                            value: downloadProgress.progress),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    )
                  : Image.asset(
                      'assets/placeholder_1024.png',
                      fit: BoxFit.cover,
                    ),
            ),
            Container(
              width: double.infinity,
              height: double.infinity,
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
            ),
            Align(
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
                  document.data['address'],
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
          ],
        ),
      );
    }

    Widget _setHeaderContent() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 260,
            child: StreamBuilder(
              stream: Firestore.instance
                  .collection(_uid)
                  .orderBy("createdAt", descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Something went wrong'));
                }

                if (snapshot.hasData) {
                  return PageView.builder(
                    itemCount: snapshot.data.documents.length + 1,
                    controller: PageController(
                        initialPage: _addressIndex,
                        keepPage: true,
                        viewportFraction: 0.8),
                    onPageChanged: (int i) {
                      setState(() {
                        _addressIndex = i;
                        _selectedIndex = 0;
                      });
                      if (i != 0) {
                        _onPageChange(snapshot.data.documents[i - 1]);
                      }
                    },
                    itemBuilder: (context, index) {
                      Widget result;
                      if (index == 0) {
                        result = _itemFeedback();
                      } else {
                        result = _headerAddresses(
                            snapshot.data.documents[index - 1]);
                      }
                      return Transform.scale(
                        scale: index == _addressIndex ? 1 : 0.9,
                        child: result,
                      );
                    },
                  );
                }

                return Center(child: CircularProgressIndicator(strokeWidth: 6));
              },
            ),
          ),
        ],
      );
    }

    final Uri _emailLaunchUri = Uri(
        scheme: 'mailto',
        path: 'hostessqr@gmail.com',
        queryParameters: {'subject': "ID заведения: ${authNotifier.user.uid}"});

    _sendEmail() async {
      if (await canLaunch(_emailLaunchUri.toString())) {
        await launch(_emailLaunchUri.toString());
      } else {
        throw 'Could not launch';
      }
    }

    _openSite() async {
      String url = 'https://www.hostessqr.site';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch';
      }
    }

    Widget _setHomePage() {
      return Container(
        child: _addressIndex == 0
            ? Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25.0,
                  vertical: 50.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Вы можете связаться с нами в любое удобное для вас время, просто выбрав нужный пункт:",
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => _sendEmail(),
                      child: Row(
                        children: [
                          Icon(Icons.email, color: Colors.deepOrange[900]),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "hostessqr@gmail.com",
                              style: TextStyle(
                                color: t_primary,
                                fontSize: 16.0,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => _openSite(),
                      child: Row(
                        children: [
                          Icon(Icons.link, color: Colors.deepOrange[900]),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "www.hostessqr.site",
                              style: TextStyle(
                                color: t_primary,
                                fontSize: 16.0,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: 180,
                      height: 180,
                      child: FlareActor(
                        "assets/rive/fast_note.flr",
                        alignment: Alignment.center,
                        fit: BoxFit.contain,
                        animation: "note_page",
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  categoriesNotifier.categoriesList.isNotEmpty
                      ? Container(
                          height: 80,
                          margin: EdgeInsets.only(top: 30),
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
                        )
                      : SizedBox(height: 30),
                  foodNotifier.foodList.isNotEmpty
                      ? _setMenu()
                      : Column(
                          children: [
                            Container(
                              width: 235,
                              height: 235,
                              child: FlareActor(
                                "assets/rive/empty.flr",
                                alignment: Alignment.center,
                                fit: BoxFit.contain,
                                animation: "show",
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                categoriesNotifier.categoriesList.isEmpty
                                    ? 'Меню слишком пустое'
                                    : 'Категория пустует',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: t_primary,
                                  fontSize: 25.0,
                                  letterSpacing: 1.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  20.0, 10.0, 20.0, 0.0),
                              child: Text(
                                categoriesNotifier.categoriesList.isEmpty
                                    ? 'Похоже вы еще ничего не добавили. Давайте это исправим! Попробуйте добавить категорию.'
                                    : 'Похоже вы еще ничего не добавили. Давайте это исправим! Попробуйте добавить блюдо.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: t_primary.withOpacity(0.5),
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
      );
    }

    Positioned _buildFloatingActionButton() {
      final defaultTopMargin = MediaQuery.of(context).size.height * 0.60 - 4.0;
      final startScale = 96.0;
      final endScale = startScale / 2;

      var top = defaultTopMargin;
      var scale = 1.0;

      if (_scrollController.hasClients) {
        final offset = _scrollController.offset;
        top -= offset;
        if (offset < defaultTopMargin - startScale) {
          scale = 1.0;
        } else if (offset < defaultTopMargin - endScale) {
          scale = (defaultTopMargin - endScale - offset) / endScale;
        } else {
          scale = 0.0;
        }
      }
      return Positioned(
        child: Transform.scale(
          scale: scale,
          child: FloatingActionButton(
            onPressed: () => _showCreateDialog(),
            backgroundColor: Colors.white,
            foregroundColor: Colors.red,
            child: Icon(_addressIndex == 0 ? Icons.check : Icons.add),
          ),
        ),
        top: top,
        right: 16.0,
      );
    }

    return Scaffold(
      body: Stack(
        children: <Widget>[
          CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.60,
                floating: false,
                pinned: true,
                snap: false,
                backgroundColor: c_secondary,
                leading: _addressIndex != 0 && _language != null
                    ? Padding(
                        padding: const EdgeInsets.only(left: 20.0),
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
                flexibleSpace: FlexibleSpaceBar(
                  background: _setHeaderContent(),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  <Widget>[
                    _setHomePage(),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.20),
                  ],
                ),
              )
            ],
          ),
          _addressIndex != 0 ? _buildFloatingActionButton() : SizedBox(),
          _isUploading == true
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black54,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SpinKitWave(
                        color: Colors.white,
                        size: 50.0,
                      ),
                      Text(
                        'Вносим изменения',
                        style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }

  _setCategory(String category) => setState(() => _category = category);

  _onSelected(int index) => setState(() => _selectedIndex = index);
}
