import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hostessrestaurant/api/categories_api.dart';
import 'package:hostessrestaurant/api/food_api.dart';
import 'package:hostessrestaurant/api/login_api.dart';
import 'package:hostessrestaurant/api/profile_api.dart';
import 'package:hostessrestaurant/global/colors.dart';
import 'package:hostessrestaurant/models/categories.dart';
import 'package:hostessrestaurant/notifier/auth_notifier.dart';
import 'package:hostessrestaurant/notifier/categories_notifier.dart';
import 'package:hostessrestaurant/notifier/food_notifier.dart';
import 'package:hostessrestaurant/notifier/profile_notifier.dart';
import 'package:hostessrestaurant/screens/food_form_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _restaurant = 'Jardin';
  String _address = 'Одесса, ул. Гаванная 10';
  String _category;
  int _selectedIndex = 0;
  Categories _categories;
  TextEditingController _categoryController = TextEditingController();

  @override
  void initState() {
    ProfileNotifier profileNotifier =
        Provider.of<ProfileNotifier>(context, listen: false);
    getProfile(profileNotifier, _restaurant, _address);

    CategoriesNotifier categoriesNotifier =
        Provider.of<CategoriesNotifier>(context, listen: false);
    getCategories(categoriesNotifier, _restaurant, _address);
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
        _categories, _onCategoryUploaded, _restaurant, _address, categoryText);
  }

  _onCategoryUploaded(Categories categories) {
    CategoriesNotifier categoriesNotifier =
        Provider.of<CategoriesNotifier>(context, listen: false);
    getCategories(categoriesNotifier, _restaurant, _address);
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
        minLines: 1,
        maxLines: 3,
        keyboardType: TextInputType.text,
        style: TextStyle(fontSize: 20, color: t_primary),
        decoration: InputDecoration(
          labelText: 'Название',
          prefixIcon: Icon(Icons.title),
        ),
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
    deleteCategory(
        _categories, _onCategoryDelete, _restaurant, _address, _category);
  }

  _onCategoryDelete(Categories categories) {
    CategoriesNotifier categoriesNotifier =
        Provider.of<CategoriesNotifier>(context, listen: false);
    getCategories(categoriesNotifier, _restaurant, _address);
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
      getFoods(foodNotifier, _restaurant, _address, category);
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
                restaurant: _restaurant,
                address: _address,
                category: _category,
              ),
            ),
          );
          _refreshList(categoriesNotifier.categoriesList[_selectedIndex].title);
        },
      );
      AlertDialog alert = AlertDialog(
        title: Text('Что бы вы хотели добавить?'),
        actions: [okButton, cancelButton],
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

    Widget _menuItem(int index) {
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
                      restaurant: _restaurant,
                      address: _address,
                      category: _category,
                    ),
                  ),
                );
                _refreshList(
                    categoriesNotifier.categoriesList[_selectedIndex].title);
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
                              imageUrl: foodNotifier.foodList[index].imageLow,
                              fit: BoxFit.cover,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) => Padding(
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
                      padding: const EdgeInsets.fromLTRB(10.0, 2.0, 5.0, 2.0),
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
    }

    Widget _drawerHeader() {
      return Container(
        width: double.infinity,
        height: 150,
        color: c_primary,
        padding: EdgeInsets.fromLTRB(16.0, 20.0, 0.0, 20.0),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: RawMaterialButton(
                onPressed: () {},
                fillColor: c_secondary.withOpacity(0.5),
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
                padding: EdgeInsets.all(10.0),
                shape: CircleBorder(),
              ),
            ),
            profileNotifier.profileList.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        profileNotifier.profileList[0].title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        profileNotifier.profileList[0].address,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  )
                : SizedBox(),
          ],
        ),
      );
    }

    Widget _drawerAddresses(DocumentSnapshot document) {
      return ListTile(
        onTap: () {},
        title: Text(document.data['address']),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: c_primary,
        title: Text(authNotifier.user.displayName),
        centerTitle: true,
        actions: <Widget>[
          // action button
          FlatButton(
            onPressed: () => signout(authNotifier),
            child: Text(
              "выйти",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            _drawerHeader(),
            StreamBuilder(
              stream: Firestore.instance.collection(_restaurant).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Something went wrong'));
                }

                if (!snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 0.0),
                    child: CircularProgressIndicator(strokeWidth: 10),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return _drawerAddresses(snapshot.data.documents[index]);
                  },
                );
              },
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
                    Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 10),
                          ),
                        ),
                        ListView.builder(
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
                            return _menuItem(index);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: c_secondary,
        elevation: 4.0,
        icon: const Icon(Icons.add),
        label: const Text(
          'ДОБАВИТЬ',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () => _showCreateDialog(),
      ),
    );
  }
}
