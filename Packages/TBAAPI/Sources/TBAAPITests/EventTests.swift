import Testing
@testable import TBAAPI

struct EventTests {
    @Test func doNothing() {

    }

    struct EventTypeTests {
        @Test func eventTypeSorted() async throws {
            let eventTypes = EventType.allCases
            let expected: [EventType] = [.preseason, .regional, .district, .remote, .districtChampionshipDivision, .districtChampionship, .championshipDivision, .championshipFinals, .festivalOfChampions, .offseason, .unlabeled]
            try #require(eventTypes.count == expected.count, "Unsupported event type - update test")
            for _ in 0..<500000 {
                #expect(eventTypes.shuffled().sorted() == expected)
            }
        }
    }
}
