// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "GSMODApplianceSelection",
    defaultLocalization: "en",
    platforms: [.iOS("17.0")],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "GSMODApplianceSelectionKit",
            targets: ["GSMODApplianceSelectionKit"]
        ),
        .library(
            name: "GSMODApplianceSelectionView",
            targets: ["GSMODApplianceSelectionView"]
        ),
        .library(
            name: "GSMODApplianceSelectionComposableInterfaces",
            targets: ["GSMODApplianceSelectionComposableInterfaces"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(
            name: "RxSwift",
            url: "https://github.com/ReactiveX/RxSwift",
            from: "6.0.0"
        ),
        .package(
            name: "SwiftyBeaver",
            url: "https://github.com/SwiftyBeaver/SwiftyBeaver",
            from: "2.0.0"
        ),
        .package(url: "https://github.com/realm/realm-cocoa", from: "10.0.0"),
//        .package(
//            name: "GSMODCoreUI",
//            url: "https://github.com/groupeseb/GSMOD-iOS-CoreUI",
//            from: "11.0.0"
//        ),
//        .package(
//            name: "GSMODWebClient",
//            url: "https://github.com/groupeseb/GSMOD-iOS-WebClient",
//            from: "21.0.0"
//        ),
//        .package(
//            name: "GSMODCache",
//            url: "https://github.com/groupeseb/GSMOD-iOS-Cache",
//            from: "9.0.0"
//        ),
        
//        .package(
//            name: "GSMODRealmPersistenceHelper",
//            url: "https://github.com/groupeseb/GSMOD-iOS-RealmPersistenceHelper",
//            branch: "tech/xcode26"
//        ),
        .package(
            name: "Rx-swift-composable-architecture",
            url: "https://github.com/bioche/RxSwiftComposableArchitecture",
            .upToNextMajor(from: "1.0.0")
        )
//        .package(
//            name: "GSMODComposableArchitecture",
//            url: "https://github.com/groupeseb/GSMOD-iOS-ComposableArchitecture",
//            from: "7.0.0"
//        )
    ],
    targets: /*realmBinariesTarget() + */[
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "GSMODApplianceSelectionKit",
            dependencies: [
//                "GSMODWebClient",
//                "GSMODCache",
//                "GSMODRealmPersistenceHelper",
                .product(name: "Realm", package: "realm-cocoa"),
                .product(name: "RealmSwift", package: "realm-cocoa"),
                "RxSwift",
                "SwiftyBeaver",
                .product(name: "RxRelay", package: "RxSwift")
            ]
        ),
        .target(
            name: "GSMODApplianceSelectionComposableInterfaces",
            dependencies: [
                .product(name: "RxComposableArchitecture", package: "Rx-swift-composable-architecture"),
                "GSMODApplianceSelectionKit"
            ]
        ),
        .target(
            name: "GSMODApplianceSelectionView",
            dependencies: [
//                .product(name: "GSMODCoreUI", package: "GSMODCoreUI"),
                "GSMODApplianceSelectionKit",
                "GSMODApplianceSelectionComposableInterfaces"
            ]
        ),
        .testTarget(
            name: "GSMODApplianceSelectionKitTests",
            dependencies: [
                "GSMODApplianceSelectionKit",
                .product(name: "RxTest", package: "RxSwift")
            ]
        )
    ]
)

///// Define the binary zip file to be fetch for Realm and RealmSwift packages
//func realmBinariesTarget() -> [Target] {
//    var realmVersion = "v10.54.6" // release tag from Github
//    
//    // To find a zip checksum, download it localy and use :
//    // `swift package compute-checksum pathToTheZip`
//    
//    // FULL PROCEDURE DESCRIBED IN README
//    
//    let xcodeVersion = "26.1.0"
//    
//    return [
//        .binaryTarget(
//            name: "Realm",
//            path: "realm_binaries_\(realmVersion)/Realm.xcframework"
//        ),
//        .binaryTarget(
//            name: "RealmSwift",
//            path: "realm_binaries_\(realmVersion)/\(xcodeVersion)/RealmSwift.xcframework"
//        )
//    ]
//}

