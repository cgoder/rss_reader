# iOS Build Instructions for RSS Reader App

## Prerequisites
- macOS operating system (iOS apps can only be built on macOS)
- Xcode installed from Mac App Store
- Apple ID for code signing (free Apple ID is sufficient for personal use)
- Flutter SDK installed and working

## Step-by-Step Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/cgoder/rss_reader.git
cd rss_reader
```

### 2. Install Dependencies
```bash
cd rss_reader_app
flutter pub get
```

### 3. Open Project in Xcode
```bash
open -a Xcode ios/Runner.xcworkspace
```

### 4. Configure Project in Xcode
1. In Xcode, select the Runner project in the navigator
2. Go to the "General" tab
3. Set your Team under "Signing & Capabilities"
4. Choose a unique Bundle Identifier (e.g., com.yourname.rssreader)

### 5. Build IPA File
There are multiple ways to build an IPA:

#### Method A: Using Flutter Command
```bash
# Generate release build
flutter build ipa --release
```

This will create the IPA file in:
`build/ios/ipa/rss_reader_app.ipa`

#### Method B: Using Xcode
1. In Xcode, select your device (Generic iOS Device)
2. Go to Product > Archive
3. After archiving, use the Organizer to export the IPA

#### Method C: Using Flutter with codesigning
```bash
# If you have provisioning profiles set up
flutter build ipa --export-options-plist=path/to/ExportOptions.plist
```

### 6. Alternative Cloud-Based Building Options

If you don't have macOS, consider these cloud-based solutions:
- Codemagic (https://codemagic.io/)
- Bitrise (https://www.bitrise.io/)
- GitHub Actions with macOS runners
- App Center (https://appcenter.ms/)

## Important Notes
- You'll need an Apple Developer account ($99/year) to distribute to the App Store
- For testing on physical devices, a paid developer account is required
- Free Apple ID is sufficient for simulator testing and personal distribution

## Troubleshooting
If you encounter build issues:
1. Make sure all CocoaPods are properly installed:
   ```bash
   cd ios && pod install && cd ..
   ```
2. Clean and rebuild:
   ```bash
   flutter clean
   flutter pub get
   flutter build ipa
   ```

## Distribution
Once you have the IPA file, you can:
- Distribute via TestFlight (requires paid Apple Developer account)
- Sideload using tools like AltStore (no developer account required)
- Upload to the App Store (requires paid Apple Developer account)