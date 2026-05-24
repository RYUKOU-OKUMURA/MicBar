import CoreAudio
import Foundation

// Phase S: Core Audio spike — list, get default, switch (optional device name arg)
// Run: xcodebuild -scheme MicBarSpike -configuration Debug build
//      .build/Debug/MicBarSpike list|default|switch [deviceName]

enum SpikeCommand: String {
    case list
    case `default` = "default"
    case switchDevice = "switch"
}

let args = CommandLine.arguments
guard args.count >= 2,
      let command = SpikeCommand(rawValue: args[1]) else {
    fputs("Usage: MicBarSpike <list|default|switch> [deviceName]\n", stderr)
    exit(1)
}

let service = CoreAudioSpikeService()

do {
    switch command {
    case .list:
        print("=== listInputDevices (check: no mic permission dialog) ===")
        let devices = try service.listInputDevices()
        for device in devices {
            let mark = device.isDefault ? " [DEFAULT]" : ""
            print("  \(device.id): \(device.displayName) (uid: \(device.uid))\(mark)")
        }
        print("Total: \(devices.count)")

    case .default:
        print("=== getDefaultInputDevice (check: no mic permission dialog) ===")
        if let device = try service.getDefaultInputDevice() {
            print("  Default: \(device.displayName) (id: \(device.id))")
        } else {
            print("  No default input device")
        }

    case .switchDevice:
        guard args.count >= 3 else {
            fputs("Usage: MicBarSpike switch <deviceDisplayName>\n", stderr)
            exit(1)
        }
        let targetName = args[2...].joined(separator: " ")
        print("=== setDefaultInputDevice -> \(targetName) (check: no mic permission dialog) ===")
        let devices = try service.listInputDevices()
        guard let target = devices.first(where: { $0.displayName == targetName || $0.name == targetName }) else {
            fputs("Device not found: \(targetName)\n", stderr)
            exit(1)
        }
        try service.setDefaultInputDevice(target.id)
        if let newDefault = try service.getDefaultInputDevice() {
            print("  Switched to: \(newDefault.displayName)")
        }
    }
} catch {
    fputs("Error: \(error)\n", stderr)
    exit(1)
}

// MARK: - Spike Core Audio (mirrors production service)

struct SpikeDevice {
    let id: AudioDeviceID
    let uid: String
    let name: String
    let displayName: String
    let isDefault: Bool
}

final class CoreAudioSpikeService {
    private let systemObjectID = AudioObjectID(kAudioObjectSystemObject)

    func listInputDevices() throws -> [SpikeDevice] {
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
        let displayNames = formatDisplayNames(names: names)

        return zip(devices, displayNames).map { device, displayName in
            SpikeDevice(
                id: device.id,
                uid: device.uid,
                name: device.name,
                displayName: displayName,
                isDefault: device.id == defaultID
            )
        }
    }

    func getDefaultInputDevice() throws -> SpikeDevice? {
        try listInputDevices().first(where: \.isDefault)
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
            throw NSError(domain: "MicBarSpike", code: Int(status))
        }
    }

    private func formatDisplayNames(names: [String]) -> [String] {
        var nameCounts: [String: Int] = [:]
        for name in names { nameCounts[name, default: 0] += 1 }
        var nameIndices: [String: Int] = [:]
        return names.map { name in
            if nameCounts[name, default: 0] <= 1 { return name }
            let index = (nameIndices[name, default: 0]) + 1
            nameIndices[name] = index
            return index == 1 ? name : "\(name) \(index)"
        }
    }

    private func fetchAllDeviceIDs() throws -> [AudioDeviceID] {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var dataSize: UInt32 = 0
        guard AudioObjectGetPropertyDataSize(systemObjectID, &address, 0, nil, &dataSize) == noErr,
              dataSize > 0 else {
            throw NSError(domain: "MicBarSpike", code: 1)
        }
        let count = Int(dataSize) / MemoryLayout<AudioDeviceID>.size
        var ids = [AudioDeviceID](repeating: 0, count: count)
        guard AudioObjectGetPropertyData(systemObjectID, &address, 0, nil, &dataSize, &ids) == noErr else {
            throw NSError(domain: "MicBarSpike", code: 2)
        }
        return ids
    }

    private func fetchDefaultInputDeviceID() throws -> AudioDeviceID? {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var deviceID = AudioDeviceID(0)
        var dataSize = UInt32(MemoryLayout<AudioDeviceID>.size)
        guard AudioObjectGetPropertyData(systemObjectID, &address, 0, nil, &dataSize, &deviceID) == noErr,
              deviceID != 0 else { return nil }
        return deviceID
    }

    private func hasInputChannels(deviceID: AudioDeviceID) throws -> Bool {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreamConfiguration,
            mScope: kAudioDevicePropertyScopeInput,
            mElement: kAudioObjectPropertyElementMain
        )
        var dataSize: UInt32 = 0
        guard AudioObjectGetPropertyDataSize(deviceID, &address, 0, nil, &dataSize) == noErr,
              dataSize > 0 else { return false }
        let bufferListPointer = UnsafeMutablePointer<AudioBufferList>.allocate(capacity: Int(dataSize))
        defer { bufferListPointer.deallocate() }
        guard AudioObjectGetPropertyData(deviceID, &address, 0, nil, &dataSize, bufferListPointer) == noErr else {
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
        guard AudioObjectGetPropertyData(deviceID, &address, 0, nil, &dataSize, &name) == noErr else {
            throw NSError(domain: "MicBarSpike", code: 3)
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
        guard AudioObjectGetPropertyData(deviceID, &address, 0, nil, &dataSize, &uid) == noErr else {
            throw NSError(domain: "MicBarSpike", code: 4)
        }
        return uid as String
    }
}
