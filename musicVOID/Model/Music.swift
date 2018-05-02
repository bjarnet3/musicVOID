//
//  Music.swift
//  Hey DJ
//
//  Created by Bjarne Tvedten on 01.10.2017.
//  Copyright © 2017 Bjarne Tvedten. All rights reserved.
//

import Foundation

struct Music {
    
    var persistID: String
    var artist: String?
    var title: String?
    var imageLocation: String?
    var votes: Int?
    
    init(persistID: String, artist: String?, title: String?, imageLocation: String?) {
        self.persistID = persistID
        self.artist = artist
        self.title = title
        self.imageLocation = imageLocation
    }
    
}
