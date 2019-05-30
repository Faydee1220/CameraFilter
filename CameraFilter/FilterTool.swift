//
//  FilterTool.swift
//  CameraFilter
//
//  Created by 永動科技RQ on 2019/5/30.
//  Copyright © 2019 永動科技 RQ. All rights reserved.
//

import Foundation
import UIKit
import CoreImage
import RxSwift

class FilterTool: NSObject {
    static let shared = FilterTool()

    private var context: CIContext

    private override init() {
        context = CIContext()
    }

    func applyFilter(to inputImage: UIImage) -> Observable<UIImage> {
        return Observable<UIImage>.create({ (observer) -> Disposable in
            self.applyFilter(to: inputImage, completion: { (filteredImage) in
                observer.onNext(filteredImage)
            })
            return Disposables.create()
        })
    }

    private func applyFilter(to inputImage: UIImage, completion: @escaping ((UIImage) -> ())) {
        let filter = CIFilter(name: "CICMYKHalftone")
        filter?.setValue(5.0, forKey: kCIInputWidthKey)

        if let sourceImage = CIImage(image: inputImage) {
            filter?.setValue(sourceImage, forKey: kCIInputImageKey)
            if let outputImage = filter?.outputImage,
                let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                let processedImage = UIImage(cgImage: cgImage, scale: inputImage.scale,
                                             orientation: inputImage.imageOrientation)
                completion(processedImage)
            }
        }

    }
}
