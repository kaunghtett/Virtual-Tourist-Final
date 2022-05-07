//
//  Pin+Extension.swift
//  Virtual Tourist Udacity
//
//  Created by Min Kaung Htet on 06/05/2022.
//

import Foundation
import CoreData

extension Pin {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
