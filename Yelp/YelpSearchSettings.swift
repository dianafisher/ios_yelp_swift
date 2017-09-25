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
    var categories: [Category]
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
        location = CLLocation(latitude: 37.785771, longitude: -122.406165)  // San Francisco as default
    }
    
    func parameters() -> [String : Any] {
        
        var parameters: [String : Any] = ["term": searchTerm as Any]
        
        let coordinateString = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        parameters["ll"] = coordinateString as Any
        
        parameters["sort"] = sortMode.code
        
        if categories.count > 0 {
            
            let codes = categories.map{$0.code}
            
            track("codes: \(String(describing: codes))")
            
            parameters["category_filter"] = codes.joined(separator: ",")
        }
                
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
