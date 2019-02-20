# BSAutocomplete

[![CI Status](https://img.shields.io/travis/boraseoksoon/BSAutocomplete.svg?style=flat)](https://travis-ci.org/boraseoksoon/BSAutocomplete)
[![Version](https://img.shields.io/cocoapods/v/BSAutocomplete.svg?style=flat)](https://cocoapods.org/pods/BSAutocomplete)
[![License](https://img.shields.io/cocoapods/l/BSAutocomplete.svg?style=flat)](https://cocoapods.org/pods/BSAutocomplete)
[![Platform](https://img.shields.io/cocoapods/p/BSAutocomplete.svg?style=flat)](https://cocoapods.org/pods/BSAutocomplete)

BSAutocomplete provides easy-to-use and powerful autocomplete based on full screen UI for iOS.

<br>
[![Video Label](https://media.giphy.com/media/bE3Olvp3azcW8qxAJu/giphy.gif)](https://youtu.be/l_FbmPHrbBI)
[![Video Label](https://media.giphy.com/media/5YfdI7NQBhtU9LNZeF/giphy.gif)](https://youtu.be/uOJv1TJQAyAI)
<br>

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

iOS 10.0+ <br>
Swift 4.2 + <br>

## How to use

<br>
First things first,
<br> 
<b>Step 0. import BSAutocomplete</b>
<br>

```Swift
import BSAutocomplete
```
<br>

<b>Step 1. Create Instance programmatically as an instance variable </b>
<br>
Declare and create instance as an instance variable as below.
<br>
BSAutocomplete is only supported in a programmatical way.
<br>

```Swift
/**
* Creating BSAutocomplete instance..
*/

///
/// - parameter basedOn: a targetView to be based on for which it is usually self.view of UIViewController's instnace. 
/// - parameter prefix: a prefix string to provoke an instance of BSAutocomplete into showing and being hidden. For example, it could be '#', '@' or '$'. 
/// - parameter data: a list of string for you to display, to be shown by an instance of BSAutocomplete.
/// - returns: BSAutocomplete instance

private lazy var autocomplete: BSAutocomplete = { [unowned self] in
  let autocomplete = BSAutocomplete(basedOn: self.view, prefix: Prefix.at.rawValue, data: hashtags)
  autocomplete.delegate = self

  return autocomplete
}()

```
<br>
<b>Step 1. declare BSAutocomplete's delegate in order to keep track of events that will be given by BSAutocomplete at the certain circumstances.</b>
<br>
You will be able to assume when to be invoked by looking over the naming of delegate methods. 
<br>

```Swift
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

```

<br>
<b>Step 2. In viewDidLoad, apply readyToUse() method to get ready to show BSAutocomplete.</b>
<br>
It must be done before the use. Do it just as below.  
<br>

```Swift
override func viewDidLoad() {
  super.viewDidLoad()

  /**
  * Must apply this API in viewDidLoad or similar appropriate method time being called
  * before the use of BSAutocomplete's instance.
  */
  autocomplete.readyToUse()
}

```

<br>
<b>Step 3. add the code below to keep track of observing a current text being typed.</b>
<br>
Apply the below API to observe the text being input. 
Put a one of string being typed latest into currentUserInput parameter along with which you also need to provide an instance where text input is being input, wrapped by Either type provided by the library, which is either UITextfield or UITextView. 
You must need to use this API. Otherwise, an instance of BSAutocomplete has no chance to become visible. 
<br>

```Swift
// MARK: - UITextFieldDelegate Methods -
extension ViewController: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    /**
    * Must apply this API to keep track of the text being written.
    */
    autocomplete.observe(currentUserInput: string, from: .textField(textField))
    
    return true
  }
}

// MARK: - UITextViewDelegate Methods -
extension ViewController: UITextViewDelegate {
func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
  /**
  * Must apply this API to keep track of the text being written.
  */
  autocomplete.observe(currentUserInput: text, from: .textView(textView))
  
  return true
}

```

<br>
<b>That's all! Just enjoy BSAutocomplete! :)</b>
<br>

## ETC

BSAutocomplete is built based on the Ramotion/reel-search project.
Ramotion/reel-search repository URL: https://github.com/Ramotion/reel-search
(reel-search in BSAutocomplete has been so customized slightly that it is different.)

## Installation

We recommend using CocoaPods to install the library.
BSAutocomplete is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'BSAutocomplete'
```

## Author

boraseoksoon@gmail.com

## License

BSAutocomplete is available under the MIT license. See the LICENSE file for more info.

