import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:hostessrestaurant/global/colors.dart';
import 'package:hostessrestaurant/notifier/profile_notifier.dart';
import 'package:provider/provider.dart';

class ImagesGallery extends StatefulWidget {
  final String uid;
  final String address;

  ImagesGallery({Key key, @required this.uid, this.address}) : super(key: key);

  @override
  _ImagesGalleryState createState() => _ImagesGalleryState();
}

class _ImagesGalleryState extends State<ImagesGallery> {
  int _selectedIndex;
  String _selectedCategory;

  @override
  Widget build(BuildContext context) {
    ProfileNotifier profileNotifier = Provider.of<ProfileNotifier>(context);

    Widget _chipItem(int index, DocumentSnapshot document) {
      return FilterChip(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        label: Text(
          document["title"],
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
          setState(() => _selectedCategory = document["title"]);
        },
      );
    }

    Widget _setCategory() {
      return StreamBuilder(
        stream: Firestore.instance
            .collection('Database')

            /// Users or Public_Catering
            .document('Public_Catering')
            .collection(widget.uid)
            .document(widget.address)
            .collection(profileNotifier.profileList[0].subLanguages[0])
            .document('Categories')
            .collection('Menu')
            .orderBy('createdAt', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.hasData) {
            return Container(
              color: c_background,
              child: Container(
                height: 80,
                margin: EdgeInsets.only(top: 10),
                child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.all(5.0),
                        child: _chipItem(index, snapshot.data.documents[index]),
                      );
                    }),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: Center(child: CircularProgressIndicator(strokeWidth: 6)),
          );
        },
      );
    }

    Widget _menuItem(DocumentSnapshot document) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Container(
          height: 100,
          child: InkWell(
            onTap: () {
              Navigator.pop(
                  context, "${document['imageHigh']}#${document['imageLow']}");
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
                    child: document['imageLow'] != null
                        ? CachedNetworkImage(
                            imageUrl: document['imageLow'],
                            fit: BoxFit.cover,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) => Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: CircularProgressIndicator(
                                  value: downloadProgress.progress,
                                  backgroundColor: c_background),
                            ),
                            errorWidget: (context, url, error) => Image.asset(
                                'assets/placeholder_200.png',
                                fit: BoxFit.cover),
                          )
                        : Image.asset('assets/placeholder_200.png',
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
                          document['title'],
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
                          document['description'],
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
              ],
            ),
          ),
        ),
      );
    }

    Widget _setMenu() {
      return _selectedCategory != null
          ? StreamBuilder(
              stream: Firestore.instance
                  .collection('Database')

                  /// Users or Public_Catering
                  .document('Public_Catering')
                  .collection(widget.uid)
                  .document(widget.address)
                  .collection(profileNotifier.profileList[0].subLanguages[0])
                  .document('Menu')
                  .collection(_selectedCategory)
                  .orderBy('createdAt', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Something went wrong'));
                }

                if (snapshot.hasData) {
                  return ListView.builder(
                    padding: EdgeInsets.only(
                      left: 25.0,
                      top: 0.0,
                      right: 30.0,
                      bottom: 20.0,
                    ),
                    itemCount: snapshot.data.documents.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return _menuItem(snapshot.data.documents[index]);
                    },
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 100.0),
                  child:
                      Center(child: CircularProgressIndicator(strokeWidth: 6)),
                );
              },
            )
          : Column(
              children: [
                Container(
                  width: 200,
                  height: 200,
                  child: FlareActor(
                    "assets/rive/search_button.flr",
                    alignment: Alignment.center,
                    fit: BoxFit.contain,
                    animation: "open",
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    'Выберите категорию',
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
                  padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                  child: Text(
                    'Чтобы добавить существующее изображение, сначало выберите нужную категорию, а затем блюдо',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: t_primary.withOpacity(0.5),
                      fontSize: 18.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: c_secondary,
        title: Text('Выбор изображения...'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [SizedBox(height: 100), _setMenu()],
            ),
          ),
          _setCategory(),
        ],
      ),
    );
  }

  _onSelected(int index) => setState(() => _selectedIndex = index);
}
