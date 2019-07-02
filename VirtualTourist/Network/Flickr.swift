//
//  Flickr.swift
//  VirtualTourist
//
//  Created by Arch Studios on 6/25/19.
//  Copyright © 2019 AS. All rights reserved.
//

import Foundation

class Flickr {
    static var photosArr = [String]()
    
    // getURL: To construct the URL
    static func getURL(latitude: Double, longitude: Double, page: Int = 1, perPage: Int = 4) -> String {
        let lat = String(describing: latitude)
        let lon = String(describing: longitude)
        let apiKey = "a97b2f5b25f571f0a79e537cda1692b5"
        let url = "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&accuracy=11&safe_search=1&lat=\(lat)&lon=\(lon)&extras=url_m&per_page=\(perPage)&page=\(page)&format=json&nojsoncallback=1"
        
        return url
    }
    
    
    // getPhotoURL: To extract photo urls from Flickr fetched data
    static func getPhotoURL(urlString: String, completion: @escaping (Bool?, String?)->()) {
        guard let url = URL(string: urlString) else {
            completion(nil, "Can't convert url")
            return
            
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard error == nil else {
                completion(nil, "Can't connect to fetch photo")
                return
                
            }
            
            guard let res = response as? HTTPURLResponse else {
                completion(nil, "Response error")
                return
                
            }
            
            let statusCode = res.statusCode
            guard (200...299).contains(statusCode) else {
                completion(nil, "Response out of range")
                return
                
            }
            
            guard let data = data else {
                completion(nil, "There is no data")
                return
                
            }
            
            guard let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                completion(nil, "Can't convert data to json object")
                return
                
            }
            
            guard let photosDict = result["photos"] as? [String: Any] else {
                completion(nil, "Can't fetch photos dictonary out of data")
                return
                
            }
            
            guard let photoDict = photosDict["photo"] as? [[String: Any]] else {
                completion(nil, "Can't fetch photo dictionary out of photos dictionary")
                return
                
            }
            
            for photo in photoDict {
                guard let photoURL = photo["url_m"] as? String else {
                    completion(nil, "Can't get the photo url out of photo dictionary")
                    return
                    
                }
                photosArr.append(photoURL)
            }
            
            completion(true, nil)
        }
        task.resume()
    }
    
    
    
    // getImage: To fethc the image out of photo's url
    static func getImage(url: URL, completion: @escaping (Data?, String?,  Error?)->()){
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                completion(nil, nil, error)
                return
                
            }
            
            guard let res = response as? HTTPURLResponse else {
                completion(nil, "Response error", nil)
                return
                
            }
            
            let statusCode = res.statusCode
            guard (200...299).contains(statusCode) else {
                completion(nil, "Response out of range", nil)
                return
                
            }
            
            guard let data = data else {
                completion(nil, "There is no data", nil)
                return
                
            }
            completion(data, nil, nil)
            
        }
        task.resume()
        
    }
    
}
