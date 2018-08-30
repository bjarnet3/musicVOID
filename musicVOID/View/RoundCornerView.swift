//
//  RoundCornerShadowView.swift
//  musicVOID
//
//  Created by Bjarne Tvedten on 13.08.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

class RoundCornerView: UIView {
    
    @IBInspectable
    var image: UIImage? {
        didSet {
            setupView(image: image)
        }
    }
    
    private func setupView(image: UIImage?) {
        // add the shadow to the base view
        backgroundColor = UIColor.clear
        layer.shadowColor = PINK_DARK_SOLID.cgColor
        layer.shadowOffset = CGSize(width: 1.3, height: 5.8)
        layer.shadowOpacity = 0.93
        layer.shadowRadius = 10.95
        
        // add the border to subview
        let borderView = UIView()
        borderView.frame = bounds
        borderView.layer.cornerRadius = self.frame.height / 2
        borderView.layer.borderColor = WHITE_ALPHA.cgColor
        borderView.layer.borderWidth = 3.45
        borderView.layer.masksToBounds = true
        borderView.isUserInteractionEnabled = false
        addSubview(borderView)
        
        // add any other subcontent that you want clipped
        let otherSubContent = UIImageView()
        otherSubContent.image = image
        otherSubContent.frame = bounds
        otherSubContent.isUserInteractionEnabled = false
        borderView.addSubview(otherSubContent)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for view in subviews {
            view.setNeedsDisplay()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.autoresizesSubviews = true
        setupView(image: image)
    }
    
    
}
