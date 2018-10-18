//
//  HeatSlider.swift
//  HeatSlider
//
//  Created by Eric on 10/12/18.
//  Copyright © 2018 Eric Pintos. All rights reserved.
//

import UIKit

public protocol HeatSliderDelegate: NSObjectProtocol {
  func heatSlider(_ heatSlider: HeatSlider, didUpdatePercentage percentage: Float)
}

@IBDesignable
open class HeatSlider: UIView, UIScrollViewDelegate {

  // MARK: - Outlets
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var sliderBackground: UIView!
  @IBOutlet weak var sliderForeground: UIView!
  
  // MARK: - Properties
  open weak var delegate: HeatSliderDelegate?
  
  fileprivate var containerView: UIView!
  fileprivate var nibName = "HeatSlider"
  
  @IBInspectable public var cornerRadius: CGFloat = 15 {
    didSet {
      scrollView.layer.cornerRadius = cornerRadius
    }
  }
  
  @IBInspectable public var sliderForegroundColor: UIColor = .white {
    didSet {
      configureAppearance()
    }
  }
  
  @IBInspectable public var sliderBackgroundColor: UIColor = UIColor.white.withAlphaComponent(0.25) {
    didSet {
      configureAppearance()
    }
  }
  
  public var percentage: Float = 50 {
    didSet {
      onPercentageUpdate()
    }
  }
  
  // MARK: - init
  public override init(frame: CGRect) {
    super.init(frame: frame)
    xibSetup()
    configure()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    xibSetup()
    configure()
  }
  
  fileprivate func xibSetup() {
    containerView = loadViewFromNib()
    containerView.frame = bounds
    containerView.backgroundColor = .clear
    containerView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
    addSubview(containerView)
  }
  
  fileprivate func loadViewFromNib() -> UIView {
    let bundle = Bundle(for: type(of: self))
    let nib = UINib(nibName: nibName, bundle: bundle)
    let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
    return view
  }
  
  // MARK: - Configuration
  private func configure() {
    configureAppearance()
    configureScrollView()
    configureGestureRecognizer()
  }
  
  private func configureAppearance() {
    backgroundColor = .clear
    sliderBackground.backgroundColor = sliderBackgroundColor
    sliderForeground.backgroundColor = sliderForegroundColor
  }
  
  private func configureScrollView() {
    scrollView.decelerationRate = .fast
    scrollView.layer.cornerRadius = cornerRadius
  }
  
  private func configureGestureRecognizer() {
    let tapRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onSliderTap(gesture:)))
    tapRecognizer.minimumPressDuration = 0.2
    scrollView.addGestureRecognizer(tapRecognizer)
  }
  
  open override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    // We wait to set the delegate until the drawing in order
    // to prevent unwanted delegate calls that mess with the slider
    scrollView.delegate = self
    
    refreshSlider()
    delegate?.heatSlider(self, didUpdatePercentage: percentage)
  }
  
  // MARK: - Actions
  @objc func onSliderTap(gesture: UILongPressGestureRecognizer) {
    if gesture.state == .began && !scrollView.isDragging {
      let location = gesture.location(in: self)
      UIView.animate(withDuration: 0.1) {
        let progress = abs(self.scrollView.frame.height - location.y) / self.scrollView.frame.height
        self.percentage = Float(progress * 100)
      }
    }
  }
  
  private func onPercentageUpdate() {
    let restrictedPercentage = max(0, min(self.percentage, 100))
    if restrictedPercentage != percentage {
      self.percentage = restrictedPercentage
    }
    
    refreshSlider()
    delegate?.heatSlider(self, didUpdatePercentage: percentage)
  }
  
  private func refreshSlider() {
    let scrollHeight = self.scrollView.frame.height
    let calculatedOffset = scrollHeight * CGFloat(percentage / 100)
    if self.scrollView.contentOffset.y != calculatedOffset {
      self.scrollView.contentOffset.y = calculatedOffset
    }
  }

  // MARK: - UIScrollViewDelegate Methods
  private func getScrollViewProgress() -> Float {
    return Float(min(100, (100 * scrollView.contentOffset.y / scrollView.frame.height)))
  }
  
  open func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let calculatedPercentage = getScrollViewProgress()
    if calculatedPercentage != self.percentage {
      self.percentage = calculatedPercentage
    }
  }
}
