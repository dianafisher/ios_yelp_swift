//
//  YelpSearchSettings.swift
//  Yelp
//
//  Created by Diana Fisher on 9/22/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import Foundation
import MapKit

class YelpSearchSettings: NSObject {
    
    var searchTerm: String
    var offset: Int
    var limit: Int
    var distance: Distance
    var sortMode: SortMode
    var categories: [Category]?
    var dealsOn: Bool
    var location: CLLocation
    
    override init() {
        searchTerm = "Restaurants"
        offset = 0
        limit = 20
        sortMode = SortModes[0]
        dealsOn = false
        distance = Distances[0]
        categories = [Category]()
        location = CLLocation(latitude: 37.785771, longitude: -122.406165)  // San Francisco
    }
    
    func parameters() -> [String : Any] {
        
        // Default the location to San Francisco
        var parameters: [String : Any] = ["term": searchTerm as Any, "ll": "37.785771,-122.406165" as Any]
        
        parameters["sort"] = sortMode.code
        
        if categories != nil && categories!.count > 0 {
            
            let codes = categories?.map{$0}
            
            track("codes: \(String(describing: codes))")
            
            categories?.forEach({ (category) in
                print(category.name)
            })

        }
        
//        if categories != nil && categories!.count > 0 {
//            parameters["category_filter"] = (categories!).joined(separator: ",") as AnyObject?
//        }
        
        parameters["deals_filter"] = dealsOn as AnyObject?
        
        let distanceMeters = distance.metersString()
        if distanceMeters != nil {
            parameters["radius_filter"] = distanceMeters
        }
        
        parameters["limit"] = limit as AnyObject
        parameters["offset"] = offset as AnyObject
        
        track("parameters \(parameters)")
        
        return parameters
    }
    
    public func track(_ message: String, file: String = #file, function: String = #function, line: Int = #line ) {
        
        let filename = (file as NSString).lastPathComponent
        print("🅿️\(function):\(filename):\(line) - \(message) ")
        
    }
    
}
