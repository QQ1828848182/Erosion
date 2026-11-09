//
//  FileBrowserView.swift
//  AccessiblePlus
//
//  Created by lunginspector on 5/12/26.
//

import SwiftUI

import QuickLook
import Combine

enum FileSortMode: String, CaseIterable, Codable, Hashable {
    case system, name, date, type, size
    
    var id: String { label }
    
    var label: String {
        switch self {
        case .system: return "默认"
        case .name: return "名称"
        case .date: return "日期"
        case .type: return "类型"
        case .size: return "大小"
        }
    }
}

struct FileBrowserView: View {
    @EnvironmentObject var mgr: ErosionManager
    var path: URL = URL(fileURLWithPath: "/")
    var isContainer = false
    var shouldGrant = false
    
    @State private var dirFiles: [FileItem] = []
    @State private var unfilteredFiles: [FileItem] = []
    @State private var searchText = ""
    @AppStorage("maxInode") var maxInode = 7500000
    @AppStorage("chosenSort") var chosenSort: FileSortMode = .system
    @AppStorage("filesAscend") var filesAscend = true
    @AppStorage("listStyle") var listStyle = 1
    @AppStorage("hideDates") var hideDates = false
    @AppStorage("textViewerSize") var textViewerSize = 10
    @AppStorage("useMonospaced") var useMonospaced = true
    
    @State private var showFileImporter = false
    @State private var showFailure = false
    @State private var failMsg = ""
    @State private var isLoading = false
    @State private var hasLoaded = false
    
