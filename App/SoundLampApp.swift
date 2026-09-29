import SwiftUI

@main
struct SoundLampApp: App {
    @StateObject private var model = AppModel()

    var body: some Scene {
        MenuBarExtra {
            MenuContent(model: model)
        } label: {
            Image(nsImage: MenuIcon.image(
                silent: model.status.state.isSilent,
                headphones: model.status.outputKind == .headphones
            ))
        }
        .menuBarExtraStyle(.menu)
    }
}

struct MenuContent: View {
    @ObservedObject var model: AppModel

    var body: some View {
        Text(model.statusText)
        Text(model.deviceText)

        Divider()

        Button(L10n.setToZero) { model.setToZero() }
            .disabled(!model.status.canSetToZero)

        Divider()

        Toggle(L10n.launchAtLogin, isOn: Binding(
            get: { model.launchAtLogin },
            set: { model.setLaunchAtLogin($0) }
        ))

        Button(L10n.about) { model.showAbout() }

        Divider()

        Button(L10n.quit) { NSApp.terminate(nil) }
            .keyboardShortcut("q")
    }
}
