//
//  CustomKeyView.swift
//  Erosion
//
//  Created by lunginspector on 9/8/26.
//

import SwiftUI


struct MGCustomKey: Identifiable, Codable, Equatable {
    var id: String { key }
    let key: String
    var value: Int
    var isOn = false
}

struct CustomKeyView: View {
    @AppStorage("mgCustKeyArray") private var customKeys = [MGCustomKey]()
    @State private var cstkKey = ""
    @State private var cstkValue: Int?
    @State private var itemToEdit: MGCustomKey?
    
    var body: some View {
        List {
            Section {
                TextField("键", text: $cstkKey)
                TextField("值", value: $cstkValue, format: .number)
                    .keyboardType(.numberPad)
                Button("添加键") {
                    if cstkKey.isEmpty || cstkValue == nil {
                        Alertinator.shared.alert(title: "这似乎不是有效的键！", body: "请先在该字段中填入内容，然后重试！")
                    } else if let _ = customKeys.firstIndex(where: { $0.key == cstkKey }) {
                        Alertinator.shared.alert(title: "该键已经添加过了！", body: "如需修改，请滚动到该键。")
                    } else {
                        customKeys.append(MGCustomKey(key: cstkKey, value: cstkValue ?? 0))
                    }
                }
            } header: {
                HeaderLabel("添加键", symbol: "plus")
            }
            
            Section {
                ForEach(customKeys) { item in
                    Toggle(isOn: mgIsOnBinding(for: item)) {
                        Button(item.key) {
                            itemToEdit = item
                        }
                        .foregroundStyle(Color(.label))
                    }
                }
                // new thing to learn: ondelete. way better for having a delete button actually as it'll add it to each cell automatically.
                .onDelete { indexSet in
                    customKeys.remove(atOffsets: indexSet)
                }
            }
        }
        .navigationTitle("自定义键")
        .scrollDismissesKeyboard(.interactively)
        .sheet(item: $itemToEdit) { item in
            EditorPane(item: item)
                .presentationDetents([.fraction(0.3)])
        }
    }
    
    // i hate this as a solution, but it seems like there's a long-standing bug in swiftui where the whole app will crash if i drop all items from an array that uses a direct binding with toggles. really stupid, i know, but that's sorta the way things are. gotta love swiftui...
    // -lunginspector 8/6/26
    private func mgIsOnBinding(for item: MGCustomKey) -> Binding<Bool> {
        Binding(
            get: { customKeys.first(where: { $0.id == item.id })?.isOn ?? false },
            set: { newValue in
                if let index = customKeys.firstIndex(where: { $0.id == item.id }) {
                    customKeys[index].isOn = newValue
                }
            }
        )
    }
    
    private struct EditorPane: View {
        @State var item: MGCustomKey
        @Environment(\.dismiss) var dismiss
        @AppStorage("mgCustKeyArray") var customKeys: [MGCustomKey] = []
        
        var body: some View {
            NavigationStack {
                VStack {
                    Text(item.key)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .modifier(TextFieldBackground())
                    TextField("值", value: $item.value, format: .number)
                        .modifier(TextFieldBackground())
                }
                .padding(.horizontal)
                .navigationTitle("修改键")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Label("关闭", systemImage: "xmark")
                                .labelStyle(.iconOnly)
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(role: .adaptiveConfirm) {
                            if let index = customKeys.firstIndex(where: { $0.key == item.key }) {
                                customKeys[index] = item
                            }
                            dismiss()
                        } label: {
                            Label("确认", systemImage: "checkmark")
                                .labelStyle(.iconOnly)
                        }
                    }
                }
            }
        }
    }
}
