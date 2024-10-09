import 'dart:io';

import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';  // Import pdfx for PDF viewing

class FileViewer extends StatelessWidget {
  final String filePath;

  const FileViewer({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    if (filePath.endsWith('.pdf')) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("PDF View"),
        ),
        body: PdfView(
          controller: PdfController(
            document: PdfDocument.openFile(filePath),
          ),
        ),
      );
    } else if (filePath.endsWith('.txt')) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Text View"),
        ),
        body: FutureBuilder<String>(
          future: File(filePath).readAsString(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Text(snapshot.data ?? ''),
              );
            } else {
              return const Center(child: PencilLoaderProgressBar());
            }
          },
        ),
      );
    } else if (filePath.endsWith('.jpg') ||
        filePath.endsWith('.png') ||
        filePath.endsWith('.jpeg')) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Image View"),
        ),
        body: Center(
          child: Image.file(File(filePath)),
        ),
      );
    } else if (filePath.endsWith('.doc') || filePath.endsWith('.docx')) {
      return DocumentViewerWithLoader(filePath: filePath);
    } else {
      return Scaffold(
        appBar: AppBar(title: const Text("Unsupported Format")),
        body: const Center(child: Text("Unsupported file format")),
      );
    }
  }
}

class DocumentViewerWithLoader extends StatefulWidget {
  final String filePath;

  const DocumentViewerWithLoader({super.key, required this.filePath});

  @override
  _DocumentViewerWithLoaderState createState() =>
      _DocumentViewerWithLoaderState();
}

class _DocumentViewerWithLoaderState extends State<DocumentViewerWithLoader> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate a document loading process
    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Document View"),
      ),
      body: Stack(
        children: [
          if (_isLoading)
            const Center(
              child: PencilLoaderProgressBar(),
            ),
          if (!_isLoading)
            PdfView(
              controller: PdfController(
                document: PdfDocument.openFile(widget.filePath),
              ),
            ),
        ],
      ),
    );
  }
}
