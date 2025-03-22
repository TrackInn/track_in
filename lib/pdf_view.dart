import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PDFViwerScreen extends StatefulWidget {
  final String url;

  const PDFViwerScreen({super.key, required this.url});

  @override
  _PDFViwerScreenState createState() => _PDFViwerScreenState();
}

class _PDFViwerScreenState extends State<PDFViwerScreen> {
  String urlPDFPath = "";
  bool exists = true;
  int _totalPages = 0;
  int _currentPage = 0;
  bool pdfReady = false;
  PDFViewController? _pdfViewController;
  bool loaded = false;

  Future<File> getFileFromUrl(String url, {name}) async {
    var fileName = 'testonline';
    if (name != null) {
      fileName = name;
    }
    try {
      var data = await http.get(Uri.parse(url));
      var bytes = data.bodyBytes;
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/" + fileName + ".pdf");
      File urlFile = await file.writeAsBytes(bytes);
      return urlFile;
    } catch (e) {
      throw Exception("Error opening url file");
    }
  }

  Future<void> downloadPDF() async {
    if (await Permission.storage.request().isGranted) {
      try {
        final response = await http.get(Uri.parse(widget.url));

        if (response.statusCode == 200) {
          Directory? directory;
          if (Platform.isAndroid) {
            if (await Permission.manageExternalStorage.request().isGranted) {
              directory = Directory('/storage/emulated/0/Download');
            }
          } else {
            directory = await getApplicationDocumentsDirectory();
          }

          if (directory == null) {
            throw Exception("Unable to access storage");
          }

          String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
          String filePath = '${directory.path}/PDF_$timestamp.pdf';
          File file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          Fluttertoast.showToast(
            msg: "Download complete: $filePath",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        } else {
          throw Exception(
              "Failed to download file. Status: ${response.statusCode}");
        }
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Download failed: $e",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "Storage permission required!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      await openAppSettings();
    }
  }

  @override
  void initState() {
    super.initState();
    requestStoragePermission();
  }

  Future<void> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      getFileFromUrl(widget.url).then(
        (value) => {
          setState(() {
            if (value != null) {
              urlPDFPath = value.path;
              loaded = true;
              exists = true;
            } else {
              exists = false;
            }
          })
        },
      );
    } else {
      setState(() {
        exists = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loaded) {
      return Scaffold(
        appBar: AppBar(
          title: Text("PDF Viewer", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue,
          iconTheme: IconThemeData(
              color: Colors.white), // Set the arrow color to white
          actions: [
            IconButton(
              icon: Icon(Icons.download, color: Colors.white),
              onPressed: downloadPDF, // Trigger the download function
            ),
          ],
        ),
        body: PDFView(
          filePath: urlPDFPath,
          autoSpacing: true,
          enableSwipe: true,
          pageSnap: true,
          swipeHorizontal: true,
          nightMode: false,
          onError: (e) {
            // Show some error message or UI
          },
          onRender: (_pages) {
            setState(() {
              _totalPages = _pages!;
              pdfReady = true;
            });
          },
          onViewCreated: (PDFViewController vc) {
            setState(() {
              _pdfViewController = vc;
            });
          },
          onPageError: (page, e) {},
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.chevron_left),
              iconSize: 50,
              color: Colors.black,
              onPressed: () {
                setState(() {
                  if (_currentPage > 0) {
                    _currentPage--;
                    _pdfViewController!.setPage(_currentPage);
                  }
                });
              },
            ),
            Text(
              "${_currentPage + 1}/$_totalPages",
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right),
              iconSize: 50,
              color: Colors.black,
              onPressed: () {
                setState(() {
                  if (_currentPage < _totalPages - 1) {
                    _currentPage++;
                    _pdfViewController!.setPage(_currentPage);
                  }
                });
              },
            ),
          ],
        ),
      );
    } else {
      if (exists) {
        return Scaffold(
          appBar: AppBar(
            title: Text("PDF Viewer", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.blue,
          ),
          body: Center(
            child: Text(
              "Loading..",
              style: TextStyle(fontSize: 20),
            ),
          ),
        );
      } else {
        return Scaffold(
          appBar: AppBar(
            title: Text("PDF Viewer", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.blue,
          ),
          body: Center(
            child: Text(
              "PDF Not Available",
              style: TextStyle(fontSize: 20),
            ),
          ),
        );
      }
    }
  }
}
