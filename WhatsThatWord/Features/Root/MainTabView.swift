import SwiftUI

struct MainTabView: View {
    @State private var tab = 0
    @State private var showAdd = false
    @State private var openedFromAdd: UUID?

    var body: some View {
        TabView(selection: $tab) {
            HomeView(showAdd: $showAdd, openedEntryID: $openedFromAdd)
                .tabItem { Label("Home", systemImage: "house") }
                .tag(0)

            LibraryView(showAdd: $showAdd)
                .tabItem { Label("Words", systemImage: "textformat") }
                .tag(1)

            ReviewHubView()
                .tabItem { Label("Review", systemImage: "rectangle.on.rectangle") }
                .tag(2)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(3)
        }
        .sheet(isPresented: $showAdd) {
            AddWordSheet { entry in
                openedFromAdd = entry.entryID
                tab = 0
            }
        }
    }
}
