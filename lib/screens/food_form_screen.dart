import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hostessrestaurant/api/food_api.dart';
import 'package:hostessrestaurant/global/colors.dart';
import 'package:hostessrestaurant/model/food.dart';
import 'package:hostessrestaurant/notifier/food_notifier.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class FoodForm extends StatefulWidget {
  final bool isUpdating;
  final String restaurant;
  final String address;
  final String category;

  FoodForm({this.isUpdating, this.restaurant, this.address, this.category});

  @override
  _FoodFormState createState() => _FoodFormState(
      isUpdating: isUpdating,
      restaurant: restaurant,
      address: address,
      category: category);
}

class _FoodFormState extends State<FoodForm> {
  _FoodFormState(
      {this.isUpdating, this.restaurant, this.address, this.category});

  final bool isUpdating;
  final String restaurant;
  final String address;
  final String category;
  Food _currentFood;
  String _imageUrlHigh, _imageUrlLow;
  File _imageFileHigh, _imageFileLow;
  List _subIngredients = [];
  TextEditingController subIngredientController = TextEditingController();
  List _subPrice = [];
  TextEditingController subPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    FoodNotifier foodNotifier =
        Provider.of<FoodNotifier>(context, listen: false);

    if (isUpdating == true) {
      _currentFood = foodNotifier.currentFood;
      _imageUrlHigh = _currentFood.imageHigh;
      _imageUrlLow = _currentFood.imageLow;
      _subIngredients.addAll(_currentFood.subIngredients);
      _subPrice.addAll(_currentFood.subPrice);
    } else {
      _currentFood = Food();
    }
  }

  _showImageLow() {
    if (_imageFileLow == null && _imageUrlLow == null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Stack(
          children: [
            Image.asset(
              'assets/placeholder_200.png',
              fit: BoxFit.cover,
              width: 100,
              height: 100,
            ),
            Container(
              width: 100,
              height: 100,
              child: FlatButton(
                padding: EdgeInsets.all(16),
                color: Colors.black26,
                child: Icon(
                  Icons.camera_enhance,
                  size: 40,
                  color: Colors.white,
                ),
                onPressed: () => _getLocalImage(),
              ),
            )
          ],
        ),
      );
    } else if (_imageFileLow != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: <Widget>[
            Image.file(
              _imageFileLow,
              fit: BoxFit.cover,
              width: 100,
              height: 100,
            ),
            Container(
              width: 100,
              height: 100,
              child: FlatButton(
                padding: EdgeInsets.all(16),
                color: Colors.black26,
                child: Icon(
                  Icons.camera_enhance,
                  size: 40,
                  color: Colors.white,
                ),
                onPressed: () => _getLocalImage(),
              ),
            )
          ],
        ),
      );
    } else if (_imageUrlLow != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: <Widget>[
            Container(
              width: 100,
              height: 100,
              child: CachedNetworkImage(
                imageUrl: _imageUrlLow,
                fit: BoxFit.cover,
                progressIndicatorBuilder: (context, url, downloadProgress) {
                  return Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: CircularProgressIndicator(
                      value: downloadProgress.progress,
                    ),
                  );
                },
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            Container(
              width: 100,
              height: 100,
              child: FlatButton(
                padding: EdgeInsets.all(16),
                color: Colors.black26,
                child: Icon(
                  Icons.camera_enhance,
                  size: 40,
                  color: Colors.white,
                ),
                onPressed: () => _getLocalImage(),
              ),
            )
          ],
        ),
      );
    }
  }

  _showImageHigh() {
    if (_imageFileHigh == null && _imageUrlHigh == null) {
      return Image.asset(
        'assets/placeholder_1024.png',
        fit: BoxFit.cover,
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.80,
      );
    } else if (_imageFileHigh != null) {
      return Image.file(
        _imageFileHigh,
        fit: BoxFit.cover,
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.80,
      );
    } else if (_imageUrlHigh != null) {
      return Container(
        width: double.infinity,
        color: c_background,
        height: MediaQuery.of(context).size.height * 0.80,
        child: CachedNetworkImage(
          imageUrl: _imageUrlHigh,
          fit: BoxFit.cover,
          progressIndicatorBuilder: (context, url, downloadProgress) {
            return Center(
              child: CircularProgressIndicator(
                value: downloadProgress.progress,
                strokeWidth: 10,
              ),
            );
          },
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      );
    }
  }

  Future<void> _getLocalImage() async {
    final picker = ImagePicker();

    ///Get Image
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile.path != null) {
      setState(() {
        _imageFileHigh = File(pickedFile.path);
        _imageFileLow = File(pickedFile.path);
      });
    }

    /// Crop Image
    File croppedHigh = await ImageCropper.cropImage(
      sourcePath: _imageFileHigh.path,
      maxWidth: 735,
      maxHeight: 1102,
      compressQuality: 80,
      aspectRatioPresets: [CropAspectRatioPreset.ratio16x9],
    );

    File croppedLow = await ImageCropper.cropImage(
      sourcePath: _imageFileLow.path,
      maxWidth: 165,
      maxHeight: 165,
      compressQuality: 100,
      aspectRatioPresets: [CropAspectRatioPreset.square],
    );

    setState(() {
      _imageFileHigh = croppedHigh ?? _imageFileHigh;
      _imageFileLow = croppedLow ?? _imageFileLow;
    });
  }

  Widget _buildNameField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Название',
        prefixIcon: Icon(Icons.title),
      ),
      maxLength: 50,
      minLines: 1,
      maxLines: 3,
      initialValue: _currentFood.title,
      keyboardType: TextInputType.text,
      style: TextStyle(fontSize: 20, color: t_primary),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Название обязательно!';
        }

        if (value.length < 3) {
          return 'Слишком короткое Название';
        }

        return null;
      },
      onChanged: (String value) {
        _currentFood.title = value;
      },
    );
  }

  Widget _buildCategoryField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Описание',
        prefixIcon: Icon(Icons.subtitles),
      ),
      maxLength: 500,
      minLines: 1,
      maxLines: 5,
      initialValue: _currentFood.description,
      keyboardType: TextInputType.text,
      style: TextStyle(fontSize: 20, color: t_primary),
      validator: (String value) {
        if (value.isEmpty) {
          _currentFood.description = _currentFood.title;
        }
        return null;
      },
      onChanged: (String value) {
        _currentFood.description = value;
      },
    );
  }

  _buildIngredientField() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: TextField(
          controller: subIngredientController,
          keyboardType: TextInputType.text,
          maxLength: 30,
          decoration: InputDecoration(
            labelText: 'Ингредиенты',
            prefixIcon: Icon(Icons.line_style),
          ),
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  _buildPriceField() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: TextField(
          controller: subPriceController,
          keyboardType: TextInputType.text,
          maxLength: 30,
          decoration: InputDecoration(
            labelText: 'Порция/Цена',
            prefixIcon: Icon(Icons.attach_money),
          ),
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  _showAlertDialog(String text) {
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () => Navigator.of(context).pop(),
    );
    AlertDialog alert = AlertDialog(
      title: Text('Упс...'),
      content: Text(text),
      actions: [okButton],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _showDeleteDialog() {
    Widget okButton = FlatButton(
        child: Text("Да"),
        onPressed: () {
          deleteFood(
              _currentFood, _onFoodDeleted, restaurant, address, category);
          Navigator.of(context).pop();
        });
    Widget cancelButton = FlatButton(
      child: Text("Нет"),
      onPressed: () => Navigator.of(context).pop(),
    );
    AlertDialog alert = AlertDialog(
      title: Text('Удаление'),
      content: Text('Вы уверены что хотите удалить это блюдо?'),
      actions: [cancelButton, okButton],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _onFoodUploaded(Food food) {
    Navigator.pop(context);
  }

  _onFoodDeleted(Food food) {
    Navigator.pop(context);
  }

  _addSubIngredient(String text) {
    if (text.isNotEmpty) {
      setState(() {
        _subIngredients.add(text);
      });
      subIngredientController.clear();
    }
  }

  _addSubPrice(String text) {
    if (text.isNotEmpty) {
      setState(() {
        _subPrice.add(text);
      });
      subPriceController.clear();
    }
  }

  _addFood() {
    _currentFood.subIngredients = _subIngredients;
    _currentFood.subPrice = _subPrice;

    if (_currentFood.subPrice.isNotEmpty) {
      _currentFood.title.isNotEmpty
          ? addFood(_currentFood, _imageFileHigh, _imageFileLow,
              _onFoodUploaded, restaurant, address, category)
          : _showAlertDialog('Похоже вы забыли добавить навание блюда');
    } else {
      _showAlertDialog('Похоже вы забыли указать цену');
    }
  }

  _editFood() {
    _currentFood.subIngredients = _subIngredients;
    _currentFood.subPrice = _subPrice;

    bool imageExist;
    if (_currentFood.subPrice.isNotEmpty) {
      _currentFood.imageHigh != null ? imageExist = true : imageExist = false;
      _currentFood.title.isNotEmpty
          ? editFood(_currentFood, imageExist, _imageFileHigh, _imageFileLow,
              _onFoodUploaded, restaurant, address, category)
          : _showAlertDialog('Похоже вы забыли добавить навание блюда');
    } else {
      _showAlertDialog('Похоже вы забыли указать цену');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _showImageHigh(),
          Container(
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
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            body: DraggableScrollableSheet(
                initialChildSize: 0.55,
                maxChildSize: 0.80,
                minChildSize: 0.25,
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: c_background,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0),
                      ),
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 35.0),
                      child: Form(
                        autovalidate: true,
                        child: Column(children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              isUpdating != true
                                  ? "Добавить блюдо"
                                  : "Редактировать блюдо",
                              style: TextStyle(
                                color: t_primary,
                                fontSize: 25.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          _showImageLow(),
                          SizedBox(height: 10),
                          _buildNameField(),
                          _buildCategoryField(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              _buildPriceField(),
                              FloatingActionButton(
                                heroTag: 'price',
                                backgroundColor: c_primary,
                                elevation: 0,
                                highlightElevation: 0,
                                mini: true,
                                onPressed: () =>
                                    _addSubPrice(subPriceController.text),
                                child: Icon(Icons.add),
                                foregroundColor: Colors.white,
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(children: _buildListPrice()),
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              _buildIngredientField(),
                              FloatingActionButton(
                                heroTag: 'ingredients',
                                backgroundColor: c_primary,
                                elevation: 0,
                                highlightElevation: 0,
                                mini: true,
                                onPressed: () => _addSubIngredient(
                                    subIngredientController.text),
                                child: Icon(Icons.add),
                                foregroundColor: Colors.white,
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(children: _buildListIngredients()),
                          ),
                          SizedBox(height: 100),
                        ]),
                      ),
                    ),
                  );
                }),
          ),
          SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: RawMaterialButton(
                    onPressed: () => Navigator.pop(context),
                    fillColor: c_secondary.withOpacity(0.5),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(13.0),
                    shape: CircleBorder(),
                  ),
                ),
                isUpdating == true
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: RawMaterialButton(
                          onPressed: () => _showDeleteDialog(),
                          fillColor: Colors.red[900],
                          child: Icon(
                            Icons.delete_forever,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.all(13.0),
                          shape: CircleBorder(),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: c_secondary,
        onPressed: () {
          isUpdating != true ? _addFood() : _editFood();
        },
        icon: Icon(isUpdating != true ? Icons.create : Icons.save),
        label: Text(
          isUpdating != true ? "ОПУБЛИКОВАТЬ" : 'СОХРАНИТЬ',
          style: TextStyle(color: Colors.white),
        ),
        foregroundColor: Colors.white,
      ),
    );
  }

  _buildListIngredients() {
    List<Widget> choices = List();

    _subIngredients.forEach((ingredient) {
      choices.add(
        Container(
          margin: const EdgeInsets.symmetric(vertical: 1.0),
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Chip(
            backgroundColor: c_primary.withOpacity(0.2),
            elevation: 0,
            label: Text(
              ingredient,
              style: TextStyle(
                fontSize: 16,
                color: t_primary,
                fontWeight: FontWeight.w400,
              ),
            ),
            deleteIcon: Icon(
              Icons.cancel,
              color: Colors.red[900],
            ),
            onDeleted: () {
              setState(() {
                _subIngredients.remove(ingredient);
              });
              subIngredientController.clear();
            },
          ),
        ),
      );
    });
    return choices;
  }

  _buildListPrice() {
    List<Widget> choices = List();

    _subPrice.forEach((price) {
      choices.add(
        Container(
          margin: const EdgeInsets.symmetric(vertical: 1.0),
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Chip(
            backgroundColor: c_primary.withOpacity(0.2),
            elevation: 0,
            label: Text(
              price,
              style: TextStyle(
                fontSize: 16,
                color: t_primary,
                fontWeight: FontWeight.w400,
              ),
            ),
            deleteIcon: Icon(
              Icons.cancel,
              color: Colors.red[900],
            ),
            onDeleted: () {
              setState(() {
                _subPrice.remove(price);
              });
              subPriceController.clear();
            },
          ),
        ),
      );
    });
    return choices;
  }
}
