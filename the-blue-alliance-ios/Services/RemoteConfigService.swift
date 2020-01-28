import Crashlytics
import FirebaseRemoteConfig
import Foundation
import TBAUtils

protocol RemoteConfigObservable {
    func remoteConfigUpdated()
}

class RemoteConfigService {

    var remoteConfig: RemoteConfig

    public var remoteConfigProvider = Provider<RemoteConfigObservable>()

    init(remoteConfig: RemoteConfig) {
        self.remoteConfig = remoteConfig

        // Allow remote config fetching frequently
        #if DEBUG
        let configSettings = RemoteConfigSettings()
        configSettings.minimumFetchInterval = 0
        remoteConfig.configSettings = configSettings
        #endif

        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
    }

    internal func fetchRemoteConfig(completion: ((_ error: Error?) -> Void)? = nil) {
        remoteConfig.fetchAndActivate { (remoteConfigStatus, error) in
            if let error = error {
                Crashlytics.sharedInstance().recordError(error)
            } else {
                self.remoteConfigProvider.post {
                    $0.remoteConfigUpdated()
                }
            }
            completion?(error)
        }
    }

}
