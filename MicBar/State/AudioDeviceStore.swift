import CoreAudio
import Foundation

enum DeviceListState: Equatable {
    case loading
    case normal
    case empty
    case fetchFailed
}

@MainActor
final class AudioDeviceStore: ObservableObject {
    @Published private(set) var devices: [AudioInputDevice] = []
    @Published private(set) var currentDevice: AudioInputDevice?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var listState: DeviceListState = .loading

    var tooltipText: String {
        currentDevice?.displayName ?? "MicBar"
    }

    private let audioService: AudioDeviceProviding
    private var refreshGeneration = 0
    private var isRefreshing = false

    init(audioService: AudioDeviceProviding = CoreAudioService()) {
        self.audioService = audioService
    }

    func refreshOnLaunch() {
        Task { await refresh() }
    }

    func refresh() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        refreshGeneration += 1
        let generation = refreshGeneration

        isLoading = true
        listState = .loading
        errorMessage = nil

        defer {
            if generation == refreshGeneration {
                isLoading = false
                isRefreshing = false
            }
        }

        do {
            let fetchedDevices = try audioService.listInputDevices()
            guard generation == refreshGeneration else { return }

            devices = fetchedDevices
            currentDevice = fetchedDevices.first(where: \.isDefault)

            if fetchedDevices.isEmpty {
                listState = .empty
            } else {
                listState = .normal
            }
        } catch {
            guard generation == refreshGeneration else { return }
            devices = []
            currentDevice = nil
            listState = .fetchFailed
        }
    }

    func switchDevice(_ device: AudioInputDevice) async {
        errorMessage = nil

        do {
            try audioService.setDefaultInputDevice(device.id)
            await refresh()
            if listState == .normal {
                errorMessage = nil
            }
        } catch {
            errorMessage = AudioDeviceError.switchErrorMessage
        }
    }
}
