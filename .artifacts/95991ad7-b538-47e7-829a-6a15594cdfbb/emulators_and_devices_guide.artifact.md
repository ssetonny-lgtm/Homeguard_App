# HGA - Multi-Device Emulation & Testing Guide

HomeGuard Africa (HGA) is fully responsive and engineered to run natively across all device types and screen form factors (Phones, Tablets, Foldables, Desktops, and Web Browsers).

---

## 1. Available Emulators & Targets

### A. Android Emulators (Phones, Tablets, Foldables)
You can launch and manage Android virtual devices using Flutter or Android Studio:
- **List available emulators**:
  ```bash
  flutter emulators
  ```
- **Launch the Android Phone emulator (`Medium_Phone`)**:
  ```bash
  flutter emulators --launch Medium_Phone
  ```
- **Create new device profiles** (Tablet / Foldable / Wear / TV):
  ```bash
  flutter emulators --create --name "Pixel_Tablet"
  flutter emulators --create --name "Foldable_Device"
  ```
- **Run HGA on the Android emulator**:
  ```bash
  flutter run -d emulator-5554
  ```

### B. Windows Desktop Target
Run HGA as a native windowed desktop application on Windows:
```bash
flutter run -d windows
```

### C. Web Browsers (Responsive Testing for All Screen Sizes)
Run HGA in Chrome or Edge and resize the browser window to test phone, tablet, and desktop layouts dynamically:
```bash
flutter run -d chrome
```
*Tip: In Chrome, press `F12` to open Developer Tools and toggle Device Toolbar (`Ctrl+Shift+M`) to test iPhone, iPad, Galaxy Tab, and desktop viewports instantly.*
