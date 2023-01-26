//
//  ViewController.swift
//  Todoey
//
//  Created by Santosh Krishnamurthy on 1/21/23.
//

import UIKit
import RealmSwift

class ToDoListViewController: UITableViewController{

    
    let realm = try! Realm()
    var toDoList : Results<ToDoItemRlm>?
    
    // We use context to perform CRUD operatioon on CoreData entities
    // let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // this is the category selected in Category list VC
    var selectedCategory: CategoryItemRlm? {
        didSet{
            // this block is executed when variable is set with value
            loadData()
        }
    }
    
    // Not using userDefaults.
    // let userDefaults = UserDefaults()

    // using Dockments folder to save custom objects
    // returns the path to the documents folder
    let toDoItemsDocuentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appending(path: "ToDoListItems.plist")

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Print the path to documents folder
        // print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)
                
        // Reading UserDefaults file
        /*
        if let userList = userDefaults.object(forKey: "ToDoList") as? [String]{
            toDoList = ToDoList(stringArray: userList)
        } else {
            print("No items in user default list")
        }
         */
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Only one section in the table
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows in a given section
        // print("\(toDoList.count) rows in section \(section)")
        return toDoList?.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath)
        
        // below method is deprecated
        // cell.textLabel?.text = toDoList[indexPath.row]
        
        // textLabel is depricated. we shoould use contentConfiguration
        var contentConfig = cell.defaultContentConfiguration()
        
        // Update details in configuration
        contentConfig.text = toDoList?[indexPath.row].title ?? "No items created"
        contentConfig.textProperties.color = UIColor.red
        contentConfig.textProperties.font = UIFont.systemFont(ofSize: 20)
        
        // Apply updated configuration back to cell
        cell.contentConfiguration = contentConfig
        
        cell.accessoryType = (toDoList?[indexPath.row].done ?? false) ? UITableViewCell.AccessoryType.checkmark : UITableViewCell.AccessoryType.none

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Print the row selected
        print("user selected \(toDoList?[indexPath.row].title ?? "") with done: \(String(describing: toDoList?[indexPath.row].done))")
        // deselect the row
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let item = toDoList?[indexPath.row]{
            do{
                try realm.write({
                    // below line updated a bool property in our calss
                    item.done = !item.done
                    // below link is used to delete an item from Realm DB
                    // realm.delete(item)
                })
                tableView.reloadData()
            } catch {
                print("Error while updating Realm DB - \(error)")
            }
        }
    }
     
    
    //MARK: - Show pop-up for user to enter new item
    @IBAction func addItemPressed(_ sender: UIBarButtonItem) {
        
        // Create a local instance of textfield
        var textField = UITextField()
        
        // Create a alert view controller
        let alert = UIAlertController(title: "Add new Todoey item", message: "", preferredStyle: UIAlertController.Style.alert)
        
        // create action / button that goes in the alertview controller
        let action = UIAlertAction(title: "Add", style: UIAlertAction.Style.default) { action in
            // We are able to access the textField because it is a class ref variable and not local to the closure
            if let newToDoItem = textField.text, newToDoItem != ""{

                // Create a new instance of ToDoItemRLM object
                let newItem = ToDoItemRlm()
                // set the complete flag
                newItem.done = false
                // set the title
                newItem.title = newToDoItem
                // Save the array in the user defaults plist against a key
                // self.userDefaults.set(self.toDoList?.items, forKey: "ToDoList")
                self.saveItem(item: newItem)
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
        // Add a text field to an alert
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Enter new To Do item"
            textField = alertTextField
        }
        // add the actin to the alert VC
        alert.addAction(cancel)
        alert.addAction(action)
        
        
        // Present alert VC
        present(alert, animated: true)
    }
    
    // load data for Realm DB
    func loadData() -> Void {
        
        toDoList = selectedCategory?.toDoItems.sorted(byKeyPath: "dateCreated", ascending: false)
        tableView.reloadData()
    }
    
    // Save data for Realm DB
    func saveItem(item: ToDoItemRlm) -> Void {
        
        if let currentCategory = selectedCategory{
            do{
                try realm.write {
                    currentCategory.toDoItems.append(item)
                }
            } catch {
                print("Error while saving to Realm DB - \(error)")
            }

        }
        tableView.reloadData()
    }
    
    func updateData(item: ToDoItemRlm) -> Void {
        do{
            try realm.write {
                item
            }
        } catch {
            print("Error while updating Realm DB - \(error)")
        }
        tableView.reloadData()
    }

    /* below function used in CoreData
    func saveItem() -> Void {
        do{
            try context.save()
        } catch {
            print("Error saving to CoreData: \(error)")
        }
        
        
        // reload table view
        self.tableView.reloadData()
    }

    
    func loadData(request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest(), predicate: NSPredicate? = nil) -> Void {
        do{
            // Create a default predicate
            let defaultPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory?.name ?? "")
            // Add the default oredicate to an array
            var predicateArray = [defaultPredicate]
            // If function received input add that to predicate array
            if let newPredicate = predicate{
                predicateArray.append(newPredicate)
            }
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicateArray)
            request.predicate = compoundPredicate
            
            toDoList = try context.fetch(request)
        } catch {
            print("Error Fetching Item array from SQLITE -  \(error)")
        }
        
    }
    
    func deleteData(atRow indexPath: IndexPath) -> Void{
        print("Deleting row \(indexPath.row) with Title: \(String(describing: toDoList[indexPath.row].title) )")
        // The data in context / staging area will be updated to mark the row to be deleted
        context.delete(toDoList[indexPath.row])
        // We need to commit the changes to Context by saving the changes
        saveItem()
    }
     */
    
    /* used for saving data using encoder
    func saveItem() -> Void {
        // saving new data in a plist in Documents folder
        let encoder = PropertyListEncoder()
        do{
            let data = try encoder.encode(self.toDoList?.items)
            try data.write(to: self.toDoItemsDocuentPath!)
        } catch {
            print("Error encoding item array\(error)")
        }
        
        
        // reload table view
        self.tableView.reloadData()
    }
     */
    
    /* used to load data from file using decoder
    func loadData() -> Void {
        do{
            guard let data = try? Data(contentsOf: toDoItemsDocuentPath!) else {
                print("Unable to read data from plist file")
                toDoList = ToDoList()
                return
            }
            let decoder = PropertyListDecoder()
            let toDoItemArray = try decoder.decode([ToDoListItem].self, from: data)
            toDoList = ToDoList(items: toDoItemArray)
        } catch {
            print("Error Decoding Item array \(error)")
        }
        
    }
     */
    
}

extension ToDoListViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Below linr first filters the list based on filter predicate and then sorts the result based on column
        toDoList = toDoList?.filter("title CONTAINS[cd] %@", searchBar.text ?? "").sorted(byKeyPath: "dateCreated", ascending: false)
        print(searchBar.text!)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadData()
            tableView.reloadData()
            // Any time we are updating UI we should do it on the main thread / Queue
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
