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
        searchTerm = "Thai"
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
            
            categories?.forEach({ (category) in
                print(category.name)
            })

        }
        
//        if categories != nil && categories!.count > 0 {
//            parameters["category_filter"] = (categories!).joined(separator: ",") as AnyObject?
//        }
        
        parameters["deals_filter"] = dealsOn as AnyObject?
        parameters["radius_filter"] = distance.inMeters()
        parameters["limit"] = limit as AnyObject
        parameters["offset"] = offset as AnyObject
        
        return parameters
    }
    
    static let filterNames = ["Deals", "Distance", "Sort By", "Category"]
    
}
