//
//  ViewController.swift
//  HeatSlider
//
//  Created by Eric Pintos on 10/11/18.
//  Copyright © 2018 Eric Pintos. All rights reserved.
//

import UIKit

class ViewController: UIViewController, HeatSliderDelegate {

  @IBOutlet weak var slider: HeatSlider!
  @IBOutlet weak var label: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.slider.delegate = self
  }
  
  func heatSlider(_ heatSlider: HeatSlider, didUpdatePercentage percentage: Float) {
    self.label.text = String(percentage.rounded())
  }
}

