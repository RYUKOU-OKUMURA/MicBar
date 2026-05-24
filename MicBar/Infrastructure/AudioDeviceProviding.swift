import CoreAudio

protocol AudioDeviceProviding: Sendable {
    func listInputDevices() throws -> [AudioInputDevice]
    func getDefaultInputDevice() throws -> AudioInputDevice?
    func setDefaultInputDevice(_ deviceID: AudioDeviceID) throws
}
