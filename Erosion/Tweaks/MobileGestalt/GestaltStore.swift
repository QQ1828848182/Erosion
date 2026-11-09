//
//  GestaltStore.swift
//  Erosion
//
//  Created by lunginspector on 8/19/26.
//

import SwiftUI

import Combine

enum MGURL {
    static let fsGestaltURL = URL(fileURLWithPath: "/private/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist")
    static let savedGestaltURL = URL.documentsDirectory.appendingPathComponent("OriginalGestalt.plist")
}

enum MGMsg {
    // warnings
    static let region = "启用此修改可能违反当地法律！你可能会遭到当地司法管辖区的法律追究。使用前请自行承担风险。"
    static let ipadOS = "如果你使用的是字母数字密码，请完全不要使用此修改。不要关闭「在台前调度中显示程序坞」，否则设备会变砖。启用此修改后，请预期会出现整体不稳定、应用无法使用以及设备功能异常等问题。"
    static let support = "如果某个修改无法按预期工作，请不要向我们寻求支持。许多修改都依赖于你的设备以及 Apple 服务器的配合。使用所有这些修改均需自行承担风险。"
    static let mgReset = "重置 MobileGestalt 会删除原始缓存。这能帮你移除那些无法还原的修改，但存在极小的概率会让设备变砖。"
    
    // info
    static let intInstall = "这将启用一些原本面向 Apple 内部使用、却被遗留在正式版 iOS 中的内部功能。该修改可能破坏部分设备功能，包括从 App Store 安装系统应用。"
    static let intBuild = "此开关主要会在「设置」应用中显示内部存储信息。该修改可能引发问题，尤其是在 iPadOS 上。"
    static let spoofUseless = "伪装设备型号可能会导致 Face ID 等功能失效。由于你的设备已支持 Apple Intelligence，此修改对你没有任何意义。"
    static let spoofAI = "此修改并不会启用新的 Siri AI 功能。若要下载 AI 模型，你需要伪装设备。伪装设备型号可能导致 Face ID 等功能失效。如果取消伪装，请不要再进入「设置」中的 Siri 部分。"
    static let subtype = "仅当你希望把灵动岛下移到更低的位置时才修改子类型。请使用本页更下方的开关来启用灵动岛！"
    static let mgResetComp = "要完成重置，你需要重启 iPhone。请立即执行。"
    static let revertComp = "建议重启设备，以便所有修改都能还原。"

    // settings
    static let mgResetSavWarn = "在保存 MobileGestalt 之前，请先移除所有修改，这样以后若想重置真实 gestalt 时才不会被重新写入。"
    static let hidTweakWarn = "显示那些针对你的设备配置而被刻意隐藏的修改，可能会启用一些导致设备损坏或数据丢失的功能！"
}

enum MGKey {
    // bindings
    static let ipadosCacheEx = [
        "uKc7FPnEO++lVhHWHFlGbQ", // ipad
        "mG0AnH/Vy1veoqoLRAIgTA", // MedusaFloatingLiveAppCapability
        "UCG5MkVahJxG1YULbbd5Bg", // MedusaOverlayAppCapability
        "ZYqko/XM5zD3XBfN5RmaXA", // MedusaPinnedAppCapability
        "nVh/gwNpy7Jv1NOk00CMrw", // MedusaPIPCapability,
        "qeaj75wk3HF4DwQ8qbIi7g", // DeviceSupportsEnhancedMultitasking
    ]
    
    // hardware features
    static let island = "YlEtTtHlNesRBMal1CqRaA" // DeviceSupportsDynamicIsland
    static let AOTime = "j8/Omm6s1lsmTDFsXjsBfA" // DeviceSupportsAlwaysOnTime
    static let AOD = "2OOJf1VhaM7NxfRok3HbWQ" // DeviceSupportsAlwaysOnDisplay
    static let AODVibrancy = "ykpu7qyhqFweVMKtxNylWA" // DeviceSupportsAODVibrancy
    static let chargeLim = "37NVydb//GP/GrhuTN+exg" // DeviceSupports80ChargeLimit
    static let bootChime = "QHxt+hGLaBPbQJbXiUJX3w" // DeviceSupportsBootChime
    
