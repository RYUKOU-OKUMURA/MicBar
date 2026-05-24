import CoreAudio
import Foundation

final class CoreAudioService: AudioDeviceProviding, @unchecked Sendable {
    private let systemObjectID = AudioObjectID(kAudioObjectSystemObject)

    func listInputDevices() throws -> [AudioInputDevice] {
        let deviceIDs = try fetchAllDeviceIDs()
        let defaultID = try fetchDefaultInputDeviceID()

        var devices: [(id: AudioDeviceID, uid: String, name: String)] = []
        for deviceID in deviceIDs {
            guard try hasInputChannels(deviceID: deviceID) else { continue }
            let name = try fetchDeviceName(deviceID: deviceID)
            let uid = try fetchDeviceUID(deviceID: deviceID)
            devices.append((deviceID, uid, name))
        }

        let names = devices.map(\.name)
        let displayNames = DisplayNameFormatter.format(names: names)

        return zip(devices, displayNames).map { device, displayName in
            AudioInputDevice(
                id: device.id,
                uid: device.uid,
                name: device.name,
                displayName: displayName,
                isDefault: device.id == defaultID
            )
        }
    }

    func getDefaultInputDevice() throws -> AudioInputDevice? {
        let devices = try listInputDevices()
        return devices.first(where: \.isDefault)
    }

    func setDefaultInputDevice(_ deviceID: AudioDeviceID) throws {
        var mutableDeviceID = deviceID
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let status = AudioObjectSetPropertyData(
            systemObjectID,
            &address,
            0,
            nil,
            UInt32(MemoryLayout<AudioDeviceID>.size),
            &mutableDeviceID
        )

        guard status == noErr else {
            throw AudioDeviceError.switchFailed
        }
    }

    // MARK: - Private

    private func fetchAllDeviceIDs() throws -> [AudioDeviceID] {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var dataSize: UInt32 = 0
        var status = AudioObjectGetPropertyDataSize(
            systemObjectID,
            &address,
            0,
            nil,
            &dataSize
        )
        guard status == noErr, dataSize > 0 else {
            throw AudioDeviceError.listFailed
        }

        let deviceCount = Int(dataSize) / MemoryLayout<AudioDeviceID>.size
        var deviceIDs = [AudioDeviceID](repeating: 0, count: deviceCount)

        status = AudioObjectGetPropertyData(
            systemObjectID,
            &address,
            0,
            nil,
            &dataSize,
            &deviceIDs
        )
        guard status == noErr else {
            throw AudioDeviceError.listFailed
        }

        return deviceIDs
    }

    private func fetchDefaultInputDeviceID() throws -> AudioDeviceID? {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var deviceID = AudioDeviceID(0)
        var dataSize = UInt32(MemoryLayout<AudioDeviceID>.size)
        let status = AudioObjectGetPropertyData(
            systemObjectID,
            &address,
            0,
            nil,
            &dataSize,
            &deviceID
        )

        guard status == noErr, deviceID != 0 else {
            return nil
        }
        return deviceID
    }

    private func hasInputChannels(deviceID: AudioDeviceID) throws -> Bool {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreamConfiguration,
            mScope: kAudioDevicePropertyScopeInput,
            mElement: kAudioObjectPropertyElementMain
        )

        var dataSize: UInt32 = 0
        var status = AudioObjectGetPropertyDataSize(
            deviceID,
            &address,
            0,
            nil,
            &dataSize
        )
        guard status == noErr, dataSize > 0 else {
            return false
        }

        let bufferListPointer = UnsafeMutablePointer<AudioBufferList>.allocate(
            capacity: Int(dataSize)
        )
        defer { bufferListPointer.deallocate() }

        status = AudioObjectGetPropertyData(
            deviceID,
            &address,
            0,
            nil,
            &dataSize,
            bufferListPointer
        )
        guard status == noErr else {
            return false
        }

        let bufferList = UnsafeMutableAudioBufferListPointer(bufferListPointer)
        return bufferList.contains { $0.mNumberChannels > 0 }
    }

    private func fetchDeviceName(deviceID: AudioDeviceID) throws -> String {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioObjectPropertyName,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var name: CFString = "" as CFString
        var dataSize = UInt32(MemoryLayout<CFString>.size)
        let status = AudioObjectGetPropertyData(
            deviceID,
            &address,
            0,
            nil,
            &dataSize,
            &name
        )
        guard status == noErr else {
            throw AudioDeviceError.listFailed
        }
        return name as String
    }

    private func fetchDeviceUID(deviceID: AudioDeviceID) throws -> String {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceUID,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var uid: CFString = "" as CFString
        var dataSize = UInt32(MemoryLayout<CFString>.size)
        let status = AudioObjectGetPropertyData(
            deviceID,
            &address,
            0,
            nil,
            &dataSize,
            &uid
        )
        guard status == noErr else {
            throw AudioDeviceError.listFailed
        }
        return uid as String
    }
}
