import FirebaseDatabase
import Foundation

protocol GameDaySpecialEvent: GameDayWebcast {
    var keyName: String { get }
    var name: String { get }
}

protocol GameDayEvent {
    var key: String { get }
    var name: String { get }
    var shortName: String { get }
    var webcasts: [GameDayWebcast] { get }
}

protocol GameDayWebcast {
    var channel: String { get }
    var status: String { get } // TODO: Set this to be GameDay status or something - webcast status? It exists somewhere else
    var title: String { get }
    var type: String { get }
    var thumbnail: String { get }
}

struct WebcastDatabaseService {

    public var specialWebcasts: [GameDaySpecialEvent] = []
    public var liveEvents: [GameDayEvent] = []

    init(database: Database) {
        let ref = database.reference()

        ref.child("special_webcasts").observe(.value) { (snapshot) in
            guard let value = snapshot.value as? [[String: String]] else {
                return
            }
            print(value)
        }

        ref.child("live_events").observe(.value) { (snapshot) in
            guard let value = snapshot.value as? [[String: String]] else {
                return
            }
            print(value)
        }
    }

}
