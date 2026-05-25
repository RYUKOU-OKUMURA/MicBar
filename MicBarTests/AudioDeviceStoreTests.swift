import CoreAudio
import XCTest
@testable import MicBar

final class AudioDeviceStoreTests: XCTestCase {
    @MainActor
    func testRefreshForegroundSuccessUpdatesDevices() async {
        let mock = MockAudioDeviceService()
        mock.listResult = [
            AudioInputDevice(id: 1, uid: "a", name: "Mic A", displayName: "Mic A", isDefault: true),
            AudioInputDevice(id: 2, uid: "b", name: "Mic B", displayName: "Mic B", isDefault: false),
        ]
        let store = AudioDeviceStore(audioService: mock)

        await store.refreshForeground()

        XCTAssertEqual(store.devices.count, 2)
        XCTAssertEqual(store.currentDevice?.displayName, "Mic A")
        XCTAssertFalse(store.isLoading)
        XCTAssertEqual(store.listState, .normal)
        XCTAssertNil(store.errorMessage)
        XCTAssertEqual(mock.listCallCount, 1)
    }

    @MainActor
    func testRefreshBackgroundDoesNotSetLoading() async {
        let mock = MockAudioDeviceService()
        mock.listResult = [
            AudioInputDevice(id: 1, uid: "a", name: "Mic A", displayName: "Mic A", isDefault: true),
        ]
        let store = AudioDeviceStore(audioService: mock)

        await store.refreshForeground()
        await store.refreshBackground()

        XCTAssertEqual(store.listState, .normal)
        XCTAssertFalse(store.isLoading)
    }

    @MainActor
    func testRefreshOnMenuAppearSkipsWhenSnapshotUnchanged() async {
        let mock = MockAudioDeviceService()
        mock.listResult = [
            AudioInputDevice(id: 1, uid: "a", name: "Mic A", displayName: "Mic A", isDefault: true),
        ]
        let store = AudioDeviceStore(audioService: mock)

        await store.refreshForeground()
        let countAfterLaunch = mock.listCallCount
        mock.peekSnapshot = DeviceSnapshot(devices: mock.listResult)

        await store.refreshOnMenuAppear()

        XCTAssertEqual(mock.listCallCount, countAfterLaunch)
        XCTAssertEqual(mock.peekCallCount, 1)
    }

    @MainActor
    func testRefreshOnMenuAppearRefreshesWhenSnapshotChanged() async {
        let mock = MockAudioDeviceService()
        mock.listResult = [
            AudioInputDevice(id: 1, uid: "a", name: "Mic A", displayName: "Mic A", isDefault: true),
        ]
        let store = AudioDeviceStore(audioService: mock)

        await store.refreshForeground()
        mock.peekSnapshot = DeviceSnapshot(devices: [
            AudioInputDevice(id: 2, uid: "b", name: "Mic B", displayName: "Mic B", isDefault: true),
        ])

        await store.refreshOnMenuAppear()

        XCTAssertGreaterThan(mock.listCallCount, 1)
    }

    @MainActor
    func testRefreshForegroundFailureSetsFetchFailed() async {
        let mock = MockAudioDeviceService()
        mock.listError = AudioDeviceError.listFailed
        let store = AudioDeviceStore(audioService: mock)

        await store.refreshForeground()

        XCTAssertTrue(store.devices.isEmpty)
        XCTAssertNil(store.currentDevice)
        XCTAssertEqual(store.listState, .fetchFailed)
    }

    @MainActor
    func testRefreshEmptySetsEmptyState() async {
        let mock = MockAudioDeviceService()
        mock.listResult = []
        let store = AudioDeviceStore(audioService: mock)

        await store.refreshForeground()

        XCTAssertEqual(store.listState, .empty)
    }

    @MainActor
    func testDefaultDeviceHasCheck() async {
        let mock = MockAudioDeviceService()
        mock.listResult = [
            AudioInputDevice(id: 1, uid: "a", name: "Mic A", displayName: "Mic A", isDefault: false),
            AudioInputDevice(id: 2, uid: "b", name: "Mic B", displayName: "Mic B", isDefault: true),
        ]
        let store = AudioDeviceStore(audioService: mock)

        await store.refreshForeground()

        XCTAssertTrue(store.devices.first(where: { $0.id == 2 })?.isDefault == true)
        XCTAssertEqual(store.currentDevice?.id, 2)
    }

    @MainActor
    func testSwitchFailureSetsErrorMessage() async {
        let mock = MockAudioDeviceService()
        mock.listResult = [
            AudioInputDevice(id: 1, uid: "a", name: "Mic A", displayName: "Mic A", isDefault: true),
        ]
        mock.switchError = AudioDeviceError.switchFailed
        let store = AudioDeviceStore(audioService: mock)

        await store.refreshForeground()
        await store.switchDevice(mock.listResult[0])

        XCTAssertEqual(store.errorMessage, AudioDeviceError.switchErrorMessage)
    }

    @MainActor
    func testMonitoringCallbackTriggersBackgroundRefresh() async {
        let mock = MockAudioDeviceService()
        mock.listResult = [
            AudioInputDevice(id: 1, uid: "a", name: "Mic A", displayName: "Mic A", isDefault: true),
        ]
        let store = AudioDeviceStore(audioService: mock)

        await store.refreshForeground()
        let countBefore = mock.listCallCount

        mock.simulateDeviceChange()
        try? await Task.sleep(nanoseconds: 150_000_000)

        XCTAssertGreaterThan(mock.listCallCount, countBefore)
        XCTAssertEqual(store.listState, .normal)
    }
}

// MARK: - Mock

final class MockAudioDeviceService: AudioDeviceProviding, @unchecked Sendable {
    var listResult: [AudioInputDevice] = []
    var listError: Error?
    var switchError: Error?
    var peekSnapshot: DeviceSnapshot?
    private(set) var listCallCount = 0
    private(set) var peekCallCount = 0
    private var onChangeHandler: (@Sendable () -> Void)?

    func listInputDevices() throws -> [AudioInputDevice] {
        listCallCount += 1
        if let listError { throw listError }
        return listResult
    }

    func getDefaultInputDevice() throws -> AudioInputDevice? {
        try listInputDevices().first(where: \.isDefault)
    }

    func setDefaultInputDevice(_ deviceID: AudioDeviceID) throws {
        if let switchError { throw switchError }
    }

    func peekDeviceSnapshot() throws -> DeviceSnapshot {
        peekCallCount += 1
        if let peekSnapshot { return peekSnapshot }
        return DeviceSnapshot(devices: try listInputDevices())
    }

    func startMonitoring(onChange: @escaping @Sendable () -> Void) {
        onChangeHandler = onChange
    }

    func stopMonitoring() {
        onChangeHandler = nil
    }

    func simulateDeviceChange() {
        onChangeHandler?()
    }
}
