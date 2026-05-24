import SwiftUI

@main
struct MicBarApp: App {
    @StateObject private var store: AudioDeviceStore

    init() {
        let audioStore = AudioDeviceStore()
        _store = StateObject(wrappedValue: audioStore)
        Task { @MainActor in
            await audioStore.refresh()
        }
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(store: store)
        } label: {
            MenuBarLabelView(store: store)
        }
        .menuBarExtraStyle(.menu)
    }
}
