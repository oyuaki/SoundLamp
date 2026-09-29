import Foundation

/// Abstraction over the audio hardware so the monitoring logic can be tested.
/// Handlers are expected to be delivered on the main thread.
public protocol AudioSystem: AnyObject {
    func defaultOutputDevice() -> DeviceID?
    func snapshot(of device: DeviceID) -> DeviceSnapshot?

    /// Fires when the default output device or the device list changes.
    func observeOutputDevices(_ handler: @escaping () -> Void) -> ObservationToken
    /// Fires when anything relevant on `device` changes (volume, mute, controls, liveness).
    func observeDevice(_ device: DeviceID, _ handler: @escaping () -> Void) -> ObservationToken

    @discardableResult func setVolume(_ volume: Float, on device: DeviceID) -> Bool
    @discardableResult func setMute(_ muted: Bool, on device: DeviceID) -> Bool
}

/// Removes its listener when cancelled or deallocated.
public final class ObservationToken {
    private var onCancel: (() -> Void)?

    public init(_ onCancel: @escaping () -> Void) {
        self.onCancel = onCancel
    }

    public func cancel() {
        onCancel?()
        onCancel = nil
    }

    deinit { cancel() }
}
