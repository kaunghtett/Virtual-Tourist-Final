//
//  FlickrResponse.swift
//  Virtual Tourist Udacity
//
//  Created by Min Kaung Htet on 06/05/2022.
//

import Foundation

struct PhotoResponse: Codable {
    let photos: Photos
    let stat: String
}

// MARK: - Photos
struct Photos: Codable {
    let page : Int
    let pages: Int
    let perpage: Int
    let total: Int
    let photo: [PhotoStruct]
}
