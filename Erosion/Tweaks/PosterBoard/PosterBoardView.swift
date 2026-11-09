//
//  PosterBoardView.swift
//  Erosion
//
//  Created by lunginspector on 8/19/26.
//

import SwiftUI

import UniformTypeIdentifiers

let pbHandler = PBHandler()

enum PBMsg {
    static var noTendies = "导入一些 tendies 即可开始应用自定义壁纸。"
    static var tooManyTendies = "一次最多只能设置 15 张壁纸。如果想应用这个壁纸包，请先取消选择另一个。"
    static var limitWarning = "你已设置超过五张壁纸。这可能导致部分壁纸无法正常显示。你仍然确定要应用这些壁纸吗？"
    static var corruption = "请确认没有任何壁纸已损坏，然后重试。"
    static var finishApply = "继续后 PosterBoard 将会打开。请从应用切换器中结束它。如果没有出现壁纸，请尝试在设置中重置 Collections、MercuryPoster 或 Videos。"
    static var applyInfo = "如果 PosterBoard 中没有出现壁纸，请在设置中重置 Collections 后重试。"
    static var imprtFailed = "请确认你已选择有效的壁纸文件，然后重试。"
}

struct PosterBoardView: View {
    @AppStorage("pbContainerPath") private var pbContainerPath = ""
    @AppStorage("tendiesArray") private var tendiesArray: [TendiesObject] = []
    @AppStorage("hasShownFirstRunMsg") private var hasShownFirstRunMsg = false
    
    @State private var showImporter = false
    let columns = Array(repeating: GridItem(.flexible()), count: device.userInterfaceIdiom == .pad ? 4 : 2)
    
