//
//  ArtworkImageView.swift
//  musicVOID
//
//  Created by Bjarne Tvedten on 28.04.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

class CoverImageView: UIImageView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        testShaddow()
    }
    
    func testShaddow() {
        layer.roundCorners(radius: self.frame.height/2)
        layer.addShadow(offset: CGSize(width: 3, height: 3), opacity: 0.5, radius: 3, color: .black)
    }
    
}
