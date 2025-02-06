//
//  MainView.swift
//  MemorablePlacesFinal
//
//  Created by Yeabsera Damte on 12/7/24.
//

//Programmer: Yeabsera Damte
//Date: 12/12/2024
//Xcode (Version 16.1)
//macOS Sequoia 15.0.1
//Description: This app is an interactive application, that allows the user to select specific memorable locations
// and add the relevant infromation to a list as specified in the final instructions





/*
import Foundation

import SwiftUI
import CoreData

struct MyMemorablePlacesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject private var locationManager = LocationManager()

    @FetchRequest(
        entity: MemorablePlace.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \MemorablePlace.timestamp, ascending: true)]
    ) var places: FetchedResults<MemorablePlace>
    
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationView {
            VStack {
                if places.isEmpty {
                    Text("No Memorable Places")
                        .foregroundColor(.gray)
                } else {
                    List {
                        ForEach(places) { place in
                            NavigationLink(destination: PlaceDetailView(place: place)) {
                                VStack(alignment: .leading) {
                                    Text(place.address ?? "Unknown Address")
                                        .font(.headline)
                                    if let timestamp = place.timestamp {
                                        Text("\(timestamp, style: .date) \(timestamp, style: .time)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("My Memorable Places")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    // Edit button (optional)
                    Button {
                        // Implement editing logic here (e.g., toggle an edit mode)
                    } label: {
                        Image(systemName: "pencil")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                //AddPlacesView(isPresented: $showingAddSheet)
                AddPlacesView(isPresented: $showingAddSheet, locationManager: locationManager)

                    .environment(\.managedObjectContext, self.viewContext)
            }
        }
    }
}
*/




import SwiftUI
import CoreData

struct MyMemorablePlacesView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @StateObject private var locationManager = LocationManager()

    @FetchRequest(
        entity: MemorablePlace.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \MemorablePlace.timestamp, ascending: true)]
    ) var places: FetchedResults<MemorablePlace>

    @State private var showingAddSheet = false
    
    // New state properties for editing
    @State private var selectedPlace: MemorablePlace? = nil
    @State private var showEditSheet = false
    @State private var editedName = ""

    var body: some View {
        NavigationView {
            VStack {
                if places.isEmpty {
                    Text("No Memorable Places")
                        .foregroundColor(.gray)
                } else {
                    List {
                        // When the user selects a place, we push PlaceDetailView.
                        // On returning (onDisappear of PlaceDetailView), we set that place as selectedPlace.
                        ForEach(places) { place in
                            NavigationLink(
                                destination: PlaceDetailView(place: place)
                                    .onDisappear {
                                        // When returning from detail, record which place was last viewed.
                                        selectedPlace = place
                                    }
                            ) {
                                VStack(alignment: .leading) {
                                    Text(place.address ?? "Unknown Address")
                                        .font(.headline)
                                    if let timestamp = place.timestamp {
                                        Text("\(timestamp, style: .date) \(timestamp, style: .time)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("My Memorable Places")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    // Edit button: only show sheet if there's a last selected place
                    Button {
                        if let selected = selectedPlace {
                            editedName = selected.address ?? ""
                            showEditSheet = true
                        }
                    } label: {
                        Image(systemName: "pencil")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddPlacesView(isPresented: $showingAddSheet, locationManager: locationManager)
                    .environment(\.managedObjectContext, self.viewContext)
            }
            /*
            .sheet(isPresented: $showEditSheet) {
                // Edit sheet to rename the selected place
                VStack {
                    Text("Edit To Name")
                        .font(.headline)
                        .padding()

                    TextField("New Name", text: $editedName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .background(Color.yellow)
                        .cornerRadius(8)
                        .padding()

                    Button("Save") {
                        // Update Core Data
                        if let selected = selectedPlace {
                            selected.address = editedName
                            do {
                                try viewContext.save()
                            } catch {
                                print("Failed to save updated name: \(error)")
                            }
                            showEditSheet = false
                        }
                    }
                    .font(.title)
                    .padding()
                }
                .padding()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }*/
            .sheet(isPresented: $showEditSheet) {
                VStack {
                    // Top bar with an "X" button on the right
                    HStack {
                        Spacer()
                        Button(action: {
                            // Dismiss the edit sheet
                            showEditSheet = false
                        }) {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(.primary)
                                .padding()
                        }
                    }

                    Text("Edit To Name")
                        .font(.headline)
                        .padding()

                    TextField("New Name", text: $editedName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .background(Color.yellow)
                        .cornerRadius(8)
                        .padding()

                    Button("Save") {
                        // Update Core Data and dismiss
                        if let selected = selectedPlace {
                            selected.address = editedName
                            do {
                                try viewContext.save()
                            } catch {
                                print("Failed to save updated name: \(error)")
                            }
                            showEditSheet = false
                        }
                    }
                    .font(.title)
                    .padding()

                    Spacer()
                }
                .padding()
                .presentationDetents([.large])   // Make the sheet taller
                .presentationDragIndicator(.visible)
            }


        }
    }
}
