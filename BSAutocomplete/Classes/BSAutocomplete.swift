//
//  ViewController.swift
//  BSAutocomplete
//
//  Created by boraseoksoon@gmail.com on 02/20/2019.
//  Copyright (c) 2019 boraseoksoon@gmail.com. All rights reserved.
//

import UIKit

class BSAutocomplete: UIView {
  private var dataSource: SimplePrefixQueryDataSource!
  private var ramReel: RAMReel<RAMCell, RAMTextField, SimplePrefixQueryDataSource>!
  
  private weak var _observedTouchView: UIView! {
    didSet {
      _observedTouchView.isUserInteractionEnabled = true
    }
  }
  private weak var observedTouchView: UIView! {
    get {
      return _observedTouchView
    }
    set {
      _observedTouchView = newValue
    }
  }

  
  required init?(coder aDecoder: NSCoder) {
    fatalError("creating instance programatically is not allowed!")
  }
  
  init(data: [String]) {
    super.init(frame: UIScreen.main.bounds)
    
    guard let baseView = FindBaseView(from: self.observedTouchView.superview) else { print("baseView not found"); return }
    
    dataSource = SimplePrefixQueryDataSource(data)

    ramReel = RAMReel(frame: baseView.bounds,
                      dataSource: dataSource,
                      placeholder: "Start by typing…",
                      attemptToDodgeKeyboard: true) {
                        print("Plain:", $0)
                        
    }
    
    ramReel.hooks.append {
      let r = Array($0.reversed())
      let j = String(r)
      print("Reversed:", j)
    }
    
    baseView.addSubview(ramReel.view)
    ramReel.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
  }
}

extension BSAutocomplete {
  public func readyToUse() -> Void {
    FindBaseView(from: self.observedTouchView.superview)?.addSubview(self)
  }
}

// MARK: - Functions -
func FindBaseView(from givenView: UIView?) -> UIView? {
  return givenView?.superview == nil ?  givenView : FindBaseView(from: givenView?.superview)
}

func Delay(_ delaySeconds: Double, completion: @escaping () -> Void) -> Void {
  DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds) {
    completion()
  }
}

