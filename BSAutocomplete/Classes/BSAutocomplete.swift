//
//  ViewController.swift
//  BSAutocomplete
//
//  Created by boraseoksoon@gmail.com on 02/20/2019.
//  Copyright (c) 2019 boraseoksoon@gmail.com. All rights reserved.
//

import UIKit

public enum Either<T1: UITextView, T2: UITextField> {
  case textView(T1)
  case textField(T2)
}

public class BSAutocomplete: UIView {
  // MARK: - Instance Variables -
  private var dataSource: SimplePrefixQueryDataSource!
  private var ramReel: RAMReel<RAMCell, RAMTextField, SimplePrefixQueryDataSource>!
  
  // MARK: - Initializers  -
  required init?(coder aDecoder: NSCoder) {
    fatalError("creating instance programatically is not allowed!")
  }
  
  public init(at focusView: Either<UITextView, UITextField>, data: [String]) {
    super.init(frame: UIScreen.main.bounds)
    
    switch focusView {
    case .textView(let textView):
      initialization(at: textView, data: data)

    case .textField(let textField):
      initialization(at: textField, data: data)
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  // MARK: - View LifeCycle Methods  -
  override public func awakeFromNib() {
    super.awakeFromNib()
  }
  
}

// MARK: - Own Methods -
extension BSAutocomplete {
//  public func readyToUse() -> Void {
//    FindBaseView(from: self.observedTouchView.superview)?.addSubview(self)
//  }
  private func initialization(at focusView: UIView, data: [String]) -> Void {
    guard let baseView = FindBaseView(from: focusView) else { print("**ERROR**"); return }
    
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
    
    ramReel.view.isHidden = true
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

