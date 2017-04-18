//
//  inputViewController.swift
//  taskapp
//
//  Created by 森重翔平 on 2017/04/06.
//  Copyright © 2017年 森重翔平. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class inputViewController: UIViewController {

  @IBOutlet weak var titleTextField: UITextField!
  
  @IBOutlet weak var contentsTextView: UITextView!
  
  @IBOutlet weak var detePicker: UIDatePicker!
  
  @IBOutlet weak var category: UILabel!

  @IBOutlet weak var categoryText: UITextField!
  
  var task: Task!
  let realm = try! Realm()
  
  
  override func viewDidLoad() {
        super.viewDidLoad()
    
    let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
    self.view.addGestureRecognizer(tapGesture)
    
    titleTextField.text = task.title
    contentsTextView.text = task.contents
    detePicker.date = task.date as Date

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.]
      

  }
  
  override func viewWillDisappear(_ animated: Bool) {
    try! realm.write {
      self.task.category = self.categoryText.text!
      self.task.title = self.titleTextField.text!
      self.task.contents = self.contentsTextView.text
      self.task.date = self.detePicker.date as NSDate
      self.realm.add(self.task, update: true)
    }
    
    setNotification(task: task)
    
    super.viewWillDisappear(animated)
  }
  
  func setNotification(task: Task) {
    let content = UNMutableNotificationContent()
    content.title = task.title
    content.body = task.contents
    content.sound = UNNotificationSound.default()
    
    let calendar = NSCalendar.current
    let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date as Date)
    let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
    
    let request = UNNotificationRequest.init(identifier: String(task.id), content: content, trigger: trigger)
    
    let center = UNUserNotificationCenter.current()
    center.add(request) { (error) in
      print(error)
  }
  
  
  center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
  for request in requests {
      print("/--------------")
      print(request)
      print("/--------------")
  }
  }
  }
  
  func dismissKeyboard(){
    
    view.endEditing(true)
  }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


