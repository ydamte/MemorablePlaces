//
//  PlaceDetailView.swift
//  MemorablePlacesFinal
//
//  Created by Yeabsera Damte on 12/7/24.
//
/*
import SwiftUI
import MapKit

//extension MemorablePlace: Identifiable {}



struct PlaceDetailView: View {
    let place: MemorablePlace
    @State private var region: MKCoordinateRegion

    init(place: MemorablePlace) {
        self.place = place
        let coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
        _region = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        ))
    }

    var body: some View {
        VStack {
            Map(coordinateRegion: $region, annotationItems: [place]) { placeItem in
                MapMarker(coordinate: CLLocationCoordinate2D(latitude: placeItem.latitude,
                                                             longitude: placeItem.longitude))
            }
            .disabled(true) // Non-clickable map
            .frame(height: 300)

            Text(place.address ?? "Unknown Address")
                .font(.title2)
                .padding()

            if let timestamp = place.timestamp {
                Text("Visited on \(timestamp, style: .date) at \(timestamp, style: .time)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                // Edit button to rename place
                Button(action: {
                    // Show a sheet or alert with a textfield to rename
                }) {
                    Image(systemName: "pencil")
                }
            }
        }
    }
}
*/






/*
import SwiftUI
import MapKit

struct PlaceDetailView: View {
    let place: MemorablePlace
    @State private var region: MKCoordinateRegion

    init(place: MemorablePlace) {
        self.place = place
        let coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
        _region = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        ))
    }

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: [place]) { placeItem in
            MapMarker(coordinate: CLLocationCoordinate2D(latitude: placeItem.latitude,
                                                         longitude: placeItem.longitude))
        }
        .navigationTitle("Memorable Place")
        .navigationBarTitleDisplayMode(.inline)
        .edgesIgnoringSafeArea([.bottom])
    }
}
*/



import SwiftUI
import MapKit

struct PlaceDetailView: View {
    let place: MemorablePlace
    @State private var region: MKCoordinateRegion

    init(place: MemorablePlace) {
        self.place = place
        let coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
        _region = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        ))
    }

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: [place]) { placeItem in
            MapMarker(coordinate: CLLocationCoordinate2D(latitude: placeItem.latitude,
                                                         longitude: placeItem.longitude))
        }
        .navigationTitle("Memorable Place")
        .navigationBarTitleDisplayMode(.inline)
        .edgesIgnoringSafeArea([.bottom])
    }
}

