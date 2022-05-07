//
//  Location.swift
//  Virtual Tourist Udacity
//
//  Created by Min Kaung Htet on 06/05/2022.
//

import Foundation

struct Location: Codable {
    let latitude: Double
    let longitude: Double
    let location: String
    let country: String
    
    enum CodingKeys: String, CodingKey {
        case location, country, latitude, longitude
    }
}
