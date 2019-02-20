//
//  ViewController.swift
//  BSAutocomplete
//
//  Created by boraseoksoon@gmail.com on 02/20/2019.
//  Copyright (c) 2019 boraseoksoon@gmail.com. All rights reserved.
//

import UIKit
import BSAutocomplete

class ViewController: UIViewController {
  // MARK: - IBOutlets and IBActions -
  @IBOutlet var titleTextField: UITextField! {
    didSet {
      titleTextField.delegate = self
    }
  }
  
  @IBOutlet var contentsTextView: UITextView! {
    didSet {
      contentsTextView.layer.borderColor = UIColor.black.cgColor
      contentsTextView.layer.borderWidth = 0.25
      contentsTextView.delegate = self
    }
  }
  
  @IBOutlet var nicknameTextField: UITextField! {
    didSet {
      nicknameTextField.delegate = self
    }
  }
  
  @IBOutlet var segmentControl: UISegmentedControl!
  @IBAction func segmentControlAction(_ sender: Any) {
    switch (sender as! UISegmentedControl).selectedSegmentIndex {
    case 0:
      // @
      prefix = Prefix.at
    case 1:
      // #
      prefix = Prefix.hash
    case 2:
      // $
      prefix = Prefix.cash
    default:
      break
    }
  }
  
  // MARK: - Instance Variables -
  private var prefix: Prefix = Prefix.at {
    didSet {
      /// change prefix to filter of BSAutocomplete's instance.
      print("change prefix to filter of BSAutocomplete's instance : \(prefix.rawValue)!")
      autocomplete.prefix = prefix.rawValue
      
      self.view.endEditing(true)
      
      self.view.subviews.forEach {
        if $0 is UITextView {
          ($0 as! UITextView).text = "Type '\(prefix.rawValue)' to see autocomplete!"
        } else if $0 is UITextField {
          ($0 as! UITextField).text = ""
          ($0 as! UITextField).placeholder = "Type '\(prefix.rawValue)' to see autocomplete!"
        }
      }
    }
  }

  /// Test input text from data.txt file in the main bundle(Supporting Files directory)
  /**
   TEST INPUT:
   
   #Swift
   #Objective-C
   #Scala
   #Kotlin
   #C
   #Javascript
   #Python
   #Clojure
   #C#
   #Scheme
   #C++
   #COBOL
   
   @Haskell
   @Lisp
   @Ocalm
   @Rust
   @SmallTalk
   @Java
   @Ruby
   @Parscal
   @Perl
   @PHP
   @Assembly
   @ADA
   @Groovy
   @Go
   @F#
   @Fotran
   
   $1
   $2
   $4
   $8
   $16
   $32
   $64
   $128
   $256
   $10
   $100
   $111
   $112
   $113
   $1000
   $1000
   $10000
   $20
   $200
   $2000
   $2000
   $20000
   */
  
  fileprivate let hashtags: [String] = {
    do {
      guard let dataPath = Bundle.main.path(forResource: "data", ofType: "txt") else {
        return []
      }
      
      let data = try WordReader(filepath: dataPath)
      return data.words
    }
    catch let error {
      print(error)
      return []
    }
  }()
  
  private enum Prefix: String {
    case at = "@"
    case hash = "#"
    case cash = "$"
  }
  
  /**
   * Creating BSAutocomplete instance..
   */
  private lazy var autocomplete: BSAutocomplete = { [unowned self] in
    let autocomplete = BSAutocomplete(basedOn: self.view,
                                      prefix: Prefix.at.rawValue,
                                      data: hashtags)
    autocomplete.delegate = self
    
    return autocomplete
  }()
  
  // MARK: - ViewController LifeCycle Methods -
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view, typically from a nib.
    
    /**
     * Must apply this API in viewDidLoad or similar appropriate method time being called
     * before the use of BSAutocomplete's instance.
     */
    autocomplete.readyToUse()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}

// MARK: - Own methods -
extension UIViewController {
  func evaluateType(sender: Either<UITextView, UITextField>, complete: @escaping (_ either: Either<UITextView, UITextField>) -> Void) -> Void {
    /// append additional empty space, " ".
    DispatchQueue.main.async {
      switch sender {
      case .textView(let textView):
        print("sender : \(textView)")
        complete(sender)
      case .textField(let textField):
        print("sender : \(textField)")
        complete(sender)
      }
    }
  }
}
/**
 * Here is the delegate methods.
 */
// MARK: - BSAutocompleteDelegate Methods -
extension ViewController: BSAutocompleteDelegate {
  func autoCompleteDidChooseItem(text: String, sender: Either<UITextView, UITextField>) -> Void {
    print("autoCompleteDidChooseItem : ", text)
    
    self.evaluateType(sender: sender) { sender in
      /**
       * User level logic to add the empty space at the end for convenience.
       */
      DispatchQueue.main.async {
        switch sender {
        case .textView(let textView):
          guard let text = textView.text else { return }
          textView.text = text + " "
          
        case .textField(let textField):
          guard let text = textField.text else { return }
          textField.text = text + " "
        }
      }
      
    }
  }
  
  func autoCompleteTextDidChange(text: String, sender: Either<UITextView, UITextField>) -> Void {
    print("autoCompleteTextDidChange : ", text)
  }
  
  func autoCompleteDidShow(sender: Either<UITextView, UITextField>) -> Void {
    print("autoCompleteDidShow")
  }
  
  func autoCompleteDidHide(sender: Either<UITextView, UITextField>) -> Void {
    print("autoCompleteDidHide!")
  }
}

// MARK: - UITextFieldDelegate Methods -
extension ViewController: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    /**
     * Must apply this API to keep track of the text.
     */
    autocomplete.receive(currentUserInput: string, from: .textField(textField))
    return true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    /// keyboard down logic
    if textField.isFirstResponder {
      textField.resignFirstResponder()
    }
    return true
  }
}

// MARK: - UITextViewDelegate Methods -
extension ViewController: UITextViewDelegate {
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    /**
     * Must apply this API to keep track of the text.
     */
    autocomplete.receive(currentUserInput: text, from: .textView(textView))
    
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
