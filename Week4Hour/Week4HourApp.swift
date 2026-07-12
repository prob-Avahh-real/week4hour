import SwiftUI

@main
struct Week4HourApp: App {
    @StateObject private var vm = DEALViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vm)
                .preferredColorScheme(.dark)
        }
    }
}
