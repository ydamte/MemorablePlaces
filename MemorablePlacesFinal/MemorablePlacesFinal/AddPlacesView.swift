//
//  AddPlacesView.swift
//  MemorablePlacesFinal
//
//  Created by Yeabsera Damte on 12/7/24.
//
/*
import SwiftUI
import MapKit
import CoreData
import CoreLocation

struct AddPlacesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isPresented: Bool
    
    //@StateObject private var locationManager = LocationManager()
    @ObservedObject var locationManager: LocationManager
    @State private var region = MKCoordinateRegion()
    @State private var tappedLocations: [CLLocationCoordinate2D] = []
    @State private var annotatedPlaces: [AnnotatedPlace] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                Map(coordinateRegion: $region, annotationItems: annotatedPlaces) { place in
                    MapMarker(coordinate: place.coordinate, tint: .red)
                }
                .onAppear {
                    // Set initial region to user’s location when available
                    if let userLoc = locationManager.lastLocation {
                        region = MKCoordinateRegion(
                            center: userLoc.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onEnded { _ in }
                        .onChanged { value in
                            // No dragging needed, but you can detect map taps by overlaying a transparent layer
                        }
                )
                // For tapping the map, you can use a UITapGestureRecognizer via UIViewRepresentable.
                // Alternatively, add a transparent overlay and compute coordinates from the gesture location.
                // Below is a simplified approach using a MapTapViewCoordinator (described later).
            }
            .navigationTitle("Add Places")
            .navigationBarItems(
                leading: Button(action: {
                    // On cancel, just dismiss
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                },
                trailing: Button("Save") {
                    // Save all places to Core Data
                    savePlaces()
                    isPresented = false
                }
            )
            /*
            .onReceive(locationManager.$lastLocation) { loc in
                if let loc = loc {
                    region.center = loc.coordinate
                }
            }
            */
            .onReceive(locationManager.$lastLocation) { loc in
                if let loc = loc {
                    region = MKCoordinateRegion(
                        center: loc.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                }
            }

        }
        .onAppear {
            locationManager.requestLocation()
            //$locationManager.requestLocation
        }
        .overlay(
            // An invisible layer to detect taps on the map.
            // On tap, we convert the tap point into a coordinate and add a pin.
            /*
            GeometryReader { geo in
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { location in
                        let tapPoint = CGPoint(x: location.x, y: location.y)
                        let coord = convertPointToCoordinate(point: tapPoint, in: geo.size)
                        addPlace(at: coord)
                    }
            }*/
            Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, annotationItems: annotatedPlaces) { place in
                MapAnnotation(coordinate: place.coordinate) {
                    Image(systemName: "pin.fill")
                        .foregroundColor(.red)
                        .onTapGesture {
                            print("Tapped on place: \(place.address)")
                        }
                }
            }
            .onTapGesture(coordinateSpace: .global) { location in
                let coord = convertPointToCoordinate(point: location, in: UIScreen.main.bounds.size)
                addPlace(at: coord)
            }

        )
    }
    
    private func convertPointToCoordinate(point: CGPoint, in size: CGSize) -> CLLocationCoordinate2D {
        // Convert a CGPoint tap into coordinates using the region
        let latSpan = region.span.latitudeDelta
        let longSpan = region.span.longitudeDelta
        
        let lat = region.center.latitude - (latSpan/2) + (latSpan * Double(point.y / size.height))
        let lon = region.center.longitude - (longSpan/2) + (longSpan * Double(point.x / size.width))
        
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    private func addPlace(at coordinate: CLLocationCoordinate2D) {
        // Get address from coordinate using CLGeocoder
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            let address = placemarks?.first?.formattedAddress ?? "Unknown Address"
            let newPlace = AnnotatedPlace(coordinate: coordinate, address: address, timestamp: Date())
            annotatedPlaces.append(newPlace)
        }
    }
    
    /*
    private func savePlaces() {
        for place in annotatedPlaces {
            let newEntity = MemorablePlace(context: viewContext)
            newEntity.latitude = place.coordinate.latitude
            newEntity.longitude = place.coordinate.longitude
            newEntity.address = place.address
            newEntity.timestamp = place.timestamp
        }
        do {
            try viewContext.save()
        } catch {
            print("Error saving: \(error)")
        }
    }*/
    private func savePlaces() {
        for place in annotatedPlaces {
            // Check if place already exists in Core Data
            let fetchRequest: NSFetchRequest<MemorablePlace> = MemorablePlace.fetchRequest()
            fetchRequest.predicate = NSPredicate(
                format: "latitude == %lf AND longitude == %lf",
                place.coordinate.latitude, place.coordinate.longitude
            )

            do {
                let matches = try viewContext.fetch(fetchRequest)
                if matches.isEmpty {
                    // Save only if it's a new place
                    let newEntity = MemorablePlace(context: viewContext)
                    newEntity.latitude = place.coordinate.latitude
                    newEntity.longitude = place.coordinate.longitude
                    newEntity.address = place.address
                    newEntity.timestamp = place.timestamp
                }
            } catch {
                print("Error checking for duplicates: \(error)")
            }
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving: \(error)")
        }
    }

}

