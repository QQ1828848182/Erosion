//
//  FMRootView.swift
//  Erosion
//
//  Created by lunginspector on 8/26/26.
//

import SwiftUI

enum FSPaths {
    static let appContainers = "/var/mobile/Containers/Data/Application"
    static var appBundles = "/var/containers/Bundle/Application"
}

enum FSURL {
    static let appContainers = URL(fileURLWithPath: FSPaths.appContainers)
    static var sysGroup = URL(fileURLWithPath: "/var/containers/Shared/SystemGroup")
    static var configProfiles = FSURL.sysGroup.appendingPathComponent("systemgroup.com.apple.configurationprofiles/Library/ConfigurationProfiles")
    static var internalDaemons = URL(fileURLWithPath: "/var/mobile/Containers/Data/InternalDaemon")
    static var appPlugins = URL(fileURLWithPath: "/var/mobile/Containers/Data/PluginKitPlugin")
    static var appGroup = URL(fileURLWithPath: "/var/mobile/Containers/Shared/AppGroup")
    static var systemData = URL(fileURLWithPath: "/var/containers/Data/System")
}

struct FMRootView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink("数据容器", destination: FileBrowserView(path: FSURL.appContainers, isContainer: true))
                    NavigationLink("插件容器", destination: FileBrowserView(path: FSURL.appPlugins, isContainer: true))
                    NavigationLink("App 群组", destination: FileBrowserView(path: FSURL.appGroup, shouldGrant: true))
                } header: {
                    HeaderLabel("应用", symbol: "square.grid.2x2")
                }
                
                Section {
                    NavigationLink("守护进程容器", destination: FileBrowserView(path: FSURL.internalDaemons, isContainer: true))
                    NavigationLink("系统容器", destination: FileBrowserView(path: FSURL.systemData, shouldGrant: true))
                    NavigationLink("SystemGroup 容器", destination: FileBrowserView(path: FSURL.sysGroup, isContainer: true))
                } header: {
                    HeaderLabel("系统", symbol: "gear")
                }
            }
            .navigationTitle("文件浏览")
        }
    }
}
