//
//  BottleVM.swift
//  Whisky
//
//  Created by Isaac Marovitz on 24/03/2023.
//

import Foundation

class BottleVM: ObservableObject {
    static let shared = BottleVM()

    static let containerDir = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library")
        .appendingPathComponent("Containers")
        .appendingPathComponent("com.isaacmarovitz.Whisky")

    static let bottleDir = containerDir
        .appendingPathComponent("Bottles")

    @Published var bottles: [Bottle] = [
        Bottle()
    ]

    @MainActor
    func loadBottles() {
        Task(priority: .background) {
            bottles.removeAll()

            let enumerator = FileManager.default.enumerator(at: BottleVM.bottleDir,
                                                            includingPropertiesForKeys: [.isDirectoryKey],
                                                            options: [.skipsSubdirectoryDescendants, .skipsHiddenFiles])

            while let url = enumerator?.nextObject() as? URL {
                print(url.path)
                bottles.append(Bottle(path: url))
            }
        }
    }

    func createNewBottle(bottleName: String) {
        Task(priority: .userInitiated) {
            do {
                if !FileManager.default.fileExists(atPath: BottleVM.bottleDir.path) {
                    try FileManager.default.createDirectory(atPath: BottleVM.bottleDir.path,
                                                            withIntermediateDirectories: true)
                }

                let newBottleDir = BottleVM.bottleDir.appendingPathComponent(bottleName)
                try FileManager.default.createDirectory(atPath: newBottleDir.path, withIntermediateDirectories: true)

                let bottle = Bottle(path: newBottleDir)
                try await Wine.cfg(bottle: bottle)
            } catch {
                print("Failed to create new bottle")
            }
        }
    }
}
