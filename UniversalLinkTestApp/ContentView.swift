//
//  ContentView.swift
//  UniversalLinkTestApp
//
//  Created by 한현민 on 10/11/24.
//

import SafariServices
import SwiftUI

enum Path: String {
    case root = "/"
    case entrance = "/entrance"
    case room = "/room"
}

enum OpeningBrowser: String {
    case systemDefault = "System Default"
    case safari = "Safari"
}

enum NavigationPath: Hashable {
    case safariView
}

struct ContentView: View {
    let baseUrlString = "https://cocopen.net"
    let paths: [Path] = [.root, .entrance, .room]
    
    @State private var selectedPath: Path = .root
    @State private var enteredRoomNumber: String = ""
    @State private var openingBrowser: OpeningBrowser = .systemDefault
    
    // 모달 상태관리
    @State private var isShowingShareSheet: Bool = false
    
    // 화면 이동용
    @State private var navigationPath: [NavigationPath] = []
    
    var toBeOpenedUrlString: String {
        var result = baseUrlString
        result.append(selectedPath.rawValue)
        
        if selectedPath != .room {
            return result
        } else {
            guard !enteredRoomNumber.isEmpty else {
                return result
            }
            result.append("/\(enteredRoomNumber)")
            return result
        }
    }
    
    var url: URL {
        URL(string: toBeOpenedUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 20.0) {
                Text("\(toBeOpenedUrlString)")
                
                TextField("roomId:", text: $enteredRoomNumber)
                    .onChange(of: enteredRoomNumber) { oldValue, newValue in
                        if newValue.count > 8 {
                            enteredRoomNumber = oldValue
                        }
                        enteredRoomNumber = enteredRoomNumber.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                    }
                    .multilineTextAlignment(.center)
                    .frame(width: 150)
                
                HStack {
                    Button("root") {
                        selectedPath = .root
                    }
                    
                    Button("entrance") {
                        selectedPath = .entrance
                    }
                    
                    Button("room") {
                        selectedPath = .room
                    }
                }
                
                Picker("Opening Browser", selection: $openingBrowser) {
                    Text(OpeningBrowser.systemDefault.rawValue).tag(OpeningBrowser.systemDefault)
                    Text(OpeningBrowser.safari.rawValue).tag(OpeningBrowser.safari)
                }
                
                switch openingBrowser {
                case .systemDefault:
                    Button("Open in System Default Browser") {
                        debugStatus()
                        UIApplication.shared.open(url)
                    }
                    .buttonStyle(.borderedProminent)
                    
                case .safari:
                    Button("Open in Safari") {
                        debugStatus()
                        navigationPath.append(.safariView)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .navigationTitle("Universal Link Test")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        openAppStore()
                    } label: {
                        Image(systemName: "link.circle")
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isShowingShareSheet.toggle()
                    } label: {
                        Image(systemName: "square.and.arrow.up.circle")
                    }
                }
            }
            .sheet(isPresented: $isShowingShareSheet) {
                ShareSheet(items: [url])
                    .presentationDetents([.medium, .large]) // 앞에 오는 게 처음 상태
            }
            .navigationDestination(for: NavigationPath.self, destination: { path in
                switch path {
                case .safariView:
                    SafariView(url: url)
                }
            })
        }
        .onAppear {
            UITextField.appearance().clearButtonMode = .whileEditing
        }
    }
    
    private func openAppStore() {
        if let url = URL(string: "https://apps.apple.com/kr/app/cocopen/id1544024422") {
            UIApplication.shared.open(url)
        }
    }
    
    private func debugStatus() {
        debugPrint(#function, "url:", url, "has been passed to", openingBrowser)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // 업데이트는 필요하지 않음
    }
}

struct SafariView: UIViewControllerRepresentable {
    var url: URL
    
    func makeUIViewController(context: Context) -> some UIViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

#Preview {
    ContentView()
}
