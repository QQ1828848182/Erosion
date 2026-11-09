//
//  SettingsView.swift
//  Erosion
//
//  Created by lunginspector on 8/20/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("autoRespring") var autoRespring = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("自动 Respring", isOn: $autoRespring)
                } header: {
                    HeaderLabel("应用设置", symbol: "gearshape")
                } footer: {
                    Text("应用修改后自动 Respring 设备。")
                }
                
                Section {
                    AppInfoCell(build: build)
                } header: {
                    HeaderLabel("关于", symbol: "info.circle")
                } footer: {
                    Text("由 [jailbreak.party](https://jailbreak.party) 团队用爱心制作。")
                }
                
                Section {
                    LinkCreditCell(image: Image("lunginspector"), name: "lunginspector", description: "主要开发者与维护者。", url: "https://github.com/lunginspector")
                    LinkCreditCell(image: Image("forcequit"), name: "forcequit", description: "worse_query 沙盒逃逸。", url: "https://github.com/forcequitOS")
                    LinkCreditCell(image: Image("0xjohnny"), name: "0xjohnny", description: "worse_query 沙盒逃逸。", url: "https://github.com/0xjohnnydev")
                    LinkCreditCell(image: Image("skadz108"), name: "Skadz", description: "漏洞实现、后端功能与项目维护者。", url: "https://github.com/skadz108")
                    LinkCreditCell(image: Image("rooootdev"), name: "rooootdev", description: "各类后端组件。", url: "https://github.com/rooootdev")
                    LinkCreditCell(image: Image("neonmodder123"), name: "neonmodder123", description: "开发了 WebView respring 方法。", url: "https://github.com/neonmodder123")
                } header: {
                    HeaderLabel("致谢", symbol: "star")
                }
            }
            .navigationTitle("设置")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        ToolbarLabel("关闭", symbol: "xmark")
                    }
                }
            }
        }
    }
}
