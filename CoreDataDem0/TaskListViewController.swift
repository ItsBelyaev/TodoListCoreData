//
//  ViewController.swift
//  CoreDataDem0
//
//  Created by Daniil Belyaev on 17.08.2021.
//

import UIKit
import CoreData



class TaskListViewController: UITableViewController {
    
    private var context = StorageManager.shared.persistentContainer.viewContext
    private let cellID = "cell"
    private var taskList: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        fetchData()
    }
    
    
    private func setupNavigationBar() {
        
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = UIColor(red: 21/255, green: 101/255, blue: 192/255, alpha: 194/255)
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewTask))
        navigationController?.navigationBar.tintColor = .white
    }
    @objc private func addNewTask() {
        
        showAlert(title: "New Task", message: "What do you want to do?")
    }
    
    private func fetchData() {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            taskList = try context.fetch(fetchRequest)
        } catch let error{
            print(error.localizedDescription)
        }
        
        
    }
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add", style: .cancel) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            self.save(task)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addTextField { tf in
            tf.placeholder = "Task"
        }
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    private func save(_ taskName: String) {
        
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: context) else {
            return
        }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: context) as? Task else {return}
        
        task.name = taskName
        taskList.append(task)
        
        
        let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
        
        tableView.insertRows(at: [cellIndex], with: .automatic)
        
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print(error.localizedDescription)
            }
        }
        
    }
    
    
}

extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = task.name
        cell.contentConfiguration = content
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            guard let objects = try? self.context.fetch(fetchRequest) else {return }
            self.taskList.remove(at: indexPath.row)
            self.context.delete(objects[indexPath.row])
            self.tableView.reloadData()
            
            do {
                try self.context.save()
            } catch let error {
                print(error.localizedDescription)
            }
            
            
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Edit Task", message: "What do you want to change?", preferredStyle: .alert)
        alert.addTextField { tf in
            tf.text = self.taskList[indexPath.row].name
            tf.placeholder = "Task"
        }
        
        let editAction = UIAlertAction(title: "Done", style: .cancel) { _ in
            
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            
            guard let objects = try? self.context.fetch(fetchRequest) else {return }
            
            objects[indexPath.row].name = alert.textFields?.first?.text
            
            self.taskList.remove(at: indexPath.row)
            self.taskList.insert(objects[indexPath.row], at: indexPath.row)
            
            do {
                try self.context.save()
            } catch let error {
                print(error.localizedDescription)
            }
            self.tableView.reloadData()
            

        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(editAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}

