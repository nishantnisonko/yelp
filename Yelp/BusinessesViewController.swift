//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController , UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    var businesses: [Business]!
    var filters = Filters()
    var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        
        searchBar = UISearchBar()
        searchBar.delegate = self

        searchBar.sizeToFit()
        navigationItem.titleView = searchBar

        Business.searchWithTerm(term: "", completion: { (businesses: [Business]?, error: Error?) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil{
            return businesses!.count
        }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        cell.business = businesses[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        filtersViewController.delegate = self
        filtersViewController.filters = self.filters
    }
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        
        self.filters.categories = filters["categories"] as? [String]
        self.filters.deals = filters["deals"] as? Bool
        self.filters.sort = filters["sort"] as! Int
        self.filters.distance = filters["distance"] as! Int

        print(self.filters.sort)
        Business.searchWithTerm(term: "Restaurants", sort: YelpSortMode(rawValue: self.filters.sort) , distance: YelpDistanceMode(rawValue: self.filters.distance), categories: self.filters.categories, deals: self.filters.deals, completion: { (businesses: [Business]!, error: Error?) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
        
        })
        
    }
    
}


// SearchBar methods
extension BusinessesViewController: UISearchBarDelegate {
    
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
        
        filters.searchString = searchBar.text
        searchBar.resignFirstResponder()
        Business.searchWithTerm(term: filters.searchString!, completion: { (businesses: [Business]?, error: Error?) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
        })
        
//        Business.searchWithTerm(term: filters.searchString!, sort: YelpSortMode(rawValue: self.filters.sort ?? 0) , distance: YelpDistanceMode(rawValue: self.filters.distance ?? 0), categories: self.filters.categories!, deals: self.filters.deals!, completion: { (businesses: [Business]!, error: Error?) -> Void in
//            self.businesses = businesses
//            self.tableView.reloadData()
//            
//        })
    }
}

