import SwiftUI

struct MenuBarView: View {
    @ObservedObject var store: AudioDeviceStore
    @ObservedObject var settings: MicBarSettings

    var body: some View {
        Group {
            switch store.listState {
            case .loading:
                loadingContent
            case .empty:
                emptyContent
            case .fetchFailed:
                fetchFailedContent
            case .normal:
                normalContent
            }
        }
        .onAppear {
            settings.syncLoginItemFromSystem()
            store.setMenuVisible(true)
            Task { await store.refreshOnMenuAppear() }
        }
        .onDisappear {
            store.setMenuVisible(false)
        }
    }

    // MARK: - Loading (§7, Device List Loading)

    private var loadingContent: some View {
        Text("入力デバイスを取得中…")
            .disabled(true)
    }

    // MARK: - Normal (§9.1)

    private var normalContent: some View {
        Group {
            Text("MicBar")
                .disabled(true)

            if let errorMessage = store.errorMessage {
                Text(errorMessage)
                    .disabled(true)
            }

            if let current = store.currentDevice {
                Text("現在の入力:\n\(current.displayName)")
                    .disabled(true)
            }

            Divider()

            ForEach(store.devices) { device in
                DeviceMenuItemView(device: device) {
                    Task { await store.switchDevice(device) }
                }
            }

            Divider()
            settingsFooter
            footerActions
        }
    }

    // MARK: - Empty (§9.2)

    private var emptyContent: some View {
        Group {
            Text("入力デバイスが見つかりません")
                .disabled(true)
            Divider()
            footerActions
        }
    }

    // MARK: - Fetch failed (§9.3)

    private var fetchFailedContent: some View {
        Group {
            Text("入力デバイスを取得できませんでした")
                .disabled(true)
            Divider()
            footerActions
        }
    }

    // MARK: - Settings footer (F-014)

    private var settingsFooter: some View {
        Group {
            Toggle("ログイン時に起動", isOn: loginItemBinding)
            Toggle("メニューバーにデバイス名を表示", isOn: $settings.showMenuBarLabel)
        }
    }

    private var loginItemBinding: Binding<Bool> {
        Binding(
            get: { settings.loginItemEnabled },
            set: { newValue in
                do {
                    try settings.setLoginItemEnabled(newValue)
                } catch {
                    settings.syncLoginItemFromSystem()
                }
            }
        )
    }

    // MARK: - Footer

    private var footerActions: some View {
        Group {
            Button("入力デバイスを再読み込み") {
                Task { await store.refreshForeground() }
            }
            Button("終了") {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}
