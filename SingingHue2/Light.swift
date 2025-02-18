//
//  Light.swift
//  SingingHue2
//
//  Created by Everett Wilson on 2/18/25.
//

import Foundation

enum LightType {
    case single
    case group
}

class Light {
    let lightID: String
    let type: LightType
    
    var resourceType: String {
        switch type {
        case .single:
            return "light"
        case .group:
            return "grouped_light"
        }
    }
    
    init(lightID: String, type: LightType) {
        self.lightID = lightID
        self.type = type
    }
}
