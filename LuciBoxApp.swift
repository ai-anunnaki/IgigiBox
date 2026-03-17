import SwiftUI

@main
struct LuciBoxApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var menuBarManager = MenuBarManager()
    @AppStorage("showMenuBar") private var showMenuBar = false
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .onAppear {
                    if showMenuBar {
                        menuBarManager.setupMenuBar()
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) { }
            
            CommandMenu("视图") {
                Toggle("菜单栏模式", isOn: $showMenuBar)
                    .keyboardShortcut("m", modifiers: [.command, .shift])
                    .onChange(of: showMenuBar) { newValue in
                        if newValue {
                            menuBarManager.setupMenuBar()
                        } else {
                            menuBarManager.hideMenuBar()
                        }
                    }
            }
        }
        
        Settings {
            SettingsView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return !UserDefaults.standard.bool(forKey: "showMenuBar")
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("进程管理", systemImage: "cpu")
                }
                .keyboardShortcut("1", modifiers: .command)
            
            FileManagerContentView()
                .tabItem {
                    Label("文件管理", systemImage: "folder")
                }
                .keyboardShortcut("2", modifiers: .command)
            
            ClipboardContentView()
                .tabItem {
                    Label("剪贴板", systemImage: "doc.on.clipboard")
                }
                .keyboardShortcut("3", modifiers: .command)
            
            SystemMonitorView()
                .tabItem {
                    Label("系统监控", systemImage: "chart.xyaxis.line")
                }
                .keyboardShortcut("4", modifiers: .command)
        }
        .frame(minWidth: 800, minHeight: 600)
    }
}

struct SettingsView: View {
    @AppStorage("showMenuBar") private var showMenuBar = false
    @AppStorage("autoRefreshInterval") private var autoRefreshInterval = 5.0
    
    var body: some View {
        Form {
            Section("外观") {
                Toggle("启用菜单栏模式", isOn: $showMenuBar)
                Text("启用后，应用将在菜单栏显示图标")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Section("性能") {
                Slider(value: $autoRefreshInterval, in: 1...10, step: 1) {
                    Text("自动刷新间隔")
                }
                Text("当前: \(Int(autoRefreshInterval)) 秒")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Section("关于") {
                HStack {
                    Text("版本")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("Bundle ID")
                    Spacer()
                    Text("org.igigi.lucibox")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("版权")
                    Spacer()
                    Text("© 2026 Igigi")
                        .foregroundColor(.gray)
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 500, height: 400)
    }
}


