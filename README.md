# 📂 FileShareApp

A fast and simple Flutter app to share files between devices with ease!

---

## 📚 About This Project

FileShareApp was created as my Third Year Project for **BSC.CS at Model College, Mumbai University**. The project showcases cross-platform mobile development using Flutter and Dart, focusing on fast, user-friendly file sharing.

---

## 🚀 Overview

**FileShareApp** lets you transfer files seamlessly between smartphones, tablets, and computers. Whether photos, documents, or videos—sharing is just a tap away.

---

## ✨ Features

- **Cross-platform support:** Works on Android, iOS, and desktop.
- **Network Connection:** The app works seamlessly when both devices are connected to the same Wi-Fi network or a mobile hotspot.
- **User-friendly UI:** Clean, minimal interface for all ages.
-  **QR Code or Manual Entry:** Users can initiate transfers by scanning a QR code for quick pairing or manually entering the receiver’s IP address and port number.
- **Fast Local Transfers:** Leveraging efficient socket-based communication, Xbean provides lightning-fast transfer speeds for large files.
- **History:** View previous transfers and resend files.
- **Security:** Files are shared directly between devices on the local network using HTTP sockets and Encrypted transfers for safety.

---

## 🛠️ Tech Stack

- **Flutter:** UI framework
- **Dart:** Programming language
- **GoRouter:** For declarative and flexible navigation within the app.
- **Flutter Riverpod:** A robust state management library used for managing app-wide state like themes and transfer history.
- **Lottie:** For displaying smooth, scalable animations throughout the user interface.
- **FilePicker:** A package for picking files from the device's storage.
- **Mobile Scanner & QR Flutter:** Used for scanning and generating QR codes for easy device pairing.
- **http:** A networking library for handling the file transfer protocol.
- **permission_handler:** A package for requesting and checking device permissions.

---

## 📥 Installation

**Pre-requisites:**  
- Flutter SDK ([Install guide](https://docs.flutter.dev/get-started/install))
- Git

**Steps:**

1. **Clone the repository:**
    ```
    git clone https://github.com/Vishnu9604/FileShareApp.git
    cd FileShareApp
    ```

2. **Install dependencies:**
    ```
    flutter pub get
    ```

3. **Run the app:**
    ```
    flutter run
    ```

---

## 🗂️ Usage

1. **Open the app** on your device.
2. **Select files** you want to share.
3. **Choose recipient device** (auto-discovered or via QR code).
4. **Tap "Send"** and watch the magic happen!

**Note:** Both devices must be on the same network or connected through Bluetooth/Wi-Fi Direct.

---

## 🧑‍💻 Contributing

Want to make FileShareApp better?  
Follow these steps:

1. Fork the repo & clone your fork.
2. Make changes in a new branch.
3. Push and open a Pull Request describing your changes.

**See [`CONTRIBUTING.md`](CONTRIBUTING.md) for more details!**

---

## ❓ FAQ

**Q: What types of files can I share?**  
A: Any file type—images, docs, videos, APKs, etc.

**Q: Is my data secure?**  
A: Yes! Transfers are encrypted.

**Q: Can I send files to a PC?**  
A: Desktop support is planned; stay tuned!

---

## 📚 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Useful Flutter samples](https://docs.flutter.dev/cookbook)

---

## 📝 License

Distributed under the MIT License. See `LICENSE` for details.

---

> _Feel free to reach out for feature requests or bug reports!_
