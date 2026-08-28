import ProjectDescription

let deploymentTargets: DeploymentTargets = .macOS("26.0")
let bundlePrefix = "com.taeminyun.TelePointer"

let appInfoPlist: [String: Plist.Value] = [
    "CFBundleDevelopmentRegion": "$(DEVELOPMENT_LANGUAGE)",
    "CFBundleExecutable": "$(EXECUTABLE_NAME)",
    "CFBundleIdentifier": "$(PRODUCT_BUNDLE_IDENTIFIER)",
    "CFBundleInfoDictionaryVersion": "6.0",
    "CFBundleName": "$(PRODUCT_NAME)",
    "CFBundlePackageType": "APPL",
    "CFBundleShortVersionString": "1.0.0",
    "CFBundleVersion": "1",
    "LSMinimumSystemVersion": "$(MACOSX_DEPLOYMENT_TARGET)",
    "NSPrincipalClass": "NSApplication",
    "LSUIElement": true,
]

func module(
    name: String,
    sources: [BuildableFolder],
    dependencies: [TargetDependency] = []
) -> Target {
    .target(
        name: name,
        destinations: .macOS,
        product: .staticFramework,
        bundleId: "\(bundlePrefix).\(name)",
        deploymentTargets: deploymentTargets,
        buildableFolders: sources,
        dependencies: dependencies
    )
}

let project = Project(
    name: "TelePointer",
    settings: .settings(
        base: [
            "SWIFT_VERSION": "6.0",
            "SWIFT_STRICT_CONCURRENCY": "complete",
        ]
    ),
    targets: [
        .target(
            name: "TelePointer",
            destinations: .macOS,
            product: .app,
            bundleId: bundlePrefix,
            deploymentTargets: deploymentTargets,
            infoPlist: .dictionary(appInfoPlist),
            buildableFolders: [
                "TelePointer/App/Sources",
                "TelePointer/App/Resources",
            ],
            entitlements: .dictionary([
                "com.apple.security.app-sandbox": true,
            ]),
            dependencies: [
                .target(name: "MenuBar"),
                .target(name: "Settings"),
            ]
        ),
        module(
            name: "MenuBar",
            sources: ["TelePointer/Features/MenuBar/Sources"],
            dependencies: [
                .target(name: "PointerCore"),
                .target(name: "LaunchAtLogin"),
                .target(name: "Settings"),
                .external(name: "KeyboardShortcuts"),
            ]
        ),
        module(
            name: "Settings",
            sources: ["TelePointer/Features/Settings/Sources"],
            dependencies: [
                .target(name: "PointerCore"),
                .external(name: "KeyboardShortcuts"),
            ]
        ),
        module(
            name: "PointerCore",
            sources: ["TelePointer/Core/PointerCore/Sources"]
        ),
        .target(
            name: "PointerCoreTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "\(bundlePrefix).PointerCoreTests",
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            buildableFolders: [
                "TelePointer/Core/PointerCore/Tests",
            ],
            dependencies: [
                .target(name: "PointerCore"),
            ]
        ),
        module(
            name: "LaunchAtLogin",
            sources: ["TelePointer/Core/LaunchAtLogin/Sources"]
        ),
    ]
)
