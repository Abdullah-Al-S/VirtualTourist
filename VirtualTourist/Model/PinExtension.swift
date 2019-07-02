//
//  PinExtension.swift
//  VirtualTourist
//
//  Created by Arch Studios on 6/25/19.
//  Copyright © 2019 AS. All rights reserved.
//

import Foundation
import MapKit

extension Pin {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
    
}
