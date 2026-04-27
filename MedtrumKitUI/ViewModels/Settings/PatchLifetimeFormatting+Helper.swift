import SwiftUI

class PatchLifetimeFormatting {
    let DAY = String(localized: "day", comment: "Unit for singular day")
    let DAYS = String(localized: "days", comment: "Unit for plural days")

    let HOUR = String(localized: "hour", comment: "Unit for singular hour")
    let HOURS = String(localized: "hours", comment: "Unit for plural hours")

    let MINUTE = String(localized: "minute", comment: "Unit for singular minute")
    let MINUTES = String(localized: "minutes", comment: "Unit for plural minutes")
}

extension PatchLifetimeFormatting {
    func processPatchLifetime(_ startDate: Date, _ endDate: Date) -> String {
        let lifetime = max(0, endDate.timeIntervalSince(startDate))

        let days = Int(lifetime.days.rounded(.towardZero))
        let hours = Int(lifetime.hours.truncatingRemainder(dividingBy: 24).rounded(.towardZero))
        let minutes = Int(lifetime.minutes.truncatingRemainder(dividingBy: 60).rounded(.towardZero))

        if days > 0 {
            if hours == 0 {
                return [
                    "\(days) \(days == 1 ? DAY : DAYS)",
                    "\(minutes) \(minutes == 1 ? MINUTE : MINUTES)"
                ].joined(separator: " ")
            }

            return [
                "\(days) \(days == 1 ? DAY : DAYS)",
                "\(hours) \(hours == 1 ? HOUR : HOURS)"
            ].joined(separator: " ")
        }

        if hours == 0 {
            return "\(minutes) \(minutes == 1 ? MINUTE : MINUTES)"
        }

        return [
            "\(hours) \(hours == 1 ? HOUR : HOURS)",
            "\(minutes) \(minutes == 1 ? MINUTE : MINUTES)"
        ].joined(separator: " ")
    }
}
