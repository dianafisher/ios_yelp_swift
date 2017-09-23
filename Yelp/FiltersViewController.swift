//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Diana Fisher on 9/21/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    @objc optional func filtersViewController(_ filtersViewController: FiltersViewController, didUpdateFilters filters:[String:Any])
    
//    @objc optional func filtersViewController(_ filtersViewController: FiltersViewController, didUpdateSearchSettings: YelpSearchSettings)
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
    
    var searchSettings: YelpSearchSettings?
    
    weak var delegate: FiltersViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sectionsOpen = [false, false, false, false]
        
        tableView.delegate = self
        tableView.dataSource = self
        
        dealsSwitchIsOn = (searchSettings?.dealsOn)!
        
        // Set navigationBar tint colors
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.8288504481, green: 0.1372715533, blue: 0.1384659708, alpha: 1)
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
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
        
        var filters = [String: Any]()
        
        var selectedCategories = [String]()
        
        for (row,isOn) in categorySwitchStates {
            if isOn {
                // add the filter to an array of categories
                selectedCategories.append(Categories[row].code)
            }
        }
        
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories
        }
        
        // check if deals switch is on
        filters["deals"] = dealsSwitchIsOn
        
        delegate?.filtersViewController!(self, didUpdateFilters: filters)
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

// MARK: - UITableViewDelegate
extension FiltersViewController: UITableViewDelegate {
    // table view delegate methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        
        if (section > 0) {
            let row = indexPath.row            
            print("selected row \(row)")
            
            sectionsOpen[indexPath.section] = !sectionsOpen[indexPath.section]
            
            // Reload this section
            let sectionIndex = IndexSet(integer: indexPath.section)
            tableView.reloadSections(sectionIndex, with: UITableViewRowAnimation.fade)
        }
        
    }
    
}

// MARK: - UITableViewDataSource
extension FiltersViewController: UITableViewDataSource {
    // table view data source methods
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return YelpSearchSettings.filterNames[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return YelpSearchSettings.filterNames.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sectionsOpen[section] {
            switch(section) {
            case 0:
                return 1
            case 1:
                return Distances.count
            case 2:
                return SortModes.count
            case 3:
                return Categories.count
            default: return 0
            }
            
        } else {
            if section < 3 {
                return 1
            } else {
                return 3
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        
        // Section 0 is Deals
        if section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: switchCellReuseIdentifier, for: indexPath) as! SwitchCell
            
            cell.switchLabel.text = "Offering a Deal"
            cell.delegate = self
            
            cell.onSwitch.isOn = categorySwitchStates[indexPath.row] ?? false  // nil-coalescing operator
            return cell
        }
            
        // Section 1 is Distance
        else if section == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: dropDownCellReuseIdentifier, for: indexPath) as! DropDownCell
            
            cell.titleLabel.text = Distances[indexPath.row].name
            
            if sectionsOpen[section] {
                if indexPath.row == 0 {
                    cell.statusImageView.image = UIImage (named: "round-done-button")
                } else {
                    cell.statusImageView.image = UIImage (named: "unselected")
                }
                
            } else {
                cell.statusImageView.image = UIImage (named: "drop-down-arrow")
            }
            
            
            return cell
        }
            
        // Section 2 is Sort By
        else if section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: dropDownCellReuseIdentifier, for: indexPath) as! DropDownCell
                        
            cell.titleLabel.text = SortModes[indexPath.row].name
            
            if sectionsOpen[section] {
                if indexPath.row == 0 {
                    cell.statusImageView.image = UIImage (named: "round-done-button")
                } else {
                    cell.statusImageView.image = UIImage (named: "unselected")
                }
            } else {
                cell.statusImageView.image = UIImage (named: "drop-down-arrow")
            }

            return cell
        }
            
        // Last section is Categories
        else {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "DropDownCell", for: indexPath) as! DropDownCell
//            
//            cell.titleLabel.text = categories[indexPath.row]["name"]!
//            if indexPath.row > 0 {
//                cell.statusImageView.image = UIImage (named: "unselected")
//            }
//            return cell
            
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
