import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:audio_manager/audio_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:image_picker/image_picker.dart';


void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  bool isPlaying = false;
  Duration _duration;
  Duration _position;
  double _slider;
  double _sliderVolume;
  String _error;
  var date = DateTime.now();  //DateTime.now().weekday
  num curIndex = 0;
  PlayMode playMode = AudioManager.instance.playMode;
  var blueColor =Color.fromRGBO(1, 22, 39, .8);

  List distinctIds =[];

  List<String> attachments = [];
  bool isHTML = false;

  final _recipientController = TextEditingController(
    text: 'vvbnagendra@gmail.com',
  );

  final _subjectController = TextEditingController(text: 'Ideas & Suggestions');

  final _bodyController = TextEditingController(
    text: 'Mail body.',
  );

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> send() async {
    final Email email = Email(
      body: _bodyController.text,
      subject: _subjectController.text,
      recipients: [_recipientController.text],
      attachmentPaths: attachments,
      isHTML: isHTML,
    );

    String platformResponse;

    try {
      await FlutterEmailSender.send(email);
      platformResponse = 'success';
    } catch (error) {
      platformResponse = error.toString();
    }

    if (!mounted) return;

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(platformResponse),
    ));
  }


  final list = [
    {
      "title": "Vinayaka - Suklam",
      "desc": "All Weeks",
      "url": "assets/audios/suklam.mp3",
      "coverUrl": "assets/images/Vinayaka.jpg",
    },
    {
      "title": "Shiva - Bilwashtakam",
      "desc": "Monday",
      "url": "assets/audios/shiva2.mp3",
      "coverUrl": "assets/images/Shiva.jpg",
    },
    {
      "title": "Hanuma - Chalisa",
      "desc": "Tuesday",
      "url": "assets/audios/hanuma.mp3",
      "coverUrl": "assets/images/Hanuma.jpg",
    },
    {
      "title": "Vishnu - Sahasrananama",
      "desc": "Wednesday",
      "url": "assets/audios/vishnu.mp3",
      "coverUrl": "assets/images/Vishnu.jpg",
    },
    {
      "title": "Saibaba - Harathi",
      "desc": "Thursday",
      "url": "assets/audios/sai.mp3",
      "coverUrl": "assets/images/Sai Baba.jpg",
    },
    {
      "title": "Lalita Devi - Sahasrananama",
      "desc": "Friday",
      "url": "assets/audios/lalita.mp3",
      "coverUrl": "assets/images/Lakshmi Devi.jpg",
    },
    {
      "title": "Venkateswara - Suprabhatam",
      "desc": "Saturday",
      "url": "assets/audios/venkat.mp3",
      "coverUrl": "assets/images/Venkateswara.jpg",
    },
    {
      "title": "Aditya - Hrudayam",
      "desc": "Sunday",
      "url": "assets/audios/surya.mp3",
      "coverUrl": "assets/images/Surya.jpg",
    },
    {
      "title": "Krishna - Gaanam",
      "desc": "Wednesday",
      "url": "assets/audios/krishna.mp3",
      "coverUrl": "assets/images/Vishnu.jpg",
    },
    {
      "title": "network",
      "desc": "network resouce playback",
      "url": "https://raw.githubusercontent.com/vvbnagendra/sankeerthana/master/hanuma.mp3",
      "coverUrl": "https://homepages.cae.wisc.edu/~ece533/images/airplane.png"
    }
  ];


  @override
  void initState() {
    super.initState();

    initPlatformState();
    setupAudio();
    print('hello youtube by nag');
    // loadFile();
  }


  @override
  void dispose() {
    AudioManager.instance.stop();
    super.dispose();
  }

  void setupAudio() {
    List<AudioInfo> _list = [];
    list.forEach((item) => _list.add(AudioInfo(item["url"],
        title: item["title"], desc: item["desc"], coverUrl: item["coverUrl"])));

    var newList = list.map((item) => item["coverUrl"]);
    distinctIds = newList.toSet().toList();
    print("$distinctIds");
    print(DateTime.now().weekday);
    print(distinctIds[0].substring(14,distinctIds[0].indexOf('.')));

    AudioManager.instance.audioList = _list;
    AudioManager.instance.intercepter = true;
    AudioManager.instance.play(auto: false);

    AudioManager.instance.onEvents((events, args) {
      print("$events, $args");
      switch (events) {
        case AudioManagerEvents.start:
          print("start load data callback, curIndex is ${AudioManager.instance.curIndex}");
          _position = AudioManager.instance.position;
          _duration = AudioManager.instance.duration;
          _slider = 0;
          setState(() {});
          break;
        case AudioManagerEvents.ready:
          print("ready to play");
          _error = null;
          _sliderVolume = AudioManager.instance.volume;
          _position = AudioManager.instance.position;
          _duration = AudioManager.instance.duration;
          setState(() {});
          // if you need to seek times, must after AudioManagerEvents.ready event invoked
          // AudioManager.instance.seekTo(Duration(seconds: 10));
          break;
        case AudioManagerEvents.seekComplete:
          _position = AudioManager.instance.position;
          _slider = _position.inMilliseconds / _duration.inMilliseconds;
          setState(() {});
          print("seek event is completed. position is [$args]/ms");
          break;
        case AudioManagerEvents.buffering:
          print("buffering $args");
          break;
        case AudioManagerEvents.playstatus:
          isPlaying = AudioManager.instance.isPlaying;
          setState(() {});
          break;
        case AudioManagerEvents.timeupdate:
          _position = AudioManager.instance.position;
          _slider = _position.inMilliseconds / _duration.inMilliseconds;
          setState(() {});
          AudioManager.instance.updateLrc(args["position"].toString());
          break;
        case AudioManagerEvents.error:
          _error = args;
          setState(() {});
          break;
        case AudioManagerEvents.ended:
          AudioManager.instance.next();
          break;
        case AudioManagerEvents.volumeChange:
          _sliderVolume = AudioManager.instance.volume;
          setState(() {});
          break;
        default:
          break;
      }
    });
  }

  MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    strengths.forEach((strength) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    });
    return MaterialColor(color.value, swatch);
  }

  loadImage(String ImagePath,  fitVal, heightVal, widthVal){
    if ( ImagePath.substring(0, 4)  == 'http') {
      return Image.network(
        ImagePath,
        fit: fitVal, height: heightVal, width : widthVal
      );
    } else {
      return Image.asset(
        ImagePath,
          fit: fitVal, height: heightVal, width : widthVal
      );
    }
  }

  void loadFile() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    // Please make sure the `test.mp3` exists in the document directory
    final file = File("${appDocDir.path}/test.mp3");
    AudioInfo info = AudioInfo("file://${file.path}",
        title: "file",
        desc: "local file",
        coverUrl: "https://homepages.cae.wisc.edu/~ece533/images/baboon.png");

    list.add(info.toJson());
    AudioManager.instance.audioList.add(info);
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await AudioManager.instance.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

        title: 'Sankeerthana',
        theme: ThemeData(
            primarySwatch: createMaterialColor(Color.fromRGBO(1, 22, 39, 1))
        ),
        home:DefaultTabController(
      length: 3,
      child:         Builder (
      builder: (context) => // this will remove the error now
      Scaffold(
        backgroundColor: blueColor,
        drawer: Drawer(
          elevation: 16.0,
          child: Column(
            children: <Widget>[
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(1, 22, 39, 1),
                  ),
//                  child: Image.asset('assets/images/skicon.png', fit: BoxFit.contain, height: 150,)
                  child : loadImage('assets/images/skicon.png',BoxFit.contain,150.0,600.0)
//                   child :FadeInImage(image: NetworkImage('assets/images/skicon.png'), placeholder: AssetImage('assets/images/skicon.png'))
                ),
              ),

              ListTile(
                title: new Text("Scheduler"),
                leading: new Icon(Icons.schedule),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => tabThreeFinalNew()));
//                  Navigator.of(context).push(MaterialPageRoute(
//                      builder: (BuildContext context) => tabTwo()));

//                  Navigator.push(context,MaterialPageRoute(builder: (context)=> tabThreeFinal()));
                  }
              ),
              Divider(
                height: 0.1,
              ),
              ListTile(
                title: new Text("Playlist"),
                leading: new Icon(Icons.youtube_searched_for),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => tabTwoNew()));
                  }
              ),
              ListTile(
                title: new Text("Ideas"),
                leading: new Icon(Icons.lightbulb_outline),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => IdeasSendMail()));
                }
              ),
              ListTile(
                title: new Text("About Us"),
                leading: new Icon(Icons.person),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AboutUs()));
                  }
              )
            ],
          ),
        ),
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(text: 'Gods'),
              Tab(text: 'వారం ఎంచుకోండి'),
              Tab(text: 'షెడ్యూలర్'),
            ],
          ),
          title: Row(
            children: <Widget>[
              Image.asset('assets/images/skicon.png', fit: BoxFit.contain, height: 50,),

          ]
          ),
          backgroundColor: Color.fromRGBO(1, 22, 39, .8),
          elevation: 0.0,
        ),
        body: TabBarView(
          children: [
            tabOne(),
            tabTwo(),
            tabThreeFinal(),
          ],
        ),
      ),
      )
    )
    );
  }


  Widget tabOne() {
    return Scaffold(
      backgroundColor: blueColor,
//      appBar: AppBar(
////        title: const Text('Plugin audio player'),
//      ),
      body: Center(
        child: Column(
          children: <Widget>[
//            Text('Running on: $_platformVersion\n'),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
//              child: volumeFrame(),
            ),
            Expanded(//I am the clickable child
              child: GridView.builder(
                  padding: EdgeInsets.only(
                      left: 5.0, right: 5.0, top: 10, bottom: 10),
                  shrinkWrap: false,
                  itemCount: distinctIds.length,
                  gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  itemBuilder: (context, index) {
                    return Container(
//                      padding: EdgeInsets.all(20.0),
                      child: Center(
                        child: GridTile(
                          footer:  new Container(
                        color: blueColor,
                    child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: new Text(
//                      list[index]["title"],
                      distinctIds[index].substring(14,distinctIds[index].indexOf('.')),
                    style: const TextStyle(color: Colors.white),
                    ),
                    ),
                          ),
                          child: InkResponse(
                              child : ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child:
//                            Image.asset(
//                              distinctIds[index],
//                              fit: BoxFit.cover,
//                              height: 50.0,
//                              width: double.infinity,
//                            )
                             loadImage(distinctIds[index],BoxFit.cover,50.0,double.infinity)

                          ),
                              onTap: () {
                                Navigator.push(context,MaterialPageRoute(builder: (context)=> tabTwoFilter(distinctIds[index])));
                                print("Card Tapped");
                              }
                          ),

//                          Icon(Icons.access_alarm,
//                              size: 40.0, color: Colors.white30),
                        ),
                      ),
                      color: blueColor,
                      margin: EdgeInsets.all(1.0),
                    );
//                      ItemCard(list[index]["coverUrl"],list[index]["title"]);
//                      new Card(
//                    shape: RoundedRectangleBorder(
//                      borderRadius: BorderRadius.circular(15.0),
//                    ),
//                      child: new InkResponse(
//                        child: ClipRRect(
//                            borderRadius: BorderRadius.circular(10.0),
//                            child: Image.asset(
//                              list[index]["coverUrl"],
//                              fit: BoxFit.cover,
//                              height: 50.0,
//                              width: double.infinity,
//                            )),
////                        Image.asset('assets/images/vinayaka.jpg'),
//                        onTap: (){
//                          print(index);
//                        },
//                      ),
//                    );
                  }
                  ),
            ),
            Center(
                child: Text(_error != null
                    ? _error
                    : "${AudioManager.instance.info.title}" , style: TextStyle(color: Colors.white,
                    fontSize: 14)  )
            ),
            bottomPanel()
          ],
        ),
      ),
    );
  }




  Widget tabTwoFilter(String cover) {
    List slist =[];
    slist = list.where((emp) => emp["coverUrl"]== cover).toList();
    return Scaffold(
      backgroundColor: blueColor,
//      appBar: AppBar(
////        title: const Text('Plugin audio player'),
//      ),
      body: Center(
        child: Column(
          children: <Widget>[
//            Text('Running on: $_platformVersion\n'),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
//              child: volumeFrame(),
            ),
            Expanded(//I am the clickable child
              child: ListView.separated(
                  itemBuilder: (context, index) {
                    return
//                      ItemCard(list[index]["coverUrl"],list[index]["title"]);
                      ListTile(
                        title: Text(slist[index]["title"],
                            style: TextStyle(

//                              color: Colors.white,
                                color : slist[index]["title"]== "${AudioManager.instance.info.title}" ? Colors.white: Colors.white.withOpacity(0.5),

                                fontSize: 18)),
                        subtitle: Text(slist.toList()[index]["desc"], style: TextStyle(

//                          color: Colors.white,
                            color : slist.toList()[index]["desc"]== "${AudioManager.instance.info.desc}" ? Colors.white: Colors.white.withOpacity(0.5),
                            fontSize: 14)),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child:
                          loadImage(slist.toList()[index]["coverUrl"], BoxFit.cover, double.infinity  , 60.0)

//                          Image.asset(
//                            slist.toList()[index]["coverUrl"],
//                            fit: BoxFit.cover,
//                          ),
                        ),
                          onTap: () {
//                            Navigator.push(context,MaterialPageRoute(builder: (context)=> tabTwoFilter(distinctIds[index])));
                            print("Card Tapped2");
                            print(slist[index]["url"]);
                            print(list.indexOf(slist[index]));
                          AudioManager.instance.play(index: list.indexOf(slist[index]));
                          }

                      );
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      Divider(),
                  itemCount: slist.toList().length),
            ),
            Center(
                child: Text(_error != null
                    ? _error
                    : "${AudioManager.instance.info.title}", style: TextStyle(color: Colors.amberAccent,
                    fontSize: 14))),
            bottomPanel()
          ],
        ),
      ),
    );
  }


  Widget tabTwo() {
    return Scaffold(
      backgroundColor: blueColor,
//      appBar: AppBar(
////        title: const Text('Plugin audio player'),
//      ),
      body: Center(
        child: Column(
          children: <Widget>[
//            Text('Running on: $_platformVersion\n'),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
//              child: volumeFrame(),
            ),
            Expanded(//I am the clickable child
              child: ListView.separated(
                  itemBuilder: (context, index) {
                    return
//                      ItemCard(list[index]["coverUrl"],list[index]["title"]);
                      ListTile(
                      title: Text(list[index]["title"],
                          style: TextStyle(

//                              color: Colors.white,
                              color : list[index]["title"]== "${AudioManager.instance.info.title}" ? Colors.white: Colors.white.withOpacity(0.5),

                              fontSize: 18)),
                      subtitle: Text(list[index]["desc"], style: TextStyle(

//                          color: Colors.white,
                          color : list[index]["desc"]== "${AudioManager.instance.info.desc}" ? Colors.white: Colors.white.withOpacity(0.5),
                          fontSize: 14)),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child:  loadImage(list[index]["coverUrl"], BoxFit.cover, double.infinity  , 55.0)
//                        Image.asset(
//                          list[index]["coverUrl"],
//                          fit: BoxFit.cover,
//                        ),
                      ),
                      onTap: () {
                        AudioManager.instance.play(index: index);
                        print("nag");
                        print(index);
                      },
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      Divider(),
                  itemCount: list.length),
            ),
            Center(
                child: Text(_error != null
                    ? _error
                    : "${AudioManager.instance.info.title}", style: TextStyle(color: Colors.amberAccent,
                    fontSize: 14))),
            bottomPanel()
          ],
        ),
      ),
    );
  }

  Widget tabTwoNew() {
    return  Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Playlist'),
//        actions: <Widget>[
//          IconButton(
//            onPressed: send,
//            icon: Icon(Icons.send),
//          )
//        ],
        ),
        body: Stack(
            children: <Widget>[
              Container(
                decoration: new BoxDecoration(
                  color: Color.fromRGBO(1, 22, 39, 1),
//          backgroundBlendMode: BlendMode.color,
//      image: new DecorationImage(
//      fit: BoxFit.cover,
//          image: new NetworkImage(
//              'https://i.pinimg.com/originals/c2/47/e9/c247e913a0214313045a8a5c39f8522b.jpg'))
                ),
              ),
              Center(
                child: Column(
                  children: <Widget>[
//            Text('Running on: $_platformVersion\n'),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
//              child: volumeFrame(),
                    ),
                    Expanded(//I am the clickable child
                      child: ListView.separated(
                          itemBuilder: (context, index) {
                            return
//                      ItemCard(list[index]["coverUrl"],list[index]["title"]);
                              ListTile(
                                title: Text(list[index]["title"],
                                    style: TextStyle(

//                              color: Colors.white,
                                        color : list[index]["title"]== "${AudioManager.instance.info.title}" ? Colors.white: Colors.white.withOpacity(0.5),

                                        fontSize: 18)),
                                subtitle: Text(list[index]["desc"], style: TextStyle(

//                          color: Colors.white,
                                    color : list[index]["desc"]== "${AudioManager.instance.info.desc}" ? Colors.white: Colors.white.withOpacity(0.5),
                                    fontSize: 14)),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: loadImage(list[index]["coverUrl"], BoxFit.cover,  double.infinity  , 55.0)
//                                  Image.asset(
//                                    list[index]["coverUrl"],
//                                    fit: BoxFit.cover,
//                                  ),
                                ),
                                onTap: () {
                                  AudioManager.instance.play(index: index);
                                  print("nag");
                                  print(index);
                                },
                              );
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              Divider(),
                          itemCount: list.length),
                    ),
                    Center(
                        child: Text(_error != null
                            ? _error
                            : "${AudioManager.instance.info.title}", style: TextStyle(color: Colors.amberAccent,
                            fontSize: 14))),
                    bottomPanel()
                  ],
                ),
              )
            ]
        )
    );
  }

  Widget tabThreeFinal() {
    return   Padding(
      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text('త్వరలో వస్తోంది..!',
              style: TextStyle(color: Colors.amberAccent,height: 10, fontSize: 20),),

          ),
          SizedBox(height: 30 ),
          Center(
            child: Text('© 2020 NeoLabs All Rights Reserved',
              style: TextStyle(color: Color.fromRGBO(1, 22, 39, .9),height: 5, fontSize: 5),),

          ),
        ],
      ),
    );
  }

  Widget tabThreeFinalNew() {
    return  Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Scheduler'),
//        actions: <Widget>[
//          IconButton(
//            onPressed: send,
//            icon: Icon(Icons.send),
//          )
//        ],
      ),
      body: Stack(
          children: <Widget>[
      Container(
      decoration: new BoxDecoration(
          color: Color.fromRGBO(1, 22, 39, 1),
//          backgroundBlendMode: BlendMode.color,
//      image: new DecorationImage(
//      fit: BoxFit.cover,
//          image: new NetworkImage(
//              'https://i.pinimg.com/originals/c2/47/e9/c247e913a0214313045a8a5c39f8522b.jpg'))
      ),
    ),
    Center(
      child : SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Text('త్వరలో వస్తోంది..!',
                  style: TextStyle(color: Colors.amberAccent,height: 10, fontSize: 20),),

              ),
              SizedBox(height: 30 ),
              Center(
                child: Text('© 2020 NeoLabs All Rights Reserved',
                  style: TextStyle(color: Color.fromRGBO(1, 22, 39, .9),height: 5, fontSize: 5),),

              ),
            ],
          ),
        ),
      )
    )
    ]
      )
