import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var touchBarController: TouchBarController?
    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("Application launched!")
        
        // Hide the main window
        NSApp.windows.forEach { $0.close() }
        
        // Check if the Mac has a Touch Bar
        if hasTouchBar() {
            print("This Mac has a Touch Bar. Initializing Touch Bar controller...")
            touchBarController = TouchBarController()
        } else {
            print("This Mac does not have a Touch Bar. Exiting...")
            showNoTouchBarAlert()
            NSApp.terminate(nil) // Quit the app
        }
        
        // Add a menu bar icon
        setupMenuBarIcon()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false // Prevent the app from quitting when the window is closed
    }

    // MARK: - Menu Bar Icon

    func setupMenuBarIcon() {
        // Create a status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // Set an icon for the status bar item
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "gamecontroller", accessibilityDescription: "Pac-Man Touch Bar")
        }
        
        // Create a menu for the status bar item
        let menu = NSMenu()
        
        // Add a "Quit" option to the menu
        let quitMenuItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitMenuItem.target = self
        menu.addItem(quitMenuItem)
        
        // Assign the menu to the status bar item
        statusItem?.menu = menu
    }

    @objc func quitApp() {
        NSApp.terminate(nil) // Quit the app
    }

    // MARK: - No Touch Bar Alert

    func showNoTouchBarAlert() {
        let alert = NSAlert()
        alert.messageText = "No Touch Bar Detected"
        alert.informativeText = "This app requires a MacBook with a Touch Bar. Please run it on a compatible device."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
