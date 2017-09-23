//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController {
        
    @IBOutlet weak var tableView: UITableView!
    
    var searchBar: UISearchBar!
    var loadingMoreView: InfiniteScrollActivityView?
        
    var searchSettings = YelpSearchSettings()
    
    var businesses: [Business]!
    var isMoreDataLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Set the rowHeight to UITableViewAutomaticDimension to get the self-sizing behavior we want for the cell.
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // set estimatedRowHeight to improve performance of loading the tableView
        tableView.estimatedRowHeight = 120
        
        // Initialize the UISearchBar
        searchBar = UISearchBar()
        
        // Configure the appearance of the UISearchBar
        searchBar.text = "Restaurants"
        searchBar.tintColor = UIColor.white
        if #available(iOS 9.0, *) {
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = UIColor.gray
        }
        searchBar.delegate = self
        
        // Add the UISearchBar to the NavigationBar
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        
        // Set up the InfiniteScrollActivityView loading indicator
        let loadingViewFrame = CGRect(x: 0,
                                      y: tableView.contentSize.height,
                                      width: tableView.bounds.size.width,
                                      height: InfiniteScrollActivityView.defaultHeight)
        
        loadingMoreView = InfiniteScrollActivityView(frame: loadingViewFrame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        // Adjust the table view insets to make room for the activity view
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
        
        // Perform the first search upon load
        doSearch()
    }
    
    fileprivate func doSearch() {
        /* Example of Yelp search with more search options specified
         Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
         self.businesses = businesses
         
         for business in businesses {
         print(business.name!)
         print(business.address!)
         }
         }
         */
        
        Business.searchWithSettings(settings: searchSettings, completion: {
                                    (businesses: [Business]?, error: Error?) -> Void in
                                    
                                    self.businesses = businesses
            
            
                                    // Update UI on the main thread
                                    DispatchQueue.main.async(execute: {
                                        self.loadingMoreView?.stopAnimating()
                                        self.tableView.reloadData()
                                    })
            
                                    let count = businesses?.count ?? 0
                                    print("Result count \(count)")
                                    
                                    if let businesses = businesses {
                                        for business in businesses {
                                            print(business.name!)
                                            print(business.address!)
                                        }
                                    }
        })

    }
    
    fileprivate func loadMoreData() {
        
        print("Loading more data...")
        
        searchSettings.offset += searchSettings.limit
        doSearch()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
     // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        filtersViewController.delegate = self
    }
    
}

// MARK: - FiltersViewControllerDelegate
extension BusinessesViewController: FiltersViewControllerDelegate {
    // filters view controller delegate methods
    
    func filtersViewController(_ filtersViewController: FiltersViewController, didUpdateFilters filters: [String : Any]) {
        
        let categories = filters["categories"] as?  [String]
        let deals = filters["deals"] as? Bool
        
        Business.searchWithTerm(term: "Restaurants",
                                sort: nil,
                                categories: categories,
                                deals: deals) { (businesses: [Business]!, error: Error!) in
                                    self.businesses = businesses
            
                                    let count = businesses?.count ?? 0
                                    print("Filtered result count \(count)")
            
                                    self.tableView.reloadData()
        }
        
        //        Business.searchWithTerm(term: "Restaurants") { (businesses: [Business]!, error: Error!) in
        //            self.businesses =  businesses
        //            self.tableView.reloadData()
        //        }
    }
    
}

// MARK: - UITableViewDelegate
extension BusinessesViewController: UITableViewDelegate {
    
}

// MARK: - UITableViewDataSource
extension BusinessesViewController: UITableViewDataSource {
    // table view data source methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            return businesses.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        
        cell.business = businesses[indexPath.row]
        
        return cell
    }
    
}

// MARK: - UIScrollViewDelegate
extension BusinessesViewController: UIScrollViewDelegate {
    // scroll view delegate methods
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Handle scroll behavior
        
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled beyond the threshold, request more data
            if (scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loading indicator
                let frame = CGRect(x: 0,
                                   y: tableView.contentSize.height,
                                   width: tableView.bounds.size.width,
                                   height: InfiniteScrollActivityView.defaultHeight)
                
                loadingMoreView?.frame = frame
                
                // Start loading indicator
                loadingMoreView!.startAnimating()
                
                // Request more data
                self.loadMoreData()
            }
            
        }
    }
}

// MARK: - UISearchBarDelegate
extension BusinessesViewController: UISearchBarDelegate {
    // search bar delegate methods
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        doSearch()
    }
}
