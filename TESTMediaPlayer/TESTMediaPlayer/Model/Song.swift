//
//  MusicModel.swift
//  TESTMediaPlayer
//
//  Created by Kseniya Smirnova on 2.09.22.
//

import UIKit

struct Song {
    let title: String
    let album: String
    let path: URL
    let image: String
    
    init(image: String, name: String, album: String) {
        self.title = name
        self.album = album
        self.path = URL(fileURLWithPath: Bundle.main.path(forResource: image, ofType: "mp3") ?? image)
        self.image = image
    }
}
