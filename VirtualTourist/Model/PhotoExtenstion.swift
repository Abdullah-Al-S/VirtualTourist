//
//  PhotoExtenstion.swift
//  VirtualTourist
//
//  Created by Arch Studios on 6/27/19.
//  Copyright © 2019 AS. All rights reserved.
//

import Foundation
import MapKit

extension Photo {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
    
}

