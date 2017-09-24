//
//  Distance.swift
//  Yelp
//
//  Created by Diana Fisher on 9/23/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import Foundation

struct Distance {
    
    var miles: Double?
    var name: String
    
    let metersPerMile = 1609.344498
    
    func metersString() -> String? {
        guard let m = miles else {
            return nil
        }
        return String(format: "%.0f", metersPerMile * m)
    }
}

let Distances = [
    Distance(miles: nil, name: "Auto"),
    Distance(miles: 0.3, name: "0.3 miles"),
    Distance(miles: 1.0, name: "1 mile"),
    Distance(miles: 5.0, name: "5 miles"),
    Distance(miles: 20.0, name: "20 miles")
]
