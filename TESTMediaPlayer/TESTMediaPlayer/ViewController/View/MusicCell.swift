//
//  MusicCell.swift
//  TESTMediaPlayer
//
//  Created by Kseniya Smirnova on 2.09.22.
//

import UIKit

class MusicCell: UICollectionViewCell {
    
    //MARK: - Static
    
    static let reuseIdentifier: String = "musicCell"
    
    //MARK: - Outlets

    @IBOutlet weak var blurImageView: UIImageView!
    @IBOutlet weak var coverImageView: UIImageView!
    
    //MARK: - Functions
    
    func configure(image: String) {
        coverImageView.image = UIImage(named: image)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        coverImageView.layer.cornerRadius = 10
        
        blurImageView.alpha = 0.05
        blurImageView.layer.borderColor = UIColor.white.cgColor
        blurImageView.layer.borderWidth = 1
        blurImageView.layer.cornerRadius = 10
    }
}
