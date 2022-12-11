//
//  Notebook+Extensions.swift
//  Mooskine
//
//  Created by Yuan Gao on 12/10/22.
//  Copyright © 2022 Udacity. All rights reserved.
//

import Foundation
import CoreData

extension Notebook{
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
