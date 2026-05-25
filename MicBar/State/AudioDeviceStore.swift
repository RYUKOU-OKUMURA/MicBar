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
    @Published private(set) var isMenuVisible = false

    var tooltipText: String {
        currentDevice?.displayName ?? "MicBar"
    }

    private let audioService: AudioDeviceProviding
    private var refreshGeneration = 0
    private var isRefreshing = false
    private var lastSnapshot: DeviceSnapshot?
    private var pendingMonitorRefresh = false
    private var monitorRefreshTask: Task<Void, Never>?

    init(audioService: AudioDeviceProviding = CoreAudioService()) {
        self.audioService = audioService
        startDeviceMonitoring()
    }

    deinit {
        audioService.stopMonitoring()
        monitorRefreshTask?.cancel()
    }

    func refreshForeground() async {
        await performRefresh(showLoading: true)
    }

    func refreshBackground() async {
        await performRefresh(showLoading: false)
    }

    func refreshOnMenuAppear() async {
        if listState == .loading {
            await refreshForeground()
            return
        }

        if let lastSnapshot,
           let current = try? audioService.peekDeviceSnapshot(),
           current == lastSnapshot {
            return
        }

        await refreshForeground()
    }

    func setMenuVisible(_ visible: Bool) {
        isMenuVisible = visible
    }

    func switchDevice(_ device: AudioInputDevice) async {
        errorMessage = nil

        do {
            try audioService.setDefaultInputDevice(device.id)
            await refreshForeground()
            if listState == .normal {
                errorMessage = nil
            }
        } catch {
            errorMessage = AudioDeviceError.switchErrorMessage
        }
    }

    // MARK: - Private

    private func startDeviceMonitoring() {
        audioService.startMonitoring { [weak self] in
            Task { @MainActor in
                self?.handleDeviceChangeNotification()
            }
        }
    }

    private func handleDeviceChangeNotification() {
        pendingMonitorRefresh = true
        monitorRefreshTask?.cancel()
        monitorRefreshTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 100_000_000)
            guard !Task.isCancelled, pendingMonitorRefresh else { return }
            pendingMonitorRefresh = false
            if isMenuVisible {
                await refreshForeground()
            } else {
                await refreshBackground()
            }
        }
    }

    private func performRefresh(showLoading: Bool) async {
        guard !isRefreshing else { return }
        isRefreshing = true
        refreshGeneration += 1
        let generation = refreshGeneration

        if showLoading {
            isLoading = true
            listState = .loading
            errorMessage = nil
        }

        defer {
            if generation == refreshGeneration {
                isLoading = false
                isRefreshing = false
            }
        }

        do {
            let fetchedDevices = try audioService.listInputDevices()
            guard generation == refreshGeneration else { return }

            applyFetchedDevices(fetchedDevices)
        } catch {
            guard generation == refreshGeneration else { return }
            if showLoading {
                devices = []
                currentDevice = nil
                listState = .fetchFailed
            }
        }
    }

    private func applyFetchedDevices(_ fetchedDevices: [AudioInputDevice]) {
        devices = fetchedDevices
        currentDevice = fetchedDevices.first(where: \.isDefault)
        lastSnapshot = DeviceSnapshot(devices: fetchedDevices)

        if fetchedDevices.isEmpty {
            listState = .empty
        } else {
            listState = .normal
        }
    }
}
