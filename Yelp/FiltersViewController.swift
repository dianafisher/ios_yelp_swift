//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Diana Fisher on 9/21/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    
    @objc optional func filtersViewController(_ filtersViewController: FiltersViewController, didUpdateSearchSettings searchSettings: YelpSearchSettings)
}

enum YelpFilter: Int {
    case deals = 0, distance, sortBy, category
}

private let switchCellReuseIdentifier = "SwitchCell"
private let dropDownCellReuseIdentifier = "DropDownCell"

class FiltersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var categorySwitchStates = [Int:Bool]()
    fileprivate var sectionsOpen = [Bool]()
    fileprivate var dealsSwitchIsOn: Bool = false
    fileprivate var sortMode: SortMode = SortModes[0]
    fileprivate var distance: Distance = Distances[0]
    
    var searchSettings: YelpSearchSettings?
    
    weak var delegate: FiltersViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sectionsOpen = [false, false, false, false]
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Set the user interface based on the current search settings
        initializeUI()
        
        // Set navigationBar tint colors
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.8288504481, green: 0.1372715533, blue: 0.1384659708, alpha: 1)
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    fileprivate func initializeUI() {
        
        // Set deal switch
        dealsSwitchIsOn = (searchSettings?.dealsOn)!
        
        let categories = searchSettings!.categories
        
        // Set category switches based on current search settings
        for (index, element) in Categories.enumerated() {

            if categories.contains( where: {$0.code == element.code}) {

                categorySwitchStates[index] = true
            }
        }

        // Set sort mode
        sortMode = searchSettings!.sortMode
        
        // Set distance
        distance = searchSettings!.distance
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBAction
    @IBAction func onCancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSearchPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)

        // Gather the selected categories
        var selectedCategories = [Category]()
        
        for (row,isOn) in categorySwitchStates {
            if isOn {
                selectedCategories.append(Categories[row])
            }
        }
        
        if selectedCategories.count > 0 {
            searchSettings?.categories = selectedCategories
        }
        
        track("searchSettings categories \(String(describing: searchSettings?.categories))")
        
        // Set the values on searchSettings
        searchSettings?.dealsOn = dealsSwitchIsOn
        searchSettings?.distance = distance
        searchSettings?.sortMode = sortMode
        
        delegate?.filtersViewController!(self, didUpdateSearchSettings: searchSettings!)
    }
    
    fileprivate func didSelectDistanceAt(_ indexPath: IndexPath) {
        
        if sectionsOpen[indexPath.section] {
            let row = indexPath.row
            
            distance = Distances[row]
        }
        
        sectionsOpen[indexPath.section] = !sectionsOpen[indexPath.section]
        
        // Reload this section
        let sectionIndex = IndexSet(integer: indexPath.section)
        tableView.reloadSections(sectionIndex, with: UITableViewRowAnimation.fade)
        
    }
    
    fileprivate func didSelectSortByAt(_ indexPath: IndexPath) {
        
        if sectionsOpen[indexPath.section] {
            let row = indexPath.row
            
            sortMode = SortModes[row]
        }
        
        sectionsOpen[indexPath.section] = !sectionsOpen[indexPath.section]
        
        // Reload this section
        let sectionIndex = IndexSet(integer: indexPath.section)
        tableView.reloadSections(sectionIndex, with: UITableViewRowAnimation.fade)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

public func track(_ message: String, file: String = #file, function: String = #function, line: Int = #line ) {
    
    let filename = (file as NSString).lastPathComponent
    print("✳️\(function):\(filename):\(line) - \(message) ")
    
}


// MARK: - UITableViewDelegate
extension FiltersViewController: UITableViewDelegate {
    // table view delegate methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section

        switch (section) {
            case YelpFilter.deals.rawValue:
                break
            case YelpFilter.distance.rawValue:
                didSelectDistanceAt(indexPath)
                break
            case YelpFilter.sortBy.rawValue:
                didSelectSortByAt(indexPath)
                break
            case YelpFilter.category.rawValue:
                break
            default:
                break
        }
        
    }
}

