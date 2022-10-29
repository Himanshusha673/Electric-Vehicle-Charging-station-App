import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf_flutter/pdf_flutter.dart';

enum PdfLoadType {
  file,
  network,
  assets,
}

class PdfViewScreen extends StatefulWidget {
  final String? pdfTitle;
  final PdfLoadType? pdfLoadType;
  final File? file; // PdfLoadType.file
  final String? url; // PdfLoadType.network
  final String? assetPath; // PdfLoadType.assets

  const PdfViewScreen({
    Key? key,
    required this.pdfTitle,
    required this.pdfLoadType,
    this.file,
    this.url,
    this.assetPath,
  }) : super(key: key);

  @override
  _PdfViewScreenState createState() => _PdfViewScreenState();
}

class _PdfViewScreenState extends State<PdfViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar,
              Divider(thickness: 1),
              Expanded(
                child: _buildBody,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget get _buildAppBar {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 5.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          Expanded(
            child: Text(
              '${widget.pdfTitle}',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headline1,
            ),
          ),
        ],
      ),
    );
  }

  Widget get _buildBody {
    switch (widget.pdfLoadType) {
      case PdfLoadType.file:
        return PDF.file(
          widget.file!,
          width: double.infinity,
          height: double.infinity,
          placeHolder: Center(
            child: CircularProgressIndicator(),
          ),
        );
      case PdfLoadType.network:
        return PDF.network(
          widget.url.toString(),
          width: double.infinity,
          height: double.infinity,
          placeHolder: Center(
            child: CircularProgressIndicator(),
          ),
        );
      case PdfLoadType.assets:
        return PDF.asset(
          widget.assetPath.toString(),
          width: double.infinity,
          height: double.infinity,
          placeHolder: Center(
            child: CircularProgressIndicator(),
          ),
        );
      default:
        return PDF.file(
          widget.file!,
          width: double.infinity,
          height: double.infinity,
          placeHolder: Center(
            child: CircularProgressIndicator(),
          ),
        );
    }
  }
}