    var body: some View {
        List {
            if isLoading {
                Section {
                    VStack(alignment: .leading) {
                        HStack {
                            ProgressView()
                                .offset(y: 0.5)
                            Text("正在加载文件…")
                                .fontWeight(.medium)
                        }
                        if isContainer {
                            Text("由于获取容器路径的方法非常缓慢，这些文件可能需要 30 秒甚至更久才能加载完成。")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } else if showFailure {
                CompactAlert(title: "从目录加载文件失败！", symbol: "folder.badge.questionmark", text: failMsg)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            } else {
                ForEach(dirFiles) { file in
                    if file.type == .folder {
                        FolderRow(file: file, shouldGrant: isContainer ? true : false, isContainer: isContainer)
                    } else {
                        FileRow(file: file)
                    }
                }
            }
        }
        .navigationTitle(path.lastPathComponent)
        .navigationBarTitleDisplayMode(.inline)
        .customListStyle(listStyle)
        .adaptiveListMargin()
        .searchable(text: $searchText)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ForEach(FileSortMode.allCases, id: \.self) { option in
                        Button {
                            chosenSort = option
                        } label: {
                            if chosenSort == option {
                                Label(option.label, systemImage: "checkmark")
                                    .tag(option)
                            } else {
                                Text(option.label)
                                    .tag(option)
                            }
                        }
                    }
                    Divider()
                    Button {
                        filesAscend.toggle()
                    } label: {
                        if filesAscend {
                            Label("升序", systemImage: "chevron.up")
                        } else {
                            Label("降序", systemImage: "chevron.down")
                        }
                    }
                    .disabled(chosenSort == .system)
                } label: {
                    Label("排序", systemImage: "line.3.horizontal.decrease")
                }
                .labelStyle(.iconOnly)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    if !isContainer {
                        Menu {
                            Button {
                                Alertinator.shared.prompt(title: "你想给新文件取什么名字？请务必在末尾加上扩展名。", placeholder: "new.txt", completion: { name in
                                    let name = name ?? ""
                                    if !name.isEmpty {
                                        do {
                                            let fileURL = path.appendingPathComponent(name)
                                            try Data().write(to: fileURL)
                                            mgr.refreshFiles.toggle()
                                        } catch {
                                            print("(fm) 创建文件失败：\(error.localizedDescription)")
                                            Alertinator.shared.alert(title: "创建文件失败！", body: Errors.checkLogs)
                                        }
                                    }
                                })
                            } label: {
                                Label("文件", systemImage: "doc")
                            }
                            
                            Button {
                                Alertinator.shared.prompt(title: "你想给新属性列表取什么名字？", placeholder: "属性列表名称", completion: { name in
                                    let name = name ?? ""
                                    if !name.isEmpty {
                                        do {
                                            let fileURL = path.appendingPathComponent(name + ".plist")
                                            let data = try PropertyListSerialization.data(fromPropertyList: NSMutableDictionary(), format: .xml, options: 0)
                                            try data.write(to: fileURL)
                                            mgr.refreshFiles.toggle()
                                        } catch {
                                            print("(fm) 创建 Plist 失败：\(error.localizedDescription)")
                                            Alertinator.shared.alert(title: "创建属性列表失败！", body: Errors.checkLogs)
                                        }
                                    }
                                })
                            } label: {
                                Label("属性列表", systemImage: "tablecells")
                            }
                            
                            Button {
                                Alertinator.shared.prompt(title: "你想给新文件夹取什么名字？", placeholder: "文件夹名称", completion: { name in
                                    let name = name ?? ""
                                    if !name.isEmpty {
                                        do {
                                            try fm.createDirectoryIfNeeded(at: path.appendingPathComponent(name))
                                            mgr.refreshFiles.toggle()
                                        } catch {
                                            print("(fm) 创建文件夹失败：\(error.localizedDescription)")
                                            Alertinator.shared.alert(title: "创建文件夹失败！", body: Errors.checkLogs)
                                        }
                                    }
                                })
                            } label: {
                                Label("文件夹", systemImage: "folder")
                            }
                            
                            Button {
                                Alertinator.shared.prompt(title: "你希望新的符号链接指向哪里？", placeholder: "/path/to/dir", completion: { symPath in
                                    let symPath = symPath ?? ""
                                    if !symPath.isEmpty {
                                        do {
                                            try fm.createSymbolicLink(atPath: path.appendingPathComponent(URL(fileURLWithPath: symPath).lastPathComponent).path, withDestinationPath: symPath)
                                            mgr.refreshFiles.toggle()
                                        } catch {
                                            print("(fm) 创建符号链接失败：\(error.localizedDescription)")
                                            Alertinator.shared.alert(title: "创建符号链接失败！", body: "\(error.localizedDescription)")
                                        }
                                    }
                                })
                            } label: {
                                Label("符号链接", systemImage: "arrow.up.right.circle")
                            }
                        } label: {
                            Label("新建…", systemImage: "plus")
                        }
                        
                        Button {
                            showFileImporter.toggle()
                        } label: {
                            Label("导入文件", systemImage: "arrow.down.doc")
                        }
                        Divider()
                    }
                    NavigationLink {
                        FileBrowserView(path: URL.documentsDirectory)
                    } label: {
                        Label("打开应用文档", systemImage: "folder")
                    }
                    NavigationLink {
                        List {
                            Section {
                                HStack {
                                    Text("最大 Inode")
                                    TextField("7500000", value: $maxInode, format: .number)
                                        .multilineTextAlignment(.trailing)
                                }
                            } header: {
                                HeaderLabel("容器抓取", symbol: "externaldrive")
                            } footer: {
                                Text("这会控制文件的加载速度。数值越低 = 抓取越快，但文件数量越少。")
                            }
                            
                            Section {
                                Picker("列表样式", selection: $listStyle) {
                                    Text("默认").tag(1)
                                    Text("普通").tag(2)
                                    Text("分组").tag(3)
                                }
                                Toggle("隐藏日期", isOn: $hideDates)
                            } header: {
                                HeaderLabel("显示选项", symbol: "eye")
                            }
                            
                            Section {
                                Stepper(value: $textViewerSize) {
                                    HStack {
                                        Text("文字大小")
                                        Spacer()
                                        Text(textViewerSize.description)
                                    }
                                }
                                Toggle("等宽字体", isOn: $useMonospaced)
                            } header: {
                                HeaderLabel("文本查看器", symbol: "doc.plaintext")
                            }
                        }
                        .navigationTitle("文件浏览设置")
                    } label: {
                        Label("设置", systemImage: "gearshape")
                    }
                } label: {
                    Label("操作", systemImage: "ellipsis")
                }
                .labelStyle(.iconOnly)
            }
        }
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.item]) { result in
            handleImport(result)
        }
        .refreshable {
            mgr.refreshFiles.toggle()
        }
        .onAppear {
            if !mgr.storedFiles.isEmpty && mgr.storedURL == path {
                dirFiles = sortFiles(files: mgr.storedFiles)
                unfilteredFiles = sortFiles(files: mgr.storedFiles)
            } else if isContainer && hasLoaded {
                // do nothing as it's already being stored in the variable
            } else {
                if shouldGrant {
                    let res = wq.grantAccess(path: path.path)
                    if res.0 {
                        loadFilesFromPath()
                    } else {
                        showFailure = true
                        failMsg = "你没有权限查看此目录。"
                    }
                } else {
                    loadFilesFromPath()
                }
            }
        }
        // I want to talk to the Apple Engineer who thought it would be cool to remove the one-parameter action closure from onChange.
        .onChange(of: searchText) { (newSearch, _) in
            dirFiles = unfilteredFiles.filter { $0.name.localizedCaseInsensitiveContains(newSearch) }
        }
        .modifier(KeyboardDismissObserver() {
            dirFiles = unfilteredFiles
        })
        .onChange(of: chosenSort) {
            loadFilesFromPath()
        }
        .onChange(of: filesAscend) {
            loadFilesFromPath()
        }
        .onChange(of: mgr.refreshFiles) {
            loadFilesFromPath()
        }
    }
    
    // MARK: handle files
    private func loadFilesFromPath() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                var unsortedFiles: [FileItem] = []
                if isContainer {
                    let paths = fsHandlers.getDirPaths(path.path, maxInode: Int64(maxInode))
                    for path in paths {
                        unsortedFiles.append(getFileItem(at: URL(fileURLWithPath: path), isContainer: true))
                    }
                } else {
                    let pathFiles = try fm.contentsOfDirectory(at: path, includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey, .fileSizeKey, .contentModificationDateKey])
                    
                    unsortedFiles = pathFiles.map { fileURL in
                        if path == FSURL.appGroup || path == FSURL.systemData {
                            return getFileItem(at: fileURL, isContainer: true)
                        } else {
                            return getFileItem(at: fileURL)
                        }
                    }
                }
                dirFiles = sortFiles(files: unsortedFiles)
                unfilteredFiles = sortFiles(files: unsortedFiles)
                if isContainer {
                    mgr.storedFiles = unsortedFiles
                    mgr.storedURL = path
                }
                hasLoaded = true
            } catch {
                print("(fm) 从 \(path) 加载文件失败：\(error.localizedDescription)")
                showFailure = true
                failMsg = "你可能没有权限查看此目录。查看错误日志以获取更详细的信息。"
            }
            isLoading = false
        }
    }
    
    private func sortFiles(files: [FileItem]) -> [FileItem] {
        var sortedFiles: [FileItem]
        
        switch chosenSort {
        case .system:
            sortedFiles = files
        case .name:
            sortedFiles = files.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        case .date:
            sortedFiles = files.sorted { $0.modifiedDate > $1.modifiedDate }
        case .type:
            sortedFiles = files.sorted { $0.type.sortOrder < $1.type.sortOrder }
        case .size:
            sortedFiles = files.sorted { $0.size < $1.size }
        }

        sortedFiles = filesAscend ? sortedFiles : sortedFiles.reversed()
        sortedFiles = sortedFiles.sorted { a, b in
            a.hidden && !b.hidden
        }
        return sortedFiles
    }
    
    // MARK: handle import
    private func handleImport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let fileURL):
            do {
                let stopAccess = fileURL.startAccessingSecurityScopedResource()
                defer {
                    if stopAccess {
                        fileURL.stopAccessingSecurityScopedResource()
                    }
                }
                let data = try Data(contentsOf: fileURL)
                
                let newURL = path.appendingPathComponent(fileURL.lastPathComponent)
                try? fm.removeItem(at: newURL)
                
                try data.write(to: newURL)
                mgr.refreshFiles.toggle()
            } catch {
                print("(fm) 导入文件失败：\(error.localizedDescription)")
                Alertinator.shared.alert(title: "导入文件失败！", body: "\(error.localizedDescription)")
            }
        case .failure(let error):
            print("(fm) 导入文件失败：\(error.localizedDescription)")
            Alertinator.shared.alert(title: "导入文件失败！", body: "\(error.localizedDescription)")
        }
    }
}

// MARK: user interface
extension View {
    @ViewBuilder
    func customListStyle(_ selection: Int) -> some View {
        switch selection {
        case 2: self.listStyle(.inset)
        case 3: self.listStyle(.grouped)
        default: self.listStyle(.insetGrouped)
        }
    }
    
    @ViewBuilder
    func adaptiveListMargin() -> some View {
        if #available(iOS 26.0, *) {
            self.contentMargins(.top, 1)
        }
    }
}

struct KeyboardDismissObserver: ViewModifier {
    var action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onReceive(Publishers.keyboardDismissed) { _ in
                action()
            }
    }
}

extension Publishers {
    static var keyboardDismissed: AnyPublisher<Void, Never> {
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardDidHideNotification)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}
