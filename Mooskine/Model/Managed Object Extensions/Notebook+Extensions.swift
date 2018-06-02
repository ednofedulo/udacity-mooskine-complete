//
//  Notebook+Extensions.swift
//  Mooskine
//
//  Created by Edno Fedulo on 27/05/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation
import CoreData

extension Notebook {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.creationDate = Date()
    }
}
