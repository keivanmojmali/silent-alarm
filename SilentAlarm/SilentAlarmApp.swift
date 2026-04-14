import SwiftUI
import UserNotifications

@main
struct SilentAlarmApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    var statusBarItem: NSStatusItem?
    var popover: NSPopover?
    let alarmManager = AlarmManager()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        if let appIcon = NSImage(named: "AppIcon") {
            NSApp.applicationIconImage = appIcon
        }

        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }

        alarmManager.onAlarmTriggered = { [weak self] in
            self?.handleAlarmTriggered()
        }

        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let statusButton = statusBarItem?.button {
            let icon = NSImage(named: "MenuBarIcon")
            icon?.size = NSSize(width: 18, height: 18)
            icon?.isTemplate = true
            statusButton.image = icon
            statusButton.action = #selector(togglePopover)
            statusButton.target = self
        }

        popover = NSPopover()
        popover?.contentSize = NSSize(width: 340, height: 420)
        popover?.behavior = .transient
        popover?.animates = true
        popover?.contentViewController = NSHostingController(
            rootView: ContentView(alarmManager: alarmManager)
        )
    }

    private func handleAlarmTriggered() {
        sendNotification()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.forceShowPopover()
        }
    }

    private func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Silent Alarm"
        content.body = "Your timer has finished."
        content.sound = nil

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send notification: \(error)")
            }
        }
    }

    @objc func togglePopover() {
        guard let statusButton = statusBarItem?.button else { return }

        if let popover = popover {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: statusButton.bounds, of: statusButton, preferredEdge: .minY)
            }
        }
    }

    func forceShowPopover() {
        guard let statusButton = statusBarItem?.button else { return }
        NSApp.activate(ignoringOtherApps: true)
        popover?.show(relativeTo: statusButton.bounds, of: statusButton, preferredEdge: .minY)
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        forceShowPopover()
        completionHandler()
    }
}
