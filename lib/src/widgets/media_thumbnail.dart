import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:impulse_utils/impulse_utils.dart';

class MediaThumbnail extends StatefulWidget {
  final Widget placeHolder;
  final String file;
  final bool isVideo;
  final bool returnPath;
  final Size? size;
  final Duration? fadeDuration;
  final bool reCache;
  final double containerSize;

  const MediaThumbnail({
    super.key,
    required this.placeHolder,
    required this.file,
    required this.isVideo,
    this.returnPath = true,
    this.size,
    this.fadeDuration,
    this.reCache = false,
    this.containerSize = 50,
  });

  @override
  State<MediaThumbnail> createState() => _MediaThumbnailState();
}

class _MediaThumbnailState extends State<MediaThumbnail> {
  Future<(String?, Uint8List?)>? _future;
  final _impulseUtils = ImpulseUtils();

  @override
  void initState() {
    super.initState();
    _future = _impulseUtils.getMediaThumbNail(
      file: widget.file,
      isVideo: widget.isVideo,
      returnPath: widget.returnPath,
      size: widget.size,
      reCache: widget.reCache,
    );
  }

  @override
  void didUpdateWidget(covariant MediaThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.file != oldWidget.file ||
        widget.returnPath != oldWidget.returnPath ||
        widget.size != oldWidget.size ||
        widget.isVideo ||
        widget.containerSize != oldWidget.containerSize ||
        oldWidget.isVideo) {
      _future = _impulseUtils.getMediaThumbNail(
        file: widget.file,
        isVideo: widget.isVideo,
        returnPath: widget.returnPath,
        size: widget.size,
        reCache: widget.reCache,
      );
      setState(() {});
      // build(context);
    }
  }

  Widget child(AsyncSnapshot<(String?, Uint8List?)> snapshot) {
    if (snapshot.hasError) {
      return widget.placeHolder;
    }
    if (!snapshot.hasData) {
      return widget.placeHolder;
    } else {
      if (snapshot.data!.$1 != null) {
        return Container(
          // height: widget.containerSize,
          // width: widget.containerSize,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(
                File(snapshot.data!.$1!),
              ),
              // fit: BoxFit.cover,
            ),
            color: Colors.transparent,
          ),
        );
      } else {
        return Container(
          // height: widget.containerSize,
          // width: widget.containerSize,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: MemoryImage(
                snapshot.data!.$2!,
              ),
              // fit: BoxFit.cover,
            ),
            color: Colors.transparent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        return AnimatedSwitcher(
          duration: widget.fadeDuration ?? const Duration(milliseconds: 1000),
          child: child(snapshot),
        );
      },
    );
  }
}
