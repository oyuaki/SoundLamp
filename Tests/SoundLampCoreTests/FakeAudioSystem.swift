import SoundLampCore

/// In-memory `AudioSystem` that records listener registrations and fires them synchronously.
final class FakeAudioSystem: AudioSystem {
    var devices: [DeviceID: DeviceSnapshot] = [:]
    var defaultDevice: DeviceID?

    private var nextID = 0
    private var systemHandlers: [Int: () -> Void] = [:]
    private var deviceHandlers: [Int: (DeviceID, () -> Void)] = [:]
    private(set) var deviceRegistrationCount: [DeviceID: Int] = [:]

    func activeDeviceListeners(for device: DeviceID) -> Int {
        deviceHandlers.values.filter { $0.0 == device }.count
    }

    var activeSystemListeners: Int { systemHandlers.count }

    // MARK: Simulation

    /// Changes a device's state and notifies its listeners, like the HAL would.
    func update(_ device: DeviceID, _ change: (inout DeviceSnapshot) -> Void) {
        guard var snapshot = devices[device] else { return }
        change(&snapshot)
        devices[device] = snapshot
        fireDevice(device)
    }

    func switchDefault(to device: DeviceID?) {
        defaultDevice = device
        fireSystem()
    }

    func connect(_ device: DeviceID, _ snapshot: DeviceSnapshot, makeDefault: Bool) {
        devices[device] = snapshot
        if makeDefault { defaultDevice = device }
        fireSystem()
    }

    func disconnect(_ device: DeviceID, newDefault: DeviceID?) {
        devices[device] = nil
        defaultDevice = newDefault
        fireDevice(device)
        fireSystem()
    }

    func fireSystem() {
        systemHandlers.values.forEach { $0() }
    }

    func fireDevice(_ device: DeviceID) {
        deviceHandlers.values.filter { $0.0 == device }.forEach { $0.1() }
    }

    // MARK: AudioSystem

    func defaultOutputDevice() -> DeviceID? { defaultDevice }

    func snapshot(of device: DeviceID) -> DeviceSnapshot? { devices[device] }

    func observeOutputDevices(_ handler: @escaping () -> Void) -> ObservationToken {
        let id = makeID()
        systemHandlers[id] = handler
        return ObservationToken { [weak self] in self?.systemHandlers[id] = nil }
    }

    func observeDevice(_ device: DeviceID, _ handler: @escaping () -> Void) -> ObservationToken {
        let id = makeID()
        deviceHandlers[id] = (device, handler)
        deviceRegistrationCount[device, default: 0] += 1
        return ObservationToken { [weak self] in self?.deviceHandlers[id] = nil }
    }

    func setVolume(_ volume: Float, on device: DeviceID) -> Bool {
        guard devices[device]?.canSetVolume == true else { return false }
        update(device) { $0.volume = volume }
        return true
    }

    func setMute(_ muted: Bool, on device: DeviceID) -> Bool {
        guard devices[device]?.canSetMute == true else { return false }
        update(device) { $0.isMuted = muted }
        return true
    }

    private func makeID() -> Int {
        nextID += 1
        return nextID
    }
}

extension DeviceSnapshot {
    static func speakers(volume: Float = 0, muted: Bool = false) -> DeviceSnapshot {
        DeviceSnapshot(name: "MacBook Pro Speakers", volume: volume, isMuted: muted, canSetVolume: true, canSetMute: true)
    }

    static func airPods(volume: Float = 0.5) -> DeviceSnapshot {
        DeviceSnapshot(name: "AirPods Pro", volume: volume, isMuted: false, canSetVolume: true, canSetMute: true)
    }

    /// e.g. HDMI / some USB interfaces: no volume control, optional mute.
    static func fixedVolume(mute: Bool? = nil) -> DeviceSnapshot {
        DeviceSnapshot(name: "HDMI Display", volume: nil, isMuted: mute, canSetVolume: false, canSetMute: mute != nil)
    }
}
