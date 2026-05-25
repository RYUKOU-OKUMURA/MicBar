import SwiftUI

@main
struct MicBarApp: App {
    @StateObject private var store: AudioDeviceStore
    @StateObject private var settings: MicBarSettings

    init() {
        let audioStore = AudioDeviceStore()
        let appSettings = MicBarSettings()
        _store = StateObject(wrappedValue: audioStore)
        _settings = StateObject(wrappedValue: appSettings)
        appSettings.syncLoginItemFromSystem()
        Task { @MainActor in
            await audioStore.refreshForeground()
        }
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(store: store, settings: settings)
        } label: {
            MenuBarLabelView(store: store, settings: settings)
        }
        .menuBarExtraStyle(.menu)
    }
}
