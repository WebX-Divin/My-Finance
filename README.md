
# My-Finance

Follow the instructions below to set up and run the project on your system using VS Code.

## Prerequisites

Before running the project, ensure you have the following installed:

1. **Flutter SDK**: [Download & Install Flutter](https://flutter.dev/docs/get-started/install)
2. **Dart SDK**: Comes bundled with Flutter
3. **Android Studio** (for Android Emulator) or **Xcode** (for iOS Development)
4. **VS Code**: [Download VS Code](https://code.visualstudio.com/)
5. **Flutter & Dart Extensions** in VS Code
6. **Git**: [Download Git](https://git-scm.com/downloads)

## Installation & Setup

### 1. Clone the Repository

Open a terminal and run:

```sh
git clone https://github.com/WebX-Divin/My-Finance.git
```

Then navigate to the project directory:

```sh
cd My-Finance
```

### 2. Install Dependencies

Run the following command to install required Flutter packages:

```sh
flutter pub get
```

### 3. Configure a Device or Emulator

- To run on a physical Android device, enable **USB debugging**.
- To use an emulator:
  - Open **Android Studio**, create a new virtual device, and launch it.
  - Alternatively, for iOS, open **Xcode** and set up a simulator.

Check available devices using:

```sh
flutter devices
```

### 4. Run the App

Use the following command to start the application:

```sh
flutter run
```

Or run it from VS Code:

- Open the project in VS Code.
- Press `F5` or use the **Run and Debug** option.

### 5. (Optional) Fix Any Missing Dependencies

If you encounter issues, run:

```sh
flutter doctor
```

Follow the suggestions to install missing dependencies.

## Additional Commands

- **To run the app on a specific device** (replace `device_id` with the actual ID from `flutter devices`):

  ```sh
  flutter run -d <device_id>
  ```

- **To clean the project (if facing build issues)**:

  ```sh
  flutter clean
  flutter pub get
  ```

- **To build APK for Android**:

  ```sh
  flutter build apk
  ```

- **To build iOS (macOS only)**:

  ```sh
  flutter build ios
  ```

## Contributions

Feel free to fork this repository and submit pull requests for improvements.

## License

This project is licensed under the MIT License.

---

Happy Coding! 🚀
