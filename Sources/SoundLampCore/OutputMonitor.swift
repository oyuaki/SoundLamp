import Foundation

/// Tracks the default output device and keeps listeners attached to whichever
/// device is current. Use from the main thread only.
public final class OutputMonitor {
    public private(set) var status: OutputStatus = .noDevice
    public var onChange: ((OutputStatus) -> Void)?

    private let system: AudioSystem
    private var systemToken: ObservationToken?
    private var deviceToken: ObservationToken?
    private var observedDevice: DeviceID?
    /// Device details that determine which property listeners should be attached.
    private var observedShape: ObservationShape?

    private struct ObservationShape: Equatable {
        var hasVolume: Bool
        var hasMute: Bool
        var outputKind: OutputDeviceKind?

        init(_ snapshot: DeviceSnapshot?) {
            hasVolume = snapshot?.volume != nil
            hasMute = snapshot?.isMuted != nil
            outputKind = snapshot?.outputKind
        }
    }

    public init(system: AudioSystem) {
        self.system = system
    }

    public var isRunning: Bool { systemToken != nil }

    public func start() {
        guard systemToken == nil else { return }
        systemToken = system.observeOutputDevices { [weak self] in
            self?.reattach(force: true)
        }
        reattach(force: true)
    }

    public func stop() {
        systemToken?.cancel()
        systemToken = nil
        detachDevice()
    }

    /// Re-reads everything and re-registers all listeners (e.g. after wake from sleep).
    public func resync() {
        guard isRunning else { return }
        systemToken?.cancel()
        systemToken = system.observeOutputDevices { [weak self] in
            self?.reattach(force: true)
        }
        reattach(force: true)
    }

    /// Sets the current device to silent: volume 0, or mute when volume can't be changed.
    public func setToZero() {
        guard let device = observedDevice, let snapshot = system.snapshot(of: device) else { return }
        if snapshot.volume != nil, snapshot.canSetVolume {
            system.setVolume(0, on: device)
        } else if snapshot.canSetMute {
            system.setMute(true, on: device)
        }
        refresh()
    }

    private func reattach(force: Bool) {
        let device = system.defaultOutputDevice()
        if force || device != observedDevice {
            attach(to: device)
        }
        refresh()
    }

    private func attach(to device: DeviceID?) {
        detachDevice()
        observedDevice = device
        guard let device else { return }
        observedShape = ObservationShape(system.snapshot(of: device))
        deviceToken = system.observeDevice(device) { [weak self] in
            self?.deviceDidChange(device)
        }
    }

    private func detachDevice() {
        deviceToken?.cancel()
        deviceToken = nil
        observedDevice = nil
        observedShape = nil
    }

    private func deviceDidChange(_ device: DeviceID) {
        // Ignore late callbacks from a device we've already moved away from.
        guard device == observedDevice else { return }
        // Controls can appear after a device connects (e.g. Bluetooth);
        // re-register so listeners on the new controls take effect.
        if ObservationShape(system.snapshot(of: device)) != observedShape {
            attach(to: device)
        }
        refresh()
    }

    private func refresh() {
        let snapshot = observedDevice.flatMap { system.snapshot(of: $0) }
        let newStatus = snapshot == nil
            ? OutputStatus.noDevice
            : OutputStatus(deviceID: observedDevice, snapshot: snapshot)
        guard newStatus != status else { return }
        status = newStatus
        onChange?(newStatus)
    }
}
