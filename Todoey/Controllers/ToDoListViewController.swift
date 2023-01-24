//
//  ViewController.swift
//  Todoey
//
//  Created by Santosh Krishnamurthy on 1/21/23.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController{

    var toDoList = [ToDoItem]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Not using userDefaults.
    // let userDefaults = UserDefaults()

    // using Dockments folder to save custom objects
    // returns the path to the documents folder
    let toDoItemsDocuentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appending(path: "ToDoListItems.plist")

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Print the path to documents folder
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)
                
        // Reading UserDefaults file
        /*
        if let userList = userDefaults.object(forKey: "ToDoList") as? [String]{
            toDoList = ToDoList(stringArray: userList)
        } else {
            print("No items in user default list")
        }
         */
        loadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Only one section in the table
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows in a given section
        // print("\(toDoList.count) rows in section \(section)")
        return toDoList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath)
        
        // below method is deprecated
        // cell.textLabel?.text = toDoList[indexPath.row]
        
        // textLabel is depricated. we shoould use contentConfiguration
        var contentConfig = cell.defaultContentConfiguration()
        
        // Update details in configuration
        contentConfig.text = toDoList[indexPath.row].title
        contentConfig.textProperties.color = UIColor.red
        contentConfig.textProperties.font = UIFont.systemFont(ofSize: 20)
        
        // Apply updated configuration back to cell
        cell.contentConfiguration = contentConfig
        
        cell.accessoryType = (toDoList[indexPath.row].done) ? UITableViewCell.AccessoryType.checkmark : UITableViewCell.AccessoryType.none

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("user selected \(toDoList[indexPath.row].title ?? "") with done: \(toDoList[indexPath.row].done)")
        tableView.deselectRow(at: indexPath, animated: true)
        
        // you can change the value of a property by using setvalue method
        toDoList[indexPath.row].setValue(!(toDoList[indexPath.row].done), forKey: "done")
        // you can directly access the property of the entiy and update its value
        // toDoList[indexPath.row].done = !(toDoList[indexPath.row].done)
        
        tableView.cellForRow(at: indexPath)?.accessoryType = toDoList[indexPath.row].done ? UITableViewCell.AccessoryType.checkmark : UITableViewCell.AccessoryType.none
        
        saveItem()
        // tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
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

                // create new item to be stored in CoreData Entity
                // The Entity is same as table and is represented by a class.
                // The class is subclassed from NSManagedObject
                // each row in Entity / Table is an instance of the class
                let newItem = ToDoItem(context: self.context)
                newItem.done = false
                newItem.title = newToDoItem
                self.toDoList.append(newItem)
                
                // Add new Item to array
                // self.toDoList?.add(title: newToDoItem)
                
                // Save the array in the user defaults plist against a key
                // self.userDefaults.set(self.toDoList?.items, forKey: "ToDoList")
                self.saveItem()
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

    func saveItem() -> Void {
        do{
            try context.save()
        } catch {
            print("Error saving to CoreData: \(error)")
        }
        
        
        // reload table view
        self.tableView.reloadData()
    }

    func loadData() -> Void {
        do{
            // create a  fetch request from Entity Type Method
            let request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
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
        // create a empty request. similar to select *
        let request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        
        // Add where condition / filters
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.predicate = predicate
        
        // add sorting condition for result
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        // fetch the result
        do{
            toDoList = try context.fetch(request)
        } catch {
            print("Error Fetching Item array from SQLITE -  \(error)")
        }
        
        tableView.reloadData()

        print(searchBar.text!)
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
