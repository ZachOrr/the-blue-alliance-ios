import Foundation
import FirebaseRemoteConfig

extension RemoteConfig {

    private struct TBARemoteConfigKeys {
        static let signInWithAppleEnabled = "sign_in_with_apple_enabled"
    }

    var signInWithAppleEnabled: Bool {
        return configValue(forKey: TBARemoteConfigKeys.signInWithAppleEnabled).boolValue
    }

    /*
    var latestAppVersion: Int {
        guard let latestAppVersion = configValue(forKey: TBARemoteConfigKeys.latestAppVersion).numberValue else {
            assertionFailure("\(TBARemoteConfigKeys.latestAppVersion) not in RemoteConfigDefaults - fix that")
            return -1
        }
        return latestAppVersion.intValue
    }
    */

}
