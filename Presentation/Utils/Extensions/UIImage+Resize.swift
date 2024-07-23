//
//  UIExtension.swift
//  walkbook
//
//  Created by 육성민 on 7/15/24.
//

import UIKit

extension UIImage {
//    func resize(targetSize: CGSize) -> UIImage? {
//        let size = self.size
//        let widthRatio  = targetSize.width  / size.width
//        let heightRatio = targetSize.height / size.height
//        let newSize = CGSize(width: size.width * min(widthRatio, heightRatio),
//                             height: size.height * min(widthRatio, heightRatio))
//        
//        let rect = CGRect(origin: .zero, size: newSize)
//        
//        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
//        self.draw(in: rect)
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        return newImage
//    }
}

extension UIImage {
    func resize(targetSize size: CGSize) -> UIImage? {
        guard let data = self.pngData() else { return nil }
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }

        let options: [CFString: Any] = [
            kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height),
            kCGImageSourceCreateThumbnailFromImageAlways: true
        ]
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else { return nil }

        return UIImage(cgImage: cgImage)
    }
}
