//
//  ViewController.swift
//  taskapp
//
//  Created by 森重翔平 on 2017/04/06.
//  Copyright © 2017年 森重翔平. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
  
  


  @IBOutlet weak var tableView: UITableView!
  
  @IBOutlet weak var search: UISearchBar!
  
  let realm = try! Realm()
  
  var category : Category!
  
  
  var taskArray = try! Realm().objects(Task.self).sorted(byProperty: "date", ascending: false)
  var wakaran = try! Realm().objects(Task.self).sorted(byProperty: "category", ascending: false)
  
  private var Search: UISearchBar!
  var searchResult = [String]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    tableView.delegate = self
    tableView.dataSource = self
    search.delegate = self
    search.enablesReturnKeyAutomatically = false
    
  }
  

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?){
    let inputViewController:inputViewController = segue.destination as! inputViewController
    
    if segue.identifier == "cellSegue" {
      let indexPath = self.tableView.indexPathForSelectedRow
      inputViewController.task = taskArray[indexPath!.row]
    } else {
      let task = Task()
      task.date = NSDate()
      
      if taskArray.count != 0 {
        task.id = taskArray.max(ofProperty: "id")! + 1
      }
      
      inputViewController.task = task
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection: Int) -> Int {
    return taskArray.count
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
    
    let task = taskArray[indexPath.row]
    cell.textLabel?.text = task.title
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyy-MM-dd HH:mm"
    
    let dateString:String = formatter.string(from: task.date as Date)
    cell.detailTextLabel?.text = dateString
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: "cellSegue",sender: nil)
  }
  
  func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCellEditingStyle {
    return UITableViewCellEditingStyle.delete
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == UITableViewCellEditingStyle.delete {
      
      let task = self.taskArray[indexPath.row]
      
      let center = UNUserNotificationCenter.current()
      center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
      
      
      
      try! realm.write {
        self.realm.delete(task)
        tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
      }
      
      center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
        for request in requests {
          print("/---------------")
          print(request)
          print("---------------/")
  
  }
  
        


}
}
}
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText.isEmpty {
      taskArray = try! Realm().objects(Task.self).sorted(byProperty: "date", ascending: false)
    } else {
      let predicate = NSPredicate(format: "category == %@", searchText)
      taskArray = try! Realm().objects(Task.self).filter(predicate).sorted(byProperty: "date", ascending: false)
    }
    self.tableView.reloadData()
  }
  
}
