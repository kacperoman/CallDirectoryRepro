# Call Directory Repro

A minimal iOS sample for testing caller identification and number blocking with
a Call Directory Extension. The SwiftUI app saves a phone number for the
extension and asks iOS to reload it. The extension adds the number either as
an identification entry labeled **CallerID Tester** or as a blocking entry.

## Issue

On iOS 27.0.1, adding a number as a blocking entry does not block an incoming
call. The caller identification label disappears, but the call still reaches
the iPhone.

## Before testing

This repro requires a **real iPhone**. Call Directory Extensions and incoming
cellular calls cannot be tested in the iOS Simulator.

In Xcode, configure signing for both the **CallDirectoryRepro** app target and
the **CallDirectoryExtension** target:

1. Select your Apple Development team for each target.
2. Ensure both targets have the **App Groups** capability and use the same
   group. The project currently uses
   `group.de.provectus.CallDirectoryRepro`; register an App Group for your
   developer team if this one is unavailable.
3. If you use a different group identifier, update it in both targets'
   entitlement files and in `appGroupIdentifier` in both Swift source files.
   The signed provisioning profiles must include the App Group capability.
4. If Xcode requires different bundle identifiers, update the app and
   extension identifiers in the project. Keep the extension identifier
   consistent with `extensionIdentifier` in the app.

## How to test

1. Open `CallDirectoryRepro.xcodeproj` in Xcode and run the app on an iPhone.
2. Enable the Call Directory Extension in iOS Settings under **Phone** >
   **Call Blocking & Identification**. The Settings location may vary by iOS
   version.
3. Use a second phone to call the iPhone running this sample.
4. In the app, enter the caller's number using digits only, including the
   country code. Do not include `+`, `00`, spaces, or other formatting (for
   example, enter `4989...`).
5. Tap **Identify** and wait for the app to report that the extension reload
   succeeded.
6. Call the iPhone. The incoming call should be identified as **CallerID
   Tester**.
7. Return to the app, tap **Block**, and wait for the extension reload to
   succeed.
8. Call the iPhone again.

## Expected and observed results

- **Expected:** The blocked call does not ring through to the iPhone and is
  handled as a blocked call (for example, sent to voicemail).
- **Observed on iOS 27:** The call still goes through, but the **CallerID
  Tester** identification is no longer shown. The identification entry appears
  to have been removed, while call blocking does not take effect.

## OS versions tested

- **iOS 27.2:** Blocking issue reproduced.
- **iOS 27.0.1:** Blocking issue reproduced.
- **iOS 26:** Not tested.
- **iOS 18**: Blocking works as expected.

