import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
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
      return _Image(data: snapshot.data!, containerSize: widget.containerSize);
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

class _Image extends StatelessWidget {
  final double? containerSize;
  final (String?, Uint8List?) data;
  const _Image({
    Key? key,
    this.containerSize,
    required this.data,
  }) : super(key: key);

  ImageProvider _getProvider() {
    if (data.$1 != null) {
      return FileImage(File(data.$1!));
    } else {
      return MemoryImage(data.$2!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: containerSize,
      width: containerSize,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: _getProvider(),
          fit: BoxFit.cover,
        ),
        color: Colors.transparent,
      ),
    );
  }
}
