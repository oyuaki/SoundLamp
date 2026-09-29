import AppKit
import ServiceManagement
import SoundLampCore

@MainActor
final class AppModel: ObservableObject {
    @Published private(set) var status: OutputStatus = .noDevice
    @Published private(set) var launchAtLogin = false

    private let monitor = OutputMonitor(system: CoreAudioSystem())
    private var wakeObserver: NSObjectProtocol?

    init() {
        monitor.onChange = { [weak self] in self?.status = $0 }
        monitor.start()
        status = monitor.status
        refreshLaunchAtLogin()

        // Listeners can go stale across sleep; re-register everything on wake.
        wakeObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.monitor.resync() }
        }
    }

    var statusText: String {
        switch status.state {
        case .noDevice: return L10n.statusNoDevice
        case .silent(.muted): return L10n.statusMuted
        case .silent(.volumeZero): return L10n.statusVolumeZero
        case .audible(let volume?): return L10n.statusAudible(percent: SoundState.displayPercent(volume))
        case .audible(nil): return L10n.statusAudibleUnknown
        }
    }

    var deviceText: String {
        guard status.deviceID != nil else { return L10n.deviceNone }
        return L10n.device(status.deviceName ?? L10n.deviceUnknown)
    }

    func setToZero() {
        monitor.setToZero()
    }

    func setLaunchAtLogin(_ enabled: Bool) {
        let service = SMAppService.mainApp
        do {
            if enabled {
                try service.register()
            } else {
                try service.unregister()
            }
        } catch {
            NSLog("SoundLamp: failed to update login item: \(error.localizedDescription)")
        }
        if service.status == .requiresApproval {
            SMAppService.openSystemSettingsLoginItems()
        }
        refreshLaunchAtLogin()
    }

    private func refreshLaunchAtLogin() {
        launchAtLogin = SMAppService.mainApp.status == .enabled
    }

    func showAbout() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(nil)
    }
}