// MARK: - UITableViewDataSource
extension FiltersViewController: UITableViewDataSource {
    // table view data source methods
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Filters[section].name
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Filters.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch(section) {
            case YelpFilter.deals.rawValue:
                return 1
                
            case YelpFilter.distance.rawValue:
                return sectionsOpen[section] ? Distances.count : 1
                
            case YelpFilter.sortBy.rawValue:
                return sectionsOpen[section] ? SortModes.count : 1
                
            case YelpFilter.category.rawValue:
                return Categories.count
//                return sectionsOpen[section] ? Categories.count : 3
            
            default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        
        // Deals
        if section == YelpFilter.deals.rawValue {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: switchCellReuseIdentifier, for: indexPath) as! SwitchCell
            
            cell.switchLabel.text = "Offering a Deal"
            cell.delegate = self
            
            // Set the value of the switch based on the search settings
            cell.onSwitch.isOn = dealsSwitchIsOn
            return cell
        }

        // Distance
        else if section == YelpFilter.distance.rawValue {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: dropDownCellReuseIdentifier, for: indexPath) as! DropDownCell
            
            let selectedDistance = distance
            
            // Find the index of the selectedDistance in the Distances array
            let selectedDistanceIndex = Distances.index(where: {(d) -> Bool in
                d.name == selectedDistance.name
            })
            
            if sectionsOpen[section] {
                
                let distance = Distances[indexPath.row]
                cell.titleLabel.text = distance.name
                
                // if the distance at this row is our currently selected distance, then show a checkmark image
                if (indexPath.row == selectedDistanceIndex) {
                    cell.statusImageView.image = #imageLiteral(resourceName: "round-done-button")
                } else {
                    cell.statusImageView.image = #imageLiteral(resourceName: "unselected")
                }
                
            } else {
                cell.titleLabel.text = selectedDistance.name
                cell.statusImageView.image = #imageLiteral(resourceName: "drop-down-arrow")
            }
            
            
            return cell
        }
            
        // Sort Mode
        else if section == YelpFilter.sortBy.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: dropDownCellReuseIdentifier, for: indexPath) as! DropDownCell

            let selectedSortMode = sortMode
            
            // Find the index of the selectedSortMode in the SortModes array
            let selectedSortModeIndex = SortModes.index(where: {(s) -> Bool in
                s.name == selectedSortMode.name
            })
            
            
            if sectionsOpen[section] {
                let sortMode = SortModes[indexPath.row]
                cell.titleLabel.text = sortMode.name
                
                if (indexPath.row == selectedSortModeIndex) {
                    cell.statusImageView.image = #imageLiteral(resourceName: "round-done-button")
                } else {
                    cell.statusImageView.image = #imageLiteral(resourceName: "unselected")
                }
                
            } else {
                cell.titleLabel.text = selectedSortMode.name
                cell.statusImageView.image = #imageLiteral(resourceName: "drop-down-arrow")
            }

            return cell
        }
            
        // Categories
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: switchCellReuseIdentifier, for: indexPath) as! SwitchCell
            cell.switchLabel.text = Categories[indexPath.row].name
            cell.delegate = self
            cell.onSwitch.isOn = categorySwitchStates[indexPath.row] ?? false
            
            return cell
        }
        
    }
}

// MARK: - SwitchCellDelegate
extension FiltersViewController: SwitchCellDelegate {
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPath(for: switchCell)
        
        let section = indexPath?.section
        
        if section == YelpFilter.deals.rawValue {
            dealsSwitchIsOn = value
        }
        
        if section == YelpFilter.category.rawValue {
            // store the switch state in our switchStates dictionary
            categorySwitchStates[(indexPath?.row)!] = value            
        }
        
    }
}
