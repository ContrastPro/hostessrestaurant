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
  bool _isClicked = false;
  bool _globalSearch;
  String _imageUrl;
  File _imageFile;
  Item _selectedLanguage;
  List _subLanguages = [];
  Profile profile = Profile();
  ScrollController _scrollController;

  @override
  void initState() {
    ProfileNotifier profileNotifier =
        Provider.of<ProfileNotifier>(context, listen: false);
    _imageUrl = profileNotifier.profileList[0].image;
    _subLanguages.addAll(profileNotifier.profileList[0].subLanguages);
    _globalSearch = profileNotifier.profileList[0].globalSearch;

    profile.id = profileNotifier.profileList[0].id;
    profile.title = profileNotifier.profileList[0].title;
    profile.address = profileNotifier.profileList[0].address;
    profile.phone = profileNotifier.profileList[0].phone;
    profile.image = profileNotifier.profileList[0].image;
    profile.subTime = profileNotifier.profileList[0].subTime;
    profile.createdAt = profileNotifier.profileList[0].createdAt;

    _scrollController = ScrollController();
    _scrollController.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ProfileNotifier profileNotifier = Provider.of<ProfileNotifier>(context);
    AuthNotifier authNotifier = Provider.of<AuthNotifier>(context);

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

    Future<List<String>> _createSearchKey(String key) async {
      List<String> indexList = [];
      List<String> splitList = key.split(" ");

      for (int i = 0; i < splitList.length; i++) {
        for (int y = 1; y < splitList[i].length + 1; y++) {
          indexList.add(splitList[i].substring(0, y).toLowerCase());
        }
      }
      return indexList;
    }

    _editProfile() async {
      bool imageExist;
      profile.image != null ? imageExist = true : imageExist = false;
      profile.subLanguages = _subLanguages;
      profile.globalSearch = _globalSearch;
      await editAddress(
        profile,
        authNotifier.user.uid,
        imageExist,
        _imageFile,
      );
      setState(() => _isUploading = !_isUploading);
    }

    _addToGlobalSearch() async {
      GlobalProfile globalProfile = GlobalProfile();
      globalProfile.id = authNotifier.user.uid + "#" + profile.id;
      if (_globalSearch == true) {
        globalProfile.title = profile.title;
        globalProfile.address = profile.address;
        globalProfile.subSearchKey = await _createSearchKey(profile.title);
        await addToGlobalSearch(globalProfile);
        _editProfile();
      } else {
        await deleteFromGlobalSearch(globalProfile);
        _editProfile();
      }
    }

    _setImageHigh() {
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

    Widget _setTime() {
      DateTime date = DateTime.now();
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.access_time,
            color: Colors.white,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              profileNotifier.profileList[0].subTime[date.weekday - 1],
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      );
    }

    Widget _setBasicOptions() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Основные настройки',
            style: TextStyle(
              fontSize: 20,
              color: t_primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 32),
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
          TextFormField(
            enabled: false,
            decoration: InputDecoration(
              labelText: 'Адрес',
              prefixIcon: Icon(Icons.restaurant),
            ),
            maxLength: 50,
            maxLines: 1,
            initialValue: profile.address,
            keyboardType: TextInputType.text,
            style: TextStyle(fontSize: 20, color: t_primary),
          ),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Номер телефона',
              prefixIcon: Icon(Icons.phone),
            ),
            maxLength: 50,
            maxLines: 1,
            initialValue: profile.phone,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.deny(' '),
              FilteringTextInputFormatter.allow(RegExp('[+0-9]'))
            ],
            style: TextStyle(fontSize: 20, color: t_primary),
            onChanged: (String value) {
              profile.phone = value;
            },
          ),
        ],
      );
    }

    Widget _timeItem(String day, int index) {
      return TextFormField(
        decoration: InputDecoration(labelText: day),
        maxLength: 13,
        maxLines: 1,
        initialValue: profile.subTime[index],
        keyboardType: TextInputType.datetime,
        style: TextStyle(fontSize: 18, color: t_primary),
        onChanged: (String value) {
          profile.subTime[index] = value;
        },
      );
    }

    Widget _setTimeList() {
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
          Text(
            'Время работы вашего заведения',
            style: TextStyle(
              fontSize: 16,
              color: t_primary,
              fontWeight: FontWeight.normal,
            ),
          ),
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            crossAxisCount: 2,
            childAspectRatio: 1.8,
            padding: const EdgeInsets.only(top: 16),
            children: <Widget>[
              _timeItem('Понедельник', 0),
              _timeItem('Вторник', 1),
              _timeItem('Среда', 2),
              _timeItem('Четверг', 3),
              _timeItem('Пятница', 4),
              _timeItem('Суббота', 5),
              _timeItem('Воскресенье', 6),
            ],
          ),
        ],
      );
    }

    Widget _setLanguage() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                              'assets/languages/${_subLanguages[index]}.png'),
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
                onPressed: () => setState(() => _isClicked = !_isClicked),
                child: Icon(_isClicked ? Icons.expand_less : Icons.add),
                foregroundColor: Colors.white,
              ),
            ],
          ),
          AnimatedContainer(
            duration: Duration(seconds: 1),
            curve: Curves.fastOutSlowIn,
            height: _isClicked ? 50.0 : 0.0,
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
                    if (!_subLanguages.contains(value.language)) {
                      if (_selectedLanguage != null) {
                        _subLanguages.removeLast();
                      }
                      setState(() {
                        _selectedLanguage = value;
                        _subLanguages.add(_selectedLanguage.language);
                      });
                    }
                  },
                  items: languages.map((Item lang) {
                    return DropdownMenuItem<Item>(
                      value: lang,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                child: Image.asset(
                                    'assets/languages/${lang.icon}'),
                              ),
                              SizedBox(width: 15),
                              Text(
                                lang.title,
                                style:
                                    TextStyle(color: t_primary, fontSize: 18),
                              ),
                            ],
                          ),
                          _subLanguages.contains(lang.language)
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
        ],
      );
    }

    Widget _setGlobalSearch() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Глобальный поиск',
            style: TextStyle(
              fontSize: 20,
              color: t_primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Ваше заведение смогут найти по названию',
            style: TextStyle(
              fontSize: 16,
              color: t_primary,
              fontWeight: FontWeight.normal,
            ),
          ),
          SizedBox(height: 16),
          CheckboxListTile(
            contentPadding: EdgeInsets.all(0),
            title: const Text('Отображать в глобальном поиске'),
            value: _globalSearch,
            onChanged: (bool value) {
              setState(() => _globalSearch = !_globalSearch);
              _addToGlobalSearch();
              setState(() => _isUploading = !_isUploading);
            },
          ),
        ],
      );
    }

    Widget _setHeaderContent() {
      return Stack(
        children: [
          _setImageHigh(),
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
                  SizedBox(height: 35),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          profile.address,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ],
                  ),
                  profile.phone.isNotEmpty
                      ? Column(
                          children: [
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.phone,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    profile.phone,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : SizedBox(),
                  SizedBox(height: 20),
                  _setTime(),
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _setBasicOptions(),
          SizedBox(height: 32),
          _setTimeList(),
          SizedBox(height: 32),
          _setLanguage(),
          SizedBox(height: 32),
          _setGlobalSearch(),
          SizedBox(height: 62),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  signOut(authNotifier);
                  Navigator.pop(context);
                },
                color: Colors.red[900],
                textColor: Colors.white,
                child: const Text('Выйти из аккаунта'),
              ),
            ],
          ),
          SizedBox(height: 82),
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
            onPressed: () async {
              setState(() => _isUploading = !_isUploading);
              await _editProfile();
              Navigator.pop(context);
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
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5.0),
                    child: RawMaterialButton(
                      elevation: 0,
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(
                              text: "${authNotifier.user.uid}#${profile.id}"),
                        );
                      },
                      fillColor: c_secondary.withOpacity(0.9),
                      child: Icon(
                        Icons.share,
                        color: Colors.white,
                      ),
                      shape: CircleBorder(),
                    ),
                  ),
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
