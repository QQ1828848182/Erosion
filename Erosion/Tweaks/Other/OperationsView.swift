//
//  OperationsView.swift
//  Erosion
//
//  Created by lunginspector on 8/17/26.
//

import SwiftUI
import UniformTypeIdentifiers


struct OperationsView: View {
    @State private var directory = ""
    @State private var fileName = ""
    @State private var isAcc = false
    @State private var showImporter = false
    
    @State private var imprtName = ""
    @State private var imprtData = Data()
    
    var body: some View {
        List {
            Section {
                TextField("目录", text: $directory)
                    .disabled(isAcc)
                TextField("文件名", text: $fileName)
                    .disabled(isAcc)
                HStack {
                    Button("授予访问权限") {
                        let res = wq.grantAccess(path: "\(directory)/\(fileName)")
                        if !res.0 {
                            Alertinator.shared.alert(title: "获取目标文件访问权限失败！", body: "\(res.1): \(res.2)")
                        } else {
                            isAcc = true
                        }
                    }
                    .disabled(isAcc)
                    if isAcc {
                        Spacer()
                        HStack {
                            Image(systemName: "checkmark")
                            Text("已获得访问权限")
                        }
                        .foregroundStyle(.green)
                    }
                }
                if isAcc {
                    Button("更改路径", role: .destructive) {
                        isAcc = false
                        imprtName = ""
                        imprtData = Data()
                    }
                    
                    Button("导出文件") {
                        let fileDir = "\(directory)/\(fileName)"
                        presentShareSheet(with: URL(fileURLWithPath: fileDir))
                    }
                }
            } header: {
                HeaderLabel("目标", symbol: "dot.scope")
            }
            
            Section {
                HStack {
                    Button("导入文件") {
                        showImporter = true
                    }
                    .disabled(!imprtData.isEmpty)
                    if !imprtName.isEmpty {
                        Spacer()
                        Text(imprtName)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }
                
                Button("覆盖文件") {
                    do {
                        let targetURL = URL(fileURLWithPath: "\(directory)/\(fileName)")
                        try imprtData.write(to: targetURL)
                        print("(ov) 文件覆盖成功：\(targetURL.path)（\(imprtData.count) 字节）")
                        Haptic.shared.play(.soft)
                    } catch {
                        print("(ov) 覆盖失败：\(error.localizedDescription)")
                        Alertinator.shared.alert(title: "覆盖文件失败！", body: "请确认路径正确且你拥有访问权限。查看错误日志以获取更详细的信息。")
                    }
                }
                .disabled(imprtData.isEmpty)
                
                Button("移动文件") {
                    do {
                        let targetURL = URL(fileURLWithPath: "\(directory)").appendingPathComponent(imprtName)
                        try imprtData.write(to: targetURL)
                        print("(ov) 文件移动成功：\(imprtName) -> \(targetURL.path)")
                        Haptic.shared.play(.soft)
                    } catch {
                        print("(ov) 移动失败：\(error.localizedDescription)")
                        Alertinator.shared.alert(title: "移动文件失败！", body: "请确认路径正确且你拥有访问权限。查看错误日志以获取更详细的信息。")
                    }
                }
                .disabled(imprtData.isEmpty)
                
                Button("删除文件", role: .destructive) {
                    do {
                        let targetURL = URL(fileURLWithPath: "\(directory)/\(fileName)")
                        try fm.removeItem(at: targetURL)
                        print("(ov) 文件删除成功：\(targetURL.path)")
                        Haptic.shared.play(.heavy)
                    } catch {
                        print("(ov) 删除失败：\(error.localizedDescription)")
                        Alertinator.shared.alert(title: "删除文件失败！", body: "请确认路径正确且你拥有访问权限。查看错误日志以获取更详细的信息。")
                    }
                }
                .disabled(imprtData.isEmpty)
            } header: {
                HeaderLabel("操作", symbol: "wrench.and.screwdriver")
            }
        }
        .navigationTitle("文件操作")
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.item]) { result in
            handleImport(result)
        }
    }
    
    func handleImport(_ res: Result<URL, Error>) {
        switch res {
        case .success(let recURL):
            do {
                let stopAccess = recURL.startAccessingSecurityScopedResource()
                defer {
                    if stopAccess {
                        recURL.stopAccessingSecurityScopedResource()
                    }
                }
                
                imprtData = try Data(contentsOf: recURL)
                imprtName = recURL.lastPathComponent
            } catch {
                print("(ov) 导入文件失败：\(error.localizedDescription)")
                Alertinator.shared.alert(title: "导入文件失败！", body: "该文件可能无效、已损坏或无法访问。请尝试其他用于覆盖的文件。")
            }
        case .failure(let error):
            print("(ov) 导入文件失败：\(error.localizedDescription)")
            Alertinator.shared.alert(title: "导入文件失败！", body: "该文件可能无效、已损坏或无法访问。请尝试其他用于覆盖的文件。")
        }
    }
}
