import CoreAudio

struct DeviceSnapshot: Equatable {
    let deviceIDs: [AudioDeviceID]
    let defaultDeviceID: AudioDeviceID?

    init(devices: [AudioInputDevice]) {
        deviceIDs = devices.map(\.id).sorted()
        defaultDeviceID = devices.first(where: \.isDefault)?.id
    }
}
