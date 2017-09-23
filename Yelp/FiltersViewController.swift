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
}

class FiltersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var categorySwitchStates = [Int:Bool]()
    fileprivate var sectionsOpen = [Bool]()
    fileprivate var dealsSwitchIsOn: Bool = false        
    
    weak var delegate: FiltersViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sectionsOpen = [false, false, false, false]
        
        tableView.delegate = self
        tableView.dataSource = self
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
                selectedCategories.append(YelpSearchSettings.categories[row]["code"]!)
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
                return YelpSearchSettings.distances.count
            case 2:
                return YelpSearchSettings.sortByOptions.count
            case 3:
                return YelpSearchSettings.categories.count
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
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            
            cell.switchLabel.text = "Offering a Deal"
            cell.delegate = self
            
            cell.onSwitch.isOn = categorySwitchStates[indexPath.row] ?? false  // nil-coalescing operator
            return cell
        }
            
        // Section 1 is Distance
        else if section == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DropDownCell", for: indexPath) as! DropDownCell
            
            cell.titleLabel.text = YelpSearchSettings.distances[indexPath.row]["name"]!
            
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "DropDownCell", for: indexPath) as! DropDownCell
            
            print(YelpSearchSettings.sortByOptions[indexPath.row]["name"]!)
            let text: String = YelpSearchSettings.sortByOptions[indexPath.row]["name"]! as! String
            cell.titleLabel.text = text
            
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
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            cell.switchLabel.text = YelpSearchSettings.categories[indexPath.row]["name"]
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
