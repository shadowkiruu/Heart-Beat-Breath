import SwiftUI
import UserNotifications

@main
struct Heart_Beat_Breath_Watch_AppApp: App {
    
    init() {
        requestNotificationPermissions()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notification permissions: \(error)")
            } else if granted {
                print("Notification permissions granted.")
            } else {
                print("Notification permissions denied.")
            }
        }
    }
}
