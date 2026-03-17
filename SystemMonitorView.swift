import SwiftUI
import Charts

struct SystemMonitorView: View {
    @StateObject private var monitor = SystemMonitor()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // CPU使用率
                MonitorCard(
                    title: "CPU使用率",
                    value: monitor.systemInfo.cpuUsage,
                    unit: "%",
                    color: .blue,
                    icon: "cpu"
                )
                
                // 内存使用率
                MonitorCard(
                    title: "内存使用率",
                    value: monitor.systemInfo.memoryUsage,
                    unit: "%",
                    color: .green,
                    icon: "memorychip"
                )
                
                // 磁盘使用率
                MonitorCard(
                    title: "磁盘使用率",
                    value: monitor.systemInfo.diskUsage,
                    unit: "%",
                    color: .orange,
                    icon: "internaldrive"
                )
                
                // 网络速度
                VStack(alignment: .leading, spacing: 12) {
                    Label("网络速度", systemImage: "network")
                        .font(.headline)
                    
                    HStack(spacing: 20) {
                        VStack(alignment: .leading) {
                            Text("上传")
                                .font(.caption)
                                .foregroundColor(.gray)
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text(String(format: "%.2f", monitor.systemInfo.networkUpload))
                                    .font(.system(.title2, design: .rounded))
                                    .fontWeight(.semibold)
                                Text("MB/s")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading) {
                            Text("下载")
                                .font(.caption)
                                .foregroundColor(.gray)
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text(String(format: "%.2f", monitor.systemInfo.networkDownload))
                                    .font(.system(.title2, design: .rounded))
                                    .fontWeight(.semibold)
                                Text("MB/s")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(12)
            }
            .padding()
        }
        .onAppear {
            monitor.startMonitoring()
        }
        .onDisappear {
            monitor.stopMonitoring()
        }
    }
}

struct MonitorCard: View {
    let title: String
    let value: Double
    let unit: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.headline)
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(String(format: "%.1f", value))
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(color)
                Text(unit)
                    .font(.title3)
                    .foregroundColor(.gray)
            }
            
            ProgressView(value: value, total: 100)
                .tint(color)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}
