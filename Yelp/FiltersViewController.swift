//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Nishanko, Nishant on 4/8/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    @objc optional func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String:AnyObject])
}



struct Section {
    
    var heading : String
    var count : Int
    
    init(title: String, count : Int) {
        
        heading = title
        self.count = count
    }
}


class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate {
    
    var categories: [[String:String]]!
    var distances : [Int: String]!
    var sorts : [Int: String]!
    
    var switchStates = [Int:Bool]()
    var selectedDistanceIndex = YelpDistanceMode.BestMatch.rawValue
    var selectedSortIndex = YelpSortMode.bestMatched.rawValue
    var deals : Bool!
    var filters: Filters!
    var sections = [Section]()

    @IBOutlet weak var tableView: UITableView!
    weak var delegate: FiltersViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categories = yelpCategories()
        distances = yelpDistances()
        sorts = yelpSort()

        tableView.dataSource = self
        tableView.delegate = self
        
        
        let dealsSection = Section(title: "", count: 1)
        let distanceSection = Section(title: "Distance", count: distances.count)
        let sortBySection = Section(title: "Sort By", count: 3)
        let categoriesSection = Section(title: "Category", count: categories.count)

        
        sections.append(dealsSection)
        sections.append(distanceSection)
        sections.append(sortBySection)
        sections.append(categoriesSection)

        
        for j in 0..<categories.count {
            let cat = categories[j] 
            if (self.filters != nil && self.filters.categories != nil){
            for k in 0..<self.filters.categories.count {
                let filterCategory = self.filters.categories[k]
                if filterCategory == cat["code"]{
                    switchStates[j] = true
                }
            }
            }
        }
        
        deals = filters.deals ?? false
        selectedSortIndex = filters.sort ?? YelpSortMode.bestMatched.rawValue

        selectedDistanceIndex = filters.distance ?? YelpDistanceMode.BestMatch.rawValue

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onSearchButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
        var filters = [String:AnyObject]()
        var selectedCategories = [String]()
        
        for (row,isSelected) in switchStates{
            if isSelected {
                selectedCategories.append(categories[row]["code"]!)
            }
        }
        
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories as AnyObject
        }
        filters["deals"] = deals as AnyObject
        
        filters["distance"] = selectedDistanceIndex as AnyObject
        
        filters["sort"] = selectedSortIndex as AnyObject

        print ("categories -> \(String(describing: filters["categories"]))" )
        print ("deals -> \(String(describing: filters["deals"]))" )
        print ("distance -> \(String(describing: filters["distance"]))" )
        print ("sort -> \(String(describing: filters["sort"]))" )

        delegate?.filtersViewController?(filtersViewController: self, didUpdateFilters: filters)
