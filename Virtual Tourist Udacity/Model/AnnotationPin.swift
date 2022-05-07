//
//  AnnotationPin.swift
//  Virtual Tourist Udacity
//
//  Created by Min Kaung Htet on 06/05/2022.
//

import Foundation
import MapKit


class AnnotationPin: MKPointAnnotation {
    var pin: Pin

    init(pin: Pin){
        self.pin = pin
        super.init()
        self.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
    }
}
