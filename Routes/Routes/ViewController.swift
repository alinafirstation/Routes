//
//  ViewController.swift
//  Routes
//
//  Created by Alina on 22.01.2022.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    private let addressButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "AddAddress"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let routeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "CreateRoute"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    private let resetButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Reset"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    private var annotationsArray = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setConstraints()
        mapView.delegate = self
        addressButton.addTarget(self, action: #selector(addressButtonTapped), for: .touchUpInside)
        routeButton.addTarget(self, action: #selector(routeButtonTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
    }
    
    @objc func addressButtonTapped() {
        showAddAddressAlert(title: "Add the address", placeholder: "Enter the address") { [self] text in
            setupPlacemark(address: text)
        }
    }
    
    @objc func routeButtonTapped() {
        for index in 0..<annotationsArray.count - 1 {
            findDirection(startCoordinate: annotationsArray[index].coordinate, endCoordinate: annotationsArray[index + 1].coordinate)
        }
        mapView.showAnnotations(annotationsArray, animated: true)
    }
    
    @objc func resetButtonTapped() {
        self.mapView.overlays.forEach {
            if !($0 is MKUserLocation) {
                self.mapView.removeOverlay($0)
            }
        }
        mapView.removeAnnotations(mapView.annotations)
        annotationsArray = [MKPointAnnotation]()
        routeButton.isHidden = true
        resetButton.isHidden = true
    }
    
    private func setupPlacemark(address: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { [self] (placemarks, error) in
            if let error = error {
                print(error)
                showErrorAlert(title: "Error", message: "Server is not available")
            }
            
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = "\(address)"
            
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            
            annotationsArray.append(annotation)
            
            if annotationsArray.count > 2 {
                routeButton.isHidden = false
                resetButton.isHidden = false
            }
            
            mapView.showAnnotations(annotationsArray, animated: true)
        }
    }
    
    private func findDirection(startCoordinate: CLLocationCoordinate2D, endCoordinate: CLLocationCoordinate2D) {
        let startLocation = MKPlacemark(coordinate: startCoordinate)
        let endLocation = MKPlacemark(coordinate: endCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: endLocation)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        
        let direction = MKDirections(request: request)
        direction.calculate { (response,error) in
            if let error = error {
                print(error)
                return
            }
            guard let response = response else {
                self.showErrorAlert(title: "Error", message: "Route is not available")
                return
            }
            
            var minRoute = response.routes[0]
            for route in response.routes {
                minRoute = (route.distance < minRoute.distance) ? route : minRoute
            }
            
            self.mapView.addOverlay(minRoute.polyline)
        }
    }
}

extension ViewController {
    private func setConstraints() {
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
        
        mapView.addSubview(addressButton)
        NSLayoutConstraint.activate([
            addressButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 50),
            addressButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 20),
            addressButton.widthAnchor.constraint(equalToConstant: 50),
            addressButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        mapView.addSubview(resetButton)
        NSLayoutConstraint.activate([
            resetButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -30),
            resetButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
            resetButton.widthAnchor.constraint(equalToConstant: 50),
            resetButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        mapView.addSubview(routeButton)
        NSLayoutConstraint.activate([
            routeButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 50),
            routeButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
            routeButton.widthAnchor.constraint(equalToConstant: 50),
            routeButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .purple
        return renderer
    }
}
