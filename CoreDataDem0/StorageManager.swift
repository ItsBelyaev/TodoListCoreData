//
//  StorageManager.swift
//  CoreDataDem0
//
//  Created by Daniil Belyaev on 17.08.2021.
//

import UIKit
import CoreData

class StorageManager {
    static let shared = StorageManager()
    
    var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "CoreDataDem0")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {

                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    func fetchData(taskList: inout [Task]) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            taskList = try context.fetch(fetchRequest)
        } catch let error{
            print(error.localizedDescription)
        }
    }
        
    func save(_ taskName: String, tableView: UITableView, taskList: inout [Task]) {
            let context = persistentContainer.viewContext
            
            guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: context) else {
                return
            }
            guard let task = NSManagedObject(entity: entityDescription, insertInto: context) as? Task else {return}
            
            task.name = taskName
            taskList.append(task)
            
            let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
            tableView.insertRows(at: [cellIndex], with: .automatic)
            
            saveContext()
            
        }
    func delete(tableView: UITableView, indexPath: IndexPath, taskList: inout [Task]) {
        let context = persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        guard let objects = try? context.fetch(fetchRequest) else {return}
        
        taskList.remove(at: indexPath.row)
        context.delete(objects[indexPath.row])
//        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.reloadData()
        
       saveContext()
    }

    
    private init() {}
}
