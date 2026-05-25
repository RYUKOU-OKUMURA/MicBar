import CoreAudio

protocol AudioDeviceProviding: Sendable {
    func listInputDevices() throws -> [AudioInputDevice]
    func getDefaultInputDevice() throws -> AudioInputDevice?
    func setDefaultInputDevice(_ deviceID: AudioDeviceID) throws
    func peekDeviceSnapshot() throws -> DeviceSnapshot
    func startMonitoring(onChange: @escaping @Sendable () -> Void)
    func stopMonitoring()
}