//      floatingActionButton: FloatingActionButton.extended(
//        icon: Icon(Icons.camera),
//        label: Text('Add Image'),
//        onPressed: _openImagePicker,
//      ),
    );
  }

  Widget AboutUs() {
    return  Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('About Me'),
//        actions: <Widget>[
//          IconButton(
//            onPressed: send,
//            icon: Icon(Icons.send),
//          )
//        ],
        ),
        body: Stack(
            children: <Widget>[
        Container(
        decoration: new BoxDecoration(
            color: Color.fromRGBO(1, 22, 39, 1),
//          backgroundBlendMode: BlendMode.color,
//      image: new DecorationImage(
//      fit: BoxFit.cover,
//          image: new NetworkImage(
//              'https://i.pinimg.com/originals/c2/47/e9/c247e913a0214313045a8a5c39f8522b.jpg'))
    ),
    ),
    Center(
        child :SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    radius: 100,
                    backgroundImage: Image.asset('assets/images/nag.jpg').image,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Nagendra Varada',
                    textScaleFactor: 3,
                    style: const TextStyle(color: Colors.amberAccent)
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Flutter. Datascience . Music.\nVideo Editor. Likes Traveling.',
                    style: const TextStyle(color: Colors.amberAccent),
                    textScaleFactor: 1,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 40,
                  ),
//                  Row(
//                    mainAxisAlignment: MainAxisAlignment.center,
//                    crossAxisAlignment: CrossAxisAlignment.center,
//                    children: <Widget>[
//                      FlatButton.icon(
//                        icon: SizedBox(
//                            width: 20,
//                            height: 20,
//                            child: Image.asset('assets/images/vinayaka.jpg')),
//                        label: Text('Github',style : const TextStyle(color: Colors.amberAccent)),
//                        onPressed:()=> {},
//                      ),FlatButton.icon(
//                        icon: SizedBox(
//                            width: 20,
//                            height: 20,
//                            child: Image.asset('assets/images/vinayaka.jpg')),
//                        label: Text('Twitter',style : const TextStyle(color: Colors.amberAccent)),
//                        onPressed:()=> {},
//                      ),FlatButton.icon(
//                        icon: SizedBox(
//                            width: 20,
//                            height: 20,
//                            child: Image.asset('assets/images/vinayaka.jpg')),
//                        label: Text('Medium',style : const TextStyle(color: Colors.amberAccent)),
//                        onPressed:()=> {},
//                      )
//                    ],
//                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      FlatButton.icon(
                        icon: SizedBox(
                            width: 20,
                            height: 20,
                            child: Image.asset('assets/images/insta.png')),
                        label: Text('Instagram',style : const TextStyle(color: Colors.amberAccent)),
                        onPressed:()=> {},
                      ),FlatButton.icon(
                        icon: SizedBox(
                            width: 20,
                            height: 20,
                            child: Image.asset('assets/images/fb.png')),
                        label: Text('Facebook',style : const TextStyle(color: Colors.amberAccent)),
                        onPressed:()=> {},
                      ),FlatButton.icon(
                        icon: SizedBox(
                            width: 20,
                            height: 20,
                            child: Image.asset('assets/images/linkedin.png')),
                        label: Text('Linkedin',style : const TextStyle(color: Colors.amberAccent)),
                        onPressed:()=> {},
                      )
                    ],
                  ),
                  Text('You are running this app on $_platformVersion', style: TextStyle(color: Colors.amberAccent,
                      fontSize: 14) ),
                ],
              ),
            ),
          ),
        )
    )
    ]
        )
