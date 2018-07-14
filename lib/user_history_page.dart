import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'employment_history_page.dart';
import 'user_rating_page.dart';
import 'loading_screen.dart';
import 'view_devices.dart';
import 'profile_header.dart';
import 'quick_actions.dart';
import 'constants.dart';
import 'edit_device.dart';
import 'edit_role.dart';
import 'edit_user.dart';

class UserHistoryPage extends StatefulWidget {
  final int colorIndex;
  final String userDocumentID;
  final bool canRateUser;

  const UserHistoryPage({
    @required this.colorIndex,
    @required this.userDocumentID,
    @required this.canRateUser,
  }) : assert(colorIndex != null),
        assert(userDocumentID != null),
        assert(canRateUser != null);

  @override
  _UserHistoryPageState createState() => _UserHistoryPageState();
}

class _UserHistoryPageState extends State<UserHistoryPage> {

  /// This controller can be used to programmatically
  /// set the current displayed page
  PageController _pageController;

  /// Indicating the current displayed page
  int _page = 0;

  Color getColor(int idx) {
    final iconColor = Color(0xEFCCCCCD);
    if (_page == idx) {
      return TodoColors.baseColors[0];
    } else {
      return iconColor;
    }
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  /// Called when the user presses on of the
  /// [BottomNavigationBarItem] with corresponding
  /// page index
  void navigationTapped(int page) {
    // Animating to the page.
    // You can use whatever duration and curve you like
    _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease
    );
  }


  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    final navigationItems = <BottomNavigationBarItem>[];
    final items = <Widget>[];
      navigationItems.add(
        new BottomNavigationBarItem(
          icon: new Icon(Icons.work, color: getColor(0),),
          title: new Text("Employment\nHistory",)),
      );
      items.add(new EmploymentHistoryPage(colorIndex: widget.colorIndex, isMadeByYou: false, noButton: true, documentID: document.documentID,));
      if(widget.canRateUser) {
        navigationItems.add(new BottomNavigationBarItem(
            icon: new Icon(Icons.stars, color: getColor(1)),
            title: new Text("Rate\nUser",)),
        );
        items.add(new UserRatingPage(colorIndex: widget.colorIndex, document: document,));
      }
      navigationItems.add(
      new BottomNavigationBarItem(
          icon: new Icon(Icons.devices, color: getColor(widget.canRateUser?2:1),),
          title: new Text("User\nDevices",)
      ),
      );
      items.add(new ViewDevicesPage(colorIndex: widget.colorIndex, documentID: document.documentID, folder: 'userDevices',));



    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      body: new PageView(
          children: items,
          controller: _pageController,
          onPageChanged: onPageChanged
      ),
      bottomNavigationBar: new BottomNavigationBar(
        currentIndex: _page,
        items: navigationItems,
        onTap: navigationTapped,
        fixedColor: TodoColors.primaryLight,
        iconSize: 25.0,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = new PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return new StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('users').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return new Center(
                child: new BarLoadingScreen(),
            );
          } else {
            DocumentSnapshot document = snapshot.data.documents.where((doc){
              return doc.documentID == widget.userDocumentID;}).first;


            final converter = _buildListItem(
                context, document);

            return OrientationBuilder(
              builder: (BuildContext context, Orientation orientation) {
                if (orientation == Orientation.portrait) {
                  return converter;
                } else {
                  return Center(
                    child: Container(
                      width: 450.0,
                      child: converter,
                    ),
                  );
                }
              },
            );
          }
        });
  }
}

