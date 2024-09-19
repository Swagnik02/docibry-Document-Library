<img src="https://github.com/user-attachments/assets/0e89c8ee-6fb4-485f-9e7d-443b6fff5a64" alt="Docibry Logo" width="100" height="100"/>

# **docibry: Document Library**

Docibry is a document management and sharing application built using Flutter and Firebase. It allows users to upload, manage, categorize, and share documents (PDFs and images) seamlessly. The app also supports user authentication, allowing users to securely sign in and manage their personalized document libraries.

## 🛠 Features

### User Authentication

- Secure login and registration using **Firebase Authentication**.
- Password-based authentication with Firebase Firestore storing user details.
- Persistent login, ensuring the user stays logged in across sessions.

### Document Management

- Upload and manage various file types such as **PDFs** and **images**.
- Categorize documents into custom categories for easy filtering.
- View, edit, delete, and update document information such as **document name**, **holder name**, and **category**.
- Local database integration (Sembast) for offline capabilities.

### File Sharing

- Share documents directly via social media, email, and other platforms using **Share Plus**.
- Save documents locally as **JPG** or **PDF**.
- Web support for downloading documents directly to the device.

### Search & Filter

- Search for documents by name or filter documents by category.
- Category chips for easy selection and filtering.

### Offline Support

- Local database storage allows access to documents even when offline.

## 🎨 UI Highlights

- Clean and modern UI built using Flutter's **Material Design**.
- Responsive design for both mobile and web platforms.
- Custom components like **Search Bar**, **Snackbar**, and **Category Filter Chips**.

## 🔧 Technology Stack

- **Framework**: Flutter
- **State Management**: Flutter BLoC
- **Firebase Services**:
  - **Authentication**: User login and registration.
  - **Firestore**: Storage for user and document details.
- **Local Storage**: Sembast for offline document management.
- **Sharing**: Share Plus for sharing documents.

## 📁 Project Structure

```
lib/
|-- blocs/               # BLoC state management logic
|-- constants/           # App constants (strings, routes)
|-- models/              # Data models (documents, user)
|-- repositories/        # Local database service
|-- services/            # File and permission handling services
|-- ui/                  # User interface
    |-- auth/            # User login and registration pages
    |-- document/        # Document management pages
    |-- home/            # Home page and document grid view
    |-- profile/         # User profile page
    |-- shareDoc/        # Document sharing page
    |-- widgets/         # Reusable custom widgets
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK: `^3.5.0`
- Firebase Account for configuring authentication and Firestore

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/docibry.git
   ```
2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Set up Firebase:

   - Create a Firebase project.
   - Enable **Firebase Authentication** and **Firestore Database**.
   - Download `google-services.json` and place it in the `android/app` directory.

4. Run the app:
   ```bash
   flutter run
   ```

### Web Support

To run the app on web:

```bash
flutter build web
```

### Firebase Setup

Update `firebase_options.dart` with your Firebase configuration:

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

## 🤝 Contributing

Contributions are welcome! Feel free to submit issues or pull requests on the [GitHub repository](https://github.com/your-username/docibry).

### How to Contribute:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature/your-feature`).
3. Commit your changes (`git commit -m 'Add new feature'`).
4. Push to the branch (`git push origin feature/your-feature`).
5. Open a Pull Request.

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
