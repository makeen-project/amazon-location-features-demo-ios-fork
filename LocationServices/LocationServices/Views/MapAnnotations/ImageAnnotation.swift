//
//  ImageAnnotation.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import Mapbox

class ImageAnnotation: MGLPointAnnotation {
    var image: UIImage?
    
    init(image: UIImage) {
        self.image = image
        super.init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class ImageAnnotationView: MGLAnnotationView {
    
    enum Constants {
        static let size: CGSize = CGSize(width: 30, height: 30)
    }
    
    private var imageView: UIImageView?
    
    init(annotation: ImageAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        frame.size = Constants.size
        addImage(annotation?.image)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func addImage(_ image: UIImage?) {
        guard let image else { return }
        self.imageView?.removeFromSuperview()
        
        let imageView = UIImageView()
        self.imageView = imageView
        imageView.frame = CGRect(origin: .zero, size: frame.size)
        addSubview(imageView)

        imageView.image = image
        
        imageView.setShadow()
    }
}
