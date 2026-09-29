import Foundation

public typealias DeviceID = UInt32

/// A point-in-time reading of an output device.
public struct DeviceSnapshot: Equatable {
    public var name: String?
    /// Main volume in 0...1, or `nil` when the device exposes no volume control.
    public var volume: Float?
    /// Mute state, or `nil` when the device exposes no mute control.
    public var isMuted: Bool?
    public var canSetVolume: Bool
    public var canSetMute: Bool

    public init(
        name: String? = nil,
        volume: Float? = nil,
        isMuted: Bool? = nil,
        canSetVolume: Bool = false,
        canSetMute: Bool = false
    ) {
        self.name = name
        self.volume = volume
        self.isMuted = isMuted
        self.canSetVolume = canSetVolume
        self.canSetMute = canSetMute
    }
}

public enum SilenceReason: Equatable {
    case muted
    case volumeZero
}

public enum SoundState: Equatable {
    /// There is no default output device, so nothing can be heard.
    case noDevice
    case silent(SilenceReason)
    /// `volume` is `nil` when the device has no readable volume.
    case audible(volume: Float?)

    /// Volumes below this are treated as exactly 0 (absorbs floating-point noise only).
    public static let zeroThreshold: Float = 0.001

    public var isSilent: Bool {
        switch self {
        case .noDevice, .silent: return true
        case .audible: return false
        }
    }

    public static func evaluate(_ snapshot: DeviceSnapshot?) -> SoundState {
        guard let snapshot else { return .noDevice }
        // macOS also mutes when the volume hits 0, so report "volume 0" first.
        if let volume = snapshot.volume, volume < zeroThreshold { return .silent(.volumeZero) }
        if snapshot.isMuted == true { return .silent(.muted) }
        // Devices without a readable volume are considered audible unless muted.
        guard let volume = snapshot.volume else { return .audible(volume: nil) }
        return .audible(volume: volume)
    }

    /// Percentage for display. Never shows 0% while audible.
    public static func displayPercent(_ volume: Float) -> Int {
        let percent = Int((volume * 100).rounded())
        return min(100, max(1, percent))
    }
}

/// Everything the UI needs to render the current output.
public struct OutputStatus: Equatable {
    public var deviceID: DeviceID?
    public var deviceName: String?
    public var state: SoundState
    /// Whether "Set Volume to 0" can do anything right now.
    public var canSetToZero: Bool

    public init(deviceID: DeviceID?, snapshot: DeviceSnapshot?) {
        self.deviceID = deviceID
        self.deviceName = snapshot?.name
        self.state = SoundState.evaluate(snapshot)
        self.canSetToZero = Self.canSetToZero(snapshot)
    }

    public static let noDevice = OutputStatus(deviceID: nil, snapshot: nil)

    private static func canSetToZero(_ snapshot: DeviceSnapshot?) -> Bool {
        guard let snapshot else { return false }
        if let volume = snapshot.volume, snapshot.canSetVolume {
            return volume >= SoundState.zeroThreshold
        }
        return snapshot.canSetMute && snapshot.isMuted != true
    }
}
