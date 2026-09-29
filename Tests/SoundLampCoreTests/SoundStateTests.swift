import SoundLampCore
import Testing

struct SoundStateTests {
    @Test func noDeviceIsSilent() {
        let state = SoundState.evaluate(nil)
        #expect(state == .noDevice)
        #expect(state.isSilent)
    }

    @Test func volumeZeroIsSilent() {
        #expect(SoundState.evaluate(.speakers(volume: 0)) == .silent(.volumeZero))
    }

    @Test func floatingPointNoiseCountsAsZero() {
        #expect(SoundState.evaluate(.speakers(volume: 0.0004)) == .silent(.volumeZero))
    }

    @Test func anyAudibleVolumeIsAudible() {
        #expect(SoundState.evaluate(.speakers(volume: 0.01)) == .audible(volume: 0.01))
        #expect(SoundState.evaluate(.speakers(volume: 0.45)) == .audible(volume: 0.45))
    }

    @Test func muteWinsOverVolume() {
        #expect(SoundState.evaluate(.speakers(volume: 0.8, muted: true)) == .silent(.muted))
        #expect(SoundState.evaluate(.speakers(volume: 0.01, muted: true)) == .silent(.muted))
    }

    @Test func volumeZeroIsReportedEvenWhenAlsoMuted() {
        // macOS mutes built-in speakers automatically at volume 0.
        #expect(SoundState.evaluate(.speakers(volume: 0, muted: true)) == .silent(.volumeZero))
    }

    @Test func deviceWithoutVolumeIsAudibleUnlessMuted() {
        #expect(SoundState.evaluate(.fixedVolume(mute: nil)) == .audible(volume: nil))
        #expect(SoundState.evaluate(.fixedVolume(mute: false)) == .audible(volume: nil))
        #expect(SoundState.evaluate(.fixedVolume(mute: true)) == .silent(.muted))
    }

    @Test func displayPercentNeverShowsZeroWhileAudible() {
        #expect(SoundState.displayPercent(0.002) == 1)
        #expect(SoundState.displayPercent(0.45) == 45)
        #expect(SoundState.displayPercent(1) == 100)
    }

    @Test func canSetToZero() {
        #expect(OutputStatus(deviceID: 1, snapshot: .speakers(volume: 0)).canSetToZero == false)
        #expect(OutputStatus(deviceID: 1, snapshot: .speakers(volume: 0.3)).canSetToZero == true)
        // Muted but volume up: still worth zeroing the volume.
        #expect(OutputStatus(deviceID: 1, snapshot: .speakers(volume: 0.3, muted: true)).canSetToZero == true)
        #expect(OutputStatus(deviceID: 1, snapshot: .fixedVolume(mute: false)).canSetToZero == true)
        #expect(OutputStatus(deviceID: 1, snapshot: .fixedVolume(mute: true)).canSetToZero == false)
        #expect(OutputStatus(deviceID: 1, snapshot: .fixedVolume(mute: nil)).canSetToZero == false)
        #expect(OutputStatus.noDevice.canSetToZero == false)
    }
}
