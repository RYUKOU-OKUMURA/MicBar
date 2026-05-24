import SwiftUI

struct MenuBarLabelView: View {
    @ObservedObject var store: AudioDeviceStore

    var body: some View {
        Image(systemName: "mic")
            .help(store.tooltipText)
    }
}
