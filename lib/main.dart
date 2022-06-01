import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:transparent_image/transparent_image.dart';


void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Album>? _albums;
  bool _loading = false;
  int itemCount=0;
  String folderName = "All";

  Album? currentAlbum;
  ValueNotifier<int>? itemLength = ValueNotifier<int>(0);
  List<keyur> folderList = [];

  @override
  void initState() {
    super.initState();
    _loading = true;
    initAsync();

    //apicall();
  }


  apicall() async {
    Response response;
    var dio = Dio();
    dio.options.connectTimeout = 10000; //5s
    dio.options.receiveTimeout = 10000;
    dio.options.headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': "Bearer G-0R7oGq8jIyzEN1UqsCTmZ7bwfInLYFDj6yzJA5AWHq9s-AKE7rATksqPrLLrIC-0DXfBtFKSrx9Pv4EpmQibqz2yFq4H8RKLi4ZEJlp9Kodepni0rNO0oEkBZy6NBHHjmBlRJNaKkCr6ZC94qhxgL8_S_OsdRx_C8--du6tbmN6CnQG9fhTY67zdVErSZ-w8dHKok3eyBov9R-KW1sEW6OYGWLTTYJILEjbpF0kbwT6ahVcoMjT8suMlcDVzkYlZiRn3rDumbjSHCf3Tw7cEx7BB774_5ZxoOCATpb_9eY7j2ArJtTLp-XSOalB4bRcQl4j_2tf7UdA24p3k7Cf16WwfI6VQlWZn-CPlTAmzA",
      'Platform': "Android",
      'AppVersion': "1.1.1.1",

      //'Authorization': 'Bearer WYpEVvYTkI1aqZ3onRiL0DY73PNnCH9UQyuOWH6i'
    };


    try {
      await dio
          .post('http://192.168.1.64/LiftForce/API/Project/AddEmployees',
          data: {"ProjectId": 229, "InstallerEmployeeId": [137, 125, 103]},
          options: Options(method: 'POST', responseType: ResponseType.json))
          .then((value) {
        print("Response status: ${value.statusCode}");
        print("Response data: $value");

      });
    } on DioError catch (e) {
      print(' Response  ${e.response}${e.message}');


    }


    print(" + + ++ + + +  + +  +");

    print(" + + ++ + + +  + +  +");

  }
  Future<void> initAsync() async {
    if (await _promptPermissionSetting()) {
      List<Album> albums =
          await PhotoGallery.listAlbums(mediumType: MediumType.image,);
      setState(() {
        print(albums.length);
        _albums = albums;
        _loading = false;
      });

      _albums?.forEach((element) {
        folderList.add(keyur(
            id: element.id.toString(),
            name: element.name.toString(),
            album: element));
      });

      currentAlbum = folderList[0].album;

      print(_albums!.iterator.current.count);
    }

    setState(() {
      _loading = false;
    });
  }

  Future<bool> _promptPermissionSetting() async {
    if (Platform.isIOS &&
            await Permission.storage.request().isGranted &&
            await Permission.photos.request().isGranted ||
        Platform.isAndroid && await Permission.storage.request().isGranted) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leadingWidth: 100,
          leading: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ValueListenableBuilder(
            valueListenable: itemLength!,
            builder: (context, val, _) {return Text(val.toString());}),
            ],
          ),
          centerTitle: true,
          title: InkWell(
              onTap: () {
                _openBottomSheet();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(folderName.toString()),
                  const Icon(Icons.keyboard_arrow_down),
                ],
              )),
          actions: const [
            Center(
                child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Done"),
            ))
          ],
        ),
        body: _loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : AlbumPage(key: globalKey, album: currentAlbum!,selectedList: (val){

              print(" 9 9 9 99 9  9 ${val.toString()}");
              itemLength!.value = val.length;


        },));
  }

  _openBottomSheet() {
    return showModalBottomSheet(
        useRootNavigator: true,
        isScrollControlled: true,
        //  backgroundColor: Colors.yellow,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0))),
        context: (context),
        enableDrag: true,
        isDismissible: true,
        builder: (BuildContext context) {
          return Container(
            height: 300,
            child: ListView.separated(
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
                // shrinkWrap: true,
                // physics: NeverScrollableScrollPhysics(),
                itemCount: folderList.length,
                itemBuilder: (context, index) {
                  return InkWell(
                      onTap: () {
                        setState(() {
                          Navigator.pop(context);
                          currentAlbum = folderList[index].album;
                          folderName = folderList[index].name;
                        });
                        itemLength!.value=0;
                        Future.delayed(Duration(milliseconds: 200), () {
                          globalKey.currentState?.initAsync();
                        });

                        /* Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => AlbumPage(folderList[index].album)));*/
                      },
                      child: Center(
                          child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(folderList[index].name.toString()),
                      )));
                }),
          );
        });
  }
}

