//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

private let businessCellReuseIdentifier = "BusinessCell"
private let filtersSegueIdentifier = "FiltersSegue"
private let detailsSegueIdentifier = "DetailsSegue"

class BusinessesViewController: UIViewController {
        
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var viewToggleButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    
    var searchBar: UISearchBar!
    var loadingMoreView: InfiniteScrollActivityView?
    
    var searchSettings = YelpSearchSettings()
    
    var businesses: [Business]!
    var isMoreDataLoading = false
    var totalResultCount = 0
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the network error view hidden initially
        networkErrorView.isHidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Set the rowHeight to UITableViewAutomaticDimension to get the self-sizing behavior we want for the cell.
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // set estimatedRowHeight to improve performance of loading the tableView
        tableView.estimatedRowHeight = 120
        
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.8288504481, green: 0.1372715533, blue: 0.1384659708, alpha: 1)
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        // Initialize the UISearchBar
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.text = searchSettings.searchTerm
        searchBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        // Set map view hidden initially
        mapView.isHidden = true
        
        if #available(iOS 9.0, *) {
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        }
                
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Network Requests
    fileprivate func doSearch() {
        
        // Hide the network error view
        self.networkErrorView.isHidden = true
       
        // Reset offset to 0
        searchSettings.offset = 0
        
        Business.searchWithSettings(
            settings: searchSettings,
            completion: { [weak self] (businesses: [Business]?, total: Int?, error: Error?) -> Void in
                
                if let businesses = businesses {
                    self?.businesses = businesses
                    
                    // Update UI on the main thread
                    DispatchQueue.main.async(execute: {
                        self?.loadingMoreView?.stopAnimating()
                        if !(self?.mapView.isHidden)! {
                            self?.loadMap()
                        }
                        self?.tableView.reloadData()
                    })
                }
                
                if let total = total {
                    self?.totalResultCount = total
                }
                
                if let error = error {
                    print("Error: \(error)")                    
                    DispatchQueue.main.async {
                        // show the network error view
                        self?.networkErrorView.isHidden = false
                    }
                }

        })

    }
    
    fileprivate func loadMoreData() {
        
        // Make sure the offset is not greater than the total number of results
        var offset = searchSettings.offset
        let limit = searchSettings.limit
        
        offset = offset + limit
        guard offset < totalResultCount else {
            return
        }
        
        searchSettings.offset += searchSettings.limit
        
        Business.searchWithSettings(
            settings: searchSettings,
            completion: { [weak self] (businesses: [Business]?, total: Int?, error: Error?) -> Void in
                
                // Apppend the results to our businesses array.
                if let businesses = businesses {
                    self?.businesses.append(contentsOf: businesses)
                    
                    // Update UI on the main thread
                    DispatchQueue.main.async(execute: {
                        self?.loadingMoreView?.stopAnimating()
                        self?.tableView.reloadData()
                        if !(self?.mapView.isHidden)! {
                            self?.loadMap()
                        }
                    })
                }
                
                if let total = total {
                    self?.totalResultCount = total
                }
                
                self?.isMoreDataLoading = false
                
                if let error = error {
                    print("Error: \(error)")
                    DispatchQueue.main.async {
                        // show the network error view
                        self?.networkErrorView.isHidden = false
                    }
                }
                
        })
        
    }
    
    fileprivate func hasMoreData() -> Bool {
        var offset = searchSettings.offset
        let limit = searchSettings.limit
        
        offset = offset + limit
        
        return offset < totalResultCount
    }
    
    // MARK: - Map View
    
    fileprivate func loadMap() {
        
        // If the map has annotations already, remove them.
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
        
        // Configure the map view
        if businesses.count > 0 {
            // Center the map at the first business in the array.
            let firstBusiness = businesses[0]
            if let centerLocation = firstBusiness.coordinate {
                let region = MKCoordinateRegionMakeWithDistance(centerLocation.coordinate, 1000, 1000)
                mapView.setRegion(region, animated: false)
            }
            
            // Load annotation for each business
            for business in businesses {
                if let location = business.coordinate {
                    // Add a map annotation
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = location.coordinate
                    annotation.title = business.name
                    mapView.addAnnotation(annotation)
                    
                }
            }
        }
        
        mapView.isHidden = false
    }
    
    // MARK: - IBActions
    
    @IBAction func viewTogglePressed(_ sender: Any) {
        
        let title = viewToggleButton.title
        if title == "Map" {
            loadMap()
            viewToggleButton.title = "List"
        } else {
            mapView.isHidden = true
            viewToggleButton.title = "Map"
        }
    }
    
    
     // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Which segue is this?
        if segue.identifier == filtersSegueIdentifier {
            let navigationController = segue.destination as! UINavigationController
            
            let filtersViewController = navigationController.topViewController as! FiltersViewController
            filtersViewController.searchSettings = searchSettings
            filtersViewController.delegate = self
        } else if segue.identifier == detailsSegueIdentifier {
            
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)
            let business = businesses?[indexPath!.row]
            
            let detailsViewController = segue.destination as! DetailsViewController
            detailsViewController.business = business
                        
        }                
    }
    
}

// MARK: - FiltersViewControllerDelegate
extension BusinessesViewController: FiltersViewControllerDelegate {
    // filters view controller delegate methods
        
    func filtersViewController(_ filtersViewController: FiltersViewController, didUpdateSearchSettings searchSettings: YelpSearchSettings) {
        self.searchSettings = searchSettings
        doSearch()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: businessCellReuseIdentifier, for: indexPath) as! BusinessCell
        
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
                
                if hasMoreData() {
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
}

// MARK: - UISearchBarDelegate
extension BusinessesViewController: UISearchBarDelegate {
    // search bar delegate methods
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.text = ""
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
        let previousTerm = searchSettings.searchTerm
        searchSettings.searchTerm = searchBar.text ?? previousTerm
        doSearch()
    }
    
}
