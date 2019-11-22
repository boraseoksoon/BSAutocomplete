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
//      titleTextField.delegate = self
    }
  }
  
  @IBOutlet var contentsTextView: UITextView! {
    didSet {
      contentsTextView.layer.borderColor = UIColor.black.cgColor
      contentsTextView.layer.borderWidth = 0.25
//      contentsTextView.delegate = self
    }
  }
  
  @IBOutlet var nicknameTextField: UITextField! {
    didSet {
//      nicknameTextField.delegate = self
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
      prefix = Prefix.none
    }
  }
  
  // MARK: - Instance Variables -
  private var prefix: Prefix = Prefix.none {
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
 
  /**
   * Creating BSAutocomplete instance..
   */
  private lazy var autocomplete: BSAutocomplete = { [unowned self] in
    let autocomplete = BSAutocomplete(observedViewList: [.textField(self.nicknameTextField),
                                                         .textView(self.contentsTextView),
                                                         .textField(self.titleTextField)],
                                      autoCompleteList: hashtags)
    autocomplete.delegate = self
    
    return autocomplete
  }()
  
  // MARK: - ViewController LifeCycle Methods -
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view, typically from a nib.
    _ = self.autocomplete
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}

/**
 * Here is the delegate methods.
 */
// MARK: - BSAutocompleteDelegate Methods -
extension ViewController: BSAutocompleteDelegate {
  func autoCompleteDidChooseItem(text: String, sender: Either<UITextView, UITextField>) -> Void {
    print("autoCompleteDidChooseItem : ", text)
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
//extension ViewController: UITextFieldDelegate {
//    public func textFieldDidBeginEditing(_ textField: UITextField) {
//        print("textFieldDidBeginEditing in VC!")
//    }
//
//  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//    /**
//     * Must apply this API to keep track of the text being written.
//     */
//    // autocomplete.observe(currentUserInput: string, from: .textField(textField))
//    return true
//  }
//
//  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//    /// keyboard down logic
////    if textField.isFirstResponder {
////      textField.resignFirstResponder()
////    }
//
//    return true
//  }
//}

// MARK: - UITextViewDelegate Methods -
//extension ViewController: UITextViewDelegate {
//  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//    /**
//     * Must apply this API to keep track of the text being written.
//     */
//    // autocomplete.observe(currentUserInput: text, from: .textView(textView))
//
//    /// keyboard down logic
////    if(text == "\n") {
////      if textView.isFirstResponder {
////        textView.resignFirstResponder()
////      }
////      return false
////    }
//
//    return true
//  }
//}

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

