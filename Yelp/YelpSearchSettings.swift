//
//  YelpSearchSettings.swift
//  Yelp
//
//  Created by Diana Fisher on 9/22/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import Foundation


class YelpSearchSettings: NSObject {
    
    var searchTerm: String
    var offset: Int
    var limit: Int
    var distance: Distance
    var sortOption: Int
    var categories: [Category]?
    var dealsOn: Bool
    
    override init() {
        searchTerm = "Thai"
        offset = 0
        limit = 20
        sortOption = YelpSortMode.distance.rawValue
        dealsOn = false
        distance = Distances[0]
        categories = [Category]()
    }
    
    func parameters() -> [String : Any] {
        
        // Default the location to San Francisco
        var parameters: [String : Any] = ["term": searchTerm as Any, "ll": "37.785771,-122.406165" as Any]
        
        parameters["sort"] = sortOption as AnyObject?
        
        if categories != nil && categories!.count > 0 {
            
            categories?.forEach({ (category) in
                print(category.name)
            })

        }
        
        
        
        parameters["deals_filter"] = dealsOn as AnyObject?
        parameters["radius_filter"] = distance.inMeters()
        parameters["limit"] = limit as AnyObject
        parameters["offset"] = offset as AnyObject
        
        return parameters
    }
    
    static let filterNames = ["Deals", "Distance", "Sort By", "Category"]
    
    static let sortByOptions = [["name": "Best Match", "code": YelpSortMode.bestMatched.rawValue],
                                ["name": "Distance", "code": YelpSortMode.distance.rawValue],
                                ["name": "Highest Rated", "code": YelpSortMode.highestRated.rawValue]]
        
}