// Helper struct to hold places before saving
struct AnnotatedPlace: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let address: String
    let timestamp: Date
}

/*
// Simple LocationManager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var lastLocation: CLLocation?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error)")
    }
}
*/
/*
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var lastLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        requestAuthorization()
    }

    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.lastLocation = location
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
        }
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}
*/
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var lastLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        requestAuthorization()
    }
    
    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    // Add this method if it's missing
    func requestLocation() {
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.lastLocation = location
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
        }
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}


// Extension to handle address formatting
extension CLPlacemark {
    var formattedAddress: String {
        [thoroughfare, subThoroughfare, locality, administrativeArea, country]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}
*/








//WORKING

/*
import SwiftUI
import MapKit
import CoreData
import CoreLocation

struct AddPlacesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isPresented: Bool
    
    @ObservedObject var locationManager: LocationManager
    @State private var region = MKCoordinateRegion()
    @State private var tappedLocations: [CLLocationCoordinate2D] = []
    @State private var annotatedPlaces: [AnnotatedPlace] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                // Main map that shows annotations
                Map(coordinateRegion: $region, annotationItems: annotatedPlaces) { place in
                    MapMarker(coordinate: place.coordinate, tint: .red)
                }
                .onAppear {
                    // Set initial region if user's location is available
                    if let userLoc = locationManager.lastLocation {
                        region = MKCoordinateRegion(
                            center: userLoc.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                    }
                }

                // Transparent overlay to detect taps
                GeometryReader { geo in
                    Color.clear
                        .contentShape(Rectangle()) // So taps are recognized
                        .onTapGesture { location in
                            let tapPoint = CGPoint(x: location.x, y: location.y)
                            let coord = convertPointToCoordinate(point: tapPoint, in: geo.size)
                            addPlace(at: coord)
                        }
                }
            }
            .navigationTitle("Add Places")
            .navigationBarItems(
                leading: Button(action: {
                    // On cancel, just dismiss
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                },
                trailing: Button("Save") {
                    // Save all places to Core Data
                    savePlaces()
                    isPresented = false
                }
            )
            .onReceive(locationManager.$lastLocation) { loc in
                if let loc = loc {
                    region = MKCoordinateRegion(
                        center: loc.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                }
            }
        }
        .onAppear {
            locationManager.requestLocation()
        }
    }
    
    private func convertPointToCoordinate(point: CGPoint, in size: CGSize) -> CLLocationCoordinate2D {
        let latSpan = region.span.latitudeDelta
        let longSpan = region.span.longitudeDelta
        
        let lat = region.center.latitude - (latSpan/2) + (latSpan * Double(point.y / size.height))
        let lon = region.center.longitude - (longSpan/2) + (longSpan * Double(point.x / size.width))
        
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    private func addPlace(at coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            let address = placemarks?.first?.formattedAddress ?? "Unknown Address"
            let newPlace = AnnotatedPlace(coordinate: coordinate, address: address, timestamp: Date())
            annotatedPlaces.append(newPlace)
        }
    }
    
    private func savePlaces() {
        for place in annotatedPlaces {
            let fetchRequest: NSFetchRequest<MemorablePlace> = MemorablePlace.fetchRequest()
            fetchRequest.predicate = NSPredicate(
                format: "latitude == %lf AND longitude == %lf",
                place.coordinate.latitude, place.coordinate.longitude
            )

            do {
                let matches = try viewContext.fetch(fetchRequest)
                if matches.isEmpty {
                    let newEntity = MemorablePlace(context: viewContext)
                    newEntity.latitude = place.coordinate.latitude
                    newEntity.longitude = place.coordinate.longitude
                    newEntity.address = place.address
                    newEntity.timestamp = place.timestamp
                }
            } catch {
                print("Error checking for duplicates: \(error)")
            }
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving: \(error)")
        }
    }

}

// Helper struct to hold places before saving
struct AnnotatedPlace: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let address: String
    let timestamp: Date
}

extension CLPlacemark {
    var formattedAddress: String {
        [thoroughfare, subThoroughfare, locality, administrativeArea, country]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}
*/










import SwiftUI
import MapKit
import CoreData
import CoreLocation

struct AddPlacesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isPresented: Bool
    @ObservedObject var locationManager: LocationManager

