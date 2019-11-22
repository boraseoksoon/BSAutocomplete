//
//  ViewController.swift
//  BSAutocomplete
//
//  Created by boraseoksoon@gmail.com on 02/20/2019.
//  Copyright (c) 2019 boraseoksoon@gmail.com. All rights reserved.
//

import UIKit

// MARK: - Enum -
public enum Prefix: String {
  case at = "@"
  case hash = "#"
  case cash = "$"
  case none = ""
}

// MARK: - Constants -
let ANIMATION_DURATION = 0.7
let TEXT_COLOR_PLACEHOLDER_ALPHA: CGFloat = 0.45
let TEXT_COLOR_FOCUS_ALPHA: CGFloat = 0.9
let SHOW_ALPHA: CGFloat = 0.5
let HIDE_ALPHA:CGFloat = 0.0

/**
 * To allow only two type, either UITextView or UITextField, use Either type.
 */
// MARK: - Enum -
public enum Either<T1: UITextView, T2: UITextField> {
  case textView(T1)
  case textField(T2)
}

/**
 * Delegate
 */
// MARK: - BSAutocompleteDelegate -
public protocol BSAutocompleteDelegate: NSObjectProtocol {
  func autoCompleteDidChooseItem(text: String, sender: Either<UITextView, UITextField>) -> Void
  func autoCompleteTextDidChange(text: String, sender: Either<UITextView, UITextField>) -> Void
  func autoCompleteDidShow(sender: Either<UITextView, UITextField>) -> Void
  func autoCompleteDidHide(sender: Either<UITextView, UITextField>) -> Void
}

/**
 * Class
 */

// MARK: - UITextFieldDelegate Methods -
extension BSAutocomplete: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        /**
         * Must apply this API to keep track of the text being written.
         */
            print("call1? : ", string)
        self.observe(currentUserInput: string, from: .textField(textField))
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder {
          textField.resignFirstResponder()
        }
        
        return true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textFieldDidBeginEditing in ac!!")
        
        if self.prefix == Prefix.none.rawValue {
            self.observe(currentUserInput: textField.text ?? "", from: .textField(textField))
        }
    }
}

// MARK: - UITextViewDelegate Methods -
extension BSAutocomplete: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        print("textViewDidChange!!")
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        /**
         * Must apply this API to keep track of the text being written.
         */
        print("call? : ", text)
        self.observe(currentUserInput: text, from: .textView(textView))
        
        /// keyboard down logic
        if(text == "\n") {
          if textView.isFirstResponder {
            textView.resignFirstResponder()
          }
          return false
        }
        
        return true
    }
}


// MARK: - BSAutocomplete Class -
public class BSAutocomplete: UIView {
    // MARK: - Delegate -
  public weak var delegate: BSAutocompleteDelegate?
  
  // MARK: - Instance Variables -
  private var dataSource: SimplePrefixQueryDataSource!
  private var ramReel: RAMReel<RAMCell, RAMTextField, SimplePrefixQueryDataSource>!
  private var baseView: UIView? {
    didSet {
      guard let baseView = self.baseView else { PRETTY(); return }
      backgroundAlphaView.frame = baseView.frame
    }
  }
  private var backgroundAlphaView: TouchPassThroughView = {
    let v = TouchPassThroughView(frame: .zero)
    v.backgroundColor = .black
    v.alpha = 0.0
    
    return v
  }()
  private var either: Either<UITextView, UITextField>?
  
  private var data: [String] = []
  private var _prefix: String = ""
  public var prefix: String {
    get {
      return _prefix
    }
    set {
      _prefix = newValue
    }
  }

  // MARK: - Initializers  -
  required init?(coder aDecoder: NSCoder) {
    fatalError("creating instance programatically is not allowed!")
  }
  
    public init(baseView: UIView? = nil,
                prefix: String = Prefix.at.rawValue,
                observedViewList: [Either<UITextView, UITextField>],
                autoCompleteList: [String]) {
        super.init(frame: UIScreen.main.bounds)
        
        observedViewList.forEach { either in
            switch either {
            case .textView(let textView):
                textView.delegate = self
            case .textField(let textField):
                textField.delegate = self
            }
        }

        self.prefix = prefix
        self.data = autoCompleteList
        
        var resolvedBaseView: UIView? = baseView
        
        // To guarantee the first VC initialization.
        Delay(0.25) {
            if baseView == nil {
                if let superview = self.superview {
                    resolvedBaseView = superview
                } else {

                    if let baseView = GetRootViewController()?.view {
                        resolvedBaseView = baseView
                    }
                }
            }
            
            if let resolvedBaseView = resolvedBaseView {
                self.initialization(at: resolvedBaseView, data: self.data)
            } else {
                fatalError("can't find baseView in BSAutocomplete constructor, which is mandatory.")
            }
        }
    }

  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
}

