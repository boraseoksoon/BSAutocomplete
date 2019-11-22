//
//  Functions.swift
//  BSAutocomplete
//
//  Created by Seoksoon Jang on 2019/11/22.
//

import Foundation

// MARK: - Functions -
func FindBaseView(from givenView: UIView?) -> UIView? {
  return givenView?.superview == nil ?  givenView : FindBaseView(from: givenView?.superview)
}

func PRETTY(file:String = #file, function:String = #function, line:Int = #line, reason: String = "none") {
  print(">>>>>> GUARD!!")
  #if DEBUG
  print("file:\(file) function:\(function) line:\(line), reason : \(reason)")
  #endif
  print(">>>>>> GUARD!!")
}


// MARK: - Grand Central Dispatch Wrapper -
func MainQ(completion: @escaping () -> Void) {
  DispatchQueue.main.async {
    completion()
  }
}

func GlobalQ(completion: @escaping () -> Void) {
  DispatchQueue.global().async {
    completion()
  }
}

let serialQueue = DispatchQueue(label: "queue.search.dayz")
func SerialQ(completion: @escaping () -> Void) {
  serialQueue.async {
    completion()
  }
}

func Delay(_ delaySeconds: Double, completion: @escaping () -> Void) -> Void {
  DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds) {
    completion()
  }
}


// MARK: -
func GetRootViewController() -> UIViewController? {
    guard let window = UIApplication.shared.keyWindow, let rootViewController = window.rootViewController else {
        return nil
    }

    var topController = rootViewController

    while let newTopController = topController.presentedViewController {
        topController = newTopController
    }

    return topController
}
