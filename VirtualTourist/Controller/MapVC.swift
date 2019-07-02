//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Arch Studios on 6/25/19.
//  Copyright © 2019 AS. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapVC: UIViewController {
    
    //////////////////////////////////////////////////
    //MARK:- Outlets
    //////////////////////////////////////////////////
    @IBOutlet weak var mapView: MKMapView!
    
    
    //////////////////////////////////////////////////
    //MARK:- Properties
    //////////////////////////////////////////////////
    var context: NSManagedObjectContext {
        return DataController.shared.context
    }
    
    var fetchResultsController: NSFetchedResultsController<Pin>!
    
    // isLaunching: This varible used to help populating the map with saved pin if there is any
    var isLaunching = true
    
    
    //////////////////////////////////////////////////
    //MARK:- Life Cycle
    //////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetch()
        if isLaunching {
            isLaunching = false
            loadPins()
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchResultsController = nil
    }
    
    
    //////////////////////////////////////////////////
    //MARK:- Custom Functions and Actions
    //////////////////////////////////////////////////
    
    // fetch()
    func fetch() {
        
        let request: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDesc = NSSortDescriptor(key: "creationDate", ascending: false)
        
        request.sortDescriptors = [sortDesc]
        
        fetchResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultsController.delegate = self
        
        do {
            try fetchResultsController.performFetch()
            setupMap()
        } catch {
            fatalError("Can't perfrom ftech")
        }
        
    }


    // mapLongPressed
    @IBAction func mapLongPressed(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else {return}
        
        let mapPoint = sender.location(in: mapView)
        let location = mapView.convert(mapPoint, toCoordinateFrom: mapView)
        let latitude = location.latitude
        let longitude = location.longitude
        
        let pin = Pin(context: context)
        pin.latitude = latitude
        pin.longitude = longitude
        
        do {
            try context.save()
            print("Context Saved")
        }
        catch {
            print(error.localizedDescription)
            fatalError("ERROR: CONTEXT NOT SAVED")
        }
        
        let mapPin = MKPointAnnotation()
        mapPin.coordinate = location
        mapView.addAnnotation(mapPin)
        
    }
    
    
    // setupMap
    func setupMap() {
        guard let pins = fetchResultsController.fetchedObjects else {return}
        let annotations = mapView.annotations
        
        for pin in pins {
            for annotation in annotations {
                if pin.latitude == annotation.coordinate.latitude && pin.longitude == annotation.coordinate.longitude {continue}
                let mapPin = MKPointAnnotation()
                mapPin.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                mapView.addAnnotation(mapPin)
            }
        }
        
    }
    
    
    // prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPhotos" {
            guard let vc = segue.destination as? PhotoCollectionVC else {
                fatalError("Cant find PhotoCollectionVC")
            }
            vc.pin = sender as? Pin
        }
    }
    
    
    // loadPins
    func loadPins() {
        guard let count = fetchResultsController.fetchedObjects?.count else {return}
        guard let pins = fetchResultsController.fetchedObjects else {return}
        if  count > 0 {
            for pin in pins {
                let mapPin = MKPointAnnotation()
                mapPin.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                mapView.addAnnotation(mapPin)
            }
        }
    }
}



//////////////////////////////////////////////////
//MARK:-
//MARK:- Extensions
//////////////////////////////////////////////////
//MARK:- MKMapViewDelegate
extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        var pinToSegue = [Pin]()
        
        guard let mapPin = view.annotation?.coordinate else {return}
        
        guard let pins = fetchResultsController.fetchedObjects else {return}
        
        // finding the pin object from core data to segue
        for pin in pins {
            let lat = pin.latitude
            let lon = pin.longitude
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            
            if mapPin.latitude - coordinate.latitude <= 0.00009 {
                
                if mapPin.longitude - coordinate.longitude <= 0.00009 {
                    pinToSegue.append(pin)
                }
            }
        }
        
        performSegue(withIdentifier: "toPhotos", sender: pinToSegue.first)

    }
}


//MARK:- NSFetchedResultsControllerDelegate
extension MapVC: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        setupMap()
    }
}
