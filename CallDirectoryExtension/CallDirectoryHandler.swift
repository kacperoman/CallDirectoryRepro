//
//  CallDirectoryHandler.swift
//  CallDirectoryExtension
//
//  Created by Kacper Oman on 27.10.26.
//

import Foundation
import CallKit

private enum CallDirectoryConfiguration {
    static let appGroupIdentifier = "group.de.provectus.CallDirectoryRepro"
    static let phoneNumberKey = "phoneNumber"
    static let modeKey = "mode"
    static let extensionErrorKey = "extensionError"
}

private enum DirectoryMode: String {
    case identify
    case block
}

class CallDirectoryHandler: CXCallDirectoryProvider {

    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        print("Triggering the extension")
        context.delegate = self
        if context.isIncremental {
            print("Incremental: Removing all entries")
            context.removeAllBlockingEntries()
            context.removeAllIdentificationEntries()
        }

        guard let defaults = UserDefaults(suiteName: CallDirectoryConfiguration.appGroupIdentifier) else {
            print("Could not open shared Call Directory data.")
            NSLog("Could not open shared Call Directory data.")
            context.cancelRequest(withError: NSError(
                domain: "CallDirectoryRepro",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Could not open shared Call Directory data."]
            ))
            return
        }

        print("Searching for a phone number in shared Call Directory data...")
        if let phoneNumber = defaults.object(forKey: CallDirectoryConfiguration.phoneNumberKey) as? Int64,
           let mode = DirectoryMode(rawValue: defaults.string(forKey: CallDirectoryConfiguration.modeKey) ?? "") {
            print("Found phone number: \(phoneNumber) with mode: \(mode.rawValue)")
            switch mode {
            case .identify:
 
                context.addIdentificationEntry(withNextSequentialPhoneNumber: phoneNumber, label: "CallerID Tester")
            case .block:
                context.addBlockingEntry(withNextSequentialPhoneNumber: phoneNumber)
            }
        } else {
            print("No phone number or mode found in shared Call Directory data.")
            NSLog("No phone number or mode found in shared Call Directory data.")
        }

        context.completeRequest()
    }

}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {
    

    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {
        let error = error as NSError
        let details = "\(error.localizedDescription) (\(error.domain), \(error.code))"
        UserDefaults(suiteName: CallDirectoryConfiguration.appGroupIdentifier)?
            .set(details, forKey: CallDirectoryConfiguration.extensionErrorKey)
    }

}
