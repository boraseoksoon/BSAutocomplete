//
//  ViewController.swift
//  BSAutocomplete
//
//  Created by boraseoksoon@gmail.com on 02/20/2019.
//  Copyright (c) 2019 boraseoksoon@gmail.com. All rights reserved.
//

import UIKit

// MARK: - Constants -
let ANIMATION_DURATION = 0.7
let TEXT_COLOR_PLACEHOLDER_ALPHA: CGFloat = 0.45
let TEXT_COLOR_FOCUS_ALPHA: CGFloat = 0.9
let SHOW_ALPHA: CGFloat = 0.35
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
    v.backgroundColor = .darkGray
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
  
  public init(basedOn: UIView, prefix: String, data: [String]) {
    super.init(frame: UIScreen.main.bounds)
    
    self.prefix = prefix
    self.data = data
    
    self.initialization(at: basedOn, data: data)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
}

// MARK: - Public Own Methods -
extension BSAutocomplete {
  public func observe(currentUserInput: String, from: Either<UITextView, UITextField>) -> Void {
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
  
  public func readyToUse() -> Void {
    guard let baseView = baseView else { PRETTY(); return }
    
    baseView.addSubview(ramReel.view)
    baseView.addSubview(backgroundAlphaView)
    ramReel.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
  }
  
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

        MainQ {
          if fullInputText == "" {
            self.hide()
          }
        }
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

// MARK: - Functions -
private func FindBaseView(from givenView: UIView?) -> UIView? {
  return givenView?.superview == nil ?  givenView : FindBaseView(from: givenView?.superview)
}

private func PRETTY(file:String = #file, function:String = #function, line:Int = #line, reason: String = "none") {
  print(">>>>>> GUARD!!")
  #if DEBUG
  print("file:\(file) function:\(function) line:\(line), reason : \(reason)")
  #endif
  print(">>>>>> GUARD!!")
}

// MARK: - Grand Central Dispatch Wrapper -
private func MainQ(completion: @escaping () -> Void) {
  DispatchQueue.main.async {
    completion()
  }
}

private func GlobalQ(completion: @escaping () -> Void) {
  DispatchQueue.global().async {
    completion()
  }
}

private let serialQueue = DispatchQueue(label: "queue.search.dayz")
private func SerialQ(completion: @escaping () -> Void) {
  serialQueue.async {
    completion()
  }
}

private func Delay(_ delaySeconds: Double, completion: @escaping () -> Void) -> Void {
  DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds) {
    completion()
  }
}

private class TouchPassThroughView: UIView {
  override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    for subview in  subviews {
      if !subview.isHidden && subview.alpha > 0 && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
        return true
      }
    }
    return false
  }
  
  override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    print("EventPassThroughView touched?")
  }
}
