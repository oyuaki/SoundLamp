import AppKit

/// Menu bar icons. Asset catalog images win; SF Symbols are the fallback.
enum MenuIcon {
    private static let silentImage = makeImage(silent: true, headphones: false)
    private static let audibleImage = makeImage(silent: false, headphones: false)
    private static let headphonesSilentImage = makeImage(silent: true, headphones: true)
    private static let headphonesAudibleImage = makeImage(silent: false, headphones: true)

    static func image(silent: Bool, headphones: Bool) -> NSImage {
        switch (headphones, silent) {
        case (false, true): return silentImage
        case (false, false): return audibleImage
        case (true, true): return headphonesSilentImage
        case (true, false): return headphonesAudibleImage
        }
    }

    private static func makeImage(silent: Bool, headphones: Bool) -> NSImage {
        let description = L10n.iconDescription(silent: silent, headphones: headphones)
        let image = asset(silent: silent, headphones: headphones)
            ?? symbol(silent: silent, headphones: headphones, description: description)
        image.accessibilityDescription = description
        return image
    }

    private static func asset(silent: Bool, headphones: Bool) -> NSImage? {
        let name: String
        switch (headphones, silent) {
        case (false, true): name = "MenuIconSilent"
        case (false, false): name = "MenuIconAudible"
        case (true, true): name = "MenuIconHeadphonesSilent"
        case (true, false): name = "MenuIconHeadphonesAudible"
        }
        guard let image = NSImage(named: name)?.copy() as? NSImage,
              !image.representations.isEmpty, image.size.width > 0 else {
            return nil
        }
        // Both headphone states follow the menu bar appearance; only the lamp's audible state is blue.
        image.isTemplate = silent || headphones
        return image
    }

    private static func symbol(silent: Bool, headphones: Bool, description: String) -> NSImage {
        let name = headphones ? "headphones" : (silent ? "speaker.slash.fill" : "speaker.wave.2.fill")
        let base = NSImage(systemSymbolName: name, accessibilityDescription: description) ?? NSImage()
        var config = NSImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        if !silent && !headphones {
            config = config.applying(NSImage.SymbolConfiguration(paletteColors: [.systemBlue]))
        }
        let image = base.withSymbolConfiguration(config) ?? base
        image.isTemplate = silent || headphones
        return image
    }
}
