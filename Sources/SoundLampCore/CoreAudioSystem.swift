import AudioToolbox
import CoreAudio
import Foundation

/// `AudioSystem` backed by the Core Audio HAL. Listener callbacks run on the main queue.
public final class CoreAudioSystem: AudioSystem {
    private let queue = DispatchQueue.main
    private let channels: [AudioObjectPropertyElement] = [1, 2]

    public init() {}

    // MARK: Reading

    public func defaultOutputDevice() -> DeviceID? {
        var address = Self.address(kAudioHardwarePropertyDefaultOutputDevice, scope: kAudioObjectPropertyScopeGlobal)
        var device = AudioDeviceID(kAudioObjectUnknown)
        var size = UInt32(MemoryLayout<AudioDeviceID>.size)
        let status = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &size, &device)
        guard status == noErr, device != kAudioObjectUnknown else { return nil }
        return device
    }

    public func snapshot(of device: DeviceID) -> DeviceSnapshot? {
        guard isAlive(device) else { return nil }
        let volumeAddress = volumeAddress(for: device)
        return DeviceSnapshot(
            name: name(of: device),
            volume: volumeAddress.flatMap { readFloat(device, $0) },
            isMuted: readMute(device),
            canSetVolume: volumeAddress.map { isSettable(device, $0) } ?? false,
            canSetMute: !muteAddresses(for: device).filter { isSettable(device, $0) }.isEmpty
        )
    }

    private func isAlive(_ device: DeviceID) -> Bool {
        var address = Self.address(kAudioDevicePropertyDeviceIsAlive, scope: kAudioObjectPropertyScopeGlobal)
        var alive: UInt32 = 0
        var size = UInt32(MemoryLayout<UInt32>.size)
        let status = AudioObjectGetPropertyData(device, &address, 0, nil, &size, &alive)
        // Some devices don't report liveness; treat them as alive.
        return status != noErr || alive != 0
    }

    private func name(of device: DeviceID) -> String? {
        var address = Self.address(kAudioObjectPropertyName, scope: kAudioObjectPropertyScopeGlobal)
        var name: Unmanaged<CFString>?
        var size = UInt32(MemoryLayout<Unmanaged<CFString>?>.size)
        let status = AudioObjectGetPropertyData(device, &address, 0, nil, &size, &name)
        guard status == noErr, let name else { return nil }
        return name.takeRetainedValue() as String
    }

    /// Prefers the virtual main volume, falling back to the main-element volume scalar.
    private func volumeAddress(for device: DeviceID) -> AudioObjectPropertyAddress? {
        let candidates = [
            Self.address(kAudioHardwareServiceDeviceProperty_VirtualMainVolume),
            Self.address(kAudioDevicePropertyVolumeScalar),
        ]
        return candidates.first { hasProperty(device, $0) }
    }

    /// The main mute control, or per-channel mutes when there is no main one.
    private func muteAddresses(for device: DeviceID) -> [AudioObjectPropertyAddress] {
        let main = Self.address(kAudioDevicePropertyMute)
        if hasProperty(device, main) { return [main] }
        return channels
            .map { Self.address(kAudioDevicePropertyMute, element: $0) }
            .filter { hasProperty(device, $0) }
    }

    private func readMute(_ device: DeviceID) -> Bool? {
        let values = muteAddresses(for: device).compactMap { readUInt32(device, $0) }
        guard !values.isEmpty else { return nil }
        return values.allSatisfy { $0 != 0 }
    }

    // MARK: Writing

    @discardableResult
    public func setVolume(_ volume: Float, on device: DeviceID) -> Bool {
        guard var address = volumeAddress(for: device) else { return false }
        var value = Float32(volume)
        let size = UInt32(MemoryLayout<Float32>.size)
        return AudioObjectSetPropertyData(device, &address, 0, nil, size, &value) == noErr
    }

    @discardableResult
    public func setMute(_ muted: Bool, on device: DeviceID) -> Bool {
        let addresses = muteAddresses(for: device).filter { isSettable(device, $0) }
        guard !addresses.isEmpty else { return false }
        var ok = true
        for var address in addresses {
            var value: UInt32 = muted ? 1 : 0
            let size = UInt32(MemoryLayout<UInt32>.size)
            ok = AudioObjectSetPropertyData(device, &address, 0, nil, size, &value) == noErr && ok
        }
        return ok
    }

    // MARK: Observing

    public func observeOutputDevices(_ handler: @escaping () -> Void) -> ObservationToken {
        addListeners(
            to: AudioObjectID(kAudioObjectSystemObject),
            addresses: [
                Self.address(kAudioHardwarePropertyDefaultOutputDevice, scope: kAudioObjectPropertyScopeGlobal),
                Self.address(kAudioHardwarePropertyDevices, scope: kAudioObjectPropertyScopeGlobal),
            ],
            handler: handler
        )
    }

    public func observeDevice(_ device: DeviceID, _ handler: @escaping () -> Void) -> ObservationToken {
        var addresses = [
            Self.address(kAudioHardwareServiceDeviceProperty_VirtualMainVolume),
            Self.address(kAudioDevicePropertyVolumeScalar),
            Self.address(kAudioDevicePropertyMute),
            Self.address(kAudioDevicePropertyDeviceIsAlive, scope: kAudioObjectPropertyScopeGlobal),
            Self.address(kAudioObjectPropertyControlList, scope: kAudioObjectPropertyScopeGlobal),
            Self.address(kAudioObjectPropertyName, scope: kAudioObjectPropertyScopeGlobal),
        ]
        for channel in channels {
            addresses.append(Self.address(kAudioDevicePropertyVolumeScalar, element: channel))
            addresses.append(Self.address(kAudioDevicePropertyMute, element: channel))
        }
        return addListeners(to: device, addresses: addresses, handler: handler)
    }

    private func addListeners(
        to object: AudioObjectID,
        addresses: [AudioObjectPropertyAddress],
        handler: @escaping () -> Void
    ) -> ObservationToken {
        let queue = self.queue
        let block: AudioObjectPropertyListenerBlock = { _, _ in handler() }
        // Registration fails for properties the object lacks; only keep the ones that succeeded.
        let registered = addresses.filter { address in
            var address = address
            return AudioObjectAddPropertyListenerBlock(object, &address, queue, block) == noErr
        }
        return ObservationToken {
            for var address in registered {
                AudioObjectRemovePropertyListenerBlock(object, &address, queue, block)
            }
        }
    }

    // MARK: Helpers

    private static func address(
        _ selector: AudioObjectPropertySelector,
        scope: AudioObjectPropertyScope = kAudioDevicePropertyScopeOutput,
        element: AudioObjectPropertyElement = kAudioObjectPropertyElementMain
    ) -> AudioObjectPropertyAddress {
        AudioObjectPropertyAddress(mSelector: selector, mScope: scope, mElement: element)
    }

    private func hasProperty(_ object: AudioObjectID, _ address: AudioObjectPropertyAddress) -> Bool {
        var address = address
        return AudioObjectHasProperty(object, &address)
    }

    private func isSettable(_ object: AudioObjectID, _ address: AudioObjectPropertyAddress) -> Bool {
        var address = address
        var settable: DarwinBoolean = false
        return AudioObjectIsPropertySettable(object, &address, &settable) == noErr && settable.boolValue
    }

    private func readFloat(_ object: AudioObjectID, _ address: AudioObjectPropertyAddress) -> Float? {
        var address = address
        var value: Float32 = 0
        var size = UInt32(MemoryLayout<Float32>.size)
        guard AudioObjectGetPropertyData(object, &address, 0, nil, &size, &value) == noErr else { return nil }
        return min(1, max(0, value))
    }

    private func readUInt32(_ object: AudioObjectID, _ address: AudioObjectPropertyAddress) -> UInt32? {
        var address = address
        var value: UInt32 = 0
        var size = UInt32(MemoryLayout<UInt32>.size)
        guard AudioObjectGetPropertyData(object, &address, 0, nil, &size, &value) == noErr else { return nil }
        return value
    }
}
