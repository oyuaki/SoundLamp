import SoundLampCore
import Testing

struct OutputMonitorTests {
    let speakers: DeviceID = 10
    let airPods: DeviceID = 20
    let hdmi: DeviceID = 30

    private func makeMonitor(_ system: FakeAudioSystem) -> (OutputMonitor, Recorder) {
        let monitor = OutputMonitor(system: system)
        let recorder = Recorder()
        monitor.onChange = { recorder.statuses.append($0) }
        monitor.start()
        return (monitor, recorder)
    }

    final class Recorder {
        var statuses: [OutputStatus] = []
    }

    // MARK: Basics

    @Test func startReadsCurrentDevice() {
        let system = FakeAudioSystem()
        system.devices[speakers] = .speakers(volume: 0)
        system.defaultDevice = speakers
        let (monitor, _) = makeMonitor(system)

        #expect(monitor.status.state == .silent(.volumeZero))
        #expect(monitor.status.deviceName == "MacBook Pro Speakers")
        #expect(system.activeSystemListeners == 1)
        #expect(system.activeDeviceListeners(for: speakers) == 1)
    }

    @Test func volumeChangeOnCurrentDeviceIsDetected() {
        let system = FakeAudioSystem()
        system.devices[speakers] = .speakers(volume: 0)
        system.defaultDevice = speakers
        let (monitor, _) = makeMonitor(system)

        system.update(speakers) { $0.volume = 0.3 }
        #expect(monitor.status.state == .audible(volume: 0.3))

        system.update(speakers) { $0.isMuted = true }
        #expect(monitor.status.state == .silent(.muted))
    }

    @Test func unchangedStatusDoesNotNotify() {
        let system = FakeAudioSystem()
        system.devices[speakers] = .speakers(volume: 0)
        system.defaultDevice = speakers
        let (_, recorder) = makeMonitor(system)
        let count = recorder.statuses.count

        system.fireDevice(speakers)
        system.fireSystem()
        #expect(recorder.statuses.count == count)
    }

    @Test func stopRemovesAllListeners() {
        let system = FakeAudioSystem()
        system.devices[speakers] = .speakers()
        system.defaultDevice = speakers
        let (monitor, _) = makeMonitor(system)

        monitor.stop()
        #expect(system.activeSystemListeners == 0)
        #expect(system.activeDeviceListeners(for: speakers) == 0)
    }

    // MARK: Device switching

    @Test func switchingToAudibleDeviceIsDetected() {
        let system = FakeAudioSystem()
        system.devices[speakers] = .speakers(volume: 0)
        system.defaultDevice = speakers
        let (monitor, recorder) = makeMonitor(system)
        #expect(monitor.status.state.isSilent)

        system.connect(airPods, .airPods(volume: 0.5), makeDefault: true)

        #expect(monitor.status.state == .audible(volume: 0.5))
        #expect(monitor.status.deviceID == airPods)
        #expect(monitor.status.deviceName == "AirPods Pro")
        #expect(recorder.statuses.last?.deviceID == airPods)
    }

    @Test func listenersMoveToNewDeviceOnSwitch() {
        let system = FakeAudioSystem()
        system.devices[speakers] = .speakers(volume: 0)
        system.devices[airPods] = .airPods(volume: 0)
        system.defaultDevice = speakers
        let (monitor, _) = makeMonitor(system)

        system.switchDefault(to: airPods)

        #expect(system.activeDeviceListeners(for: speakers) == 0)
        #expect(system.activeDeviceListeners(for: airPods) == 1)
        #expect(system.activeSystemListeners == 1)
        withExtendedLifetime(monitor) {}
    }

    @Test func changesOnNewDeviceAreDetectedAfterSwitch() {
        let system = FakeAudioSystem()
        system.devices[speakers] = .speakers(volume: 0)
        system.devices[airPods] = .airPods(volume: 0)
        system.defaultDevice = speakers
        let (monitor, _) = makeMonitor(system)

        system.switchDefault(to: airPods)
        #expect(monitor.status.state == .silent(.volumeZero))

        system.update(airPods) { $0.volume = 0.2 }
        #expect(monitor.status.state == .audible(volume: 0.2))
    }

    @Test func changesOnOldDeviceAreIgnoredAfterSwitch() {
        let system = FakeAudioSystem()
        system.devices[speakers] = .speakers(volume: 0)
        system.devices[airPods] = .airPods(volume: 0)
        system.defaultDevice = speakers
        let (monitor, recorder) = makeMonitor(system)

        system.switchDefault(to: airPods)
        let count = recorder.statuses.count

        system.update(speakers) { $0.volume = 0.9 }
        #expect(monitor.status.state == .silent(.volumeZero))
        #expect(monitor.status.deviceID == airPods)
        #expect(recorder.statuses.count == count)
    }

