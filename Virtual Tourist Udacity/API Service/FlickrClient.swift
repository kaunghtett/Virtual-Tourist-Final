//
//  FlickrClient.swift
//  Virtual Tourist Udacity
//
//  Created by Min Kaung Htet on 06/05/2022.
//

import Foundation
import UIKit

class FlickrClient {
    
    static let Scheme = "https://"
    static let Host = "api.flickr.com"
    static let Path = "/services/rest"
    static let method = "flickr.photos.search"
    static let apiKey = "62c65237d6bcdb207d24fcd07b36fbc2"
    static let keySecret = "b02a6a9ceef3099a"
    
    enum Endpoints {
        
        static let base = Scheme + Host + Path
        static let radius = 20
        case searchURLString(Double, Double, Int, Int)
        var urlString: String {
               switch self {
               case .searchURLString(let latitude, let longitude, let perPage, let pageNum):
                   return Endpoints.base
                   + "?api_key=\(FlickrClient.apiKey)"
                   + "&method=\(method)"
                   + "&lat=\(latitude)"
                   + "&lon=\(longitude)"
                   + "&radius=\(Endpoints.radius)"
                   + "&per_page=\(perPage)"
                   + "&page=\(pageNum)"
                   + "&format=json&nojsoncallback=1&extras=url_m"
               }
           }
        
        var url: URL {
               return URL(string: urlString)!
           }
      }
    
    class func getRandomPageNumber(totalPicsAvailable: Int, maxNumPicsdisplayed: Int) -> Int {
        let flickrLimit = 4000
        // Available total number of pics or flickr limit
        let numberPages = min(totalPicsAvailable, flickrLimit) / maxNumPicsdisplayed
        let randomPageNum = Int.random(in: 0...numberPages)
        print("totalPicsAvaible is \(totalPicsAvailable), numPage is \(numberPages)",
             "randomPageNum is \(randomPageNum)" )
        
        return randomPageNum
    }
    
    class func getFlickrURL(latitude: Double, longitude: Double, totalPageAmount: Int = 0, picsPerPage: Int = 15) -> URL {
        
       let perPage = picsPerPage
       let pageNum = getRandomPageNumber(totalPicsAvailable: totalPageAmount, maxNumPicsdisplayed: picsPerPage)
       let searchURL = Endpoints.searchURLString(latitude, longitude, perPage, pageNum).url
        print("\n searchURL")
        
        return searchURL
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL,
                                                          responseType: ResponseType.Type,
                                                          completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
                
            } catch {
                    print(error)

                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
            }
         }
        task.resume()
        
        return task
    }
    
    class func getPhotos(latitude: Double, longitude: Double, totalPageAmount:  Int = 0, completion: @escaping ([PhotoStruct], Int, Error?) -> Void) -> Void {
           let url = getFlickrURL(latitude: latitude, longitude: longitude, totalPageAmount: totalPageAmount)
           let _ = taskForGETRequest(url: url, responseType: PhotoResponse.self) { response, error in
               if let response = response {
                completion(response.photos.photo, response.photos.pages, nil)
               } else {
                   completion([], 0, error)
               }
           }
       }
    
    class func downloadImage(img: String, completion: @escaping (Data?, Error?) -> Void) {
        let url = URL(string: img)
        
        guard let imageURL = url else {
             DispatchQueue.main.async {
                 completion(nil, nil)
             }
             return
         }
         
         let request = URLRequest(url: imageURL)
         let task = URLSession.shared.dataTask(with: request) { data, response, error in
             DispatchQueue.main.async {
                 completion(data, nil)
             }
         }
         task.resume()
    }
}
