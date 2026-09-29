import Foundation

enum L10n {
    static var statusNoDevice: String { tr("status.noDevice") }
    static var statusMuted: String { tr("status.silent.muted") }
    static var statusVolumeZero: String { tr("status.silent.volumeZero") }
    static var statusAudibleUnknown: String { tr("status.audible.unknown") }
    static func statusAudible(percent: Int) -> String {
        String(format: tr("status.audible.percent"), percent)
    }

    static var deviceNone: String { tr("device.none") }
    static var deviceUnknown: String { tr("device.unknown") }
    static func device(_ name: String) -> String {
        String(format: tr("device.format"), name)
    }

    static var setToZero: String { tr("menu.setToZero") }
    static var launchAtLogin: String { tr("menu.launchAtLogin") }
    static var about: String { tr("menu.about") }
    static var quit: String { tr("menu.quit") }

    static var iconSilent: String { tr("icon.silent") }
    static var iconAudible: String { tr("icon.audible") }

    private static func tr(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }
}
