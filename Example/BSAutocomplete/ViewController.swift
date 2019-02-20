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
  @objc func textFieldDidChange(_ textField: UITextField) {
    print("[in ViewController] plain : ", textField.text ?? "")
  }
  
  @IBOutlet var titleTextField: UITextField! {
    didSet {
      titleTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
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
  
  // MARK: - Instance Variables -
  private lazy var autocomplete = { [unowned self] in
    return BSAutocomplete(at: Either.textField(titleTextField), data: hashtags)
  }()
  
  // MARK: - ViewController LifeCycle Methods -
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view, typically from a nib.
    autocomplete.readyToUse()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}

extension ViewController: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    print("delegate : " + string)
    autocomplete.receive(currentUserInput: string)
    return true
  }
}

extension ViewController: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
//    print("delegate  : " + textView.text!)
  }
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    print("delegate : " + text)
    autocomplete.receive(currentUserInput: text)
    return true
  }
}

fileprivate let hashtags: [String] = {
  do {
    guard let dataPath = Bundle.main.path(forResource: "hashtags", ofType: "txt") else {
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

