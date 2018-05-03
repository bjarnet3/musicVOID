//
//  MusicPlaylistTableViewCell.swift
//  Hey DJ
//
//  Created by Bjarne Tvedten on 25.09.2017.
//  Copyright © 2017 Bjarne Tvedten. All rights reserved.
//

import UIKit
import MediaPlayer

class MusicPlaylistTableViewCell: UITableViewCell {
    
    @IBOutlet weak var playlistImage: UIImageView!
    @IBOutlet weak var playlistArtist: UILabel!
    @IBOutlet weak var playlistTitle: UILabel!
    @IBOutlet weak var playlistDuration: UILabel!
    
    func configureCell(image: UIImage?, artist: String, title: String, duration: TimeInterval) {
        self.playlistImage.image = image
        self.playlistArtist.text = artist
        self.playlistTitle.text = title
        self.playlistDuration.text = duration.description
    }
    
    func loadData(from mediaItem: MPMediaItem) {
        self.playlistImage.image = mediaItem.artwork?.image(at: self.playlistImage.frame.size)
        self.playlistArtist.text = mediaItem.artist
        self.playlistTitle.text = mediaItem.title
        self.playlistDuration.text = mediaItem.playbackDuration.description
    }
}
