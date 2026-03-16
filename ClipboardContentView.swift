import SwiftUI

struct ClipboardContentView: View {
    @StateObject private var clipboardManager = ClipboardManager()
    @State private var searchText = ""
    
    var filteredHistory: [ClipboardItem] {
        if searchText.isEmpty {
            return clipboardManager.history
        }
        return clipboardManager.history.filter { $0.content.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 当前剪贴板内容
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("当前剪贴板")
                        .font(.headline)
                    Spacer()
                    Button(action: {
                        clipboardManager.copyToClipboard("")
                    }) {
                        Label("清空", systemImage: "trash")
                    }
                    .buttonStyle(.bordered)
                }
                
                ScrollView {
                    Text(clipboardManager.currentContent.isEmpty ? "（空）" : clipboardManager.currentContent)
                        .font(.system(.body, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(4)
                }
                .frame(height: 120)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // 搜索栏
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("搜索历史记录", text: $searchText)
                    .textFieldStyle(.plain)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
                
                Button(action: {
                    clipboardManager.clearHistory()
                }) {
                    Label("清空历史", systemImage: "trash.circle")
                }
                .buttonStyle(.bordered)
            }
            .padding()
            
            // 历史记录列表
            if filteredHistory.isEmpty {
                VStack {
                    Spacer()
                    Image(systemName: "doc.on.clipboard")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    Text("暂无历史记录")
                        .foregroundColor(.gray)
                    Spacer()
                }
            } else {
                List(filteredHistory) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(item.timestamp, style: .time)
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text(item.type)
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(4)
                            
                            Spacer()
                            
                            Button(action: {
                                clipboardManager.copyToClipboard(item.content)
                            }) {
                                Image(systemName: "doc.on.doc")
                            }
                            .buttonStyle(.borderless)
                            
                            Button(action: {
                                clipboardManager.deleteHistoryItem(item)
                            }) {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.borderless)
                            .foregroundColor(.red)
                        }
                        
                        Text(item.content)
                            .font(.system(.body, design: .monospaced))
                            .lineLimit(3)
                            .truncationMode(.tail)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}
