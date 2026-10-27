import CallKit
import SwiftUI
import UIKit

private enum CallDirectoryConfiguration {
    static let appGroupIdentifier = "group.de.provectus.CallDirectoryRepro"
    static let extensionIdentifier =
        "de.provectus.CallDirectoryRepro.CallDirectoryExtension"
    static let phoneNumberKey = "phoneNumber"
    static let phoneNumberTextKey = "phoneNumberText"
    static let modeKey = "mode"
    static let extensionErrorKey = "extensionError"
}

private enum DirectoryMode: String {
    case identify
    case block
}

struct ContentView: View {
    @State private var phoneNumber =
        UserDefaults(suiteName: CallDirectoryConfiguration.appGroupIdentifier)?
        .string(forKey: CallDirectoryConfiguration.phoneNumberTextKey) ?? ""
    @State private var extensionStatus = "Checking..."
    @State private var reloadStatus = "Not reloaded"
    @State private var isReloading = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Phone number") {
                    TextField("15551234567", text: $phoneNumber)
                        .keyboardType(.numberPad)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    Text("Digits only, including country code.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    Button(
                        "Identify",
                        systemImage: "person.crop.circle.badge.checkmark"
                    ) {
                        updateDirectory(mode: .identify)
                    }
                    .disabled(isReloading)

                    Button("Block", systemImage: "phone.down") {
                        updateDirectory(mode: .block)
                    }
                    .disabled(isReloading)

                }

                Section("Call Directory") {
                    LabeledContent("Extension", value: extensionStatus)
                    LabeledContent("Last reload", value: reloadStatus)
                    LabeledContent("iOS", value: UIDevice.current.systemVersion)
                }
            }
            .navigationTitle("Call Directory Test")
            .onAppear(perform: refreshExtensionStatus)
        }
    }

    private func updateDirectory(mode: DirectoryMode) {
        guard let number = Int64(phoneNumber),
            let defaults = UserDefaults(
                suiteName: CallDirectoryConfiguration.appGroupIdentifier
            )
        else {
            reloadStatus = "Could not read the phone number as an integer."
            return
        }

        defaults.set(number, forKey: CallDirectoryConfiguration.phoneNumberKey)
        defaults.set(
            phoneNumber,
            forKey: CallDirectoryConfiguration.phoneNumberTextKey
        )
        defaults.set(mode.rawValue, forKey: CallDirectoryConfiguration.modeKey)
        defaults.removeObject(
            forKey: CallDirectoryConfiguration.extensionErrorKey
        )

        isReloading = true
        reloadStatus = "Reloading..."

        CXCallDirectoryManager.sharedInstance.reloadExtension(
            withIdentifier: CallDirectoryConfiguration.extensionIdentifier
        ) { error in
            DispatchQueue.main.async {
                isReloading = false
                if let error {
                    let error = error as NSError
                    reloadStatus =
                        "\(error.localizedDescription) (\(error.domain), \(error.code))"
                } else if let extensionError = defaults.string(
                    forKey: CallDirectoryConfiguration.extensionErrorKey
                ) {
                    reloadStatus = extensionError
                } else {
                    reloadStatus = "Reload succeeded"
                }

                refreshExtensionStatus()
            }
        }
    }

    private func refreshExtensionStatus() {
        CXCallDirectoryManager.sharedInstance.getEnabledStatusForExtension(
            withIdentifier: CallDirectoryConfiguration.extensionIdentifier
        ) { status, error in
            DispatchQueue.main.async {
                if let error {
                    extensionStatus = error.localizedDescription
                    return
                }

                switch status {
                case .enabled:
                    extensionStatus = "Enabled"
                case .disabled:
                    extensionStatus = "Disabled"
                case .unknown:
                    extensionStatus = "Unknown"
                @unknown default:
                    extensionStatus = "Unknown"
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
