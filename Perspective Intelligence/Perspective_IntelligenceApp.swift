//
//  Perspective_IntelligenceApp.swift
//  Perspective Intelligence
//
//  Created by Michael Doise on 9/14/25.
//

import SwiftUI

#if os(macOS)
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Disable window state restoration to prevent previously opened windows from appearing
        UserDefaults.standard.set(false, forKey: "NSQuitAlwaysKeepsWindows")
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // When app is clicked in dock and no windows are visible, open the dashboard
        if !flag {
            NotificationCenter.default.post(name: .openDashboard, object: nil)
        }
        return true
    }
    
    @objc func openChatWindow() {
        NotificationCenter.default.post(name: .openChatWindow, object: nil)
    }
    
    @objc func openDashboard() {
        NotificationCenter.default.post(name: .openDashboard, object: nil)
    }
}

extension Notification.Name {
    static let openChatWindow = Notification.Name("openChatWindow")
    static let openDashboard = Notification.Name("openDashboard")
}
#endif

@main
struct Perspective_IntelligenceApp: App {
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var serverController = ServerController()
    @Environment(\.openWindow) private var openWindow
    #endif
    
    init() {
        // No auto-start - let the user manually start the server
        // This avoids port conflicts with other services like Ollama
    }
    
    var body: some Scene {
        #if os(macOS)
        // Main Dashboard Window - this is the default window that opens on launch
        WindowGroup("Dashboard", id: "dashboard") {
            ServerDashboardView()
                .environmentObject(serverController)
                .task {
                    // Sync controller state with actual server state on appear
                    let running = await LocalHTTPServer.shared.getIsRunning()
                    let port = await LocalHTTPServer.shared.getPort()
                    let error = await LocalHTTPServer.shared.getLastError()
                    await MainActor.run {
                        serverController.isRunning = running
                        serverController.port = port
                        serverController.errorMessage = error
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .openChatWindow)) { _ in
                    openWindow(id: "chat")
                }
                .onReceive(NotificationCenter.default.publisher(for: .openDashboard)) { _ in
                    openWindow(id: "dashboard")
                }
        }
        .defaultSize(width: 600, height: 750)
        .defaultLaunchBehavior(.presented)
        .commands {
            ChatCommands()
            CommandGroup(after: .newItem) {
                Button("Open Chat Window") {
                    NSApp.sendAction(#selector(AppDelegate.openChatWindow), to: nil, from: nil)
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
            }
        }
        
        // Menu Bar Extra
        MenuBarExtra("PI Server", systemImage: "bolt.horizontal.circle") {
            MenuBarContentView()
                .environmentObject(serverController)
                .task {
                    let running = await LocalHTTPServer.shared.getIsRunning()
                    await MainActor.run {
                        serverController.isRunning = running
                    }
                }
        }
        
        // Chat Window - suppressed on launch, only opens when requested
        WindowGroup("Chat", id: "chat") {
            ChatView()
                .environmentObject(serverController)
        }
        .defaultSize(width: 500, height: 600)
        .defaultLaunchBehavior(.suppressed)
        
        // Settings
        Settings {
            SettingsView()
        }
        #else
        WindowGroup {
            ChatView()
        }
        #endif
    }
}
