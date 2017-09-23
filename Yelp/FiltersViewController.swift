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

/*
 TODO:
 
 Filters:
    Category
    Sort (best match)
    Sort (distance)
    Sort (highest rated)
    Distance
    Deals

 Move categories helper to a new file
 */

class FiltersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var categories: [[String:String]]! // array of dictionaries
    var switchStates = [Int:Bool]()  // dictionary will hold row number: boolean
    
    var sectionsOpen = [Bool]()
    
    weak var delegate: FiltersViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categories = YelpFilters.categories
        
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
        
        for (row,isOn) in switchStates {
            if isOn {
                // add the filter to an array of categories
                selectedCategories.append(categories[row]["code"]!)
            }
        }
        
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories
        }
        
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
        return YelpFilters.filterNames[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return YelpFilters.filterNames.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sectionsOpen[section] {
            switch(section) {
            case 0:
                return 1
            case 1:
                return YelpFilters.distances.count
            case 2:
                return YelpFilters.sortByOptions.count
            case 3:
                return YelpFilters.categories.count
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
            
            cell.onSwitch.isOn = switchStates[indexPath.row] ?? false  // nil-coalescing operator
            return cell
        }
            
        // Section 1 is Distance
        else if section == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DropDownCell", for: indexPath) as! DropDownCell
            
            cell.titleLabel.text = YelpFilters.distances[indexPath.row]["name"]!
            
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
            
            cell.titleLabel.text = YelpFilters.sortByOptions[indexPath.row]["name"]! as! String
            
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
            cell.switchLabel.text = categories[indexPath.row]["name"]
            cell.delegate = self
            cell.onSwitch.isOn = switchStates[indexPath.row] ?? false
            
            return cell
        }
        
    }
}

// MARK: - SwitchCellDelegate
extension FiltersViewController: SwitchCellDelegate {
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPath(for: switchCell)
        
        // store the switch state in our switchStates dictionary
        switchStates[(indexPath?.row)!] = value
        
        print("FiltersViewController got the switch event")
    }
}