    var body: some View {
        ScrollView {
            if tendiesArray.isEmpty {
                Button {
                    showImporter = true
                } label: {
                    VStack(alignment: .leading) {
                        CompactAlert(title: "尚未导入 tendies！", symbol: "exclamationmark.triangle.fill", text: PBMsg.noTendies)
                            .padding(.horizontal, 15)
                    }
                    .frame(alignment: .leading)
                    .multilineTextAlignment(.leading)
                }
            }
            LazyVGrid(columns: columns) {
                ForEach($tendiesArray) { $tendies in
                    Button {
                        if !tendies.isOn && tendiesArray.filter({ $0.isOn }).flatMap({ $0.descrNames }).count > 15 {
                            Alertinator.shared.alert(title: "已达壁纸数量上限！", body: PBMsg.tooManyTendies)
                        } else {
                            tendies.isOn.toggle()
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: tendies.targetDescr == .photos ? "play.rectangle" : "photo")
                                .imageScale(.large)
                                .foregroundStyle(Color.accentColor)
                            VStack {
                                Text(tendies.name)
                                    .lineLimit(1)
                                    .fontWeight(.medium)
                                Text("\(tendies.descrNames.count) 张壁纸" + (tendies.descrNames.count == 1 ? "" : "s"))
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .padding(.vertical, 10)
                        .background {
                            if tendies.targetDescr == .mercury {
                                VStack {
                                    Text("M")
                                        .font(.footnote)
                                        .padding(6)
                                        .background(Color.accentColor)
                                        .clipShape(.circle)
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .frame(maxHeight: .infinity)
                                .padding(12)
                            }
                        }
                        .background {
                            RoundedRectangle(cornerRadius: 26)
                                .fill(Color(.secondarySystemBackground))
                                .overlay {
                                    if tendies.isOn {
                                        RoundedRectangle(cornerRadius: 26)
                                            .fill(Color.clear)
                                            .strokeBorder(lineWidth: 2)
                                            .foregroundStyle(Color.accentColor)
                                    }
                                }
                        }
                        .contextMenu {
                            Button {
                                let url = AppURL.pbFolders.appendingPathComponent(tendies.folderName)
                                fsHandlers.openInFilesApp(url)
                            } label: {
                                Label("显示数据文件夹", systemImage: "folder")
                            }
                            
                            Button(role: .destructive) {
                                withAnimation {
                                    let url = AppURL.pbFolders.appendingPathComponent(tendies.folderName)
                                    try? fm.removeItem(at: url)
                                    tendiesArray.removeAll { $0.id == tendies.id }
                                }
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 15)
            .foregroundStyle(Color(.label))
        }
        .navigationTitle("壁纸")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            doSetupStuff()
        }
        .safeAreaInset(edge: .bottom) {
            VStack {
                Button {
                    showImporter = true
                } label: {
                    ButtonLabel("导入 .tendies", symbol: "arrow.down.doc")
                }
            }
            .buttonStyle(ActionButtonStyle())
            .frame(maxWidth: .infinity)
            .padding(device.userInterfaceIdiom == .pad ? 0 : 15)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showImporter = true
                    } label: {
                        Label("导入 .tendies", systemImage: "arrow.down.doc")
                    }
                    
                    Button {
                        openApp(withBID: SysBID.poster)
                    } label: {
                        Label("打开 PosterBoard", systemImage: "arrow.up.right.square")
                    }
                    
                    Divider()
                    
                    NavigationLink {
                        List {
                            Section {
                                TextField("PosterBoard 路径", text: $pbContainerPath, axis: .vertical)
                                Button("获取路径") {
                                    pbContainerPath = fsHandlers.getContainerPath(forMatch: "com.apple.PosterBoard")
                                }
                            } header: {
                                HeaderLabel("PosterBoard", symbol: "photo")
                            }
                            
                            Section {
                                Button("清除导入内容") {
                                    for object in tendiesArray {
                                        let url = AppURL.pbFolders.appendingPathComponent(object.folderName)
                                        try? fm.removeItem(at: url)
                                    }
                                    tendiesArray.removeAll()
                                }
                                Button("重置 Collections", role: .destructive) {
                                    let res = resetWallpapers(for: PBPath.wpKit)
                                    if res {
                                        Haptic.shared.play(.soft)
                                    }
                                }
                                Button("重置 MercuryPoster", role: .destructive) {
                                    let res = resetWallpapers(for: PBPath.mercury)
                                    if res {
                                        Haptic.shared.play(.soft)
                                    }
                                }
                                Button("重置 Videos", role: .destructive) {
                                    let res = resetWallpapers(for: PBPath.photos)
                                    if res {
                                        Haptic.shared.play(.soft)
                                    }
                                }
                            } header: {
                                HeaderLabel("数据", symbol: "loupe")
                            } footer: {
                                Text("如果自定义壁纸应用出现异常，请尝试重置下方列出的三个扩展中的任意一个。")
                            }
                        }
                        .navigationTitle("PosterBoard 设置")
                    } label: {
                        Label("设置", systemImage: "gearshape")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("应用", role: .adaptiveConfirm) {
                    if !hasShownFirstRunMsg {
                        Alertinator.shared.alert(title: "开始之前…", body: PBMsg.applyInfo, actionLabel: "继续", action: {
                            hasShownFirstRunMsg = true
                            proceed()
                        })
                    } else if tendiesArray.filter({ $0.isOn }).flatMap({ $0.descrNames }).count > 5 {
                        Alertinator.shared.alert(title: "开始之前…", body: PBMsg.limitWarning, actionLabel: "确认", action: {
                            proceed()
                        })
                    } else {
                        proceed()
                    }
                    
                    @MainActor
                    func proceed() {
                        let res = applyObjects(tendiesArray.filter { $0.isOn })
                        if !res.0 {
                            if res.1.contains("an item with the same name already exists") {
                                Alertinator.shared.alert(title: "应用壁纸失败！", body: "你选择的某些壁纸已经添加过了。")
                            } else {
                                Alertinator.shared.alert(title: "应用壁纸失败！", body: PBMsg.corruption)
                            }
                        } else {
                            Haptic.shared.play(.soft)
                            Alertinator.shared.alert(title: "重启 PosterBoard 以完成应用！", body: PBMsg.finishApply, showCancel: false, actionLabel: "继续", action: { openApp(withBID: SysBID.poster) })
                        }
                    }
                }
                .disabled(tendiesArray.filter({ $0.isOn }).isEmpty)
                .disabled(pbContainerPath.isEmpty || !fm.fileExists(atPath: AppURL.pb.path))
            }
        }
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.item]) { result in
            let res = handleImport(result)
            if !res {
                Alertinator.shared.alert(title: "导入 .tendies 失败！", body: PBMsg.imprtFailed)
            }
        }
    }
    
    private func doSetupStuff() {
        if pbContainerPath.isEmpty {
            pbContainerPath = fsHandlers.getContainerPath(forMatch: "com.apple.PosterBoard")
        }
        if !fm.fileExists(atPath: AppURL.pb.path) {
            do {
                try fm.createDirIfNeeded(at: AppURL.pb)
                try fm.createDirIfNeeded(at: AppURL.pbFolders)
            } catch {
                Alertinator.shared.alert(title: "设置 PosterBoard 修改失败！", body: AppMsg.opFailed)
            }
        }
    }
    
    private func applyObjects(_ objects: [TendiesObject]) -> (Bool, String) {
        let descrTargets = Set(objects.map(\.targetDescr))
        for descrTarget in descrTargets {
            let target = "\(pbContainerPath)/\(descrTarget.path)"
            let res = wq.grantAccess(path: target)
            if !res.0 {
                print("(mg) 授予 \(target) 访问权限失败：\(res.2)")
                return (false, res.2)
            }
        }
        
        for object in objects {
            let container = "\(pbContainerPath)/\(object.targetDescr.path)"
            for descr in object.descrNames {
                let descrURL = AppURL.pbFolders.appendingPathComponent(object.folderName).appendingPathComponent(descr)
                let target = object.targetDescr == .mercury ? URL(fileURLWithPath: container).appendingPathComponent(descrURL.lastPathComponent) : URL(fileURLWithPath: container).appendingPathComponent(UUID().uuidString)
                do {
                    try fm.copyItem(at: descrURL, to: target)
                } catch {
                    print("(mg) 拷贝描述符失败（文件夹：\(object.folderName)）：\(error.localizedDescription)")
                    return (false, error.localizedDescription)
                }
            }
        }
        return (true, "")
    }
    
    private func resetWallpapers(for item: PBPath) -> Bool {
        do {
            let target = URL(fileURLWithPath: "\(pbContainerPath)/\(item.path)")
            let contents = try fm.contentsOfDirectory(at: target, includingPropertiesForKeys: nil)
            
            for url in contents {
                try fm.removeItem(at: url)
            }
            return true
        } catch {
            print("(pb) 重置 \(item.rawValue) 失败：\(error.localizedDescription)")
            return false
        }
    }
    
    private func handleImport(_ result: Result<URL, Error>) -> Bool {
        switch result {
        case .success(let fileURL):
            let stopAccess = fileURL.startAccessingSecurityScopedResource()
            defer {
                if stopAccess {
                    fileURL.stopAccessingSecurityScopedResource()
                }
            }
            if let tendies = pbHandler.makeObjectFromTendies(at: fileURL) {
                withAnimation {
                    tendiesArray.append(tendies)
                }
            }
            return true
        case .failure(let error):
            print("(pb) 导入文件失败：\(error.localizedDescription)")
            return false
        }
    }
}

