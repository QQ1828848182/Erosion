//
//  LogView.swift
//  dirtyZero
//
//  Created by lunginspector on 4/17/26.
//

import SwiftUI

struct LogView: View {
    @StateObject private var mgr = ErosionManager.shared
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    Text(mgr.logOutput)
                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                        .multilineTextAlignment(.leading)
                    Spacer()
                        .id(0)
                }
                .contextMenu {
                    Button {
                        Haptic.shared.play(.soft)
                        UIPasteboard.general.string = mgr.logOutput
                    } label: {
                        Label("拷贝输出", systemImage: "doc.on.doc")
                    }
                    
                    Button {
                        do {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "MM-dd-yyyy-HHmmss"
                            let date = formatter.string(from: Date())
                            
                            let tempURL = URL.temporaryDirectory.appendingPathComponent("Erosion-Log-\(date)").appendingPathExtension("txt")
                            guard let data = mgr.logOutput.data(using: .utf8) else {
                                throw "无法从日志字符串创建数据"
                            }
                            
                            try data.write(to: tempURL)
                            presentShareSheet(with: tempURL)
                        } catch {
                            print("(fm) 导出日志失败：\(error.localizedDescription)")
                        }
                    } label: {
                        Label("导出日志", systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
    }
}
