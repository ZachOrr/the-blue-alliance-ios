import CoreData
import Foundation
import TBAKit

// https://github.com/the-blue-alliance/the-blue-alliance/blob/52b459db5e1a1a0a0bb70c76e6ceccbe2f603227/static/swagger/api_v3.json#L4843
public enum WebcastType: String {
    case youtube = "youtube"
    case twitch = "twitch"
    case ustream = "ustream"
    case iframe = "iframe"
    case html5 = "html5"
    case rtmp = "rtmp"
    case livestream = "livestream"

    fileprivate static var gameDayTypes: [String] {
        return [WebcastType.twitch.rawValue]
    }
}

extension Webcast {

    public var supportedInGameDay: Bool {
        return WebcastType.gameDayTypes.contains(type)
    }

    public var displayName: String {
        if type == "youtube" {
            return "YouTube"
        } else if type == "twitch" {
            return "Twitch"
        } else if type == "direct_link" {
            // Convert our direct link string in to just the domain
            // Ex: espn.com
            guard let url = URL(string: channel), let host = url.host else {
                return "website"
            }
            let parts = host.split(separator: ".")
            // Only return last two components "etc.com"
            return parts.dropFirst(max(parts.count - 2, 0)).joined(separator: ".")
        }
        return type
    }

    public var urlString: String? {
        if type == "twitch" {
            return "https://twitch.tv/\(channel)"
        } else if type == "youtube" {
            return "https://www.youtube.com/watch?v=\(channel)"
        } else if type == "direct_link" {
            return channel
        }
        return nil
    }

    public var channel: String {
        guard let channel = getValue(\Webcast.channelRaw) else {
            fatalError("Save Webcast before accessing channel")
        }
        return channel
    }

    public var date: Date? {
        return getValue(\Webcast.dateRaw)
    }

    public var file: String? {
        return getValue(\Webcast.fileRaw)
    }

    public var type: String {
        guard let type = getValue(\Webcast.typeRaw) else {
            fatalError("Save Webcast before accessing type")
        }
        return type
    }

    public var events: [Event] {
        guard let eventsRaw = getValue(\Webcast.eventsRaw),
            let events = eventsRaw.allObjects as? [Event] else {
                return []
        }
        return events
    }

}

@objc(Webcast)
public class Webcast: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Webcast> {
        return NSFetchRequest<Webcast>(entityName: Webcast.entityName)
    }

    @NSManaged var channelRaw: String?
    @NSManaged var dateRaw: Date?
    @NSManaged var fileRaw: String?
    @NSManaged var typeRaw: String?
    @NSManaged var eventsRaw: NSSet?

}

// MARK: Generated accessors for eventsRaw
extension Webcast {

    @objc(addEventsRawObject:)
    @NSManaged func addToEventsRaw(_ value: Event)

    @objc(removeEventsRawObject:)
    @NSManaged func removeFromEventsRaw(_ value: Event)

    @objc(addEventsRaw:)
    @NSManaged func addToEventsRaw(_ values: NSSet)

    @objc(removeEventsRaw:)
    @NSManaged func removeFromEventsRaw(_ values: NSSet)

}

extension Webcast: Managed {

    /**
     Insert a Webcast with values from a TBAKit Webcast model in to the managed object context.

     - Important: Method does not manage relationship between Webcast and Event.

     - Parameter model: The TBAKit Webcast representation to set values from.

     - Parameter eventKey: The key for the Event the Webcast belongs to.

     - Parameter context: The NSManagedContext to insert the Webcast in to.

     - Returns: The inserted Webcast.
     */
    public static func insert(_ model: TBAWebcast, in context: NSManagedObjectContext) -> Webcast {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                    #keyPath(Webcast.typeRaw), model.type,
                                    #keyPath(Webcast.channelRaw), model.channel)

        return findOrCreate(in: context, matching: predicate, configure: { (webcast) in
            // Required: type, channel
            webcast.typeRaw = model.type
            webcast.channelRaw = model.channel
            webcast.dateRaw = model.date
            webcast.fileRaw = model.file
        })
    }

}

extension Webcast: Orphanable {

    public var isOrphaned: Bool {
        return events.count == 0
    }

}
