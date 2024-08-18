class StringDocCategory {
  // Category constants

  static const String allCategory = 'All';
  static const String identity = 'Identity';
  static const String education = 'Education';
  static const String work = 'Work';
  static const String finance = 'Finance';
  static const String travel = 'Travel';
  static const String health = 'Health';
  static const String legal = 'Legal';
  static const String personal = 'Personal';
  static const String property = 'Property';
  static const String miscellaneous = 'Miscellaneous';

  // List of all categories
  static const List<String> categoryList = [
    identity,
    education,
    work,
    finance,
    travel,
    health,
    legal,
    personal,
    property,
    miscellaneous,
  ];
}

class StringConstants {
  static const String appName = 'docibry';
  static const String appFullName = 'docibry: Document Library';

  // manage doc strings
  static const String stringDoc = 'Doc';
  static const String stringData = 'Data';

  // add doc strings
  static const String stringAddDoc = 'Add Document';
  static const String stringAddFile = 'Add file';
  static const String stringEnterDocName = 'Enter Document Name';

  static const String stringSelectCategory = 'Select Category';
  static const String stringCategory = 'Category';
  static const String stringDocumentId = 'Document ID';
  static const String stringHoldersName = "Holder's Name";

  // view doc strings
  static const String stringViewDoc = 'View Document';
  static const String stringAddDocSuccess = 'Document added successfully!';

  // Edit doc strings
  static const String stringEditDoc = 'Edit Document';
  static const String stringEditModeEnabled = 'Edit Mode Enabled';

  // error
  static const String stringError = 'Error:';
  static const String stringDeleteDocSuccess =
      'Document deleted successfully !';

  // warnings
  static const String stringFillAll = 'Please fill all fields';
  static const String stringNoImageSelected = 'No image selected.';
  static const String stringPermsDenied =
      'Permission denied. Please enable permissions from settings.';

  // others
  static const String stringSubmit = 'SUBMIT';
  static const String stringUpdate = 'UPDATE';
  static const String stringEdit = 'EDIT';
}
