import SwiftUI
import AppKit

class MenuBarManager: ObservableObject {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    
    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "bird", accessibilityDescription: "鸬鹚工具箱")
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 400, height: 500)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: MenuBarContentView())
    }
    
    @objc func togglePopover() {
        guard let button = statusItem?.button else { return }
        
        if let popover = popover {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
    
    func hideMenuBar() {
        if let statusItem = statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
            self.statusItem = nil
        }
    }
}

struct MenuBarContentView: View {
    @StateObject private var systemMonitor = SystemMonitor()
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Image(systemName: "bird")
                Text("鸬鹚工具箱")
                    .font(.headline)
                Spacer()
                Button(action: {
                    NSApplication.shared.activate(ignoringOtherApps: true)
                    NSApp.windows.first?.makeKeyAndOrderFront(nil)
                }) {
                    Image(systemName: "arrow.up.right.square")
                }
                .buttonStyle(.borderless)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // 快速信息
            ScrollView {
                VStack(spacing: 12) {
                    QuickInfoRow(
                        icon: "cpu",
                        title: "CPU",
                        value: String(format: "%.1f%%", systemMonitor.systemInfo.cpuUsage),
                        color: .blue
                    )
                    
                    QuickInfoRow(
                        icon: "memorychip",
                        title: "内存",
                        value: String(format: "%.1f%%", systemMonitor.systemInfo.memoryUsage),
                        color: .green
                    )
                    
                    QuickInfoRow(
                        icon: "internaldrive",
                        title: "磁盘",
                        value: String(format: "%.1f%%", systemMonitor.systemInfo.diskUsage),
                        color: .orange
                    )
                    
                    QuickInfoRow(
                        icon: "arrow.up",
                        title: "上传",
                        value: String(format: "%.2f MB/s", systemMonitor.systemInfo.networkUpload),
                        color: .purple
                    )
                    
                    QuickInfoRow(
                        icon: "arrow.down",
                        title: "下载",
                        value: String(format: "%.2f MB/s", systemMonitor.systemInfo.networkDownload),
                        color: .pink
                    )
                }
                .padding()
            }
            
            Divider()
            
            // 底部按钮
            HStack {
                Button("退出") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 400, height: 500)
        .onAppear {
            systemMonitor.startMonitoring()
        }
    }
}

struct QuickInfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            Text(title)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.system(.body, design: .monospaced))
                .fontWeight(.medium)
        }
        .padding(.vertical, 4)
    }
}
