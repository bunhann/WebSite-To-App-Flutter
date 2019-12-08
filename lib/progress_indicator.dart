import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class InfiniteProgressIndicator extends StatelessWidget {
  final EdgeInsets padding;

  const InfiniteProgressIndicator({
    Key key,
    this.padding = const EdgeInsets.all(0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: Platform.isAndroid
          ? CircularProgressIndicator(
        value: null,
        valueColor:
        AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
        strokeWidth: 2.0,
      )
          : CupertinoActivityIndicator(
        radius: 20.0,
      ),
    );
  }
}
