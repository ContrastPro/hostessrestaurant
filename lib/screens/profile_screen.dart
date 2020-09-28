import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hostessrestaurant/api/login_api.dart';
import 'package:hostessrestaurant/api/profile_api.dart';
import 'package:hostessrestaurant/global/colors.dart';
import 'package:hostessrestaurant/models/languages.dart';
import 'package:hostessrestaurant/models/profile.dart';
import 'package:hostessrestaurant/notifier/auth_notifier.dart';
import 'package:hostessrestaurant/notifier/profile_notifier.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUploading = false;
  bool isClicked = false;
  String _imageUrl;
  File _imageFile;
  Profile profile = Profile();
  Item _selectedLanguage;
  List _subLanguages = [];

  @override
  void initState() {
    ProfileNotifier profileNotifier =
        Provider.of<ProfileNotifier>(context, listen: false);
    _imageUrl = profileNotifier.profileList[0].image;
    _subLanguages.addAll(profileNotifier.profileList[0].subLanguages);

    profile.id = profileNotifier.profileList[0].id;
    profile.image = profileNotifier.profileList[0].image;
    profile.title = profileNotifier.profileList[0].title;
    profile.address = profileNotifier.profileList[0].address;
    profile.subTime = profileNotifier.profileList[0].subTime;
    profile.createdAt = profileNotifier.profileList[0].createdAt;
    super.initState();
  }

  _showImageHigh() {
    if (_imageFile == null && _imageUrl == null) {
      return Image.asset(
        'assets/login.jpg',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (_imageFile != null) {
      return Image.file(
        _imageFile,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (_imageUrl != null) {
      return Container(
        width: double.infinity,
        color: c_background,
        height: double.infinity,
        child: CachedNetworkImage(
          imageUrl: _imageUrl,
          fit: BoxFit.cover,
          progressIndicatorBuilder: (context, url, downloadProgress) {
            return Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Align(
                alignment: Alignment.centerRight,
                child: CircularProgressIndicator(
                  value: downloadProgress.progress,
                  strokeWidth: 10,
                ),
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
      setState(() => _imageFile = File(pickedFile.path));
    }

    /// Crop Image
    File croppedHigh = await ImageCropper.cropImage(
      sourcePath: _imageFile.path,
      maxWidth: 735,
      maxHeight: 1102,
      compressQuality: 80,
      aspectRatioPresets: [CropAspectRatioPreset.ratio16x9],
    );

    setState(() => _imageFile = croppedHigh ?? _imageFile);
  }

  @override
  Widget build(BuildContext context) {
    ProfileNotifier profileNotifier = Provider.of<ProfileNotifier>(context);
    AuthNotifier authNotifier = Provider.of<AuthNotifier>(context);

    Widget _timePicker() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Время работы',
            style: TextStyle(
              fontSize: 20,
              color: t_primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'Понедельник'),
                  maxLength: 13,
                  maxLines: 1,
                  initialValue: profile.subTime[0],
                  keyboardType: TextInputType.datetime,
                  style: TextStyle(fontSize: 18, color: t_primary),
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Название обязательно!';
                    }

                    if (value.length < 13) {
                      return 'Неверный формат';
                    }

                    return null;
                  },
                  onChanged: (String value) {
                    profile.subTime[0] = value;
                  },
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'Вторник'),
                  maxLength: 13,
                  maxLines: 1,
                  initialValue: profile.subTime[1],
                  keyboardType: TextInputType.datetime,
                  style: TextStyle(fontSize: 18, color: t_primary),
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Название обязательно!';
                    }

                    if (value.length < 13) {
                      return 'Неверный формат';
                    }

                    return null;
                  },
                  onChanged: (String value) {
                    profile.subTime[1] = value;
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'Среда'),
                  maxLength: 13,
                  maxLines: 1,
                  initialValue: profile.subTime[2],
                  keyboardType: TextInputType.datetime,
                  style: TextStyle(fontSize: 18, color: t_primary),
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Название обязательно!';
                    }

                    if (value.length < 13) {
                      return 'Неверный формат';
                    }

                    return null;
                  },
                  onChanged: (String value) {
                    profile.subTime[2] = value;
                  },
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'Четверг'),
                  maxLength: 13,
                  maxLines: 1,
                  initialValue: profile.subTime[3],
                  keyboardType: TextInputType.datetime,
                  style: TextStyle(fontSize: 18, color: t_primary),
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Название обязательно!';
                    }

                    if (value.length < 13) {
                      return 'Неверный формат';
                    }

                    return null;
                  },
                  onChanged: (String value) {
                    profile.subTime[3] = value;
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'Пятница'),
                  maxLength: 13,
                  maxLines: 1,
                  initialValue: profile.subTime[4],
                  keyboardType: TextInputType.datetime,
                  style: TextStyle(fontSize: 18, color: t_primary),
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Название обязательно!';
                    }

                    if (value.length < 13) {
                      return 'Неверный формат';
                    }

                    return null;
                  },
                  onChanged: (String value) {
                    profile.subTime[4] = value;
                  },
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'Суббота'),
                  maxLength: 13,
                  maxLines: 1,
                  initialValue: profile.subTime[5],
                  keyboardType: TextInputType.datetime,
                  style: TextStyle(fontSize: 18, color: t_primary),
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Название обязательно!';
                    }

                    if (value.length < 13) {
                      return 'Неверный формат';
                    }

                    return null;
                  },
                  onChanged: (String value) {
                    profile.subTime[5] = value;
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'Воскресенье'),
                  maxLength: 13,
                  maxLines: 1,
                  initialValue: profile.subTime[6],
                  keyboardType: TextInputType.datetime,
                  style: TextStyle(fontSize: 18, color: t_primary),
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Название обязательно!';
                    }

                    if (value.length < 13) {
                      return 'Неверный формат';
                    }

                    return null;
                  },
                  onChanged: (String value) {
                    profile.subTime[6] = value;
                  },
                ),
              ),
              Expanded(
                  child: Container(
                width: double.infinity,
              )),
            ],
          ),
        ],
      );
    }

    Widget _time() {
      DateTime date = DateTime.now();
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.access_time,
            color: Colors.white,
            size: 18.0,
          ),
          SizedBox(width: 10),
          Text(
            profileNotifier.profileList[0].subTime[date.weekday - 1],
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      );
    }

    Widget _buildAddressField() {
      return TextFormField(
        decoration: InputDecoration(
          labelText: 'Адрес',
          prefixIcon: Icon(Icons.restaurant),
        ),
        maxLength: 50,
        maxLines: 1,
        initialValue: profile.address,
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
          profile.address = value;
        },
      );
    }

    Widget _homeScreen() {
      return Stack(
        children: <Widget>[
          _showImageHigh(),
          Container(
            width: MediaQuery.of(context).size.width * 0.55,
            height: double.infinity,
            color: c_primary,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 50.0, 10.0, 50.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '${profileNotifier.profileList[0].title}'.toUpperCase(),
                    maxLines: 3,
                    textAlign: TextAlign.left,
                    minFontSize: 25,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 50.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 20),
                  profileNotifier.profileList[0].subTime != null
                      ? _time()
                      : Container(),
                ],
              ),
            ),
          ),
          DraggableScrollableSheet(
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
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 35.0),
                    child: Form(
                      autovalidate: true,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Stack(
                                  children: [
                                    Image.asset(
                                      'assets/login.jpg',
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
                              ),
                            ),
                            SizedBox(height: 32),
                            _buildAddressField(),
                            SizedBox(height: 32),
                            _timePicker(),
                            SizedBox(height: 32),
                            Text(
                              'Настройка меню',
                              style: TextStyle(
                                fontSize: 20,
                                color: t_primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Текущие языки',
                              style: TextStyle(
                                fontSize: 16,
                                color: t_primary,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            SizedBox(height: 16),
                            Stack(
                              children: [
                                Container(
                                  height: 50,
                                  margin: EdgeInsets.only(left: 50),
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _subLanguages.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.all(5.5),
                                          child: Container(
                                            width: 45,
                                            height: 45,
                                            child: Image.asset(
                                                'assets/${_subLanguages[index]}.png'),
                                          ),
                                        );
                                      }),
                                ),
                                FloatingActionButton(
                                  heroTag: 'price',
                                  backgroundColor: c_secondary,
                                  elevation: 0,
                                  highlightElevation: 0,
                                  mini: true,
                                  onPressed: () =>
                                      setState(() => isClicked = !isClicked),
                                  child: Icon(isClicked
                                      ? Icons.expand_less
                                      : Icons.add),
                                  foregroundColor: Colors.white,
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            AnimatedContainer(
                              duration: Duration(seconds: 1),
                              curve: Curves.fastOutSlowIn,
                              height: isClicked ? 50.0 : 0.0,
                              padding: EdgeInsets.only(left: 8),
                              child: ListView(
                                padding: EdgeInsets.all(0.0),
                                physics: NeverScrollableScrollPhysics(),
                                children: [
                                  DropdownButton<Item>(
                                    isExpanded: true,
                                    hint: Text(
                                      "Дополнительный язык",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    value: _selectedLanguage,
                                    onChanged: (Item value) {
                                      if (!_subLanguages
                                          .contains(value.language)) {
                                        if (_selectedLanguage != null) {
                                          _subLanguages.removeLast();
                                        }
                                        setState(() {
                                          _selectedLanguage = value;
                                          _subLanguages
                                              .add(_selectedLanguage.language);
                                        });
                                      }
                                    },
                                    items: languages.map((Item lang) {
                                      return DropdownMenuItem<Item>(
                                        value: lang,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  width: 30,
                                                  height: 30,
                                                  child: Image.asset(
                                                      'assets/${lang.icon}'),
                                                ),
                                                SizedBox(width: 15),
                                                Text(
                                                  lang.title,
                                                  style: TextStyle(
                                                      color: t_primary,
                                                      fontSize: 18),
                                                ),
                                              ],
                                            ),
                                            _subLanguages
                                                    .contains(lang.language)
                                                ? Icon(Icons.check)
                                                : SizedBox(),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 62),
                            Center(
                              child: FlatButton(
                                onPressed: () {
                                  signOut(authNotifier);
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Выйти из аккаунта",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.redAccent),
                                ),
                              ),
                            ),
                            SizedBox(height: 62),
                          ]),
                    ),
                  ),
                );
              }),
        ],
      );
    }

    _onProfileUploaded(Profile profile) {
      Navigator.pop(context);
    }

    _editProfile() {
      bool imageExist;
      setState(() => _isUploading = !_isUploading);
      profile.image != null ? imageExist = true : imageExist = false;
      profile.subLanguages = _subLanguages;

      editAddress(
        profile,
        authNotifier.user.uid,
        imageExist,
        _imageFile,
        _onProfileUploaded,
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.transparent,
            body: _homeScreen(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: c_secondary,
              onPressed: () => _editProfile(),
              icon: Icon(Icons.save),
              label: Text(
                'СОХРАНИТЬ',
                style: TextStyle(color: Colors.white),
              ),
              foregroundColor: Colors.white,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RawMaterialButton(
                    onPressed: () => Navigator.pop(context),
                    fillColor: c_secondary.withOpacity(0.5),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(13.0),
                    shape: CircleBorder(),
                  ),
                  RawMaterialButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                          text: authNotifier.user.uid + "#" + profile.id));
                    },
                    fillColor: c_secondary.withOpacity(0.5),
                    child: Icon(
                      Icons.share,
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(13.0),
                    shape: CircleBorder(),
                  ),
                ],
              ),
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
