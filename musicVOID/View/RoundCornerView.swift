//
//  RoundCornerShadowView.swift
//  musicVOID
//
//  Created by Bjarne Tvedten on 13.08.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

class RoundCornerView: UIView {
    
    var image: UIImage? {
        didSet {
            setupView(image: image)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView(image: image)
    }
    
    func setupView(image: UIImage?) {
        // add the shadow to the base view
        backgroundColor = UIColor.clear
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 2.8, height: 4)
        layer.shadowOpacity = 0.50
        layer.shadowRadius = 6.2
        
        // add the border to subview
        let borderView = UIView()
        borderView.frame = bounds
        borderView.layer.cornerRadius = self.frame.height / 2
        // borderView.layer.borderColor = UIColor.black.cgColor
        // borderView.layer.borderWidth = 0.5
        borderView.layer.masksToBounds = true
        borderView.isUserInteractionEnabled = false
        addSubview(borderView)
        
        // add any other subcontent that you want clipped
        let otherSubContent = UIImageView()
        otherSubContent.image = image
        otherSubContent.frame = borderView.bounds
        otherSubContent.isUserInteractionEnabled = false
        borderView.addSubview(otherSubContent)
    }
}
