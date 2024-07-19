//
//  Result.swift
//  BucketList
//
//  Created by Jon Spight on 7/18/24.
//

import Foundation
import SwiftUI

struct Result : Codable {
    let query : Query
}

struct Query: Codable {
    let pages : [Int : Page]
}

struct Page : Codable, Comparable{
    let pageid : Int
    var title : String
    let terms : [String : [String]]?
    
    var description : String {
        terms?["description"]?.first ?? "No Further description"
    }
    
    static func < (lhs: Page, rhs: Page) -> Bool {
        return lhs.title < rhs.title
    }
    
}
