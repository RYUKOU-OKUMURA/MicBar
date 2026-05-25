import Foundation

@MainActor
final class MicBarSettings: ObservableObject {
    private enum Keys {
        static let showMenuBarLabel = "showMenuBarLabel"
    }

    @Published var showMenuBarLabel: Bool {
        didSet {
            UserDefaults.standard.set(showMenuBarLabel, forKey: Keys.showMenuBarLabel)
        }
    }

    @Published private(set) var loginItemEnabled = false

    init() {
        showMenuBarLabel = UserDefaults.standard.bool(forKey: Keys.showMenuBarLabel)
    }

    func syncLoginItemFromSystem() {
        loginItemEnabled = LoginItemService.isEnabled
    }

    func setLoginItemEnabled(_ enabled: Bool) throws {
        try LoginItemService.setEnabled(enabled)
        loginItemEnabled = LoginItemService.isEnabled
    }
}
