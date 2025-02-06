//
//  TappableMapView.swift
//  MemorablePlacesFinal
//
//  Created by Yeabsera Damte on 12/11/24.
//

import SwiftUI
import MapKit

/*
struct TappableMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var onTap: (CLLocationCoordinate2D) -> Void

    class Coordinator: NSObject, UIGestureRecognizerDelegate, MKMapViewDelegate {
        var parent: TappableMapView
        init(parent: TappableMapView) {
            self.parent = parent
        }
        /*
        @objc func handleTap(gesture: UITapGestureRecognizer) {
            let mapView = gesture.view as! MKMapView
            let tapPoint = gesture.location(in: mapView)
            let coordinate = mapView.convert(tapPoint, toCoordinateFrom: mapView)
            parent.onTap(coordinate)
        }
        */
        @objc func handleTap(gesture: UITapGestureRecognizer) {
            let mapView = gesture.view as! MKMapView
            let tapPoint = gesture.location(in: mapView)
            let coordinate = mapView.convert(tapPoint, toCoordinateFrom: mapView)
            print("Tap detected at coordinate: \(coordinate)") // Add this line
            parent.onTap(coordinate)
        }

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.setRegion(region, animated: false)
        mapView.delegate = context.coordinator

        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        tapGesture.delegate = context.coordinator
        mapView.addGestureRecognizer(tapGesture)

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: false)
    }
}
*/



struct TappableMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var annotatedPlaces: [AnnotatedPlace]
    var onTap: (CLLocationCoordinate2D) -> Void

    class Coordinator: NSObject, UIGestureRecognizerDelegate, MKMapViewDelegate {
        var parent: TappableMapView
        init(parent: TappableMapView) {
            self.parent = parent
        }

        @objc func handleTap(gesture: UITapGestureRecognizer) {
            let mapView = gesture.view as! MKMapView
            let tapPoint = gesture.location(in: mapView)
            let coordinate = mapView.convert(tapPoint, toCoordinateFrom: mapView)
            parent.onTap(coordinate)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.setRegion(region, animated: false)
        mapView.delegate = context.coordinator

        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        tapGesture.delegate = context.coordinator
        mapView.addGestureRecognizer(tapGesture)

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: false)
        
        // Clear existing annotations
        uiView.removeAnnotations(uiView.annotations)

        // Add annotations for each place
        for place in annotatedPlaces {
            let annotation = MKPointAnnotation()
            annotation.coordinate = place.coordinate
            annotation.title = place.address
            uiView.addAnnotation(annotation)
        }
    }
}