    // internal
    static let intInstall = "EqrsVvjcYDdxHBiQmGhAWw" // apple-internal-install
    static let intBuild = "LBJfwOEzExRxzlAnSuI7eg" // InternalBuild
    
    // eligbility
    static let srd = "XYlJKKkj2hztRP1NWWnhlw" // ResearchFuse
    static let appIntell = "A62OafQ85EJAiiqKn4agtg" // DeviceSupportsGenerativeModelSystems
    static let regionCode = "h63QSdBCiT/z0WU6rdQv6Q" // RegionCode
    static let regionSysconfig = "yK+xavymRGZ3xWc1tb8XDg" // RegionInfoFromSysconfig
    
    // prefs
    static let crashDet = "HCzWusHQwZDea6nNhaKndw" // DeviceSupportsCollisionSOS
    static let pwm = "6IejgN+1Fmu5/QrZFOIeNw" // DeviceSupportsPulseWidthMaximization
    static let appPencil = "yhHcB0iH0d1XzPO/CFd3ow" // DeviceSupportsApplePencil
    static let camButton = "CwvKxM2cEogD3p+HYgaW0Q" // CameraButtonCapability
    static let grapPefr = "oOV1jhJbdV3AddkcCg0AEA" // apple-graphics-performance-tier
    static let actButton = "cT44WE1EohiwRzhsZ8xEsw" // RingerButtonCapability
    static let tapToWake = "yZf3GTRMGTuwSV/lD7Cagw" // DeviceSupportsTapToWake
    
    // ipados
    static let stageMgr = "qeaj75wk3HF4DwQ8qbIi7g" // DeviceSupportsEnhancedMultitasking
    
    // lookup
    static let deviceClass = "+3Uf0Pm5F8Xy7Onyvko0vA" // DeviceClass
    static let artwork = "oPeik/9e8lQWMszEjbPzng" // ArtworkTraits
    static let prodType = "h9jDsbgj7xIVeIQ8S3/X3Q" // ProductType
}

final class GestaltStore: ObservableObject {
    static let shared = GestaltStore()
    
    @Published var mgCurrentDict = NSMutableDictionary()
    var cacheExtra: NSMutableDictionary {
        return mgCurrentDict["CacheExtra"] as? NSMutableDictionary ?? NSMutableDictionary()
    }
    
    init() {}
    
    // MARK: actions
    func mgPullKeys(_ keys: [String]) {
        for key in keys {
            cacheExtra.removeObject(forKey: key)
        }
    }
    
    func isEnabled(_ keys: [String], enableValue: Int = 1) -> Bool {
        let values = self.cacheExtra[keys] as? [Int] ?? []
        let testVal = self.cacheExtra[keys.first!] as? Int
        if values.allSatisfy({ $0 == testVal }) {
            return testVal == enableValue
        }
        return false
    }
    
    func strVal(forKey key: String) -> String {
        let value = self.cacheExtra[key] as? String ?? ""
        return value
    }
    
    // MARK: bindings
    func mgKeyBinding(_ keys: [String], defaultValue: Int = 0, enableValue: Int = 1) -> Binding<Bool> {
        return Binding(get: {
            if let value = self.cacheExtra[keys.first!] as? Int {
                return value == enableValue
            }
            return false
        }, set: { enabled in
            self.objectWillChange.send()
            for key in keys {
                if enabled {
                    self.cacheExtra[key] = enableValue
                } else {
                    self.cacheExtra.removeObject(forKey: key)
                }
            }
        })
    }
    
    func mgTrollPadBinding() -> Binding<Bool> {
        return Binding(get: {
            if let value = self.cacheExtra[MGKey.ipadosCacheEx.first!] as? Int? {
                return value == 1
            }
            return false
        }, set: { enabled in
            self.objectWillChange.send()
            if self.mgSetiPadOS(enable: enabled) {
                for key in MGKey.ipadosCacheEx {
                    if enabled {
                        self.cacheExtra[key] = 1
                    } else {
                        self.cacheExtra.removeObject(forKey: key)
                    }
                }
            }
        })
    }
    