//      floatingActionButton: FloatingActionButton.extended(
//        icon: Icon(Icons.camera),
//        label: Text('Add Image'),
//        onPressed: _openImagePicker,
//      ),
    );
  }




  Widget bottomPanel() {
    return Column(children: <Widget>[
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: songProgress(context),
      ),
      Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
                icon: getPlayModeIcon(playMode),
                onPressed: () {
                  playMode = AudioManager.instance.nextMode();
                  setState(() {});
                }),
            IconButton(
                iconSize: 36,
                icon: Icon(
                  Icons.skip_previous,
                  color: Colors.amberAccent,
                ),
                onPressed: () => AudioManager.instance.previous()),
            IconButton(
              onPressed: () async {
                bool playing = await AudioManager.instance.playOrPause();
                print("await -- $playing");
              },
              padding: const EdgeInsets.all(0.0),
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                size: 48.0,
                color: Colors.amberAccent,
              ),
            ),
            IconButton(
                iconSize: 36,
                icon: Icon(
                  Icons.skip_next,
                  color: Colors.amberAccent,
                ),
                onPressed: () => AudioManager.instance.next()),
            IconButton(
                icon: Icon(
                  Icons.stop,
                  color: Colors.amberAccent,
                ),
                onPressed: () => AudioManager.instance.stop()),
          ],
        ),
      ),
    ]);
  }

  Widget getPlayModeIcon(PlayMode playMode) {
    switch (playMode) {
      case PlayMode.sequence:
        return Icon(
          Icons.repeat,
          color: Colors.amberAccent,
        );
      case PlayMode.shuffle:
        return Icon(
          Icons.shuffle,
          color: Colors.amberAccent,
        );
      case PlayMode.single:
        return Icon(
          Icons.repeat_one,
          color: Colors.amberAccent,
        );
    }
    return Container();
  }

  Widget songProgress(BuildContext context) {
    var style = TextStyle(color: Colors.amberAccent);
    return Row(
      children: <Widget>[
        Text(
          _formatDuration(_position),
          style: style,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbColor: Colors.amberAccent,
                  overlayColor: Colors.amberAccent,
                  thumbShape: RoundSliderThumbShape(
                    disabledThumbRadius: 5,
                    enabledThumbRadius: 5,
                  ),
                  overlayShape: RoundSliderOverlayShape(
                    overlayRadius: 10,
                  ),
                  activeTrackColor: Colors.amberAccent,
                  inactiveTrackColor: Colors.grey,
                ),
                child: Slider(
                  value: _slider ?? 0,
                  onChanged: (value) {
                    setState(() {
                      _slider = value;
                    });
                  },
                  onChangeEnd: (value) {
                    if (_duration != null) {
                      Duration msec = Duration(
                          milliseconds:
                          (_duration.inMilliseconds * value).round());
                      AudioManager.instance.seekTo(msec);
                    }
                  },
                )),
          ),
        ),
        Text(
          _formatDuration(_duration),
          style: style,
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    if (d == null) return "--:--";
    int minute = d.inMinutes;
    int second = (d.inSeconds > 60) ? (d.inSeconds % 60) : d.inSeconds;
    String format = ((minute < 10) ? "0$minute" : "$minute") +
        ":" +
        ((second < 10) ? "0$second" : "$second");
    return format;
  }

  Widget IdeasSendMail() {
    return  Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Send your Ideas to Developer'),
          actions: <Widget>[
            IconButton(
              onPressed: send,
              icon: Icon(Icons.send),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _recipientController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
//                      labelText: 'Recipient',
                        hintText:'Recipient',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _subjectController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
//                      labelText: 'Subject',
                      hintText: 'Subject',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _bodyController,
                    maxLines: 10,
                    decoration: InputDecoration(
//                        labelText: 'Body',
                        hintText:'Body',
                        border: OutlineInputBorder()),
                  ),
                ),
                CheckboxListTile(
                  title: Text('HTML'),
                  onChanged: (bool value) {
                    setState(() {
                      isHTML = value;
                    });
                  },
                  value: isHTML,
                ),
                ...attachments.map(
                      (item) => Text(
                    item,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          icon: Icon(Icons.camera),
          label: Text('Add Image'),
          onPressed: _openImagePicker,
        ),
      );
  }

  void _openImagePicker() async {
    File pick = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      attachments.add(pick.path);
    });
  }



  Widget volumeFrame() {
    return Row(children: <Widget>[
      IconButton(
          padding: EdgeInsets.all(0),
          icon: Icon(
            Icons.audiotrack,
            color: Colors.amberAccent,
          ),
          onPressed: () {
            AudioManager.instance.setVolume(0);
          }),
      Expanded(
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: Slider(
                value: _sliderVolume ?? 0,
                onChanged: (value) {
                  setState(() {
                    _sliderVolume = value;
                    AudioManager.instance.setVolume(value, showVolume: true);
                  });
                },
              )))
    ]);
  }
}
