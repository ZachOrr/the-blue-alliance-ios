import GoogleCast
import Foundation

class CastService: NSObject {

    override init() {
        super.init()

        let criteria = GCKDiscoveryCriteria(applicationID: "52B0EBA6")
        let options = GCKCastOptions(discoveryCriteria: criteria)
        GCKCastContext.setSharedInstanceWith(options)

        // Enable logger
        /*
        let logFilter = GCKLoggerFilter()
        logFilter.minimumLevel = .error
        GCKLogger.sharedInstance().filter = logFilter
        GCKLogger.sharedInstance().delegate = self
        */
    }

    static func playWebcast(channel: String) {
        // Pass
    }

    private static func getWebcastURL(channel: String) {
        let url = URL(string: "https://pwn.sh/tools/streamapi.py?url=twitch.tv/\(channel)")!
        let session = URLSession.init(configuration: .default)
        session.dataTask(with: url) { (data, response, error) in
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                if let jsonDict = json as? [String: String] {
                    print(jsonDict)
                }
            } else {
                // Probably got a 'null' back from the API for the JSON
            }
        }
    }

}

extension CastService: GCKLoggerDelegate {

    func logMessage(_ message: String, at level: GCKLoggerLevel, fromFunction function: String, location: String) {
        print("[Google Cast] \(function) - \(message)")
    }

}
