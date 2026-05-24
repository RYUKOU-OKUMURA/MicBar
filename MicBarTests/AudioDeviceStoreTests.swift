import CoreAudio
import XCTest
@testable import MicBar

final class AudioDeviceStoreTests: XCTestCase {
    @MainActor
    func testRefreshSuccessUpdatesDevices() async {
        let mock = MockAudioDeviceService()
        mock.listResult = [
            AudioInputDevice(id: 1, uid: "a", name: "Mic A", displayName: "Mic A", isDefault: true),
            AudioInputDevice(id: 2, uid: "b", name: "Mic B", displayName: "Mic B", isDefault: false),
        ]
        let store = AudioDeviceStore(audioService: mock)

        await store.refresh()

        XCTAssertEqual(store.devices.count, 2)
        XCTAssertEqual(store.currentDevice?.displayName, "Mic A")
        XCTAssertFalse(store.isLoading)
        XCTAssertEqual(store.listState, .normal)
        XCTAssertNil(store.errorMessage)
    }

    @MainActor
    func testRefreshFailureSetsFetchFailed() async {
        let mock = MockAudioDeviceService()
        mock.listError = AudioDeviceError.listFailed
        let store = AudioDeviceStore(audioService: mock)

        await store.refresh()

        XCTAssertTrue(store.devices.isEmpty)
        XCTAssertNil(store.currentDevice)
        XCTAssertEqual(store.listState, .fetchFailed)
    }

    @MainActor
    func testRefreshEmptySetsEmptyState() async {
        let mock = MockAudioDeviceService()
        mock.listResult = []
        let store = AudioDeviceStore(audioService: mock)

        await store.refresh()

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

        await store.refresh()

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

        await store.refresh()
        await store.switchDevice(mock.listResult[0])

        XCTAssertEqual(store.errorMessage, AudioDeviceError.switchErrorMessage)
    }
}

// MARK: - Mock

final class MockAudioDeviceService: AudioDeviceProviding, @unchecked Sendable {
    var listResult: [AudioInputDevice] = []
    var listError: Error?
    var switchError: Error?

    func listInputDevices() throws -> [AudioInputDevice] {
        if let listError { throw listError }
        return listResult
    }

    func getDefaultInputDevice() throws -> AudioInputDevice? {
        try listInputDevices().first(where: \.isDefault)
    }

    func setDefaultInputDevice(_ deviceID: AudioDeviceID) throws {
        if let switchError { throw switchError }
    }
}
