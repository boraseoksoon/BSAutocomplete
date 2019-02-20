//
//  ViewController.swift
//  BSAutocomplete
//
//  Created by boraseoksoon@gmail.com on 02/20/2019.
//  Copyright (c) 2019 boraseoksoon@gmail.com. All rights reserved.
//

import UIKit

let HASH_TAG_STR = "#"
let SEARCH_BLUR_ANIMATION_DURATION = 0.4

/**
 * To allow only two type, either UITextView or UITextField, use Either type.
 */
public enum Either<T1: UITextView, T2: UITextField> {
  case textView(T1)
  case textField(T2)
}

public class BSAutocomplete: UIView {
  // MARK: - Instance Variables -
  private var dataSource: SimplePrefixQueryDataSource!
  private var ramReel: RAMReel<RAMCell, RAMTextField, SimplePrefixQueryDataSource>!
  private var baseView: UIView?
  
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
  private func animateSearch(isShow: Bool) -> Void {
    if isShow {
      UIView.animate(withDuration: SEARCH_BLUR_ANIMATION_DURATION) {
        self.ramReel.textField.becomeFirstResponder()
      }
    }
      
    else {
      UIView.animate(withDuration: SEARCH_BLUR_ANIMATION_DURATION) {
        self.ramReel.textField.resignFirstResponder()
      }
    }
  }

  
  private func refresh(with string: String) -> Void {
    self.ramReel.textField.text = string
    self.ramReel.dataFlow.transport(string)
    if string == HASH_TAG_STR {
      self.ramReel.view.isHidden = false
//      self.ramReel.collectionView.backgroundColor = UIColor.black
//      self.ramReel.collectionView.alpha = 1.0
    } else {
      self.ramReel.view.isHidden = true
//      self.ramReel.collectionView.backgroundColor = UIColor.clear
//      self.ramReel.collectionView.alpha = 0.0
    }
  }
  
  public func receive(currentUserInput: String) -> Void {
    self.ramReel.textField.becomeFirstResponder()
    self.refresh(with: currentUserInput)
  }
  
  public func readyToUse() -> Void {
    baseView?.addSubview(ramReel.view)
    ramReel.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
  }
  
  private func initialization(at focusView: UIView, data: [String]) -> Void {
    guard let baseView = FindBaseView(from: focusView) else { print("**ERROR**"); return }

    self.baseView = baseView
    
    dataSource = SimplePrefixQueryDataSource(data)
    
    ramReel = RAMReel(frame: baseView.bounds,
                      dataSource: dataSource,
                      placeholder: "Start by typing…",
                      attemptToDodgeKeyboard: true) {
                        print("Plain:", $0)
    }
    ramReel.view.isHidden = true
    
    ramReel.hooks.append {
      let r = Array($0.reversed())
      let j = String(r)
      print("Reversed:", j)
    }

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
