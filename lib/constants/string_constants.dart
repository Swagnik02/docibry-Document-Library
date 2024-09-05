class DocCategory {
  // Category constants
  static const String all = 'All';
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
  static const List<String> allCategories = [
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

class AppStrings {
  // App info
  static const String appName = 'docibry';
  static const String appFullName = '$appName: Document Library';

  // Common labels
  static const String submit = 'SUBMIT';
  static const String update = 'UPDATE';
  static const String edit = 'EDIT';

  // Document management
  static const String addDoc = 'Add Document';
  static const String addFile = 'Add file';
  static const String enterDocName = 'Enter Document Name';
  static const String selectCategory = 'Select Category';
  static const String documentId = 'Document ID';
  static const String holdersName = "Holder's Name";
  static const String doc = "Doc";
  static const String data = "Data";
  static const String searchField = "Search for document names";

  static const String viewDoc = 'View Document';
  static const String addDocSuccess = 'Document added successfully!';
  static const String editDoc = 'Edit Document';
  static const String editModeEnabled = 'Edit Mode Enabled';

  // Warnings
  static const String fillAllFields = 'Please fill all fields';
  static const String noImageSelected = 'No image selected.';
  static const String permissionDenied =
      'Permission denied. Please enable permissions from settings.';

  // File info
  static const String pickedFile = 'Picked file';
  static const String filePath = 'File path';

  // Share document
  static const String shareDoc = 'Share Document';
}

class ErrorMessages {
  // General error messages
  static const String error = 'Error:';
  static const String deleteDocSuccess = 'Document deleted successfully!';
  static const String noDocsFound = 'No documents found';
  static const String noDataFound = 'No data available';
  static const String unsupportedFileType = 'Unsupported file type selected';
  static const String noFileSelected = 'No file selected';

  // Database errors
  static const String failedToFetchDoc = 'Failed to fetch documents from';
  static const String failedToAddDoc = 'Failed to add document to';
  static const String failedToUpdateDoc = 'Failed to update document in';
  static const String failedToDeleteDoc = 'Failed to delete document from';
}

class DbCollections {
  // Firestore collections
  static const String users = 'users';
  static const String docs = 'docs';
  static const String loggedInUserData = 'loggedInUserData';
  static const String documentsDb = 'documents.db';
}

class FileExtensions {
  // Supported file extensions
  static const List<String> image = ['jpg', 'jpeg', 'png'];
  static const List<String> document = ['pdf'];
}
