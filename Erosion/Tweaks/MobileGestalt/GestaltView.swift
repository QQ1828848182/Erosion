//
//  GestaltView.swift
//  Erosion
//
//  Created by lunginspector on 8/14/26.
//

import SwiftUI

import UniformTypeIdentifiers

struct GestaltView: View {
    @EnvironmentObject private var mgr: ErosionManager
    @StateObject private var store = GestaltStore.shared
    @AppStorage("mgOverrideGates") private var mgOverrideGates = false
    @AppStorage("mgWriteAtomically") private var mgWriteAtomically = true
    @AppStorage("autoRespring") var autoRespring = false
    @AppStorage("hasShownSheet") private var hasShownSheet = false
    @Environment(\.dismiss) private var dismiss
    
    @State private var mgSubtype = 0
    @State private var mgOgSubtype = 0
    @State private var mgOgDeviceName = ""
    @State private var mgEnableDeviceName = false
    @AppStorage("mgDeviceName") private var mgDeviceName = ""
    @AppStorage("ogMachineName") private var ogMachineName = ""
    @AppStorage("showRegionTweak") private var showRegionTweak = false
    @AppStorage("showCustomKeys") private var showCustomKeys = false
    @AppStorage("mgCustKeyArray") var customKeys: [MGCustomKey] = []
    @State private var mgProductType = ""
    
