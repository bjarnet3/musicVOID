//
//  ArtworkImageView.swift
//  musicVOID
//
//  Created by Bjarne Tvedten on 28.04.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

class CoverImageView: UIImageView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 0.5
        self.layer.borderColor = hexStringToUIColor("000000", 1.0).cgColor // UIColor.gray.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.height / 2 // self.frame.height / 2
    }
    
}
