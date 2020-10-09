import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  TextEditingController _subPortionController;
  TextEditingController _subPriceController;
  ScrollController _scrollController;

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

    _subPortionController = TextEditingController();
    _subPriceController = TextEditingController();
    _scrollController = ScrollController();
    _scrollController.addListener(() => setState(() {}));
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

  _addSubPrice(String portion, String price) {
    if (portion.isNotEmpty && price.isNotEmpty) {
      setState(() {
        _subPrice.add("$portion#$price");
      });
      _subPortionController.clear();
      _subPriceController.clear();
    }
  }

  _addFood() {
    _currentFood.subPrice = _subPrice;

    if (_currentFood.subPrice.isNotEmpty) {
      if (_currentFood.title.isNotEmpty) {
        if (_currentFood.description == null || _currentFood.description.isEmpty) {
          _currentFood.description = _currentFood.title;
        }
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
        if (_currentFood.description == null || _currentFood.description.isEmpty) {
          _currentFood.description = _currentFood.title;
        }
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
          height: double.infinity,
        );
      } else if (_imageFileHigh != null) {
        return Image.file(
          _imageFileHigh,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      } else if (_imageUrlHigh != null) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: c_background,
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
        onChanged: (String value) {
          _currentFood.description = value;
        },
      );
    }

    Widget _buildPriceField() {
      return Row(
        children: [
          Expanded(
            child: TextField(
              controller: _subPortionController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'Порция',
                helperText: 'Пример: 170/50g или 250ml',
              ),
              style: TextStyle(fontSize: 20),
            ),
          ),
          SizedBox(width: 5),
          Expanded(
            child: TextField(
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9]'))
              ],
              controller: _subPriceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Цена',
                helperText: 'Пример: 125 или 60',
                suffixIcon: IconButton(
                  onPressed: () {
                    _addSubPrice(
                        _subPortionController.text, _subPriceController.text);
                  },
                  icon: Icon(Icons.add, color: c_primary),
                ),
              ),
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
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
              backgroundColor: Colors.deepOrange[900],
              elevation: 0,
              label: Text(
                price,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
              deleteIcon: Icon(
                Icons.cancel,
                color: Colors.white,
              ),
              onDeleted: () {
                setState(() {
                  _subPrice.remove(price);
                });
                /*_subPortionController.clear();
                _subPriceController.clear();*/
              },
            ),
          ),
        );
      });
      return choices;
    }

    Widget _setHeaderContent() {
      return Stack(
        children: [
          _showImageHigh(),
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
        ],
      );
    }

    Widget _setHomePage() {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 35.0),
        child: Column(children: <Widget>[
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              isUpdating != true ? "Добавить блюдо" : "Редактировать блюдо",
              style: TextStyle(
                color: t_primary,
                fontSize: 25.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: 30),
          _showImageLow(),
          SizedBox(height: 16),
          _buildNameField(),
          SizedBox(height: 16),
          _buildCategoryField(),
          SizedBox(height: 16),
          _buildPriceField(),
          SizedBox(height: 20),
          _subPrice.isNotEmpty
              ? Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Важно! Знак \"#\" добавляеться автоматически. Это нормально",
                    style: TextStyle(
                      color: t_primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : SizedBox(),
          SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(children: _buildListPrice()),
          ),
          SizedBox(height: 100),
        ]),
      );
    }

    Positioned _buildFloatingActionButton() {
      final defaultTopMargin = MediaQuery.of(context).size.height * 0.80 - 4.0;
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
            onPressed: () {
              isUpdating != true ? _addFood() : _editFood();
            },
            backgroundColor: Colors.white,
            foregroundColor: Colors.red,
            child: Icon(Icons.save),
          ),
        ),
        top: top,
        right: 16.0,
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.80,
                floating: false,
                pinned: true,
                snap: false,
                leading: Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.0),
                  child: RawMaterialButton(
                    elevation: 0,
                    onPressed: () => Navigator.pop(context),
                    fillColor: c_secondary.withOpacity(0.5),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    shape: CircleBorder(),
                  ),
                ),
                actions: [
                  isUpdating == true
                      ? Padding(
                          padding: EdgeInsets.symmetric(vertical: 5.0),
                          child: RawMaterialButton(
                            elevation: 0,
                            onPressed: () => _showDeleteDialog(),
                            fillColor: Colors.red[900],
                            child: Icon(
                              Icons.delete_forever,
                              color: Colors.white,
                            ),
                            shape: CircleBorder(),
                          ),
                        )
                      : SizedBox(),
                ],
                backgroundColor: c_secondary,
                flexibleSpace: FlexibleSpaceBar(
                  background: _setHeaderContent(),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  <Widget>[
                    _setHomePage(),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                  ],
                ),
              )
            ],
          ),
          _buildFloatingActionButton(),
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
}
