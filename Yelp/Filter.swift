//
//  Filters.swift
//  Yelp
//
//  Created by Diana Fisher on 9/23/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import Foundation

struct Filter {
    
    var name: String
    var index: Int
}

let Filters: [Filter] = [
    Filter(name: "", index: 0),
    Filter(name: "Distance", index: 1),
    Filter(name: "Sort By", index: 2),
    Filter(name: "Category", index: 3)
]
