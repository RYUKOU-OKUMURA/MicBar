import SwiftUI

struct DeviceMenuItemView: View {
    let device: AudioInputDevice
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(device.displayName)
                Spacer()
                if device.isDefault {
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}
