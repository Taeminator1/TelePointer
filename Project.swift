import ProjectDescription

let project = Project(
    name: "TelePointer",
    targets: [
        .target(
            name: "TelePointer",
            destinations: .macOS,
            product: .app,
            bundleId: "dev.tuist.TelePointer",
            infoPlist: .default,
            buildableFolders: [
                "TelePointer/Sources",
                "TelePointer/Resources",
            ],
            dependencies: []
        ),
        .target(
            name: "TelePointerTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "dev.tuist.TelePointerTests",
            infoPlist: .default,
            buildableFolders: [
                "TelePointer/Tests"
            ],
            dependencies: [.target(name: "TelePointer")]
        ),
    ]
)
