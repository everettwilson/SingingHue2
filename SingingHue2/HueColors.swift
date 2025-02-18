//
//  HueColors.swift
//  SingingHue2
//
//  Created by Everett Wilson on 2/18/25.
//


import Foundation

struct HueColors {
    static let mapping: [String: (x: Double, y: Double)] = [
        "red":    (x: 0.675, y: 0.322),
        "green":  (x: 0.4091, y: 0.518),
        "blue":   (x: 0.167, y: 0.04),
        "yellow": (x: 0.432, y: 0.500),
        "orange": (x: 0.556, y: 0.408),
        "purple": (x: 0.272, y: 0.109),
        "pink":   (x: 0.382, y: 0.160)
    ]
}
