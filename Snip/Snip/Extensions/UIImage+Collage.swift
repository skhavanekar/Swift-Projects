//
//  UIImage+Collage.swift
//  Snip
//
//  Created by Sameer Khavanekar on 6/23/18.
//  Copyright © 2018 Sameer Khavanekar. All rights reserved.
//

import UIKit

extension UIImage {
    
    static func collage(images: [UIImage], size: CGSize) -> UIImage {
        let rows = images.count < 3 ? 1 : 2
        let columns = Int(round(Double(images.count) / Double(rows)))
        let tileSize = CGSize(width: round(size.width / CGFloat(columns)),
                              height: round(size.height / CGFloat(rows)))
        
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        UIColor.white.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        for (index, image) in images.enumerated() {
            image.scaled(tileSize).draw(at: CGPoint(
                x: CGFloat(index % columns) * tileSize.width,
                y: CGFloat(index / columns) * tileSize.height
            ))
        }
        
        let collage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return collage ?? UIImage()
    }
    
    func scaled(_ toSize: CGSize) -> UIImage {
        guard size != toSize else {
            return self
        }
        let ratio = max(toSize.width / size.width, toSize.height / size.height)
        let width = size.width * ratio
        let height = size.height * ratio
        let scaledRect = CGRect(
            x: (toSize.width - width) / 2.0,
            y: (toSize.height - height) / 2.0,
            width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(scaledRect.size, false, 0.0);
        defer { UIGraphicsEndImageContext() }
        draw(in: scaledRect)
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
}
