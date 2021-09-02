import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mykarfour/utils/ImageCompress.dart' as CompressImage;

class AssignmentBottomSheet extends StatefulWidget {
  AssignmentBottomSheet();
  @override
  _AssignmentBottomSheetState createState() => _AssignmentBottomSheetState();
}

class _AssignmentBottomSheetState extends State<AssignmentBottomSheet> {
  TextEditingController _fileNamecontroller = TextEditingController();

  String _fileName;
  String _path;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _subjectController = TextEditingController();
  TextEditingController _standardController = TextEditingController();
  TextEditingController _divisionController = TextEditingController();

  _uploadButtonPressed(var model) async {
    if (_path != null &&
        _titleController.text.trim() != '' &&
        _descriptionController.text.trim() != '' &&
        _divisionController.text.trim() != '' &&
        _standardController.text.trim() != '' &&
        _standardController.text.trim() != '') {
      // Assignment assignment = Assignment(
      //   title: _titleController.text.trim(),
      //   by: Provider.of<User>(context, listen: false).id,
      //   details: _descriptionController.text.trim(),
      //   div: _divisionController.text.trim().toUpperCase(),
      //   standard: _standardController.text.trim(),
      //   url: _path,
      //   subject: _subjectController.text.trim(),
      // );

      // await model.addAssignment(assignment);

      Navigator.pop(context);
    } else {
      // _scaffoldKey.currentState.showSnackBar(
      //   ksnackBar(context, 'All the fields are mandatory...'),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 31),
              child: Row(
                children: <Widget>[
                  FloatingActionButton(
                    onPressed: () async {
                      _path = await openFileExplorer(
                          FileType.custom, mounted, context,
                          extension: 'PDF');
                      setState(() {
                        _fileName =
                        _path != null ? _path.split('/').last : '...';
                        print(_fileName);
                        if (_fileName.isNotEmpty) {
                          _fileNamecontroller.text = _fileName;
                        }
                      });
                    },
                    child: Icon(FontAwesomeIcons.filePdf),
                  ),
                  Text(
                    ' OR ',
                  ),
                  FloatingActionButton(
                    heroTag: "fr",
                    onPressed: () async {
                      _path = await openFileExplorer(
                          FileType.image, mounted, context,
                          extension: 'NOCOMPRESSION');
                      setState(() {
                        _fileName =
                        _path != null ? _path.split('/').last : '...';
                        print(_fileName);
                        if (_fileName.isNotEmpty) {
                          _fileNamecontroller.text = _fileName;
                        }
                      });
                    },
                    child: Icon(FontAwesomeIcons.fileImage),
                  ),
                ],
              ),
            ),
            FloatingActionButton.extended(
              isExtended: true,
              heroTag: "ff",
              label: true
                  ? Text('Upload')
                  : Padding(
                padding: const EdgeInsets.only(right: 5),
                child: SpinKitDoubleBounce(
                  color: Colors.white,
                  size: 30,
                ),
              ),
              onPressed: () async {
                // if (model.state == ViewState.Idle)
                //   await _uploadButtonPressed(model);
              },
              icon: Icon(FontAwesomeIcons.arrowCircleUp),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.only(
                top: 40, left: 10, right: 10, bottom: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              // mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 40,
                  child: Text(
                    'Upload Assignment...',
                  ),
                ),
                TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      hintStyle: TextStyle(height: 1.5, fontWeight: FontWeight.w300),
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    )),
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: 150,
                  // color: Colors.blueAccent.withOpacity(0.5),
                  child: TextField(
                    controller: _descriptionController,
                    autocorrect: true,
                    maxLength: null,
                    maxLines: 30,
                    // expands: true,
                    keyboardType: TextInputType.multiline,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      hintStyle: TextStyle(height: 1.5, fontWeight: FontWeight.w300),
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: _fileNamecontroller,
                  enabled: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    hintStyle: TextStyle(height: 1.5, fontWeight: FontWeight.w300),
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: _subjectController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    hintStyle: TextStyle(height: 1.5, fontWeight: FontWeight.w300),
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _standardController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          hintStyle: TextStyle(height: 1.5, fontWeight: FontWeight.w300),
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _divisionController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          hintStyle: TextStyle(height: 1.5, fontWeight: FontWeight.w300),
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 100,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future openFileExplorer(
      FileType _pickingType, bool mounted, BuildContext context,
      {String extension}) async {
    String _path = null;
    if (_pickingType == FileType.image) {
      if (extension == null) {
        File file = await CompressImage.takeCompressedPicture(context);
        if (file != null) _path = file.path;
        if (!mounted) return '';

        return _path;
      } else {
        _path = await FilePicker.platform.pickFiles(type: _pickingType,allowedExtensions: ['jpg', 'jpeg', 'png']).then((value) => value.files.first.path);
        if (!mounted) return '';
        return _path;
      }
    } else if (_pickingType != FileType.custom) {
      try {
        _path = await FilePicker.platform.pickFiles(type: _pickingType,allowedExtensions: ['jpg', 'jpeg', 'png']).then((value) => value.files.first.path);
      } on PlatformException catch (e) {
        print("Unsupported operation" + e.toString());
      }
      if (!mounted) return '';

      return _path;
    } else if (_pickingType == FileType.custom) {
      try {
        if (extension == null) extension = 'PDF';
        _path = await FilePicker.platform.pickFiles(
            type: _pickingType, allowedExtensions: [extension]).then((value) => value.files.first.path);
      } on PlatformException catch (e) {
        print("Unsupported operation" + e.toString());
      }
      if (!mounted) return '';
      return _path;
    }
  }
}
