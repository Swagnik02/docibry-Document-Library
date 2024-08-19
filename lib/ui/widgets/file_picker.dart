
  // Future<void> _pickImage() async {
  //   var status = await Permission.photos.status;

  //   if (!status.isGranted) {
  //     status = await Permission.photos.request();
  //   }

  //   if (status.isGranted) {
  //     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  //     if (mounted) {
  //       setState(() {
  //         if (pickedFile != null) {
  //           _image = File(pickedFile.path);
  //         } else {
  //           log(StringConstants.stringNoImageSelected);
  //         }
  //       });
  //     }
  //   } else {
  //     if (mounted) {
  //       showSnackBar(context, StringConstants.stringPermsDenied);
  //     }
  //   }
  // }

  // Future<void> _pickPdf() async {
  //   File? convertedImage;
  //   final result = await FilePicker.platform.pickFiles(
  //     type: FileType.custom,
  //     allowedExtensions: ['pdf'],
  //   );

  //   if (result != null) {
  //     final pdfDoc = result.files.single;
  //     log('Picked file: ${pdfDoc.name}');
  //     log('File path: ${pdfDoc.path}');

  //     convertedImage = await pdfToImage(pdfDoc);

  //     setState(() {
  //       _image = convertedImage;
  //     });
  //   } else {
  //     log('No file selected');
  //   }
  // }