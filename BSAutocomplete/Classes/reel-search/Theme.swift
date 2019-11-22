//
//  Theme.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/11/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import UIKit

// MARK: Theme
/**
 Theme
 --
 
 Protocol that allows you change visual appearance a bit.
 */
public protocol Theme {
  
  /**
   Text font of both list labels and input textfield.
   */
  var font: UIFont { get }
  /**
   Color of textfield's text.
   
   Suggestion list's text color is calculated using this color by changing alpha channel value to `0.3`.
   */
  var textColor: UIColor { get }
  
  /**
   Color of list's background.
   */
  var listBackgroundColor: UIColor { get }
  
}

/**
 RAMTheme
 --
 
 Theme prefab.
 */
public struct RAMTheme: Theme {
  
  /// Shared theme with default settings.
  public static let sharedTheme = RAMTheme()
  
  /// Theme font.
  public let font: UIFont
  /// Theme text color.
  public let textColor: UIColor
  /// Theme background color.
  public let listBackgroundColor: UIColor
  
  fileprivate init(
    textColor: UIColor = UIColor.red,
    listBackgroundColor: UIColor = UIColor.clear,
    font: UIFont = RAMTheme.defaultFont
    )
  {
    self.textColor = textColor
    self.listBackgroundColor = listBackgroundColor
    self.font = font
  }
  
  fileprivate static var defaultFont: UIFont = RAMTheme.initDefaultFont()
  
  fileprivate static func initDefaultPlaceHolderFont() -> UIFont {
    return UIFont(name: "Verdana",
                  size: AUTOCOMPLETE_FONT_SIZE) ?? UIFont.systemFont(ofSize: AUTOCOMPLETE_FONT_SIZE)
  }
  
  fileprivate static func initDefaultFont() -> UIFont {
    return UIFont(name: "Verdana",
                  size: AUTOCOMPLETE_FONT_SIZE) ?? UIFont.systemFont(ofSize: AUTOCOMPLETE_FONT_SIZE)
  }
  
  /**
   Creates new theme with new text color.
   
   - parameter textColor: New text color.
   - returns: New `RAMTheme` instance.
   */
  public func textColor(_ textColor: UIColor) -> RAMTheme {
    return RAMTheme(textColor: textColor, listBackgroundColor: self.listBackgroundColor, font: self.font)
  }
  
  /**
   Creates new theme with new background color.
   
   - parameter listBackgroundColor: New background color.
   - returns: New `RAMTheme` instance.
   */
  public func listBackgroundColor(_ listBackgroundColor: UIColor) -> RAMTheme {
    return RAMTheme(textColor: self.textColor, listBackgroundColor: listBackgroundColor, font: self.font)
  }
  
  /**
   Creates new theme with new font.
   
   - parameter font: New font.
   - returns: New `RAMTheme` instance.
   */
  public func font(_ font: UIFont) -> RAMTheme {
    return RAMTheme(textColor: self.textColor, listBackgroundColor: self.listBackgroundColor, font: font)
  }
  
}

// MARK: - Font loader

/**
 FontLoader
 --
 */
final class FontLoader {
  
  enum AnError: Error {
    case failedToLoadFont(String)
  }
  
  static let robotoLight: FontLoader? = try? FontLoader.loadRobotoLight()
  
  static func loadRobotoLight() throws -> FontLoader {
    return try FontLoader(name: "Roboto-Light", type: "ttf")
  }
  
  let name: String
  let type: String
  
  fileprivate init(name: String, type: String) throws {
    self.name = name
    self.type = type
    
    guard FontLoader.loadedFonts[name] == nil else {
      return
    }
    
    let bundle = Bundle(for: Swift.type(of: self) as AnyClass)
    
    if
      let fontPath = bundle.path(forResource: name, ofType: type),
      let inData = try? Data(contentsOf: URL(fileURLWithPath: fontPath)),
      let provider = CGDataProvider(data: inData as CFData)
    {
      let font = CGFont(provider)
      CTFontManagerRegisterGraphicsFont(font!, nil)
      FontLoader.loadedFonts[self.name] = self
      return
    } else {
      throw AnError.failedToLoadFont(name)
    }
  }
  
  fileprivate static var loadedFonts: [String: FontLoader] = [:]
  
}

var AUTOCOMPLETE_FONT_SIZE: CGFloat {
  if UIDevice().userInterfaceIdiom == .phone {
    switch UIScreen.main.nativeBounds.height {
    case let height where height > 2436:
      return 46 - 20
    // case 2436:  // iPhone X
    case let height where height <= 2436 && height > 2208:
      return 44 - 20
    // case 1920, 2208:  // iPhone Plus
    case let height where height <= 2208 && height >= 1920:
      return 48 - 20
    case let height where height < 1920 && height > 1334:
      return 44 - 17.5  // iPhone XR
    case 1334:
      return 44 - 20
    case 1136:
      return 40 - 20
    default:
      return 32 - 20
    }
  } else {
    return 45
  }
}
