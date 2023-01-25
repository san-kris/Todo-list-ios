//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Santosh Krishnamurthy on 1/24/23.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    var toDoCategories = [CategoryItem]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
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
        return toDoCategories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        // Get cell config
        var cellConfig = cell.defaultContentConfiguration()
        // update cell config
        cellConfig.text = toDoCategories[indexPath.row].name
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
                    itemListVC.selectedCategory = toDoCategories[index.row]
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
                let newCategoryItem = CategoryItem(context: self.context)
                newCategoryItem.name = newCategoryName
                self.toDoCategories.append(newCategoryItem)
                self.saveData()
            }
        }
        alertController.addTextField()
        alertController.addAction(addAlertAction)
        alertController.addAction(cancelAlertAction)
        
        self.present(alertController, animated: true)
    }
    
    //MARK: - CRUD operations to CoreData
    func loadData(request:  NSFetchRequest<CategoryItem> = CategoryItem.fetchRequest()){
        do{
            toDoCategories = try context.fetch(request)
        } catch {
            print("Error while loading data from context - \(error)")
        }
    }
    
    func saveData(){
        do{
            try context.save()
            tableView.reloadData()
        } catch {
            print("Error while saving context - \(error)")
        }
        
    }
}
