//
//  UIView.swift
//  BSAutocomplete
//
//  Created by Seoksoon Jang on 2019/11/22.
//

import Foundation

class TouchPassThroughView: UIView {
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

