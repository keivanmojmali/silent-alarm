import SwiftUI
import Foundation
import UserNotifications

class AlarmManager: ObservableObject {
    @Published var activeAlarm: AlarmItem?
    private var timer: Timer?

    var onAlarmTriggered: (() -> Void)?

    func startAlarm(targetDate: Date, color: Color) {
        stopAlarm()
        activeAlarm = AlarmItem(targetDate: targetDate, color: color)
        startTimer()
    }

    func stopAlarm() {
        timer?.invalidate()
        timer = nil
        activeAlarm = nil
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        guard var alarm = activeAlarm else { return }

        if Date() >= alarm.targetDate && !alarm.isTriggered {
            alarm.isTriggered = true
            alarm.flashOpacity = 0.3
            activeAlarm = alarm
            onAlarmTriggered?()
        } else {
            alarm.updateRemainingTime()
            activeAlarm = alarm
        }
    }
}

struct AlarmItem: Identifiable {
    let id = UUID()
    let targetDate: Date
    let color: Color
    var isTriggered = false
    var flashOpacity: Double = 1.0
    var remainingTime = ""

    mutating func updateRemainingTime() {
        let remaining = targetDate.timeIntervalSince(Date())

        guard remaining > 0 else {
            remainingTime = "00:00"
            return
        }

        let h = Int(remaining) / 3600
        let m = Int(remaining) % 3600 / 60
        let s = Int(remaining) % 60

        remainingTime = h > 0
            ? String(format: "%02d:%02d:%02d", h, m, s)
            : String(format: "%02d:%02d", m, s)
    }
}
