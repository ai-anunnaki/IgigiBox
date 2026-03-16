import Foundation

struct Process: Identifiable {
    let id = UUID()
    let pid: Int32
    let name: String
    let ports: [Int]
}

class ProcessManager: ObservableObject {
    @Published var processes: [Process] = []
    
    func refreshProcesses() {
        var processList: [Process] = []
        
        // 获取所有进程
        let task = Foundation.Process()
        task.launchPath = "/bin/ps"
        task.arguments = ["-eo", "pid,comm"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8) {
            let lines = output.components(separatedBy: "\n")
            
            for line in lines.dropFirst() {
                let components = line.trimmingCharacters(in: .whitespaces).components(separatedBy: .whitespaces)
                if components.count >= 2,
                   let pid = Int32(components[0]) {
                    let name = components[1...].joined(separator: " ")
                    let ports = getPortsForPID(pid)
                    processList.append(Process(pid: pid, name: name, ports: ports))
                }
            }
        }
        
        DispatchQueue.main.async {
            self.processes = processList
        }
    }
    
    private func getPortsForPID(_ pid: Int32) -> [Int] {
        var ports: [Int] = []
        
        let task = Foundation.Process()
        task.launchPath = "/usr/sbin/lsof"
        task.arguments = ["-Pan", "-p", "\(pid)", "-i"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()
        
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            
            if let output = String(data: data, encoding: .utf8) {
                let lines = output.components(separatedBy: "\n")
                for line in lines {
                    if line.contains("TCP") || line.contains("UDP") {
                        let components = line.components(separatedBy: .whitespaces)
                        for component in components {
                            if component.contains(":") {
                                let parts = component.components(separatedBy: ":")
                                if let portStr = parts.last,
                                   let port = Int(portStr.components(separatedBy: "->").first ?? "") {
                                    ports.append(port)
                                }
                            }
                        }
                    }
                }
            }
        } catch {
            // 忽略错误
        }
        
        return Array(Set(ports)).sorted()
    }
    
    func killProcess(pid: Int32) -> Bool {
        let task = Foundation.Process()
        task.launchPath = "/bin/kill"
        task.arguments = ["-9", "\(pid)"]
        
        do {
            try task.run()
            task.waitUntilExit()
            return task.terminationStatus == 0
        } catch {
            return false
        }
    }
}
