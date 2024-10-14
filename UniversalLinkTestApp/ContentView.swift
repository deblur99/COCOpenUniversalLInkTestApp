//
//  ContentView.swift
//  UniversalLinkTestApp
//
//  Created by 한현민 on 10/11/24.
//

import SafariServices
import SwiftUI

enum URLType: String {
    case https = "https://"
    case uri = "cocopen://"
}

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
    let baseUri = "cocopen:/"
    let baseUrlString = "https://cocopen.net"
    let paths: [Path] = [.root, .entrance, .room]
    
    @State private var selectedPath: Path = .root
    @State private var enteredRoomNumber: String = ""
    @State private var isOnUri: Bool = false
    @State private var openingBrowser: OpeningBrowser = .systemDefault
    
    // 모달 상태관리
    @State private var isShowingShareSheet: Bool = false
    
    // 화면 이동용
    @State private var navigationPath: [NavigationPath] = []
    
    var toBeOpenedUrlString: String {
        var result = !isOnUri ? baseUrlString : baseUri
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
            List {
                Section("url entry") {
                    VStack(alignment: .leading, spacing: 20.0) {
                        Text("\(toBeOpenedUrlString)")
                        
                        HStack {
                            TextField("roomId", text: $enteredRoomNumber)
                                .onChange(of: enteredRoomNumber) { oldValue, newValue in
                                    if newValue.count > 8 {
                                        enteredRoomNumber = oldValue
                                    }
                                    
                                    // 라틴 문자와 숫자만 남기는 정규 표현식
                                    let regex = try! Regex("[A-Za-z0-9]+")
                                    
                                    enteredRoomNumber = enteredRoomNumber
                                        .matches(of: regex).map { match in
                                            String(match.0)
                                        }
                                        .joined()
                                        .lowercased()
                                }
                                .keyboardType(.asciiCapable)
                            
                            Spacer()
                            
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
                            .buttonStyle(.plain)
                            .foregroundStyle(.blue)
                            .frame(minWidth: 200)
                        }
                    }
                    
                    Toggle(isOn: $isOnUri) {
                        Text("Use URI Scheme instead of HTTPS URL")
                    }
                    .toggleStyle(.switch)
                }
                
                Section("opening method") {
                    VStack(alignment: .center) {
                        if !isOnUri {
                            Picker("Opening Browser", selection: $openingBrowser) {
                                Text(OpeningBrowser.systemDefault.rawValue).tag(OpeningBrowser.systemDefault)
                                Text(OpeningBrowser.safari.rawValue).tag(OpeningBrowser.safari)
                            }
                                
                            switch openingBrowser {
                            case .systemDefault:
                                Button("Open in System Default Browser") {
                                    #if DEBUG
                                    debugStatus()
                                    #else
                                    UIApplication.shared.open(url)
                                    #endif
                                }
                                .buttonStyle(.borderedProminent)
                                    
                            case .safari:
                                Button("Open in Safari") {
                                    #if DEBUG
                                    debugStatus()
                                    #else
                                    navigationPath.append(.safariView)
                                    #endif
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        } else {
                            HStack {
                                Spacer()
                                
                                Button("Open in System Default Browser") {
                                    #if DEBUG
                                    debugStatus()
                                    #else
                                    UIApplication.shared.open(url)
                                    #endif
                                }
                                .buttonStyle(.borderedProminent)
                                .frame(maxWidth: .infinity)
                                
                                Spacer()
                            }
                        }
                    }
                }
            }
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
