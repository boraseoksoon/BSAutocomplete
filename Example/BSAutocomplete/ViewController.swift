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
  @IBOutlet var titleTextField: UITextField!
  @IBOutlet var contentsTextView: UITextView! {
    didSet {
      contentsTextView.layer.borderColor = UIColor.black.cgColor
      contentsTextView.layer.borderWidth = 0.25
    }
  }
  
  // MARK: - Instance Variables -
  private lazy var autocomplete = { [unowned self] in
    return BSAutocomplete(at: Either.textView(contentsTextView), data: hashtags)
  }()
  
  // MARK: - ViewController LifeCycle Methods -
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view, typically from a nib.
    _ = autocomplete
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
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

