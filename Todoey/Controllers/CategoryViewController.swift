//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Santosh Krishnamurthy on 1/24/23.
//

import UIKit
// import CoreData
import RealmSwift

class CategoryViewController: UITableViewController {

    // Below lines are used to get contect for CoreData
    //var toDoCategories = [CategoryItem]()
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Obtains an instance of default Realm object
    // use lazy init when we are migrating / changing data model in Realm DB
    lazy var realm:Realm = {
        return try! Realm()
    }()
    // declare category list as a Results auto-updating datatype in Realm
    var toDoCategories: Results<CategoryItemRlm>?
    var test: String!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return toDoCategories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        // Get cell config
        var cellConfig = cell.defaultContentConfiguration()
        // update cell config
        cellConfig.text = toDoCategories?[indexPath.row].name ?? "No categories added"
        cellConfig.textProperties.color = UIColor.green
        cellConfig.textProperties.font = UIFont.systemFont(ofSize: 25)
        // apply cell config
        cell.contentConfiguration = cellConfig
        
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        
        return cell
    }
    
    
    //MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Row \(indexPath.row) was clicked")
        performSegue(withIdentifier: "GoToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToItems"{
            if let itemListVC = segue.destination as? ToDoListViewController{
                if let index = tableView.indexPathForSelectedRow{
                    itemListVC.selectedCategory = toDoCategories?[index.row]
                }
            }
        }
    }
    
    //MARK: - Add new Category
    
    @IBAction func addCategoryPressed(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "New Category Name", message: " ", preferredStyle: UIAlertController.Style.alert)
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
        let addAlertAction = UIAlertAction(title: "Add", style: UIAlertAction.Style.default) { (action) in
            
            if let newCategoryName = alertController.textFields?.first?.text {
                let newCategoryItem = CategoryItemRlm()
                newCategoryItem.name = newCategoryName
                self.saveData(category: newCategoryItem)
            }
        }
        alertController.addTextField()
        alertController.addAction(addAlertAction)
        alertController.addAction(cancelAlertAction)
        
        self.present(alertController, animated: true)
    }
    
    //MARK: - Cell Swipe Action Configuration
    // Below delegate method will be called when swiping cell from left to right
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // create a action to display when user swipes a cell with name and style
        // add a action handler closure to handle the action.
        // Call completionHandler function when actoin completes
        let action = UIContextualAction(style: .normal, title: "Favorite") { (action, view, completionHandler) in
            self.handleMarkAsFavourite()
            completionHandler(true)
        }
        // change the background color of the action
        action.backgroundColor = .systemBlue
        // add one or more actions to the configuration object and return it
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    // Below delegate method will be called when swiping cell from right to left
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // create a action to display when user swipes a cell with name and style
        // add a action handler closure to handle the action.
        // Call completionHandler function when actoin completes
        
        // add delete acton on swipe
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { (action, view, completionHandler) in
            self.handleMoveToTrash()
            completionHandler(true)
        }
        // change the background color of the action
        deleteAction.backgroundColor = .systemRed
        
        // add Alarm acton on swipe
        let alarmAction = UIContextualAction(style: .normal, title: "Alarm") { (action, view, completionHandler) in
            self.handleSetAlarm()
            completionHandler(true)
        }
        // change the background color of the action
        alarmAction.backgroundColor = .systemYellow
        // add one or more actions to the configuration object and return it
        return UISwipeActionsConfiguration(actions: [deleteAction, alarmAction])
    }
    
    // Pervious to IOS 13, swiping right to left on cell automaticaly showed Delete option
    // To prevent this from happening use below code
//    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        return .none
//    }
    
    private func handleMarkAsFavourite() {
        print("Marked as favourite")
    }

    private func handleMarkAsUnread() {
        print("Marked as unread")
    }

    private func handleMoveToTrash() {
        print("Moved to trash")
    }

    private func handleSetAlarm() {
        print("Set the alarm")
    }
    
    //MARK: - CRUD operations to CoreData
    func loadData(){
        // We are linking all objects of certain type to toDoCategories varaible.
        // This variable is auto updated every time there is change in Category objects
        toDoCategories = realm.objects(CategoryItemRlm.self)
        tableView.reloadData()
    }
    
    // takes input as one category item and saves it to Realm DB
    func saveData(category: CategoryItemRlm){
        do{
            try realm.write({
                realm.add(category, update: Realm.UpdatePolicy.error)
            })
            tableView.reloadData()
        } catch {
            print("Error while saving context - \(error)")
        }
        
    }
}
