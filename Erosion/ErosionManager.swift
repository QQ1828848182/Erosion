//
//  ErosionManager.swift
//  Erosion
//
//  Created by lunginspector on 8/24/26.
//

import Foundation
import Combine

let build = "Release"

enum Errors {
    static var checkLogs = "请查看错误日志以获取更详细的信息。"
}

enum AppURL {
    static let pb = URL.documentsDirectory.appendingPathComponent("PosterBoard")
    static let pbFolders = AppURL.pb.appendingPathComponent("Wallpapers")
    static let ps = URL.documentsDirectory.appendingPathComponent("Passcode Themes")
}

enum AppMsg {
    static let opFailed = "请重启应用后重试。如果问题仍然存在，可能是你的设备不受支持，或者该修改在你的设备上无法正常工作。"
    static let applied = "请 Respring 设备以使更改生效。"
    static let unsupported = "很抱歉，Erosion 所依赖的漏洞在此版本中已被修复。请退出应用。"
}

final class ErosionManager: ObservableObject {
    static let shared = ErosionManager()
    @Published var logOutput = ""
    @Published var shouldRespring = false
    @Published var refreshFiles = false
    
    @Published var storedFiles = [FileItem]()
    @Published var storedURL: URL = URL(fileURLWithPath: "/")
    
    init() {}
}