final GlobalKey<AlbumPageState> globalKey = GlobalKey();

class AlbumPage extends StatefulWidget {
  final Album album;

  Function selectedList;

  AlbumPage({required Key key, required this.album,required this.selectedList}) : super(key: key);

  //AlbumPage(Key key,Album album) : album = album;

  @override
  State<StatefulWidget> createState() => AlbumPageState();
}

class AlbumPageState extends State<AlbumPage> {
  List<Medium>? _media;
  List<abaz>? _selectedItems = [];

  @override
  void initState() {
    super.initState();

    initAsync();
  }

  void initAsync() async {
    _selectedItems!.clear();
    MediaPage mediaPage = await widget.album.listMedia(newest: true);
    setState(() {
      _media = mediaPage.items;
    });

   // print(_media![0].filename);
   // print(_media![0].title);
   // print(await _media![0].getFile());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(widget.album.name ?? "Unnamed Album"),
        ),*/
      body: GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 1.0,
        crossAxisSpacing: 1.0,
        children: <Widget>[
          Container(
              color: Colors.teal.withOpacity(0.5),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 35,
              )),
          ...?_media?.asMap().entries.map((medium) {
            int idx = medium.key;
            bool _isSelected = false;

            return StatefulBuilder(builder: (context, stf) {
              return GestureDetector(
                onTap: () async {
                  stf(() {
                    _isSelected = !_isSelected;

                  });

                  print("arbaz++++ ${idx}");
                  !_isSelected
                      ? //_selectedItems!.removeAt(idx)
                  _selectedItems!.removeWhere((item) => item.id == idx)
                //  _selectedItems!.remove(await medium.value.getFile())
                      : _selectedItems!.add(abaz(id: idx, name: await medium.value.getFile()));


             widget.selectedList(_selectedItems!);
                },
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.grey[300],
                      child: FadeInImage(
                        fit: BoxFit.cover,
                        placeholder: MemoryImage(kTransparentImage, scale: 1.0),
                        image: ThumbnailProvider(
                          mediumId: medium.value.id,
                          mediumType: medium.value.mediumType,
                          highQuality: true,
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: _isSelected
                          ? Colors.black.withOpacity(0.4)
                          : Colors.transparent,
                    ),
                    Checkbox(

                        tristate:true ,
                        value: _isSelected,
                        onChanged: (v) {
                          print("fdgkhnfjhgb $v");
                        }),
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      color:  Colors.transparent,
                    ),
                  ],
                ),
              );
            });
          }),
        ],
      ),
    );
  }
}

class ViewerPage extends StatelessWidget {
  final Medium medium;

  ViewerPage(Medium medium) : medium = medium;

  @override
  Widget build(BuildContext context) {
    DateTime? date = medium.creationDate ?? medium.modifiedDate;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back_ios),
          ),
          title: date != null ? Text(date.toLocal().toString()) : null,
        ),
        body: Container(
            alignment: Alignment.center,
            child: FadeInImage(
              fit: BoxFit.cover,
              placeholder: MemoryImage(kTransparentImage),
              image: PhotoProvider(mediumId: medium.id),
            )),
      ),
    );
  }
}



class abaz {
  int id;
  File name;


  abaz({required this.id, required this.name, });
}
class keyur {
  String id;
  String name;
  Album album;

  keyur({required this.id, required this.name, required this.album});
}
/*
class VideoProvider extends StatefulWidget {
  final String mediumId;

  const VideoProvider({
    required this.mediumId,
  });

  @override
  _VideoProviderState createState() => _VideoProviderState();
}

class _VideoProviderState extends State<VideoProvider> {
  VideoPlayerController? _controller;
  File? _file;

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initAsync();
    });
    super.initState();
  }

  Future<void> initAsync() async {
    try {
      _file = await PhotoGallery.getFile(mediumId: widget.mediumId);
      _controller = VideoPlayerController.file(_file!);
      _controller?.initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    } catch (e) {
      print("Failed : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return _controller == null || !_controller!.value.isInitialized
        ? Container()
        : Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        ),
        FlatButton(
          onPressed: () {
            setState(() {
              _controller!.value.isPlaying
                  ? _controller!.pause()
                  : _controller!.play();
            });
          },
          child: Icon(
            _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
      ],
    );
  }
}*/
