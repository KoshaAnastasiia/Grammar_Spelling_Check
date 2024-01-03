//
//  Extension.swift
//  Grammar_Spelling_Check
//
//  Created by kosha on 26.09.2023.
//

import Foundation
import SwiftUI

extension NSAttributedString {
    func stringWithString(rangeToReplace: NSRange, replacedWithString newStringPart: String) -> NSMutableAttributedString {
        let mutableAttributedString = mutableCopy() as! NSMutableAttributedString
        mutableAttributedString.replaceCharacters(in: rangeToReplace, with: newStringPart)
        return mutableAttributedString
    }
}

