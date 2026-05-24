import Foundation

enum AudioDeviceError: Error, Equatable {
    case listFailed
    case defaultDeviceFailed
    case switchFailed
    case noDevices
}

extension AudioDeviceError {
    static let switchErrorMessage =
        "この入力デバイスに切り替えられませんでした。接続状態を確認してください。"
}
