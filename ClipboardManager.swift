import Foundation
import AppKit

struct ClipboardItem: Identifiable {
    let id = UUID()
    let content: String
    let timestamp: Date
    let type: String
}

class ClipboardManager: ObservableObject {
    @Published var currentContent: String = ""
    @Published var history: [ClipboardItem] = []
    
    private var timer: Timer?
    private var lastChangeCount: Int = 0
    private let maxHistoryCount = 100
    
    init() {
        loadHistory()
        startMonitoring()
        updateCurrentContent()
    }
    
    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        let changeCount = pasteboard.changeCount
        
        if changeCount != lastChangeCount {
            lastChangeCount = changeCount
            updateCurrentContent()
            
            if let string = pasteboard.string(forType: .string), !string.isEmpty {
                addToHistory(content: string, type: "文本")
            }
        }
    }
    
    func updateCurrentContent() {
        let pasteboard = NSPasteboard.general
        
        if let string = pasteboard.string(forType: .string) {
            DispatchQueue.main.async {
                self.currentContent = string
            }
        }
    }
    
    private func addToHistory(content: String, type: String) {
        // 避免重复添加相同内容
        if let last = history.first, last.content == content {
            return
        }
        
        let item = ClipboardItem(content: content, timestamp: Date(), type: type)
        
        DispatchQueue.main.async {
            self.history.insert(item, at: 0)
            
            // 限制历史记录数量
            if self.history.count > self.maxHistoryCount {
                self.history = Array(self.history.prefix(self.maxHistoryCount))
            }
            
            self.saveHistory()
        }
    }
    
    func copyToClipboard(_ content: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(content, forType: .string)
        updateCurrentContent()
    }
    
    func clearHistory() {
        history.removeAll()
        saveHistory()
    }
    
    func deleteHistoryItem(_ item: ClipboardItem) {
        history.removeAll { $0.id == item.id }
        saveHistory()
    }
    
    // 持久化
    private func saveHistory() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(history.map { HistoryData(content: $0.content, timestamp: $0.timestamp, type: $0.type) }) {
            UserDefaults.standard.set(encoded, forKey: "clipboardHistory")
        }
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: "clipboardHistory"),
           let decoded = try? JSONDecoder().decode([HistoryData].self, from: data) {
            history = decoded.map { ClipboardItem(content: $0.content, timestamp: $0.timestamp, type: $0.type) }
        }
    }
    
    deinit {
        stopMonitoring()
    }
}

struct HistoryData: Codable {
    let content: String
    let timestamp: Date
    let type: String
}
