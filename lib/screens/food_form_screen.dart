import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hostessrestaurant/api/food_api.dart';
import 'package:hostessrestaurant/global/colors.dart';
import 'package:hostessrestaurant/models/food.dart';
import 'package:hostessrestaurant/notifier/food_notifier.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class FoodForm extends StatefulWidget {
  final bool isUpdating;
  final String uid;
  final String address;
  final String language;
  final String category;

  FoodForm(
      {this.isUpdating, this.uid, this.address, this.language, this.category});

  @override
  _FoodFormState createState() => _FoodFormState(
      isUpdating: isUpdating,
      uid: uid,
      address: address,
      language: language,
      category: category);
}

class _FoodFormState extends State<FoodForm> {
  _FoodFormState({
    this.isUpdating,
    this.uid,
    this.address,
    this.language,
    this.category,
  });

  final bool isUpdating;
  final String uid;
  final String address;
  final String language;
  final String category;

  bool _isUploading = false;
  String _imageUrlHigh, _imageUrlLow;
  File _imageFileHigh, _imageFileLow;
  List _subPrice = [];
  Food _currentFood;
  TextEditingController _subPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    FoodNotifier foodNotifier =
        Provider.of<FoodNotifier>(context, listen: false);

    if (isUpdating == true) {
      _currentFood = foodNotifier.currentFood;
      _imageUrlHigh = _currentFood.imageHigh;
      _imageUrlLow = _currentFood.imageLow;
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

  _buildPriceField() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: TextField(
          controller: _subPriceController,
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
          setState(() => _isUploading = !_isUploading);
          deleteFood(
              _currentFood, uid, address, language, category, _onFoodDeleted);
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

  _addSubPrice(String text) {
    if (text.isNotEmpty) {
      setState(() {
        _subPrice.add(text);
      });
      _subPriceController.clear();
    }
  }

  _addFood() {
    _currentFood.subPrice = _subPrice;

    if (_currentFood.subPrice.isNotEmpty) {
      if (_currentFood.title.isNotEmpty) {
        setState(() => _isUploading = !_isUploading);
        addFood(_currentFood, uid, address, language, category, _imageFileHigh,
            _imageFileLow, _onFoodUploaded);
      } else {
        _showAlertDialog('Похоже вы забыли добавить навание блюда');
      }
    } else {
      _showAlertDialog('Похоже вы забыли указать цену');
    }
  }

  _editFood() {
    _currentFood.subPrice = _subPrice;

    bool imageExist;
    if (_currentFood.subPrice.isNotEmpty) {
      _currentFood.imageHigh != null ? imageExist = true : imageExist = false;
      if (_currentFood.title.isNotEmpty) {
        setState(() => _isUploading = !_isUploading);
        editFood(_currentFood, uid, address, language, category, imageExist,
            _imageFileHigh, _imageFileLow, _onFoodUploaded);
      } else {
        _showAlertDialog('Похоже вы забыли добавить навание блюда');
      }
    } else {
      _showAlertDialog('Похоже вы забыли указать цену');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                                heroTag: UniqueKey(),
                                backgroundColor: c_primary,
                                elevation: 0,
                                highlightElevation: 0,
                                mini: true,
                                onPressed: () =>
                                    _addSubPrice(_subPriceController.text),
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
                        isUpdating != true
                            ? "Добавляем блюдо"
                            : "Вносим изменения",
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: MediaQuery.of(context).viewInsets.bottom == 0
          ? FloatingActionButton.extended(
              backgroundColor: c_secondary,
              onPressed: () {
                isUpdating != true ? _addFood() : _editFood();
              },
              icon: Icon(isUpdating != true ? Icons.create : Icons.save),
              label: Text(
                isUpdating != true ? "ОПУБЛИКОВАТЬ" : "СОХРАНИТЬ",
                style: TextStyle(color: Colors.white),
              ),
              foregroundColor: Colors.white,
            )
          : SizedBox(),
    );
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
              _subPriceController.clear();
            },
          ),
        ),
      );
    });
    return choices;
  }
}
