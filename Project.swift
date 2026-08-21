import ProjectDescription

let deploymentTargets: DeploymentTargets = .macOS("26.0")

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
            bundleId: "com.taeminyun.TelePointer",
            deploymentTargets: deploymentTargets,
            infoPlist: .dictionary(appInfoPlist),
            buildableFolders: [
                "TelePointer/Sources",
                "TelePointer/Resources",
            ],
            entitlements: .dictionary([
                "com.apple.security.app-sandbox": true,
            ]),
            dependencies: [
                .external(name: "KeyboardShortcuts"),
            ]
        ),
        .target(
            name: "TelePointerTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "com.taeminyun.TelePointerTests",
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            buildableFolders: [
                "TelePointer/Tests"
            ],
            dependencies: [.target(name: "TelePointer")]
        ),
    ]
)