    @State private var region = MKCoordinateRegion()
    @State private var annotatedPlaces: [AnnotatedPlace] = []

    var body: some View {
        NavigationView {
            ZStack {
                // Only this TappableMapView, no other Map overlays
                /*TappableMapView(region: $region) { coordinate in
                    addPlace(at: coordinate)
                }*/
                TappableMapView(region: $region, annotatedPlaces: annotatedPlaces) { coordinate in
                    addPlace(at: coordinate)
                }

                .onAppear {
                    if let userLoc = locationManager.lastLocation {
                        region = MKCoordinateRegion(
                            center: userLoc.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                    }
                }
            }
            .navigationTitle("Add Places")
            .navigationBarItems(
                leading: Button(action: { isPresented = false }) {
                    Image(systemName: "xmark")
                },
                trailing: Button("Save") {
                    savePlaces()
                    isPresented = false
                }
            )
            /*
            .onReceive(locationManager.$lastLocation) { loc in
                if let loc = loc {
                    // If region changes after taps, it may seem offset.
                    // Consider commenting this out after initial load if it conflicts with tap accuracy.
                    region = MKCoordinateRegion(
                        center: loc.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                }
            }*/
            .onReceive(locationManager.$lastLocation) { loc in
                if let loc = loc, annotatedPlaces.isEmpty {
                    // Update region only if we have no places yet, to avoid shifting map after taps
                    region = MKCoordinateRegion(
                        center: loc.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                }
            }

        }
        .onAppear {
            locationManager.requestLocation()
        }
    }

    private func addPlace(at coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            let address = placemarks?.first?.formattedAddress ?? "Unknown Address"
            let newPlace = AnnotatedPlace(coordinate: coordinate, address: address, timestamp: Date())
            annotatedPlaces.append(newPlace)
            print("Added place at: \(coordinate) with address: \(address)") // Verify place addition
        }
    }

    private func savePlaces() {
        // Core Data saving logic
        for place in annotatedPlaces {
            let fetchRequest: NSFetchRequest<MemorablePlace> = MemorablePlace.fetchRequest()
            fetchRequest.predicate = NSPredicate(
                format: "latitude == %lf AND longitude == %lf",
                place.coordinate.latitude, place.coordinate.longitude
            )

            do {
                let matches = try viewContext.fetch(fetchRequest)
                if matches.isEmpty {
                    let newEntity = MemorablePlace(context: viewContext)
                    newEntity.latitude = place.coordinate.latitude
                    newEntity.longitude = place.coordinate.longitude
                    newEntity.address = place.address
                    newEntity.timestamp = place.timestamp
                }
            } catch {
                print("Error checking for duplicates: \(error)")
            }
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving: \(error)")
        }
    }
}

struct AnnotatedPlace: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let address: String
    let timestamp: Date
}

extension CLPlacemark {
    var formattedAddress: String {
        [thoroughfare, subThoroughfare, locality, administrativeArea, country]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}

