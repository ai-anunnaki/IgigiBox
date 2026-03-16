import SwiftUI

@main
struct LuciBoxApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("进程管理", systemImage: "cpu")
                }
            
            FileManagerContentView()
                .tabItem {
                    Label("文件管理", systemImage: "folder")
                }
            
            ClipboardContentView()
                .tabItem {
                    Label("剪贴板", systemImage: "doc.on.clipboard")
                }
        }
        .frame(minWidth: 800, minHeight: 600)
    }
}

