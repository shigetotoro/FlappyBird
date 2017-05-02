//
//  ViewController.swift
//  FlappyBird
//
//  Created by 森重翔平 on 2017/04/23.
//  Copyright © 2017年 森重翔平. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    let skView = self.view as! SKView
    
    skView.showsFPS = true
    
    skView.showsNodeCount = true
    
    let scene = gameScene(size:skView.frame.size)
    
    skView.presentScene(scene)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override var prefersStatusBarHidden: Bool {
    get {
      return true
    }
  }


}

