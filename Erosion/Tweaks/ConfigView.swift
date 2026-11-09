//
//  ConfigView.swift
//  Erosion
//
//  Created by lunginspector on 8/21/26.
//

import SwiftUI


enum CNURL {
    static var sharedDevConfig = FSURL.configProfiles.appendingPathComponent("SharedDeviceConfiguration.plist")
    static var cloudConfig = FSURL.configProfiles.appendingPathComponent("CloudConfigurationDetails.plist")
}

enum CNMsg {
    static var supWarning = "如果你的设备已经过 MDM 配置，请千万不要触碰此开关！此外，对所有用户来说，Respring 后可能会看到一个设置界面。使用前请自行承担风险。"
    static var resetInfo = "点击「确认」后，你的脚注将被移除，设备也将不再处于监管状态。"
}

struct ConfigView: View {
    @EnvironmentObject private var mgr: ErosionManager
    @AppStorage("autoRespring") var autoRespring = false
    @State private var ftCurrentDict = NSMutableDictionary()
    @State private var ccCurrentDict = NSMutableDictionary()
    @State private var footnoteText = ""
    @State private var supervised = false
    @State private var orgName = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 14) {
                        HStack {
                            Image(systemName: "flashlight.off.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 26, height: 26)
                                .padding()
                                .modifier(QuickActionBackground())
                            Spacer()
                            Image(systemName: "camera.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 26, height: 26)
                                .padding()
                                .modifier(QuickActionBackground())
                        }
                        .padding(.horizontal, 35)
                        
                        VStack {
                            Text(footnoteText)
                                .font(.system(size: 9))
                                .frame(height: 10)
                            Capsule()
                                .frame(width: 145, height: 4)
                        }
                    }
                    .padding(.top, 25)
                    .padding(.bottom, 10)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(
                        Group {
                            Image("solarium")
                                .resizable()
                                .scaledToFill()
                                .offset(y: 10)
                        }
                    )
                    
                    TextField("自定义脚注", text: $footnoteText)
                }
                
                Section {
                    PlainToggle("启用监管", infoType: .warning, infoTitle: "监管警告！", infoMessage: CNMsg.supWarning, isOn: $supervised)
                    if supervised {
                        TextField("组织名称", text: $orgName)
                    }
                } header: {
                    HeaderLabel("监管", symbol: "eye")
                }
            }
            .navigationTitle("配置")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Alertinator.shared.alert(title: "确定要重置你的修改吗？", body: CNMsg.resetInfo, actionLabel: "确认", action: {
                            reset()
                        })
                    } label: {
                        Label("恢复修改", systemImage: "gobackward")
                            .labelStyle(.iconOnly)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("应用", role: .adaptiveConfirm) {
                        apply()
                    }
                }
            }
            .onAppear {
                doSetup()
            }
        }
    }
    
    private func doSetup() {
        if !fm.isWritableFile(atPath: CNURL.sharedDevConfig.path) {
            let res = wq.grantAccess(path: FSURL.configProfiles.path)
            if !res.0 {
                Alertinator.shared.alert(title: "获取写入权限失败！", body: AppMsg.opFailed)
                return
            }
        }
        if !fm.fileExists(atPath: CNURL.sharedDevConfig.path) {
            do {
                let dict = ["LockScreenFootnote" : ""]
                let data = try PropertyListSerialization.data(fromPropertyList: dict, format: .binary, options: 0)
                try data.write(to: CNURL.sharedDevConfig)
            } catch {
                print("(cn) 创建脚注文件失败：\(error.localizedDescription)")
                Alertinator.shared.alert(title: "创建脚注文件失败！", body: AppMsg.opFailed)
            }
        }
        loadData()
    }
    
    private func loadData() {
        if let ftDict = NSMutableDictionary(contentsOf: CNURL.sharedDevConfig) {
            ftCurrentDict = ftDict
            footnoteText = ftDict["LockScreenFootnote"] as? String ?? ""
        }
        if let ccDict = NSMutableDictionary(contentsOf: CNURL.cloudConfig) {
            ccCurrentDict = ccDict
            supervised = ccDict["IsSupervised"] as? Bool ?? false
            orgName = ccDict["OrganizationName"] as? String ?? ""
        }
    }
    
    private func apply() {
        let ftDict = ["LockScreenFootnote" : footnoteText]
        ccCurrentDict["IsSupervised"] = supervised
        ccCurrentDict["OrganizationName"] = orgName
        do {
            let ftData = try PropertyListSerialization.data(fromPropertyList: ftDict, format: .binary, options: 0)
            try ftData.write(to: CNURL.sharedDevConfig)
            let ccData = try PropertyListSerialization.data(fromPropertyList: ccCurrentDict, format: .binary, options: 0)
            try ccData.write(to: CNURL.cloudConfig)
            print("(cn) 配置修改应用成功！")
            Haptic.shared.play(.soft)
            if autoRespring {
                mgr.shouldRespring = true
            } else {
                Alertinator.shared.alert(title: "配置修改已成功应用！", body: AppMsg.applied, actionLabel: "Respring", action: { mgr.shouldRespring = true })
            }
        } catch {
            print("(cn) 写入配置文件失败：\(error.localizedDescription)")
            Alertinator.shared.alert(title: "应用修改失败！", body: AppMsg.opFailed)
        }
    }
    
    private func reset() {
        ccCurrentDict["IsSupervised"] = false
        ccCurrentDict.removeObject(forKey: "OrganizationName")
        do {
            try fm.removeItem(at: CNURL.sharedDevConfig)
            let ccData = try PropertyListSerialization.data(fromPropertyList: ccCurrentDict, format: .binary, options: 0)
            try ccData.write(to: CNURL.cloudConfig)
            print("(cn) 配置修改重置成功！")
            Haptic.shared.play(.soft)
            loadData()
            footnoteText = ""
            Alertinator.shared.alert(title: "配置修改已成功重置！", body: AppMsg.applied, actionLabel: "Respring", action: { mgr.shouldRespring = true })
        } catch {
            print("(cn) 重置配置文件失败：\(error.localizedDescription)")
            Alertinator.shared.alert(title: "重置修改失败！", body: AppMsg.opFailed)
        }
    }
}

// MARK: ui
struct QuickActionBackground: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 19.0, *) {
            content
                .glassEffect(.clear.interactive(), in: .circle)
        } else {
            content
                .background(.ultraThinMaterial, in: .circle)
        }
    }
}