// MARK: - Public Own Methods -
extension BSAutocomplete {
  public func set(textColor: UIColor) -> Void {
    self.ramReel.textField.textColor = textColor
  }
  
  public func set(font: UIFont) -> Void {
    self.ramReel.textField.font = font
  }
  
  /// HALTED
  private func set(backgroundColor: UIColor) -> Void {
    self.ramReel.collectionView.backgroundColor = backgroundColor
  }
  
}

// MARK: - Private Own Methods -
extension BSAutocomplete {
    private func observe(currentUserInput: String, from: Either<UITextView, UITextField>) -> Void {
      either = from
      
      if currentUserInput == self.prefix {
        if !self.ramReel.textField.isFirstResponder {
          self.show(with: currentUserInput)
        }
      } else {
        if self.ramReel.textField.isFirstResponder {
          self.hide()
        }
      }
    }

    
  private func show(with text: String) -> Void {
    self.ramReel.textField.becomeFirstResponder()
    
    UIView.animate(withDuration: ANIMATION_DURATION, animations: {
      self.ramReel.view.isHidden = false
      self.backgroundAlphaView.alpha = SHOW_ALPHA
    }, completion: { isFinished in
    })

    self.ramReel.textField.text = text
    self.ramReel.dataFlow.transport(text)
    
    guard let either = either else { PRETTY(); return }
    self.delegate?.autoCompleteDidShow(sender: either)
    
  }
  
  private func hide() -> Void {
    guard let either = self.either else { PRETTY(); return }
    switch either {
    case .textView(let textView):
      textView.becomeFirstResponder()
      
    case .textField(let textField):
      textField.becomeFirstResponder()
    }
    
    UIView.animate(withDuration: ANIMATION_DURATION, animations: {
      self.ramReel.view.isHidden = true
      self.backgroundAlphaView.alpha = HIDE_ALPHA
    }, completion: { isFinished in
      
    })
    
    self.ramReel.textField.text = ""
    self.ramReel.dataFlow.transport("")

    self.delegate?.autoCompleteDidHide(sender: either)
    
    // self.baseView?.endEditing(true)
  }
  
  private func initialization(at focusView: UIView, data: [String]) -> Void {
    guard let baseView = FindBaseView(from: focusView) else { PRETTY(); return }
    
    self.baseView = baseView
    
    dataSource = SimplePrefixQueryDataSource(data)
    
    ramReel = RAMReel(frame: baseView.bounds,
                      dataSource: dataSource,
                      placeholder: "Start by typing…",
                      attemptToDodgeKeyboard: true)

    ramReel.view.isHidden = true
    ramReel.collectionView.backgroundColor = backgroundColor
    
    self.addClosure()
    
    baseView.addSubview(ramReel.view)
    baseView.addSubview(backgroundAlphaView)
    ramReel.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
  }
  
  private func addClosure() -> Void {
    self.ramReel.didTapClosure = { [unowned self] text in
      GlobalQ {
        // do something if needed.
        MainQ {
          guard let either = self.either else { PRETTY(); return }
          switch either {
          case .textView(let textView):
            self.appendAtLast(from: .textView(textView), selectedItem: text)
            
          case .textField(let textField):
            self.appendAtLast(from: .textField(textField), selectedItem: text)
          }
          
          self.hide()
          self.delegate?.autoCompleteDidChooseItem(text: text, sender: either)
        }
      }
    }
    
    self.ramReel.didTypeSearchKeyword = { [unowned self] fullInputText in
      GlobalQ {
        guard let either = self.either else { PRETTY(); return }
        self.delegate?.autoCompleteTextDidChange(text: fullInputText, sender: either)

//        MainQ {
//          if fullInputText == "" {
//            self.hide()
//          }
//        }
      }
    }
  }
  
  private func appendAtLast(from: Either<UITextView, UITextField>, selectedItem: String) -> Void {
    switch from {
    case .textView(let textView):
      if let selectedRange = textView.selectedTextRange {
        if let replaceTextRange = textView.textRange(from: selectedRange.start, to: selectedRange.start) {
          // Replace it.
          textView.replace(replaceTextRange, withText: selectedItem)
        }
      }
      
    case .textField(let textField):
      if let selectedRange = textField.selectedTextRange {
        if let replaceTextRange = textField.textRange(from: selectedRange.start, to: selectedRange.start) {
          // Replace it.
          textField.replace(replaceTextRange, withText: selectedItem)
        }
      }
    }

  }
}

extension UIView {
   func copyView<T: UIView>() -> T {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as! T
   }
}