//        delegate?.filtersViewController?(filtersViewController: self, didUpdateFilters: nil)

    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].heading
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0 || indexPath.section == 3){
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            
            if(indexPath.section == 0){
                cell.switchLabel.text = "Show Deals"
                cell.onSwitch.isOn = deals ?? false
            }else{
                cell.switchLabel.text = categories[indexPath.row]["name"]
                cell.onSwitch.isOn = switchStates[indexPath.row] ?? false
            }
            cell.delegate = self

            return cell
        }else if (indexPath.section == 1){
            let cell = tableView.dequeueReusableCell(withIdentifier: "CheckCell", for: indexPath) as! CheckCell
            
            cell.checkLabel.text =  distances[indexPath.row]
            let isChecked = indexPath.row == selectedDistanceIndex
            print(isChecked, indexPath.row, selectedDistanceIndex)
            
            if isChecked {
                cell.accessoryType = .checkmark
            }else {
                cell.accessoryType = .none
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CheckCell", for: indexPath) as! CheckCell
            
            cell.checkLabel.text =  sorts[indexPath.row]
            let isChecked = indexPath.row == selectedSortIndex
            print(isChecked, indexPath.row, selectedSortIndex)
            
            if isChecked {
                cell.accessoryType = .checkmark
            }else {
                cell.accessoryType = .none
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.section)
        if(indexPath.section == 1 || indexPath.section == 2){
            let cell = tableView.dequeueReusableCell(withIdentifier: "CheckCell", for: indexPath) as! CheckCell
            print(cell.isSelected, !cell.isSelected )
            
            if(indexPath.section == 1){
                selectedDistanceIndex = indexPath.row
            }else{
                selectedSortIndex = indexPath.row
            }
            
//            tableView.reloadData()
            tableView.reloadSections(IndexSet([indexPath.section]) , with: .automatic)
            tableView.deselectRow(at: indexPath, animated:true)
//            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPath(for: switchCell)!
        if(indexPath.section == 0){
            deals = value
        }else{
            switchStates[indexPath.row] = value
        }
    }
    
    // Distance name to distance in meters
    func yelpDistances() -> [Int: String] {
        return [
            YelpDistanceMode.BestMatch.rawValue: "Best Match",
            YelpDistanceMode.QuaterMile.rawValue: ".25 mile",
            YelpDistanceMode.HalfMile.rawValue: ".5 mile",
            YelpDistanceMode.OneMile.rawValue: "1 mile",
            YelpDistanceMode.FiveMiles.rawValue: "5 miles"
        ]
    }
    
    func yelpSort() -> [Int: String] {
        return [
            YelpSortMode.bestMatched.rawValue: "Best Match",
            YelpSortMode.distance.rawValue: "Distance",
            YelpSortMode.highestRated.rawValue: "Highest rated"
        ]
    }
  
    func yelpCategories() -> [[String:String]] {
        return [["name" : "Afghan", "code": "afghani"],
    ["name" : "African", "code": "african"],
    ["name" : "American, New", "code": "newamerican"],
    ["name" : "American, Traditional", "code": "tradamerican"],
    ["name" : "Arabian", "code": "arabian"],
    ["name" : "Argentine", "code": "argentine"],
    ["name" : "Armenian", "code": "armenian"],
    ["name" : "Asian Fusion", "code": "asianfusion"],
    ["name" : "Asturian", "code": "asturian"],
    ["name" : "Australian", "code": "australian"],
    ["name" : "Austrian", "code": "austrian"],
    ["name" : "Baguettes", "code": "baguettes"],
    ["name" : "Bangladeshi", "code": "bangladeshi"],
    ["name" : "Barbeque", "code": "bbq"],
    ["name" : "Basque", "code": "basque"],
    ["name" : "Bavarian", "code": "bavarian"],
    ["name" : "Beer Garden", "code": "beergarden"],
    ["name" : "Beer Hall", "code": "beerhall"],
    ["name" : "Beisl", "code": "beisl"],
    ["name" : "Belgian", "code": "belgian"],
    ["name" : "Bistros", "code": "bistros"],
    ["name" : "Black Sea", "code": "blacksea"],
    ["name" : "Brasseries", "code": "brasseries"],
    ["name" : "Brazilian", "code": "brazilian"],
    ["name" : "Breakfast & Brunch", "code": "breakfast_brunch"],
    ["name" : "British", "code": "british"],
    ["name" : "Buffets", "code": "buffets"],
    ["name" : "Bulgarian", "code": "bulgarian"],
    ["name" : "Burgers", "code": "burgers"],
    ["name" : "Burmese", "code": "burmese"],
    ["name" : "Cafes", "code": "cafes"],
    ["name" : "Cafeteria", "code": "cafeteria"],
    ["name" : "Cajun/Creole", "code": "cajun"],
    ["name" : "Cambodian", "code": "cambodian"],
    ["name" : "Canadian", "code": "New)"],
    ["name" : "Canteen", "code": "canteen"],
    ["name" : "Caribbean", "code": "caribbean"],
    ["name" : "Catalan", "code": "catalan"],
    ["name" : "Chech", "code": "chech"],
    ["name" : "Cheesesteaks", "code": "cheesesteaks"],
    ["name" : "Chicken Shop", "code": "chickenshop"],
    ["name" : "Chicken Wings", "code": "chicken_wings"],
    ["name" : "Chilean", "code": "chilean"],
    ["name" : "Chinese", "code": "chinese"],
    ["name" : "Comfort Food", "code": "comfortfood"],
    ["name" : "Corsican", "code": "corsican"],
    ["name" : "Creperies", "code": "creperies"],
    ["name" : "Cuban", "code": "cuban"],
    ["name" : "Curry Sausage", "code": "currysausage"],
    ["name" : "Cypriot", "code": "cypriot"],
    ["name" : "Czech", "code": "czech"],
    ["name" : "Czech/Slovakian", "code": "czechslovakian"],
    ["name" : "Danish", "code": "danish"],
    ["name" : "Delis", "code": "delis"],
    ["name" : "Diners", "code": "diners"],
    ["name" : "Dumplings", "code": "dumplings"],
    ["name" : "Eastern European", "code": "eastern_european"],
    ["name" : "Ethiopian", "code": "ethiopian"],
    ["name" : "Fast Food", "code": "hotdogs"],
    ["name" : "Filipino", "code": "filipino"],
    ["name" : "Fish & Chips", "code": "fishnchips"],
    ["name" : "Fondue", "code": "fondue"],
    ["name" : "Food Court", "code": "food_court"],
    ["name" : "Food Stands", "code": "foodstands"],
    ["name" : "French", "code": "french"],
    ["name" : "French Southwest", "code": "sud_ouest"],
    ["name" : "Galician", "code": "galician"],
    ["name" : "Gastropubs", "code": "gastropubs"],
    ["name" : "Georgian", "code": "georgian"],
    ["name" : "German", "code": "german"],
    ["name" : "Giblets", "code": "giblets"],
    ["name" : "Gluten-Free", "code": "gluten_free"],
    ["name" : "Greek", "code": "greek"],
    ["name" : "Halal", "code": "halal"],
    ["name" : "Hawaiian", "code": "hawaiian"],
    ["name" : "Heuriger", "code": "heuriger"],
    ["name" : "Himalayan/Nepalese", "code": "himalayan"],
    ["name" : "Hong Kong Style Cafe", "code": "hkcafe"],
    ["name" : "Hot Dogs", "code": "hotdog"],
    ["name" : "Hot Pot", "code": "hotpot"],
    ["name" : "Hungarian", "code": "hungarian"],
    ["name" : "Iberian", "code": "iberian"],
    ["name" : "Indian", "code": "indpak"],
    ["name" : "Indonesian", "code": "indonesian"],
    ["name" : "International", "code": "international"],
    ["name" : "Irish", "code": "irish"],
    ["name" : "Island Pub", "code": "island_pub"],
    ["name" : "Israeli", "code": "israeli"],
    ["name" : "Italian", "code": "italian"],
    ["name" : "Japanese", "code": "japanese"],
    ["name" : "Jewish", "code": "jewish"],
    ["name" : "Kebab", "code": "kebab"],
    ["name" : "Korean", "code": "korean"],
    ["name" : "Kosher", "code": "kosher"],
    ["name" : "Kurdish", "code": "kurdish"],
    ["name" : "Laos", "code": "laos"],
    ["name" : "Laotian", "code": "laotian"],
    ["name" : "Latin American", "code": "latin"],
    ["name" : "Live/Raw Food", "code": "raw_food"],
    ["name" : "Lyonnais", "code": "lyonnais"],
    ["name" : "Malaysian", "code": "malaysian"],
    ["name" : "Meatballs", "code": "meatballs"],
    ["name" : "Mediterranean", "code": "mediterranean"],
    ["name" : "Mexican", "code": "mexican"],
    ["name" : "Middle Eastern", "code": "mideastern"],
    ["name" : "Milk Bars", "code": "milkbars"],
    ["name" : "Modern Australian", "code": "modern_australian"],
    ["name" : "Modern European", "code": "modern_european"],
    ["name" : "Mongolian", "code": "mongolian"],
    ["name" : "Moroccan", "code": "moroccan"],
    ["name" : "New Zealand", "code": "newzealand"],
    ["name" : "Night Food", "code": "nightfood"],
    ["name" : "Norcinerie", "code": "norcinerie"],
    ["name" : "Open Sandwiches", "code": "opensandwiches"],
    ["name" : "Oriental", "code": "oriental"],
    ["name" : "Pakistani", "code": "pakistani"],
    ["name" : "Parent Cafes", "code": "eltern_cafes"],
    ["name" : "Parma", "code": "parma"],
    ["name" : "Persian/Iranian", "code": "persian"],
    ["name" : "Peruvian", "code": "peruvian"],
    ["name" : "Pita", "code": "pita"],
    ["name" : "Pizza", "code": "pizza"],
    ["name" : "Polish", "code": "polish"],
    ["name" : "Portuguese", "code": "portuguese"],
    ["name" : "Potatoes", "code": "potatoes"],
    ["name" : "Poutineries", "code": "poutineries"],
    ["name" : "Pub Food", "code": "pubfood"],
    ["name" : "Rice", "code": "riceshop"],
    ["name" : "Romanian", "code": "romanian"],
    ["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"],
    ["name" : "Rumanian", "code": "rumanian"],
    ["name" : "Russian", "code": "russian"],
    ["name" : "Salad", "code": "salad"],
    ["name" : "Sandwiches", "code": "sandwiches"],
    ["name" : "Scandinavian", "code": "scandinavian"],
    ["name" : "Scottish", "code": "scottish"],
    ["name" : "Seafood", "code": "seafood"],
    ["name" : "Serbo Croatian", "code": "serbocroatian"],
    ["name" : "Signature Cuisine", "code": "signature_cuisine"],
    ["name" : "Singaporean", "code": "singaporean"],
    ["name" : "Slovakian", "code": "slovakian"],
    ["name" : "Soul Food", "code": "soulfood"],
    ["name" : "Soup", "code": "soup"],
    ["name" : "Southern", "code": "southern"],
    ["name" : "Spanish", "code": "spanish"],
    ["name" : "Steakhouses", "code": "steak"],
    ["name" : "Sushi Bars", "code": "sushi"],
    ["name" : "Swabian", "code": "swabian"],
    ["name" : "Swedish", "code": "swedish"],
    ["name" : "Swiss Food", "code": "swissfood"],
    ["name" : "Tabernas", "code": "tabernas"],
    ["name" : "Taiwanese", "code": "taiwanese"],
    ["name" : "Tapas Bars", "code": "tapas"],
    ["name" : "Tapas/Small Plates", "code": "tapasmallplates"],
    ["name" : "Tex-Mex", "code": "tex-mex"],
    ["name" : "Thai", "code": "thai"],
    ["name" : "Traditional Norwegian", "code": "norwegian"],
    ["name" : "Traditional Swedish", "code": "traditional_swedish"],
    ["name" : "Trattorie", "code": "trattorie"],
    ["name" : "Turkish", "code": "turkish"],
    ["name" : "Ukrainian", "code": "ukrainian"],
    ["name" : "Uzbek", "code": "uzbek"],
    ["name" : "Vegan", "code": "vegan"],
    ["name" : "Vegetarian", "code": "vegetarian"],
    ["name" : "Venison", "code": "venison"],
    ["name" : "Vietnamese", "code": "vietnamese"],
    ["name" : "Wok", "code": "wok"],
    ["name" : "Wraps", "code": "wraps"],
    ["name" : "Yugoslav", "code": "yugoslav"]]
    }
}
