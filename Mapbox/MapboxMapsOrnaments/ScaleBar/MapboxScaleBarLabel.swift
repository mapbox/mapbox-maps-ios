//
//  MapboxScaleBarLabel.swift
//  Mapbox
//
//  Copyright © 2020 Mapbox. All rights reserved.
//

import UIKit

public class MapboxScaleBarLabel: UILabel {

    override public func drawText(in rect: CGRect) {
        let originalShadowOffset = shadowOffset
        let context = UIGraphicsGetCurrentContext()

        context?.setLineWidth(2)
        context?.setLineJoin(.round)

        context?.setTextDrawingMode(.stroke)
        textColor = .white
        super.drawText(in: rect)

        context?.setTextDrawingMode(.fill)
        textColor = .black
        shadowOffset = CGSize()
        super.drawText(in: rect)

        self.shadowOffset = originalShadowOffset
    }
}
