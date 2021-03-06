//
//  ViewController.swift
//  ElastiLodge
//
//  Created by Stormacq, Sebastien on 17/11/2018.
//  Copyright © 2018 Stormacq, Sebastien. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class LodgeViewController: UIViewController {

    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var lodgeName: UILabel!
    @IBOutlet weak var lodgeCity: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var bookNowButton: UIButton!
    @IBOutlet weak var amenities: UITextView!
    @IBOutlet weak var rate: UILabel!
    
    private let app = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bookNowButton.layer.cornerRadius = 4
        bookNowButton.backgroundColor = self.view.tintColor
        
        // add ourselves as observer to be notified when data are loaded by the API
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onDataAvailable),
                                               name: app.dataAvailableNotificationName,
                                               object: nil)

    }
    
    deinit {
        // unregister from notification center
        NotificationCenter.default.removeObserver(self,
                                                  name: app.dataAvailableNotificationName,
                                                  object: nil)
    }

    @objc func onDataAvailable(_ notification:Notification) {
        
        if let imageURL = app.api.lodgeLogoUrl {
            app.loadImageFrom(url: imageURL, into: logoView)
        }
        if let nameValue = app.api.name {
            self.lodgeName.text = nameValue
        }
        if let cityValue = app.api.location {
            self.lodgeCity.text = cityValue
        }
        if let categoryValue = app.api.category {
            self.category.text = "\(self.category.text!)\(String(describing: categoryValue))"
        }
        
        // display the address
        self.address.text = "\(app.api.address[0] ?? "")\n\(app.api.address[1] ?? "") \(app.api.address[2] ?? "")\n\(app.api.address[3] ?? "")"
        
        // prepare the map, first search for coordinates for the address
        let formattedAddressed = "\(app.api.address[0] ?? ""), \(app.api.address[1] ?? "") \(app.api.address[2] ?? ""), \(app.api.address[3] ?? "")"
        coordinate(forAddress: formattedAddressed, callback: { (location) -> Void in
            
            // create a map annotation
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            annotation.title = self.lodgeName.text
            annotation.subtitle = self.lodgeCity.text
            self.map.addAnnotation(annotation)
            
            // define a region for our map view and center the map on it
            var mapRegion = MKCoordinateRegion()
            let mapRegionSpan = 0.1
            mapRegion.center = annotation.coordinate
            mapRegion.span.latitudeDelta = mapRegionSpan
            mapRegion.span.longitudeDelta = mapRegionSpan
            self.map.setRegion(mapRegion, animated: true)

        })
    
        if let phoneValue = app.api.phone {
            self.phone.text = phoneValue
        }
        if let amenitiesValue = app.api.amenities {
            self.amenities.text = amenitiesValue
        }
        if let rateValue = app.api.rate, let rateCurrencyValue = app.api.rateCurrency {
            self.rate.text = "\(rateCurrencyValue) \(rateValue)"
        }
    }
    
    /*
     * Find the coordinate for an address - NOT used, I am using the coordinate instead
     */
    private func coordinate(forAddress : String, callback: @escaping (CLLocation) -> () ) {
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(forAddress, completionHandler: { (placemarks, error) in
            if let e = error {
                print("Can not retrieve coordinate for address : \(forAddress)")
                print(e.localizedDescription)
            }
            guard let location = placemarks?.first?.location else {
                return
            }
            callback(location)
        })
    }
    
}
