import SwiftUI

struct ContentView: View {
    @StateObject private var processManager = ProcessManager()
    @State private var searchText = ""
    @State private var selectedProcess: Process?
    @State private var showingKillAlert = false
    
    var filteredProcesses: [Process] {
        if searchText.isEmpty {
            return processManager.processes
        }
        return processManager.processes.filter { process in
            process.name.localizedCaseInsensitiveContains(searchText) ||
            "\(process.pid)".contains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索栏
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("搜索进程名称或PID", text: $searchText)
                        .textFieldStyle(.plain)
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(8)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                .padding()
                
                // 进程列表
                Table(filteredProcesses) {
                    TableColumn("PID") { process in
                        Text("\(process.pid)")
                            .font(.system(.body, design: .monospaced))
                    }
                    .width(min: 60, max: 80)
                    
                    TableColumn("进程名称") { process in
                        Text(process.name)
                    }
                    .width(min: 200)
                    
                    TableColumn("端口") { process in
                        if process.ports.isEmpty {
                            Text("-")
                                .foregroundColor(.gray)
                        } else {
                            Text(process.ports.map { "\($0)" }.joined(separator: ", "))
                                .font(.system(.body, design: .monospaced))
                        }
                    }
                    .width(min: 100)
                    
                    TableColumn("操作") { process in
                        Button("杀掉") {
                            selectedProcess = process
                            showingKillAlert = true
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                    .width(min: 80, max: 80)
                }
            }
            .navigationTitle("鸬鹚工具箱 - 进程管理")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { processManager.refreshProcesses() }) {
                        Label("刷新", systemImage: "arrow.clockwise")
                    }
                }
            }
        }
        .onAppear {
            processManager.refreshProcesses()
        }
        .alert("确认杀掉进程", isPresented: $showingKillAlert, presenting: selectedProcess) { process in
            Button("取消", role: .cancel) { }
            Button("杀掉", role: .destructive) {
                if processManager.killProcess(pid: process.pid) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        processManager.refreshProcesses()
                    }
                }
            }
        } message: { process in
            Text("确定要杀掉进程 \(process.name) (PID: \(process.pid)) 吗？")
        }
    }
}

#Preview {
    ContentView()
}
