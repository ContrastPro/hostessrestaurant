import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hostessrestaurant/api/categories_api.dart';
import 'package:hostessrestaurant/api/food_api.dart';
import 'package:hostessrestaurant/api/profile_api.dart';
import 'package:hostessrestaurant/global/colors.dart';
import 'package:hostessrestaurant/models/categories.dart';
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
  String _uid;
  String _addressId;
  String _category;
  int _selectedIndex = 0;
  Categories _categories;
  TextEditingController _categoryController = TextEditingController();

  @override
  void initState() {
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    setState(() => _uid = authNotifier.user.uid);

    ProfileNotifier profileNotifier =
        Provider.of<ProfileNotifier>(context, listen: false);
    getProfile(profileNotifier, _uid, _addressId);

    _categories = Categories();
    super.initState();
  }

  _setCategory(String category) {
    setState(() => _category = category);
  }

  _onSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  _saveCategory(String categoryText) {
    addCategory(
        _categories, _onCategoryUploaded, _uid, _addressId, categoryText);
  }

  _onCategoryUploaded(Categories categories) {
    CategoriesNotifier categoriesNotifier =
        Provider.of<CategoriesNotifier>(context, listen: false);
    getCategories(categoriesNotifier, _uid, _addressId);
    Navigator.pop(context);
  }

  _addCategoryDialog() {
    Widget okButton = FlatButton(
      child: Text("Создать"),
      onPressed: () => {
        if (_categoryController.text.trim().length > 1)
          {_saveCategory(_categoryController.text.trim())}
      },
    );
    Widget cancelButton = FlatButton(
      child: Text("Отмена"),
      onPressed: () => Navigator.pop(context),
    );
    AlertDialog alert = AlertDialog(
      title: Text('Введите новую категорию'),
      content: TextField(
        controller: _categoryController,
        maxLength: 50,
        maxLines: 1,
        keyboardType: TextInputType.text,
        style: TextStyle(fontSize: 20, color: t_primary),
        decoration: InputDecoration(labelText: 'Название'),
      ),
      actions: [cancelButton, okButton],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _deleteCategory(int index) {
    deleteCategory(_categories, _onCategoryDelete, _uid, _addressId, _category);
  }

  _onCategoryDelete(Categories categories) {
    CategoriesNotifier categoriesNotifier =
        Provider.of<CategoriesNotifier>(context, listen: false);
    getCategories(categoriesNotifier, _uid, _addressId);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    AuthNotifier authNotifier = Provider.of<AuthNotifier>(context);
    ProfileNotifier profileNotifier = Provider.of<ProfileNotifier>(context);
    CategoriesNotifier categoriesNotifier =
        Provider.of<CategoriesNotifier>(context);
    FoodNotifier foodNotifier = Provider.of<FoodNotifier>(context);

    Future<void> _refreshList(String category) async {
      getFoods(foodNotifier, _uid, _addressId, category);
    }

    _showCreateDialog() {
      Widget okButton = FlatButton(
        child: Text("Категорию"),
        onPressed: () {
          Navigator.pop(context);
          _addCategoryDialog();
        },
      );
      Widget cancelButton = FlatButton(
        child: Text("Блюдо"),
        onPressed: () async {
          Navigator.pop(context);
          if (_selectedIndex == 0) {
            _setCategory(categoriesNotifier.categoriesList[0].title);
          }
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FoodForm(
                isUpdating: false,
                restaurant: _uid,
                address: _addressId,
                category: _category,
              ),
            ),
          );
          _refreshList(categoriesNotifier.categoriesList[_selectedIndex].title);
        },
      );
      AlertDialog alert = AlertDialog(
        title: Text('Что бы вы хотели добавить?'),
        actions: [
          okButton,
          categoriesNotifier.categoriesList.isNotEmpty
              ? cancelButton
              : SizedBox()
        ],
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }

    _showDeleteDialog(int index) {
      Widget okButton = FlatButton(
        child: Text("Удалить"),
        onPressed: () {
          setState(
              () => _categories = categoriesNotifier.categoriesList[index]);
          _deleteCategory(index);
        },
      );
      AlertDialog alert = AlertDialog(
        title: Text('Внимание!'),
        content: Text(
            'Все блюда в этой категории будут автоматически удалены без возможности востановления'),
        actions: [okButton],
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }

    Widget _chip(int index) {
      return GestureDetector(
        onLongPress: () => _showDeleteDialog(index),
        child: FilterChip(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
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
          elevation: 0.0,
          pressElevation: 0.0,
          onSelected: (bool value) {
            _onSelected(index);
            if (_selectedIndex != 0) {
              _refreshList(categoriesNotifier.categoriesList[index].title);
              _setCategory(categoriesNotifier.categoriesList[index].title);
            }
          },
        ),
      );
    }

    Widget _price(subPrice) {
      List<String> splitRes = subPrice.split('#');
      String splitPrice = splitRes[1];
      return Text(
        splitPrice,
        style: TextStyle(
          color: t_primary,
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
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
                          restaurant: _uid,
                          address: _addressId,
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
                              : Image.asset('assets/placeholder_1024.png',
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
                            _price(foodNotifier.foodList[index].subPrice[0]),
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
              height: MediaQuery.of(context).size.height * 0.30,
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
                                  strokeWidth: 10,
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
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 10, bottom: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              authNotifier.user.displayName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            profileNotifier.profileList.isNotEmpty
                                ? Text(
                                    profileNotifier.profileList[0].address,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  )
                                : SizedBox(),
                          ],
                        ),
                        IconButton(
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
                      ],
                    ),
                  )
                ],
              ),
            )
          : Container(
              width: double.infinity,
              height: 100,
              color: c_primary,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 20.0),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        authNotifier.user.displayName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Выберите адрес',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                          fontWeight: FontWeight.normal,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
    }

    Widget _drawerAddresses(DocumentSnapshot document) {
      return ListTile(
        onTap: () {
          setState(() => _addressId = document.data['id']);
          getCategories(categoriesNotifier, _uid, _addressId);
          getProfile(profileNotifier, _uid, _addressId);
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

    _showAddAddress() {
      Widget okButton = FlatButton(
        child: Text("Создать"),
        onPressed: () {
          if (_categoryController.text.trim().length > 3) {
            Profile profile = Profile();
            addAddress(
              profile,
              authNotifier.user.uid,
              authNotifier.user.displayName,
              _categoryController.text.trim(),
            );
            _categoryController.clear();
            Navigator.pop(context);
          }
        },
      );
      Widget cancelButton = FlatButton(
        child: Text("Отмена"),
        onPressed: () => Navigator.pop(context),
      );
      AlertDialog alert = AlertDialog(
        title: Text('Введите новый адрес'),
        content: TextField(
          controller: _categoryController,
          maxLength: 50,
          maxLines: 1,
          keyboardType: TextInputType.text,
          style: TextStyle(fontSize: 20, color: t_primary),
          decoration: InputDecoration(labelText: 'Название'),
        ),
        actions: [cancelButton, okButton],
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }

    return Scaffold(
      backgroundColor:
          foodNotifier.foodList.isNotEmpty ? c_background : Colors.white,
      appBar: AppBar(
        backgroundColor: c_primary,
        title: Text('Меню'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            _drawerHeader(),
            StreamBuilder(
              stream: Firestore.instance.collection(_uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Something went wrong'));
                }

                if (!snapshot.hasData) {
                  return CircularProgressIndicator(strokeWidth: 10);
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
              onTap: () => _showAddAddress(),
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate(
              <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 20),
                    Container(
                      height: 80,
                      child: ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          scrollDirection: Axis.horizontal,
                          itemCount: categoriesNotifier.categoriesList.length,
                          itemBuilder: (context, index) {
                            if (_selectedIndex == 0) {
                              _refreshList(
                                  categoriesNotifier.categoriesList[0].title);
                            }
                            return Padding(
                              padding: EdgeInsets.all(5.0),
                              child: _chip(index),
                            );
                          }),
                    ),
                    foodNotifier.foodList.isNotEmpty
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
                                  categoriesNotifier.categoriesList.isEmpty
                                      ? 'Меню слишком пустое'
                                      : 'Категория пустует',
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
                                  categoriesNotifier.categoriesList.isEmpty
                                      ? 'Похоже вы еще ничего не добавили. Давайте это исправим! Попробуйте добавить категорию.'
                                      : 'Похоже вы еще ничего не добавили. Давайте это исправим! Попробуйте добавить блюдо.',
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
                ),
              ],
            ),
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Visibility(
        visible: profileNotifier.profileList.isNotEmpty && _addressId != null
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
      ),
    );
  }
}
