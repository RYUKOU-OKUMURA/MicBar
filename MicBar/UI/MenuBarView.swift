import SwiftUI

struct MenuBarView: View {
    @ObservedObject var store: AudioDeviceStore

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
            Task { await store.refresh() }
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

    // MARK: - Footer

    private var footerActions: some View {
        Group {
            Button("入力デバイスを再読み込み") {
                Task { await store.refresh() }
            }
            Button("終了") {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}
