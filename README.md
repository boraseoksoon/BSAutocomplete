# BSAutocomplete

[![CI Status](https://img.shields.io/travis/boraseoksoon/BSAutocomplete.svg?style=flat)](https://travis-ci.org/boraseoksoon/BSAutocomplete)
[![Version](https://img.shields.io/cocoapods/v/BSAutocomplete.svg?style=flat)](https://cocoapods.org/pods/BSAutocomplete)
[![License](https://img.shields.io/cocoapods/l/BSAutocomplete.svg?style=flat)](https://cocoapods.org/pods/BSAutocomplete)
[![Platform](https://img.shields.io/cocoapods/p/BSAutocomplete.svg?style=flat)](https://cocoapods.org/pods/BSAutocomplete)

BSAutocomplete provides easy-to-use and powerful autocomplete feature based on the full screen experience.<br>
With prefix you would like to such as '#', '@' or '$', you can inject stylish full-screen autocomplete functionality into UITextView or UITextField so as to help users better find and write specific contents containing the prefix while typing.<br>

<img src="https://media.giphy.com/media/bE3Olvp3azcW8qxAJu/giphy.gif" width=320>
<img src="https://media.giphy.com/media/kigT3kUtaMGwtLK2gJ/giphy.gif" width=320>

It's like in this example project: <br>
<img src="https://firebasestorage.googleapis.com/v0/b/dayz-dev.appspot.com/o/bsautocomplete_screenshot.png?alt=media&token=aae319a9-2a58-4a2e-822f-3153a6f34ecd" width=240>
<br>

BSAutocomplete is heavily used in ['All DAYZ'](https://itunes.apple.com/app/id1434294288) application.<br>
It's like in 'ALL DAYZ': <br>
<img src="https://firebasestorage.googleapis.com/v0/b/dayz-dev.appspot.com/o/alldayz_screenshot.png?alt=media&token=eb5a5d25-d29c-4780-99af-48e05b784c6f" width=320>
<br>

Youtube video URL Link for how it works: <br>
[link0](https://www.youtube.com/watch?v=l_FbmPHrbBI), [link1](https://www.youtube.com/watch?v=uOJv1TJQAyA)

<!--[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/l_FbmPHrbBI/0.jpg)](https://www.youtube.com/watch?v=l_FbmPHrbBI)-->
<!--<br>-->
<!--[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/uOJv1TJQAyA/0.jpg)](https://www.youtube.com/watch?v=uOJv1TJQAyA)-->

<br>
<br>

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

iOS 10.0+ <br>
Swift 4.2 + <br>

## How to use

<b>Step 0. import BSAutocomplete</b>
<br><br>

```Swift
import BSAutocomplete
```
<br>

<b>Step 1. Create Instance programmatically as an instance variable </b>
<br>
Declare and create instance as an instance variable as below.
<br>
BSAutocomplete is only supported in a programmatical way.
<br><br>

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
<br><br>

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
<br><br>

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
Apply the below API to observe the text being input.<br>
Put a one of string being typed latest into currentUserInput parameter along with which you also need to provide an instance where text input is being input, wrapped by Either type provided by the library, which is either UITextfield or UITextView.<br>
You must need to use this API. Otherwise, an instance of BSAutocomplete has no chance to become visible. 
<br><br>

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

<br><br>
<b>That's all! Just enjoy BSAutocomplete! :)</b>
<br>

## Credits
BSAutocomplete is built heavily based on ['Ramotion/reel-search'](https://github.com/Ramotion/reel-search) that draws Core UI of BSAutocomplete.<br>
(Mind that reel-search used in BSAutocomplete has been so customized slightly that it is different if you want to clone it.)

## Installation

We recommend using CocoaPods to install the library.<br>
BSAutocomplete is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'BSAutocomplete'
```

## Author

boraseoksoon@gmail.com

## License

BSAutocomplete is available under the MIT license. See the LICENSE file for more info.

