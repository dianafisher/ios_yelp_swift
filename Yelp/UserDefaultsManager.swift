//
//  UserDefaultsManager.swift
//  Yelp
//
//  Created by Diana Fisher on 9/23/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit

class UserDefaultsManager: NSObject {
    
    private static let dealsOnKey = "dealsOn"
    private static let distanceFilterKey = "distanceFilter"
    private static let sortByFilterKey = "sortByFilter"
    private static let categoriesFilterKey = "categoriesFilter"
    
    static var dealsOn: Bool {
        get {
            return UserDefaults.standard.bool(forKey: dealsOnKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: dealsOnKey)
        }
    }
    
    static var distanceFilter: String {
        get {
            return UserDefaults.standard.string(forKey: distanceFilterKey)!
        }
        set {
            UserDefaults.standard.set(newValue, forKey: distanceFilterKey)
        }
    }
    
    static var sortByFilter: String {
        get {
            return UserDefaults.standard.string(forKey: sortByFilterKey)!
        }
        set {
            UserDefaults.standard.set(newValue, forKey: sortByFilterKey)
        }
    }
    
    static var categoriesFilter: [String] {
        get {
            return UserDefaults.standard.array(forKey: categoriesFilterKey) as! [String]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: categoriesFilterKey)
        }
    }

}
