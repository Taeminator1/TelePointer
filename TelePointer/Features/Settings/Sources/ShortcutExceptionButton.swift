import AppKit
import KeyboardShortcuts
import ShortcutException
import SwiftUI

struct ShortcutExceptionButton: View {
    private static let popoverWidth: CGFloat = 220
    private static let listHeight: CGFloat = 116
    private static let iconSize: CGFloat = 16

    let name: KeyboardShortcuts.Name
    let store: ShortcutExceptionStore

    @State private var isPresented = false
    @State private var selection: ExcludedApp.ID?

    var body: some View {
        Button {
            isPresented = true
        } label: {
            HStack(spacing: 2) {
                Image(systemName: "nosign")

                if !apps.isEmpty {
                    Text(apps.count.formatted())
                        .monospacedDigit()
                }
            }
            .foregroundStyle(apps.isEmpty ? Color.secondary : Color.accentColor)
        }
        .buttonStyle(.borderless)
        .help("Apps that ignore this shortcut")
        .popover(isPresented: $isPresented, arrowEdge: .bottom) {
            popover
        }
    }

    private var apps: [ExcludedApp] {
        store.apps(for: name.rawValue)
    }

    private var popover: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ignored in")
                .font(.headline)

            list

            HStack(spacing: 4) {
                Button {
                    add()
                } label: {
                    Image(systemName: "plus")
                }

                Button {
                    remove()
                } label: {
                    Image(systemName: "minus")
                }
                .disabled(selection == nil)
            }
            .buttonStyle(.borderless)
        }
        .padding(12)
        .frame(width: Self.popoverWidth)
    }

    @ViewBuilder
    private var list: some View {
        if apps.isEmpty {
            Text("No apps yet.")
                .foregroundStyle(.secondary)
        } else {
            List(apps, selection: $selection) { app in
                HStack(spacing: 6) {
                    icon(for: app)
                        .resizable()
                        .frame(width: Self.iconSize, height: Self.iconSize)

                    Text(app.name)
                }
            }
            .listStyle(.bordered)
            .frame(height: Self.listHeight)
        }
    }

    private func icon(for app: ExcludedApp) -> Image {
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: app.bundleID) else {
            return Image(systemName: "app.dashed")
        }

        return Image(nsImage: NSWorkspace.shared.icon(forFile: url.path(percentEncoded: false)))
    }

    private func add() {
        guard let app = ApplicationPicker.chooseApp() else { return }

        store.add(app, for: name.rawValue)
    }

    private func remove() {
        guard let bundleID = selection else { return }

        store.remove(bundleID: bundleID, for: name.rawValue)
        selection = nil
    }
}

#Preview {
    ShortcutExceptionButton(name: .movePointer, store: ShortcutExceptionStore())
        .padding()
}
