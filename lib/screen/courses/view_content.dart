import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:mykarfour/theme/app_theme.dart';
import 'package:html/dom.dart' as dom;

// Shared Data
class ViewContent extends StatefulWidget {
  String chapter;
  String content;

  ViewContent({Key key, this.chapter, this.content}) : super(key: key);

  @override
  ViewContentState createState() => ViewContentState();
}

class ViewContentState extends State<ViewContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.chapter ?? "",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height - 100,
          padding: EdgeInsets.all(10),
          child: Html(
            data: "" + widget.content + "",
            //Optional parameters:
            padding: EdgeInsets.all(8.0),
            backgroundColor: Colors.white70,
            defaultTextStyle: TextStyle(fontFamily: 'serif'),
            linkStyle: const TextStyle(
              color: Colors.redAccent,
            ),
            onLinkTap: (url) {
              // open url in a webview
            },
            onImageTap: (src) {
              // Display the image in large form.
            },
            //Must have useRichText set to false for this to work.
            // ignore: missing_return
            customRender: (node, children) {
              /* if(node is dom.Element) {
                switch(node.localName) {
                  case "video": return Chewie();
                  //case "custom_tag": return CustomWidget(...);
                }
              } */
            },
            // ignore: missing_return
            customTextAlign: (dom.Node node) {
              if (node is dom.Element) {
                switch (node.localName) {
                  case "p":
                    TextAlign.justify;
                }
              }
            },
            customTextStyle: (dom.Node node, TextStyle baseStyle) {
              if (node is dom.Element) {
                switch (node.localName) {
                  case "p":
                    return baseStyle.merge(TextStyle(height: 2, fontSize: 20));
                }
              }
              return baseStyle;
            },
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //
      //   },
      //   backgroundColor: AppTheme.buildLightTheme().primaryColor,
      //   child: Icon(Icons.print),
      // ),
    );
  }
}
