import Foundation
import TBAData

// TODO: Maybe move this one? No idea...
enum GameDayStatus {
    case none
    case online
    case offline
}

struct EventGameDayCellViewModel {

    let title: String
    let subtitle: String
    let gameDayStatus: GameDayStatus

    init(event: Event) {
        self.title = "Watch on GameDay"
        // TODO: We need to work on this copy
        self.subtitle = "\(event.gameDayWebcasts.count) webcasts"
        self.gameDayStatus = .online
    }

    init(webcast: Webcast) {
        self.title = "Watch on \(webcast.displayName)"
        self.subtitle = webcast.channel
        self.gameDayStatus = .none
    }

}
