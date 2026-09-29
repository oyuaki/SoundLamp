import AppKit

/// Menu bar icons. Asset catalog images win; SF Symbols are the fallback.
enum MenuIcon {
    private static let silentImage = makeImage(silent: true)
    private static let audibleImage = makeImage(silent: false)

    static func image(silent: Bool) -> NSImage {
        silent ? silentImage : audibleImage
    }

    private static func makeImage(silent: Bool) -> NSImage {
        let description = silent ? L10n.iconSilent : L10n.iconAudible
        let image = asset(silent: silent) ?? symbol(silent: silent, description: description)
        image.accessibilityDescription = description
        return image
    }

    private static func asset(silent: Bool) -> NSImage? {
        guard let image = NSImage(named: silent ? "MenuIconSilent" : "MenuIconAudible")?.copy() as? NSImage,
              !image.representations.isEmpty, image.size.width > 0 else {
            return nil
        }
        // Silent follows the menu bar appearance; audible keeps its own colors.
        image.isTemplate = silent
        return image
    }

    private static func symbol(silent: Bool, description: String) -> NSImage {
        let name = silent ? "speaker.slash.fill" : "speaker.wave.2.fill"
        let base = NSImage(systemSymbolName: name, accessibilityDescription: description) ?? NSImage()
        var config = NSImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        if !silent {
            config = config.applying(NSImage.SymbolConfiguration(paletteColors: [.systemBlue]))
        }
        let image = base.withSymbolConfiguration(config) ?? base
        image.isTemplate = silent
        return image
    }
}
