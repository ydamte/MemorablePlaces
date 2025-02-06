//
//  MemorablePlacesFinalApp.swift
//  MemorablePlacesFinal
//
//  Created by Yeabsera Damte on 12/7/24.
//

import SwiftUI

@main
struct MemorablePlacesFinalApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            //ContentView()
            //MainView()
            MyMemorablePlacesView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