    @Test func switchingBackAndForthKeepsTracking() {
        let system = FakeAudioSystem()
        system.devices[speakers] = .speakers(volume: 0)
        system.devices[airPods] = .airPods(volume: 0.6)
        system.defaultDevice = speakers
        let (monitor, _) = makeMonitor(system)

        system.switchDefault(to: airPods)
        system.switchDefault(to: speakers)
        #expect(monitor.status.state == .silent(.volumeZero))
        #expect(system.activeDeviceListeners(for: airPods) == 0)
        #expect(system.activeDeviceListeners(for: speakers) == 1)

        system.update(speakers) { $0.volume = 0.1 }
        #expect(monitor.status.state == .audible(volume: 0.1))

        system.switchDefault(to: airPods)
        system.update(airPods) { $0.isMuted = true }
        #expect(monitor.status.state == .silent(.muted))
    }

    @Test func disconnectingFallsBackToNextDevice() {
        let system = FakeAudioSystem()
        system.devices[speakers] = .speakers(volume: 0.4)
        system.devices[airPods] = .airPods(volume: 0)
        system.defaultDevice = airPods
        let (monitor, _) = makeMonitor(system)
        #expect(monitor.status.state.isSilent)

        system.disconnect(airPods, newDefault: speakers)

        #expect(monitor.status.deviceID == speakers)
        #expect(monitor.status.state == .audible(volume: 0.4))
        #expect(system.activeDeviceListeners(for: airPods) == 0)
    }

    @Test func noDefaultDevice() {
        let system = FakeAudioSystem()
        system.devices[speakers] = .speakers(volume: 0.4)
        system.defaultDevice = speakers
        let (monitor, _) = makeMonitor(system)

        system.disconnect(speakers, newDefault: nil)
        #expect(monitor.status == .noDevice)

        system.connect(airPods, .airPods(volume: 0.3), makeDefault: true)
        #expect(monitor.status.state == .audible(volume: 0.3))
    }

    @Test func switchingToDeviceWithoutVolume() {
        let system = FakeAudioSystem()
        system.devices[speakers] = .speakers(volume: 0)
        system.devices[hdmi] = .fixedVolume(mute: false)
        system.defaultDevice = speakers
        let (monitor, _) = makeMonitor(system)

        system.switchDefault(to: hdmi)
        #expect(monitor.status.state == .audible(volume: nil))

        system.update(hdmi) { $0.isMuted = true }
        #expect(monitor.status.state == .silent(.muted))
    }

    @Test func controlsAppearingLaterReRegisterListeners() {
        let system = FakeAudioSystem()
        // Bluetooth devices can show up before their volume control is available.
        var early = DeviceSnapshot.airPods()
        early.volume = nil
        early.isMuted = nil
        system.devices[airPods] = early
        system.defaultDevice = airPods
        let (monitor, _) = makeMonitor(system)
        #expect(monitor.status.state == .audible(volume: nil))
        #expect(system.deviceRegistrationCount[airPods] == 1)

        system.update(airPods) { $0.volume = 0; $0.isMuted = false }

        #expect(monitor.status.state == .silent(.volumeZero))
        #expect(system.deviceRegistrationCount[airPods] == 2)
        #expect(system.activeDeviceListeners(for: airPods) == 1)
    }

    @Test func resyncReRegistersEverything() {
        let system = FakeAudioSystem()
        system.devices[speakers] = .speakers(volume: 0)
        system.defaultDevice = speakers
        let (monitor, _) = makeMonitor(system)

        // Default changed while we weren't told (e.g. during sleep).
        system.devices[airPods] = .airPods(volume: 0.7)
        system.defaultDevice = airPods

        monitor.resync()
        #expect(monitor.status.deviceID == airPods)
        #expect(monitor.status.state == .audible(volume: 0.7))
        #expect(system.activeSystemListeners == 1)
        #expect(system.activeDeviceListeners(for: speakers) == 0)
        #expect(system.activeDeviceListeners(for: airPods) == 1)
    }

    // MARK: Set to zero

    @Test func setToZeroLowersVolume() {
        let system = FakeAudioSystem()
        system.devices[speakers] = .speakers(volume: 0.45)
        system.defaultDevice = speakers
        let (monitor, _) = makeMonitor(system)
        #expect(monitor.status.canSetToZero)

        monitor.setToZero()
        #expect(system.devices[speakers]?.volume == 0)
        #expect(system.devices[speakers]?.isMuted == false)
        #expect(monitor.status.state == .silent(.volumeZero))
        #expect(monitor.status.canSetToZero == false)
    }

    @Test func setToZeroMutesDeviceWithoutVolume() {
        let system = FakeAudioSystem()
        system.devices[hdmi] = .fixedVolume(mute: false)
        system.defaultDevice = hdmi
        let (monitor, _) = makeMonitor(system)

        monitor.setToZero()
        #expect(system.devices[hdmi]?.isMuted == true)
        #expect(monitor.status.state == .silent(.muted))
    }

    @Test func setToZeroActsOnCurrentDeviceAfterSwitch() {
        let system = FakeAudioSystem()
        system.devices[speakers] = .speakers(volume: 0.3)
        system.devices[airPods] = .airPods(volume: 0.5)
        system.defaultDevice = speakers
        let (monitor, _) = makeMonitor(system)

        system.switchDefault(to: airPods)
        monitor.setToZero()
        #expect(system.devices[airPods]?.volume == 0)
        #expect(system.devices[speakers]?.volume == 0.3)
    }
}
