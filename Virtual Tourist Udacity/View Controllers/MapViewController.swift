//
//  ViewController.swift
//  Virtual Tourist Udacity
//
//  Created by Min Kaung Htet on 06/05/2022.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var instructLabel: UILabel!

    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    var pin: Pin?
    let region: String = "persistedMapRegion"

    override func viewDidLoad() {
        super.viewDidLoad()
        callPersistedLocation()
        setUpMapDesign()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         refreshData()
     }

     override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
       
     }

    @IBAction func handleLongPressGestureRecognizer(_ sender: UILongPressGestureRecognizer) {
       
        if sender.state == .began {
            instructLabel.text = "Put finger on the screen to put pin on map"
            
        } else if sender.state == .ended {
            
            let location = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)
            instructLabel.text = "Long press to add new location"
            print("locationCoordinate: \(location)")
            
            saveGeoCoordination(from: location)
        }
    }
    
    func setUpMapDesign() {
        mapView.delegate = self
        mapView.overrideUserInterfaceStyle = .dark
    }
    
    func copyLocation(_ annotation: MKPointAnnotation) {
        let location = Pin(context: dataController.viewContext)
        location.creationDate = Date()
        location.longitude = annotation.coordinate.longitude
        location.latitude = annotation.coordinate.latitude
        location.locationName = annotation.title
        location.country = annotation.subtitle
        location.pages = 0
        try? dataController.viewContext.save()
        let annotationPin = AnnotationPin(pin: location)
        self.mapView.addAnnotation(annotationPin)
        
    }

    func saveGeoCoordination(from coordinate: CLLocationCoordinate2D) {
        let geoPosition = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let annotation = MKPointAnnotation()
        CLGeocoder().reverseGeocodeLocation(geoPosition) { (placemarks, error) in
            guard let placemark = placemarks?.first else { return }
            annotation.title = placemark.name ?? "Not Known"
            annotation.subtitle = placemark.country
            annotation.coordinate = coordinate
            self.copyLocation(annotation)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let photoAlbumViewController = segue.destination as? PhotoCollectionViewController else { return }
        let pinAnnotation: AnnotationPin = sender as! AnnotationPin
        photoAlbumViewController.pin = pinAnnotation.pin
        photoAlbumViewController.dataController = dataController
    }
}

 extension MapViewController: MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    func refreshData() {
        self.mapView.removeAnnotations(self.mapView.annotations)
        let request: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        request.sortDescriptors = [sortDescriptor]
           
        dataController.viewContext.perform {
          do {
            let pins = try self.dataController.viewContext.fetch(request)
            self.mapView.addAnnotations(pins.map { pin in AnnotationPin(pin: pin) })

            } catch {
                print("Error fetching Pins: \(error)")
            }
        }
    }
    
 func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        let pinAnnotation = annotation as! AnnotationPin
        pinAnnotation.title = pinAnnotation.pin.locationName
        pinAnnotation.subtitle = pinAnnotation.pin.country
        print("\(String(describing: pinAnnotation.title)) \(String(describing: pinAnnotation.subtitle))")
   
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
 
    func saveMapLocation() {
        let mapRegion = [
            "latitude" : mapView.region.center.latitude,
            "longitude" : mapView.region.center.longitude,
            "latitudeDelta" : mapView.region.span.latitudeDelta,
            "longitudeDelta" : mapView.region.span.longitudeDelta
        ]
        UserDefaults.standard.set(mapRegion, forKey: region)
    }
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        self.saveMapLocation()
    }

    
    func callPersistedLocation() {
        if let mapRegion = UserDefaults.standard.dictionary(forKey: region) {
            let location = mapRegion as! [String: CLLocationDegrees]
            let center = CLLocationCoordinate2D(latitude: location["latitude"]!, longitude: location["longitude"]!)
            let span = MKCoordinateSpan(latitudeDelta: location["latitudeDelta"]!, longitudeDelta: location["longitudeDelta"]!)
            
            mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
        }
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

        mapView.deselectAnnotation(view.annotation, animated: false)
        guard let _ = view.annotation else {
                return
            }
        if let annotation = view.annotation as? MKPointAnnotation {
            do {
                let predicate = NSPredicate(format: "longitude = %@ AND latitude = %@", argumentArray: [annotation.coordinate.longitude, annotation.coordinate.latitude])
                let pindata = try dataController.fetchLocation(predicate)!
                let annotationPin = AnnotationPin(pin: pindata)
                self.performSegue(withIdentifier: "showPhotoAlbum", sender: annotationPin)
            } catch {
                print("There was an error!")
            }
        }
    }
}