    @State private var showInfoSheet = false
    @State private var idiotButtonTimerComplete = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Picker("子类型", selection: $mgSubtype) {
                            Text("原厂 (\(mgOgSubtype))").tag(mgOgSubtype)
                            if isDynamIslandHD() && doubleSysVrs() < 19.0 {
                                Text("关闭灵动岛").tag(2436)
                            }
                            Text("iPhone 14 Pro").tag(2436)
                            Text("iPhone 14 Pro Max").tag(2796)
                            Text("iPhone 15 Pro Max").tag(2976)
                            if doubleSysVrs() >= 18.0 {
                                Text("iPhone 16 Pro").tag(2622)
                                Text("iPhone 16 Pro Max").tag(2868)
                            }
                            if doubleSysVrs() >= 26.0 {
                                Text("iPhone Air").tag(2736)
                            }
                            if doubleSysVrs() >= 27.0 {
                                Text("iPhone 18 Pro Max").tag(2670)
                            }
                            if isHomeButtonHD() {
                                Text("iPhone X 手势").tag(2436)
                            }
                        }
                        Spacer()
                        Button {
                            Alertinator.shared.alert(title: "子类型说明", body: MGMsg.subtype)
                        } label: {
                            Image(systemName: "info.circle")
                                .frame(width: 24, height: 22)
                        }
                        .buttonStyle(.plain)
                    }
                    Toggle("自定义设备名称", isOn: $mgEnableDeviceName)
                    if mgEnableDeviceName {
                        TextField("设备名称", text: $mgDeviceName)
                    }
                } header: {
                    HeaderLabel("外观信息", symbol: "paintbrush.pointed")
                }
                
                if !isDynamIslandHD() || !isAODHD() || !isBootChimeHD() || !isChargeLimitHD() || mgOverrideGates {
                    Section {
                        if !isDynamIslandHD() || mgOverrideGates {
                            PlainToggle("启用灵动岛", minVrs: 19.0, isOn: store.mgKeyBinding([MGKey.island]))
                        }
                        if !isAODHD() || mgOverrideGates {
                            PlainToggle("启用息屏显示", minVrs: 18.0, isOn: store.mgKeyBinding([MGKey.AOD, MGKey.AOTime]))
                            if store.isEnabled([MGKey.AOD]) {
                                PlainToggle("启用息屏显示色彩增强", minVrs: 18.0, isOn: store.mgKeyBinding([MGKey.AODVibrancy]))
                            }
                        }
                        if !isBootChimeHD() || mgOverrideGates {
                            PlainToggle("启用充电上限", minVrs: 17.0, isOn: store.mgKeyBinding([MGKey.chargeLim]))
                        }
                        if !isChargeLimitHD() || mgOverrideGates {
                            PlainToggle("启用开机提示音", isOn: store.mgKeyBinding([MGKey.bootChime]))
                        }
                    } header: {
                        HeaderLabel("硬件功能", symbol: "gearshape")
                    }
                }
                
                Section {
                    PlainToggle("启用内部安装", infoType: .info, infoMessage: MGMsg.intInstall, isOn: store.mgKeyBinding([MGKey.intInstall]))
                    PlainToggle("启用内部版本", infoType: .info, infoMessage: MGMsg.intBuild, isOn: store.mgKeyBinding([MGKey.intBuild]))
                } header: {
                    HeaderLabel("内部", symbol: "ant")
                }
                .disabled(store.isEnabled([MGKey.appIntell]))
                
                Section {
                    PlainToggle("启用 SRD 界面", minVrs: 26.0, isOn: store.mgKeyBinding([MGKey.srd]))
                    if showRegionTweak {
                        PlainToggle("关闭地区限制", isOn: store.mgRegionRestrictionsBinding())
                    }
                    if !isAppleIntellHD() || mgOverrideGates {
                        PlainToggle("启用 Apple Intelligence", minVrs: 18.1, isOn: store.mgKeyBinding([MGKey.appIntell]))
                            .onChange(of: store.mgKeyBinding([MGKey.appIntell]).wrappedValue) { (oldVal, newVal) in
                                if newVal {
                                    store.mgPullKeys([MGKey.intBuild, MGKey.intInstall])
                                }
                            }
                    }
                    HStack(spacing: 10) {
                        Picker("伪装", selection: $mgProductType) {
                            Text("默认").tag(ogMachineName)
                            if ogMachineName.contains("Pad") {
                                if doubleSysVrs() >= 17.4 {
                                    Text("iPad Pro 11-inch (M4)").tag("iPad16,3")
                                    Text("iPad Pro 11-inch (M4, Cellular)").tag("iPad16,4")
                                }
                                Text("iPad Pro 11-inch (4th Gen)").tag("iPad14,3")
                                Text("iPad Pro 11-inch (4th Gen, Cellular)").tag("iPad14,4")
                            } else {
                                Text("iPhone 15 Pro").tag("iPhone16,1")
                                Text("iPhone 15 Pro Max").tag("iPhone16,2")
                                if doubleSysVrs() >= 18.0 {
                                    Text("iPhone 16").tag("iPhone17,3")
                                    Text("iPhone 16 Plus").tag("iPhone17,4")
                                    Text("iPhone 16 Pro").tag("iPhone17,1")
                                    Text("iPhone 16 Pro Max").tag("iPhone17,2")
                                }
                                if doubleSysVrs() >= 19.0 {
                                    Text("iPhone 17").tag("iPhone18,3")
                                    Text("iPhone 17 Pro").tag("iPhone18,1")
                                    Text("iPhone 17 Pro Max").tag("iPhone18,2")
                                    Text("iPhone Air").tag("iPhone18,4")
                                }
                                if doubleSysVrs() >= 27.0 {
                                    Text("iPhone 18 Pro").tag("iPhone19,2")
                                    Text("iPhone 18 Pro Max").tag("iPhone19,3")
                                    Text("iPhone Duo").tag("iPhone19,4")
                                }
                            }
                        }
                        Button {
                            Alertinator.shared.alert(title: "设备伪装说明", body: isAppleIntellHD() ? MGMsg.spoofUseless : MGMsg.spoofAI)
                        } label: {
                            Image(systemName: "info.circle")
                                .frame(width: 24, height: 22)
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    HeaderLabel("资格", symbol: "flag")
                }
                
                Section {
                    if !isCrashDectHD() || mgOverrideGates {
                        PlainToggle("车祸检测", isOn: store.mgKeyBinding([MGKey.crashDet]))
                    }
                    if !isPWMHD() || mgOverrideGates {
                        PlainToggle("脉宽调制", minVrs: 19.0, isOn: store.mgKeyBinding([MGKey.pwm]))
                    }
                    if ogMachineName.contains("iPhone") || mgOverrideGates {
                        PlainToggle("Apple Pencil", isOn: store.mgKeyBinding([MGKey.appPencil]))
                    }
                    if !isCamControlHD() || mgOverrideGates {
                        PlainToggle("相机控制", minVrs: 18.0, isOn: store.mgKeyBinding([MGKey.camButton, MGKey.grapPefr]))
                    }
                    if !isActionButtonHD() || mgOverrideGates {
                        PlainToggle("操作按钮", minVrs: 17.0, isOn: store.mgKeyBinding([MGKey.actButton]))
                    }
                    if isHomeButtonHD() || mgOverrideGates {
                        PlainToggle("轻点唤醒", isOn: store.mgKeyBinding([MGKey.tapToWake]))
                    }
                } header: {
                    HeaderLabel("偏好设置包", symbol: "gear")
                }
                
                Section {
                    if machineName().contains("iPad") || mgOverrideGates {
                        PlainToggle("启用台前调度", isOn: store.mgKeyBinding([MGKey.stageMgr]))
                    }
                    if store.strVal(forKey: MGKey.deviceClass) == "iPhone" || mgOverrideGates {
                        PlainToggle("启用 iPadOS 界面", infoType: .warning, infoMessage: MGMsg.ipadOS, isOn: store.mgTrollPadBinding())
                    }
                } header: {
                    HeaderLabel("iPadOS", symbol: "ipad")
                }
            }
            .navigationTitle("MobileGestalt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            mgRevert()
                        } label: {
                            Label("还原修改", systemImage: "xmark")
                        }
                        
                        Button(role: .destructive) {
                            Alertinator.shared.alert(title: "确定要重置 MobileGestalt 吗？", body: MGMsg.mgReset, actionLabel: "确认", action: {
                                do {
                                    try fm.removeItem(at: MGURL.savedGestaltURL)
                                    try fm.removeItem(at: MGURL.fsGestaltURL)
                                    store.mgCurrentDict = NSMutableDictionary()
                                    Alertinator.shared.alert(title: "MobileGestalt 已成功重置！", body: MGMsg.mgResetComp, showCancel: false, actionLabel: "退出应用", action: { exitinator() })
                                } catch {
                                    print("(mg) 重置 MobileGestalt 失败：\(error.localizedDescription)")
                                    Alertinator.shared.alert(title: "重置 MobileGestalt 失败！", body: AppMsg.opFailed)
                                }
                            })
                        } label: {
                            Label("重置 Gestalt", systemImage: "trash")
                        }
                        
                        Divider()
                        
                        if showCustomKeys {
                            NavigationLink(destination: CustomKeyView()) {
                                Label("自定义键", systemImage: "pencil")
                            }
                        }
                        
                        // tweak-specific settings
                        NavigationLink {
                            List {
                                Section {
                                    Button("导出当前 Gestalt") {
                                        presentShareSheet(with: MGURL.fsGestaltURL)
                                    }
                                    Button("导出原始 Gestalt") {
                                        presentShareSheet(with: MGURL.savedGestaltURL)
                                    }
                                    Button("重置已保存的 Gestalt", role: .destructive) {
                                        Alertinator.shared.alert(title: "警告！", body: MGMsg.mgResetSavWarn, action: {
                                            try? fm.removeItem(at: MGURL.savedGestaltURL)
                                            let _ = mgLoadData()
                                        })
                                    }
                                } header: {
                                    HeaderLabel("数据", symbol: "loupe")
                                }
                                
                                Section {
                                    PlainToggle("显示隐藏的修改", infoType: .warning, infoMessage: MGMsg.hidTweakWarn, isOn: $mgOverrideGates)
                                    Toggle("显示自定义键", isOn: $showCustomKeys)
                                    Toggle("原子写入覆盖", isOn: $mgWriteAtomically)
                                } footer: {
                                    Text("启用原子写入后，MobileGestalt 在重启后将不会还原。")
                                }
                            }
                            .navigationTitle("Gestalt 设置")
                        } label: {
                            Label("设置", systemImage: "gear")
                        }
                    } label: {
                        Label("菜单", systemImage: "ellipsis")
                            .labelStyle(.iconOnly)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("应用", role: .adaptiveConfirm) {
                        if !hasShownSheet {
                            showInfoSheet = true
                        } else {
                            mgApply()
                        }
                    }
                }
            }
            .sheet(isPresented: $showInfoSheet) {
                NavigationStack {
                    VStack {
                        InfoSheet(title: "开始之前…") {
                            InfoSheetCell(title: "重要警告！", symbol: "exclamationmark.triangle.fill", context: MGMsg.support)
                                .modifier(SectionPlatter())
                            InfoSheetCell(title: "Apple Intelligence（经典）", symbol: "apple.intelligence", context: MGMsg.spoofAI)
                            InfoSheetCell(title: "iPadOS 界面", symbol: "ipad", context: MGMsg.ipadOS)
                            InfoSheetCell(title: "地区限制", symbol: "map", context: MGMsg.region)
                        } button: {
                            Button("应用") {
                                showInfoSheet = false
                                hasShownSheet = true
                                idiotButtonTimerComplete = false
                                mgApply(isFromSheet: true)
                            }
                            .buttonStyle(ConfirmButtonStyle())
                            .padding(.horizontal, 30)
                            .padding(.bottom, device.userInterfaceIdiom == .pad ? 25 : 0)
                            .disabled(!idiotButtonTimerComplete)
                        }
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                            idiotButtonTimerComplete = true
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("取消") {
                                showInfoSheet = false
                                idiotButtonTimerComplete = false
                            }
                        }
                    }
                }
            }
            .onAppear {
                store.mgCurrentDict = mgLoadData()
                let isWritable = fm.isWritableFile(atPath: MGURL.fsGestaltURL.path)
                if !isWritable {
                    let res = wq.grantAccess(path: MGURL.fsGestaltURL.deletingLastPathComponent().path)
                    if !res.0 {
                        Alertinator.shared.alert(title: "获取 MobileGestalt 写入权限失败！", body: "修改将不会生效。也许可以尝试重启应用？")
                    }
                }
            }
        }
    }
    
    private func mgLoadData() -> NSMutableDictionary {
        do {
            let mgData = try Data(contentsOf: MGURL.fsGestaltURL)
            if !fm.fileExists(atPath: MGURL.savedGestaltURL.path) {
                try mgData.write(to: MGURL.savedGestaltURL)
                if let locale = Locale.current.region?.identifier {
                    showRegionTweak = locale != "US"
                }
            }
            
            if let ogDict = NSDictionary(contentsOf: MGURL.savedGestaltURL),
               let ogCacheExtra = ogDict["CacheExtra"] as? NSDictionary,
               let ogArtwork = ogCacheExtra[MGKey.artwork] as? NSDictionary {
                mgOgSubtype = ogArtwork["ArtworkDeviceSubType"] as? Int ?? 0
                mgOgDeviceName = ogArtwork["ArtworkDeviceProductDescription"] as? String ?? ""
            } else {
                throw "无法从 MobileGestalt 获取信息"
            }
            
            guard let currentDict = NSMutableDictionary(contentsOf: MGURL.fsGestaltURL) else {
                throw "无法从 MobileGestalt 获取可变字典"
            }
            
            if let cacheExtra = currentDict["CacheExtra"] as? NSDictionary,
               let artwork = cacheExtra[MGKey.artwork] as? NSDictionary {
                mgSubtype = artwork["ArtworkDeviceSubType"] as? Int ?? 0
                mgDeviceName = artwork["ArtworkDeviceProductDescription"] as? String ?? ""
                if mgDeviceName != mgOgDeviceName {
                    mgEnableDeviceName = true
                }
                mgProductType = cacheExtra[MGKey.prodType] as? String ?? machineName()
            }
            
            return currentDict
        } catch {
            print("(mg) 获取 MobileGestalt 失败：\(error.localizedDescription)")
            Haptic.shared.play(.heavy)
            Alertinator.shared.alert(title: "获取 MobileGestalt 失败！", body: "修改将无法正常工作。请离开此页面。", showCancel: false, actionLabel: "退出", action: { dismiss() })
        }
        
        return [:]
    }
    
    private func mgApply(isFromSheet: Bool = false) {
        do {
            let mgDictToApply = store.mgCurrentDict
            
            if let cacheExtra = mgDictToApply["CacheExtra"] as? NSMutableDictionary,
               let artwork = cacheExtra[MGKey.artwork] as? NSMutableDictionary {
                artwork["ArtworkDeviceSubType"] = mgSubtype
                if mgEnableDeviceName {
                    artwork["ArtworkDeviceProductDescription"] = mgDeviceName
                }
                cacheExtra[MGKey.prodType] = mgProductType
                for item in customKeys {
                    if item.isOn {
                        cacheExtra[item.key] = item.value
                    } else {
                        cacheExtra.removeObject(forKey: item.key)
                    }
                }
            } else {
                throw "无法将键写入 MobileGestalt！"
            }
            
            let data = try PropertyListSerialization.data(fromPropertyList: mgDictToApply, format: .binary, options: 0)
            let res = mgWrite(data)
            
            if res {
                print("[*] 已成功覆盖 MobileGestalt！")
                Haptic.shared.play(.soft)
                if autoRespring || isFromSheet {
                    mgr.shouldRespring = true
                } else {
                    Alertinator.shared.alert(title: "MobileGestalt 修改已成功应用！", body: AppMsg.applied + (store.isEnabled([MGKey.appIntell]) ? " 如果你需要使用 Apple Intelligence，则需要重启设备。" : ""), actionLabel: "Respring", action: { mgr.shouldRespring = true })
                }
            } else {
                throw "覆盖失败！"
            }
        } catch {
            print("(mg) 应用 MobileGestalt 失败：\(error.localizedDescription)")
            Alertinator.shared.alert(title: "应用 MobileGestalt 失败！", body: "错误：\(error.localizedDescription)")
        }
    }
    
    private func mgRevert() {
        do {
            guard let mgDictToApply = NSMutableDictionary(contentsOf: MGURL.savedGestaltURL) else {
                throw "无法获取 MobileGestalt 字典！"
            }
            
            let data = try PropertyListSerialization.data(fromPropertyList: mgDictToApply, format: .binary, options: 0)
            let res = mgWrite(data)
            
            if res {
                print("[*] 已成功覆盖 MobileGestalt！")
                Haptic.shared.play(.soft)
                if let dict = NSMutableDictionary(contentsOf: MGURL.savedGestaltURL) {
                    store.mgCurrentDict = dict
                }
                Alertinator.shared.alert(title: "MobileGestalt 修改已成功还原！", body: MGMsg.revertComp)
            } else {
                throw "覆盖失败！"
            }
        } catch {
            print("(mg) 还原 MobileGestalt 失败：\(error.localizedDescription)")
            Alertinator.shared.alert(title: "还原 MobileGestalt 失败！", body: AppMsg.opFailed)
        }
    }
}

#Preview {
    ContentView()
}
