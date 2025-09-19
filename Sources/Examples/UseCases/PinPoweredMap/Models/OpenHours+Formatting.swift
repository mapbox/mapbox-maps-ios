import Foundation

extension FeatureDetails.Properties.Metadata.OpenHours {
    var formattedStatus: String {
        guard let periods = self.periods else { return "Hours unavailable" }

        let now = Date()
        let calendar = Calendar.current
        let currentDay = calendar.component(.weekday, from: now) - 1

        switch openStatus {
        case .open:
            // Find closing time for today
            for period in periods {
                if let open = period.open,
                   let openDay = open.day,
                   let openTime = period.open?.time, let closeTime = period.close?.time {

                    let openTimeInt = Int(openTime) ?? 0
                    let currentTime = calendar.component(.hour, from: now) * 100 + calendar.component(.minute, from: now)

                    if openDay == currentDay && currentTime >= openTimeInt {
                        return "until \(formatTime(closeTime))"
                    }
                }
            }
            return ""
        case .opens:
            // Check today first
            for period in periods {
                if let open = period.open, let openDay = open.day, let openTime = open.time {
                    if openDay == currentDay {
                        let openTimeInt = Int(openTime) ?? 0
                        let currentTime = calendar.component(.hour, from: now) * 100 + calendar.component(.minute, from: now)

                        if currentTime < openTimeInt {
                            return "today at \(formatTime(openTime))"
                        }
                    }
                }
            }

            // Check next 7 days for opening
            for dayOffset in 1...7 {
                let checkDay = (currentDay + dayOffset) % 7

                for period in periods {
                    if let open = period.open, let openDay = open.day, let openTime = open.time {
                        if openDay == checkDay {
                            let dayName = formatDayName(checkDay)
                            return "\(dayName) at \(formatTime(openTime))"
                        }
                    }
                }
            }
            return ""
        default:
            return ""
        }
    }

    enum OpenStatus {
        case open
        case opens
        case closed

        var description: String {
            return switch self {
            case .open: "Open"
            case .opens: "Opens"
            case .closed: "Closed"
            }
        }
    }

    var openStatus: OpenStatus {
        guard let periods = self.periods else { return .closed }

        let now = Date()
        let calendar = Calendar.current
        let currentDay = calendar.component(.weekday, from: now) - 1 // Convert to 0-6 (Sunday = 0)
        let currentTime = calendar.component(.hour, from: now) * 100 + calendar.component(.minute, from: now)

        // Find today's hours
        for period in periods {
            if let open = period.open, let close = period.close,
               let openDay = open.day, let closeDay = close.day,
               let openTime = period.open?.time, let closeTime = period.close?.time {

                // Convert time strings to integers (e.g., "1430" -> 1430)
                let openTimeInt = Int(openTime) ?? 0
                let closeTimeInt = Int(closeTime) ?? 2359

                // Check if current day matches
                if openDay == currentDay {
                    // Handle same-day hours
                    if openDay == closeDay {
                        return (currentTime >= openTimeInt && currentTime <= closeTimeInt) ? .open : .opens
                    }
                    // Handle overnight hours (open today, close tomorrow)
                    else if closeDay == (currentDay + 1) % 7 {
                        return (currentTime >= openTimeInt) ? .open : .opens
                    }
                }
                // Handle overnight hours (opened yesterday, close today)
                else if openDay == (currentDay - 1 + 7) % 7 && closeDay == currentDay {
                    return (currentTime <= closeTimeInt) ? .open : .opens
                }
            }
        }

        return .closed
    }

    private func formatTime(_ timeString: String) -> String {
        guard timeString.count == 4,
              let timeInt = Int(timeString) else { return timeString }

        let hours = timeInt / 100
        let minutes = timeInt % 100

        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short  // Uses locale-appropriate short time format

        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = hours
        components.minute = minutes

        if let date = calendar.date(from: components) {
            return formatter.string(from: date)
        }

        return timeString
    }

    private func formatDayName(_ dayIndex: Int) -> String {
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date()) - 1

        if dayIndex == today {
            return "today"
        } else if dayIndex == (today + 1) % 7 {
            return "tomorrow"
        } else {
            // Create a date for the target day and format it
            let daysFromNow = (dayIndex - today + 7) % 7
            let targetDate = calendar.date(byAdding: .day, value: daysFromNow, to: Date())!
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE" // Full weekday name in user's locale
            return formatter.string(from: targetDate)
        }
    }
}
