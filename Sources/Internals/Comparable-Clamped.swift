//
//  Comparable-Clamped.swift
//  Sliders
//
//  Created by Timothy Dubbins on 11/04/2022.
//

import Foundation

internal extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
