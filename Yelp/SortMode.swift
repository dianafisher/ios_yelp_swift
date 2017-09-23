//
//  SortByOption.swift
//  Yelp
//
//  Created by Diana Fisher on 9/23/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import Foundation

struct SortMode {

    var code: Int
    var name: String
}

let SortModes: [SortMode] = [
    SortMode(code: 0, name: "Best Match"),
    SortMode(code: 1, name: "Distance"),
    SortMode(code: 2, name: "Highest Rated")
]
