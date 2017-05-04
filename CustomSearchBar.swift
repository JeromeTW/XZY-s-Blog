//
//  CustomSearchBar.swift
//  CustomSearchBar
//
//  Created by JEROME on 2016/9/29.
//  Copyright © 2016年 Appcoda. All rights reserved.
//

import UIKit

class CustomSearchBar: UISearchBar {

    var preferredFont: UIFont!
    var preferredTextColor: UIColor!
    var preferredPlaceholder = ""
    var preferredPlaceholderColor: UIColor!
    
    init(frame: CGRect, font: UIFont, textColor: UIColor, placeholder: String, placeholderColor: UIColor) {
        super.init(frame: frame)
        self.frame = frame
        preferredFont = font
        preferredTextColor = textColor
        preferredPlaceholder = placeholder
        preferredPlaceholderColor = placeholderColor
        
        // This command results to a search bar with a translucent background and opaque search field.
        searchBarStyle = .prominent
        isTranslucent = false // 設為不是半透明
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func indexOfSearchFieldInSubviews() -> Int! {
        var index: Int!
        let searchBarView = subviews[0]
        for (i, subview) in searchBarView.subviews.enumerated() {
            if subview.isKind(of: UITextField.self) {
                index = i
                break
            }
        }
        return index
    }
    
    
    override func draw(_ rect: CGRect) {
        // Find the index of the search field in the search bar subviews.
        if let index = indexOfSearchFieldInSubviews() {
            // Access the search field
            let searchField: UITextField = subviews[0].subviews[index] as! UITextField
            // Set its frame.
            searchField.frame = CGRect(x: 5, y: 5, width: frame.size.width - 10, height: frame.size.height - 10)
            // Set the font and text color of the search field.
            searchField.font = preferredFont
            searchField.textColor = preferredTextColor
            let attributesDictionary = [NSForegroundColorAttributeName: preferredPlaceholderColor]
            searchField.attributedPlaceholder = NSAttributedString(string: preferredPlaceholder, attributes: attributesDictionary)
			
            // Set the background color of the search field.
//            searchField.backgroundColor = barTintColor
        }
        
        super.draw(rect)
    }
}
