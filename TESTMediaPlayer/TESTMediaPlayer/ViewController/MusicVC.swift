//
//  MusicVC.swift
//  TESTMediaPlayer
//
//  Created by Kseniya Smirnova on 2.09.22.
//

import UIKit

class MusicVC: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var nameTrackLabel: UILabel!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var musicCollectionView: UICollectionView!
    @IBOutlet weak var playerProgressSlider: UISlider!
    @IBOutlet weak var lightCover: UIImageView!
    @IBOutlet weak var progressLabelLeft: UILabel!
    @IBOutlet weak var progressLabelRight: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    //MARK: - Variables
    
    private let flowLayout = FlowLayout()
    private let model = PlayerModel()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        addGestureRecognizers()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return  .lightContent
    }
    
    //MARK: - Set UI
    
    func setUI() {
        playButton.setImage(UIImage(named: "playButton"), for: .normal)
        
        playerProgressSlider.setValue(0, animated: true)
        playerProgressSlider.setThumbImage(UIImage(named: "sliderCircleNormal"), for: .normal)
        playerProgressSlider.setThumbImage(UIImage(named: "sliderCircleNormal"), for: .highlighted)
        
        playButton.layer.cornerRadius = playButton.bounds.height / 2
        playButton.layer.shadowColor = UIColor.black.cgColor
        playButton.layer.shadowRadius = 20
        playButton.layer.shadowOpacity = 1
        playButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        playButton.clipsToBounds = false
        playButton.layer.masksToBounds = false
        
        lightCover.image = nil
        
        musicCollectionView.collectionViewLayout = flowLayout
        musicCollectionView.register(UINib(nibName: "MusicCell", bundle: nil), forCellWithReuseIdentifier: "musicCell")
        
        setProgressSlider()
        setLabels()
    }
    
    func setLabels() {
        nameTrackLabel.text = model.currentSong.title
        albumLabel.text = model.currentSong.album
        
        blackoutEndLabel(label: nameTrackLabel)
    }
    
    func setProgressLabels(_ reset: Bool = false) {
        progressLabelLeft.text = reset ? "00:00" : model.getPlaybackData(.currentTime).formattedTime()
        progressLabelRight.text = reset ? model.getPlaybackData(.duration).formattedTime() : model.getPlaybackData(.leftTime).formattedTime()
    }
    
    func switchPlayButton() {
        model.isPlaying.toggle()
        
        playButton.setImage(model.isPlaying ? UIImage(named: "pauseButton") : UIImage(named: "playButton"), for: .normal)
        lightCover.image = model.isPlaying ? UIImage(named: "light") : nil
        model.isPlaying ? addAnimationLightCover(imageView: lightCover) : lightCover.stopAnimating()
        musicCollectionView.reloadData()
        
        startTimer()
    }
    
    func setProgressSlider() {
        resetProgressSlider()
        startTimer()
    }
    
    func resetProgressSlider() {
        playerProgressSlider.minimumValue = Float(model.getPlaybackData(.currentTime))
        playerProgressSlider.maximumValue = Float(model.getPlaybackData(.leftTime))
    }
    
    //MARK: - GestureRecognizer
    
    func addGestureRecognizers() {
        let tapGestureRight = UISwipeGestureRecognizer(target: self, action: #selector(tapBack))
        tapGestureRight.direction = .right
        musicCollectionView.addGestureRecognizer(tapGestureRight)
        
        let tapGestureLeft = UISwipeGestureRecognizer(target: self, action: #selector(tapForward))
        tapGestureLeft.direction = .left
        musicCollectionView.addGestureRecognizer(tapGestureLeft)
    }
    
    @objc func tapBack() {
        model.playPrevious()
        choiceTrack()
        setLabels()
        resetProgressSlider()
    }
    
    @objc func tapForward() {
        model.playNext()
        choiceTrack()
        setLabels()
        resetProgressSlider()
    }
    
    private func choiceTrack() {
        musicCollectionView.scrollToItem(at: IndexPath(row: model.currentSelected, section: 0), at: .centeredHorizontally, animated: true)
        model.preparePlayer()
        setProgressLabels(true)
        musicCollectionView.reloadData()
        
        model.playPause()
    }
    
    //MARK: - Helper Functions
    
    func addAnimationLightCover(imageView: UIImageView) {
        let fadeInOut = CABasicAnimation(keyPath: "opacity")
        fadeInOut.fromValue = 0.2
        fadeInOut.toValue = 0.8
        fadeInOut.duration = 1.6
        fadeInOut.autoreverses = true
        fadeInOut.repeatCount = .infinity
        imageView.layer.add(fadeInOut, forKey: "fadeInFadeOutAnimation")
    }
    
    func blackoutEndLabel(label: UILabel) {
        let gradient = CAGradientLayer()
        gradient.frame = label.bounds
        gradient.colors = [UIColor.white.cgColor, UIColor.clear.cgColor]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 1, y: 0.0)
        label.lineBreakMode = .byClipping
        label.layer.mask = gradient
    }
    
    //MARK: - Player Functions
    
    func startTimer() {
        model.timerLabel = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateLabel), userInfo: nil, repeats: true)
        model.timerSlider = Timer.scheduledTimer(timeInterval: 0, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        
        model.timerLabel?.fire()
        model.timerSlider?.fire()
    }
    
    @objc func updateLabel() {
        setProgressLabels()
    }
    
    @objc func updateSlider() {
        playerProgressSlider.value = Float(model.getPlaybackData(.currentTime))
        guard model.isPlaying, model.getPlaybackData(.leftTime) < 1 else { return }
        tapForward()
    }
    
    //MARK: - Actions
    
    @IBAction func tapPlayButton(_ sender: UIButton) {
        switchPlayButton()
        model.playPause()
    }
    
    @IBAction func tapBackTrackButton(_ sender: UIButton) {
        tapBack()
    }
    
    @IBAction func tapForwardTrackButton(_ sender: UIButton) {
        tapForward()
    }
}

//MARK: - Extension CollectionView

extension MusicVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.tracks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MusicCell.reuseIdentifier, for: indexPath as IndexPath) as! MusicCell
        cell.configure(image: model.tracks[indexPath.row].image)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == (model.currentSelected - 1) {
            tapBack()
        } else if indexPath.row == (model.currentSelected + 1) {
            tapForward()
        }
    }
}
