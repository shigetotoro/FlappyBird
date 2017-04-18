//
//  Task.swift
//  taskapp
//
//  Created by 森重翔平 on 2017/04/11.
//  Copyright © 2017年 森重翔平. All rights reserved.
//

import Foundation
import RealmSwift

class Task: Object {
  
  dynamic var id = 0
  
  dynamic var title = ""
  
  dynamic var category = ""
  
  dynamic var contents = ""
  
  dynamic var date = NSDate()
  
  override static func primaryKey() -> String? {
    return "id"
  }
  

}
