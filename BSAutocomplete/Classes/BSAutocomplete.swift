//
//  ViewController.swift
//  BSAutocomplete
//
//  Created by boraseoksoon@gmail.com on 02/20/2019.
//  Copyright (c) 2019 boraseoksoon@gmail.com. All rights reserved.
//

import UIKit

let HASH_TAG_STR = "#"

public enum Either<T1: UITextView, T2: UITextField> {
  case textView(T1)
  case textField(T2)
}

public class BSAutocomplete: UIView {
  // MARK: - Instance Variables -
  private var dataSource: SimplePrefixQueryDataSource!
  private var ramReel: RAMReel<RAMCell, RAMTextField, SimplePrefixQueryDataSource>!
  private var localTextView: UITextView? {
    didSet {
      print("textViewText : ", localTextView?.text)
    }
  }
  
  private var localTextField: UITextField? {
    didSet {
      print("textFieldText : ", localTextField?.text)
    }
  }
  
  @objc func textFieldDidChange(_ textField: UITextField) {
    print("[in autocomplete] plain : ", textField.text ?? "")
  }
  
  // MARK: - Initializers  -
  required init?(coder aDecoder: NSCoder) {
    fatalError("creating instance programatically is not allowed!")
  }
  
  public init(at focusView: Either<UITextView, UITextField>, data: [String]) {
    super.init(frame: UIScreen.main.bounds)
    
    switch focusView {
    case .textView(let textView):
      localTextView = textView
      initialization(at: textView, data: data)

    case .textField(let textField):
      localTextField = textField
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
  public func receive(currentUserInput: String) -> Void {
    if currentUserInput == HASH_TAG_STR {
      self.ramReel.textField.text = HASH_TAG_STR
      self.ramReel.view.isHidden = false
    } else {
      self.ramReel.textField.text = ""
      self.ramReel.view.isHidden = true
    }
  }
  
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

extension UITextView {
  public var currentWord : String? {
    let beginning = beginningOfDocument
    if let start = position(from: beginning, offset: selectedRange.location),
      let end = position(from: start, offset: selectedRange.length) {
      
      let textRange = tokenizer.rangeEnclosingPosition(end, with: .word, inDirection: 1)
      
      if let textRange = textRange {
        return text(in: textRange)
      }
    }
    return nil
  }
}

