# Download an older Xcode (for macOS 13.7 Ventura)

The **App Store** often offers the latest Xcode, which may need a newer macOS. You can install an **older Xcode** that works on **macOS 13.7 (Ventura)** from Apple’s developer site.

## Where to download

**Apple Developer – all Xcode versions:**  
[https://developer.apple.com/download/all/?q=Xcode](https://developer.apple.com/download/all/?q=Xcode)

- You need an **Apple ID** (free account is enough).
- Sign in, then search or scroll to find the version you want.

## Which version to choose (macOS 13.7)

For **macOS Ventura 13.7**, these are supported:

| Xcode version | Works on macOS 13.7 | Notes |
|---------------|--------------------|--------|
| **Xcode 15.2** | Yes (needs 13.5+) | Newer, good choice |
| **Xcode 15.1 / 15.0** | Yes (needs 13.5+) | Slightly older |
| **Xcode 14.3.1** | Yes (Ventura 13.x) | Older, very safe for 13.7 |
| **Xcode 14.3** | Yes | Same as above |
| **Xcode 14.2** | Yes | Also fine |

**Suggested:** **Xcode 14.3.1** or **Xcode 15.2** (pick one).

Avoid versions that require **macOS Sonoma 14.x** or **Sequoia 15.x** (e.g. Xcode 16+) on your current Mac.

## Steps

1. **Open the download page** (in Safari or Chrome):  
   [https://developer.apple.com/download/all/?q=Xcode](https://developer.apple.com/download/all/?q=Xcode)

2. **Sign in** with your Apple ID (use “Sign in” if needed).

3. **Find your version**  
   - Use the search box and type e.g. **Xcode 14.3** or **Xcode 15.2**.  
   - Or scroll the list and pick one of the versions in the table above.

4. **Download**  
   - Click the version you want.  
   - Download the **.xip** file (it’s large, 7–12 GB; allow time and a stable connection).

5. **Install**  
   - When the download finishes, **double‑click the .xip file**.  
   - It will expand and create **Xcode.app** (often in your **Downloads** folder or on the Desktop).

6. **Move Xcode to Applications**  
   - Drag **Xcode.app** into **Applications** (or copy it there).  
   - You can delete the **.xip** file after that to free space.

7. **First run**  
   - Open **Xcode** from Applications.  
   - Accept the **license** and install any **extra components** it asks for.

8. **Point command-line tools to Xcode** (for Flutter / scripts):  
   In Terminal run:
   ```bash
   sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
   ```
   (Enter your Mac password when asked.)

After that, run the InterHungary setup script again so it can use this Xcode.

## Reference

- Apple’s Xcode support and version table:  
  [https://developer.apple.com/support/xcode/](https://developer.apple.com/support/xcode/)
