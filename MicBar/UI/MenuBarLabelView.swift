import SwiftUI

struct MenuBarLabelView: View {
    @ObservedObject var store: AudioDeviceStore
    @ObservedObject var settings: MicBarSettings

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "mic")
            if settings.showMenuBarLabel, let name = store.currentDevice?.displayName {
                Text(name)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: 120, alignment: .leading)
            }
        }
        .help(store.tooltipText)
    }
}
