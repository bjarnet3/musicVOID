//
//  MusicPlaylistTableViewCell.swift
//  Hey DJ
//
//  Created by Bjarne Tvedten on 25.09.2017.
//  Copyright © 2017 Bjarne Tvedten. All rights reserved.
//

import UIKit

class MusicPlaylistTableViewCell: UITableViewCell {
    
    @IBOutlet weak var playlistImage: UIImageView!
    @IBOutlet weak var playlistArtist: UILabel!
    @IBOutlet weak var playlistTitle: UILabel!
    
    func configureCell(image: UIImage?, artist: String, title: String) {
        self.playlistImage.image = image
        self.playlistArtist.text = artist
        self.playlistTitle.text = title
    }
}