    func mgRegionRestrictionsBinding() -> Binding<Bool> {
        return Binding<Bool>(
            get: {
                return self.cacheExtra[MGKey.regionCode] as? String == "LL" && self.cacheExtra[MGKey.regionSysconfig] as? String == "LL/A"
            },
            set: { enabled in
                self.objectWillChange.send()
                if enabled {
                    Alertinator.shared.alert(title: "警告！", body: MGMsg.region)
                    self.cacheExtra[MGKey.regionCode] = "LL"
                    self.cacheExtra[MGKey.regionSysconfig] = "LL/A"
                } else {
                    self.cacheExtra.removeObject(forKey: MGKey.regionCode)
                    self.cacheExtra.removeObject(forKey: MGKey.regionSysconfig)
                }
            }
        )
    }
    
    // MARK: particular non-binded modifications
    // this function was, surprisingly, made by Siri AI. it works as it should, at least on my test devices, so this'll have to do until someone figures out a better way.
    func mgSetiPadOS(enable: Bool) -> Bool {
        guard let cacheData = mgCurrentDict["CacheData"] as? Data else {
            print("(mg) 设置 iPadOS 失败：无法获取 CacheData")
            return false
        }
        let hexString = cacheData.map { String(format: "%02x", $0) }.joined()
        var hex = Array(hexString)
        let sliceStart = 1616
        let sliceLength = 200
        
        guard hex.count > sliceStart else {
            print("(mg) 设置 iPadOS 失败：缓存数据过短，无法包含所需的字节片段。")
            return false
        }
        
        let end = min(hex.count, sliceStart + sliceLength)
        let slice = String(hex[sliceStart..<end])
        
        guard let regex = try? NSRegularExpression(pattern: "0+(?:5555)*([0-9a-f]{4})") else { return false }
        let nsRange = NSRange(slice.startIndex..<slice.endIndex, in: slice)
        
        var matchedOffset: Int?
        regex.enumerateMatches(in: slice, range: nsRange) { match, _, stop in
            guard let match = match,
                  let range = Range(match.range(at: 1), in: slice) else { return }
            
            let value = slice[range]
            if value.filter({ $0 != "0" }).count >= 3 {
                matchedOffset = sliceStart + slice.distance(from: slice.startIndex, to: range.lowerBound)
                stop.pointee = true
            }
        }
        
        guard let offset = matchedOffset else {
            print("(mg) 设置 iPadOS 失败：在指定片段中未找到目标模式。")
            return false
        }
        
        let rightOffset = offset + 13
        let leftOffset = offset - 67
        
        guard leftOffset > 0, rightOffset < hex.count - 1 else {
            print("(mg) 设置 iPadOS 失败：计算出的偏移量超出范围。")
            return false
        }
        
        for position in [leftOffset, rightOffset] {
            guard ["1", "3"].contains(String(hex[position])),
                  hex[position - 1] == "0", hex[position + 1] == "0" else {
                print("(mg) 设置 iPadOS 失败：在计算出的偏移量处校验失败。")
                return false
            }
        }
        
        hex[leftOffset] = enable ? "3" : "1"
        
        let updatedHex = String(hex)
        var updatedData = Data(capacity: updatedHex.count / 2)
        
        var index = updatedHex.startIndex
        while index < updatedHex.endIndex {
            let next = updatedHex.index(index, offsetBy: 2)
            guard next <= updatedHex.endIndex,
                  let byte = UInt8(updatedHex[index..<next], radix: 16) else {
                print("(mg) 设置 iPadOS 失败：无法从十六进制字符串重建数据。")
                return false
            }
            updatedData.append(byte)
            index = next
        }
        
        mgCurrentDict["CacheData"] = updatedData
        return true
    }
}
