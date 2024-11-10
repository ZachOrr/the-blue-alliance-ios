import Foundation

public enum Month: Int {
    case January = 1, February, March, April, May, June, July, August,
    September, October, November, December
}

public enum Weekday: Int {
    case Sunday = 1, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
}

extension Calendar {
    /**
     Number of weeks the season is - safely hardcoded to 6.
     */
    public var seasonLengthWeeks: Int {
        return 6
    }

    /**
     The year for the current date.
     */
    public var year: Int {
        get {
            return component(.year, from: Date())
        }
    }

    public var kickoff: Date {
        return kickoff(year)
    }

    public var stopBuildDay: Date {
        return stopBuildDay(year)
    }

    /*
     Computes the date of Kickoff for a given year. Kickoff is always the first Saturday in January after Jan 2nd.

     - Parameter year: The year to find the kickoff date for - defaults to current year if nil.

     - Returns: The date of Kickoff for the given year.
     */
    public func kickoff(_ year: Int) -> Date {
        let firstOfTheYearComponents = DateComponents(year: year, month: Month.January.rawValue, day: 2)
        return date(from: firstOfTheYearComponents)!.next(.Saturday)
    }

    /**
     Computes day teams are done working on robots. The stop build day is kickoff + 6 weeks + 3 days.

     - Parameter year: The year to find the stop build date for - defaults to current year if nil.

     - Returns: The stop build date for the given year.
     */
    public func stopBuildDay(_ year: Int) -> Date {
        let numberOfDaysInWeek = 7
        return date(byAdding: DateComponents(day: (numberOfDaysInWeek * seasonLengthWeeks + 3)), to: kickoff(year))!
    }

}
