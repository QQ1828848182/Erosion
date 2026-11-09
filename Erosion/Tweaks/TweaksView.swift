//
//  TweaksView.swift
//  Erosion
//
//  Created by lunginspector on 8/26/26.
//

import SwiftUI


struct TweaksView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink("自定义壁纸", destination: PosterBoardView())
                    NavigationLink("拨号键盘美化", destination: KeypadView())
                } header: {
                    HeaderLabel("主题美化", symbol: "paintbrush")
                }
                
                Section {
                    if raveSupported() || weOnADebugBuild {
                        NavigationLink("MobileGestalt", destination: GestaltView())
                        NavigationLink("配置修改", destination: ConfigView())
                    }
                    NavigationLink("文件操作", destination: OperationsView())
                } header: {
                    HeaderLabel("系统", symbol: "gear")
                }
            }
            .navigationTitle("修改")
        }
    }
}
