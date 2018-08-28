//
//  StartViewController.swift
//  musicVOID
//
//  Created by Bjarne Tvedten on 28.04.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit
import Firebase
import MediaPlayer
import MBCircularProgressBar
import SoundWaveForm
import Foundation
import AVFoundation
import FDWaveformView

class PlayViewController: UIViewController, MPMediaPickerControllerDelegate {
    
    // MARK: - Outlet Properties
    @IBOutlet weak var coverImageView: RoundCornerView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var minimizeButton: UIButton!
    
    @IBOutlet weak var artistLabel: UILabelX!
    @IBOutlet weak var titleLabel: UILabelX!
    @IBOutlet weak var logoImageView: UIImageView!

    @IBOutlet weak var musicProgress: UIProgressView!
    @IBOutlet weak var playlistProgress: UIProgressView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableBackView: UIView!
    @IBOutlet weak var fdWaveFormView: FDWaveformView!
    @IBOutlet weak var scrollView: UIScrollView!

    fileprivate var startRendering = Date()
    fileprivate var endRendering = Date()
    fileprivate var startLoading = Date()
    fileprivate var endLoading = Date()
    fileprivate var profileResult = ""
    
    // MARK: - Media Player and Playlist Properties
    var musicPlayer = MPMusicPlayerController.applicationMusicPlayer
    var musicPlaylist = [MPMediaItem]()
    // This need to be fixed
    var musicPlaylistOrder = [String:Int]()
    // var avPlayer = AVPlayer()
    // Interesting
    // var musicQueuePlayer = MPMusicPlayerApplicationController()
    
    // ---------------------------------------------------------
    // https://github.com/benoit-pereira-da-silva/SoundWaveForm
    // ---------------------------------------------------------
    
    // MARK: - Class and Varible Properties
    var timer = Timer()
    var timeFull : Int = 0
    var timeCurrent : Int = 0
    var timeLeft : Int = 0
    var quickTimer = Timer()
    
    var progressStep : Float = 0.0
    var progressCurrent : Float = 0.0
    var progressLeft : Float = 0.0
    
    var musicUpForVote = [String]()
    var musicVotedArray = [Music]()
    var musicWinnerID: String? = nil
    
    var songsPlayed = 0
    var minimumSongsBetweenSongs = 2
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsetsMake(20, 0, 20, 0)
        
        scrollView.delegate = self
        scrollView.delegate = self
        
        // Set tableBackView
        tableBackView.clipsToBounds = true
        tableBackView.layer.cornerRadius = 28
        tableBackView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        // removeDatabaseValues(at: .voting)
        syncDatabasePlaylists()
        changedNowPlaying()
        
        addParallaxEffectOnView(self.coverImageView, 22)
        addParallaxEffectOnView(self.artistLabel, 8)
        addParallaxEffectOnView(self.titleLabel, 8)
        addParallaxEffectOnView(self.logoImageView, 10)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tab = self.tabBarController?.tabBar as! FrostyTabBar
        tab.setEffect(blurEffect: .light)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setProgress(progress: 0.0, animated: true, alpha: 0.0)
    }
    
    // MARK: - Player functions
    func nowPlaying() {
        if musicPlayer.nowPlayingItem?.title != titleLabel.text {
            if let item = musicPlayer.nowPlayingItem {
                self.coverImageView.image = item.artwork?.image(at: CGSize(width: 500, height: 500))
                self.artistLabel.text = item.artist
                self.titleLabel.text = item.title
            }
        }
    }
    
    func playAction() {
        musicPlayer.play()
        playButton.setImage(UIImage(named: "noun_255303_cc kopi"), for: .normal)
        nowPlaying()
        updateMusicTimer()
    }
    
    func pauseAction() {
        musicPlayer.pause()
        playButton.setImage(UIImage(named: "noun_255297_cc kopi"), for: .normal)
        timer.invalidate()
    }
    
    // MARK: - Playlist functions
    func setCurrentPlaylist() {
        removeDatabaseValues(at: .playlist)
        for item in musicPlaylist {
            
            if let artist = item.artist {
                if let title = item.title {
                    
                    let songInfo: [String: String] = [
                        "Artist": artist,
                        "Title": title
                    ]
                    
                    let persistIDString = item.persistentID.description
                    let eventInFirebase = DataService.connect.REF_EVENTS.child(eventID)
                    eventInFirebase.child("playlist").child(persistIDString).setValue(songInfo)
                    
                    let maxScore = songsPlayed + minimumSongsBetweenSongs
                    musicPlaylistOrder.updateValue(maxScore, forKey: persistIDString)
                }
            }
        }
    }
    
    func syncDatabasePlaylists() {
        musicPlaylist.removeAll()
        musicPlaylistOrder.removeAll()
        
        var firebasePersistIDs = [String]()
        
        DataService.connect.REF_EVENTS.child(eventID).child("playlist").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    let key = snap.key as String
                    firebasePersistIDs.append(key)
                }
            }
            let mediaQuery = MPMediaQuery()
            if let mediaQueryItems = mediaQuery.items {
                for item in mediaQueryItems {
                    for (i, fireID) in firebasePersistIDs.enumerated() {
                        if fireID == item.persistentID.description {
                            self.musicPlaylist.append(item)
                            firebasePersistIDs.remove(at: i)
                            let maxScore = self.songsPlayed + self.minimumSongsBetweenSongs
                            self.musicPlaylistOrder.updateValue(maxScore, forKey: item.persistentID.description)
                        }
                    }
                }
                let collection = MPMediaItemCollection(items: self.musicPlaylist)
                self.musicPlayer.setQueue(with: collection)
                self.musicPlayer.prepareToPlay()
                self.pauseAction()
                self.nowPlaying()
                self.tableView.reloadData()
                for persistentID in firebasePersistIDs {
                    self.removeDatabaseValues(at: .voting, persistentID)
                }
            }
        })
    }
    // MARK: - Database and Image tools
    func removeDatabaseValues(at: DBFolder,_ key: String? = nil) {
        let location = at.rawValue
        let eventInFirebase = DataService.connect.REF_EVENTS.child(eventID)
        if let keyValue = key, key != nil {
            eventInFirebase.child(location).child(keyValue).removeValue()
        } else {
            eventInFirebase.child(location).removeValue()
        }
    }

    
    func appendToMusicVoteArray(from: String) {
        for music in musicPlaylist {
            if music.persistentID.description == from {
                if let artist = music.artist {
                    if let title = music.title {
                        let persistentID = music.persistentID.description
                        let music = Music(
                            persistID: persistentID,
                            artist: artist,
                            title: title,
                            imageLocation: nil
                        )
                        musicVotedArray.append(music)
                    }
                }
            }
        }
    }
    
    // MARK: - Vote Engine (Database)
    func setMusicUpForVote() {
        musicUpForVote = []
        let maxScore = songsPlayed + minimumSongsBetweenSongs + 1
        for song in musicPlaylistOrder {
            if song.value <= maxScore {
                musicUpForVote.append(song.key)
                appendToMusicVoteArray(from: song.key)
            }
        }
        removeDatabaseValues(at: .status)
        removeDatabaseValues(at: .voting)
        let eventInFirebase = DataService.connect.REF_EVENTS.child(eventID).child("status")
        eventInFirebase.child("0").setValue("votingSet")
        
    }
    
    func checkIfValueExist(persistID: String,_ value: String = "imageLocation") {
        let ref = DataService.connect.REF_EVENTS.child(eventID).child("playlist")
        ref.child(persistID).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(value){
                print("this value exist")
            } else {
                print("imageIsNotThere")
                for music in self.musicPlaylist {
                    if music.persistentID.description == persistID {
                        let image = music.artwork?.image(at: CGSize(width: 100, height: 100))
                        self.postImageToFirebase(image: image, persistID: persistID)
                        print(persistID)
                    }
                }
            }
        })
    }
    
    func postImageToFirebase(image: UIImage?, persistID: String) {
        if let img = image {
            if let imgData = UIImageJPEGRepresentation(img, 0.4) {
                // Unique image identifier
                let imageUID = NSUUID().uuidString
                // Set metaData for the image
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                
                let storageREF = DataService.connect.REF_MUSIC_IMAGES.child("\(imageUID).jpg")
                storageREF.putData(imgData, metadata: metadata) { (metadata, error) in
                    if error != nil {
                        print("Unable to upload image to Firebase storage")
                    } else {
                        print("postImageToFirebase: Successfully uploaded image to Firebase storage")

                        storageREF.downloadURL { (url, err) in
                            if let absoluteUrlString = url?.absoluteString {
                                print(absoluteUrlString)
                                let imageLocationInPersistID : [String : String] = [
                                    "imageLocation" : absoluteUrlString]
                                
                                let databaseREF = DataService.connect.REF_EVENTS.child(eventID).child("playlist").child(persistID)
                                databaseREF.updateChildValues(imageLocationInPersistID)
                                
                                print(imageLocationInPersistID)
                            } else {
                                print("unable to get imageLocation")
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
    func sendMusicUpForVote() {
        var tempMusicUpForVote = [String]()
        let eventInFirebase = DataService.connect.REF_EVENTS.child(eventID).child("voting")
        for _ in 0...3 {
            let randomIndex = arc4random_uniform(UInt32(musicUpForVote.count) - 1)
            let persistID = musicUpForVote[Int(randomIndex)]
            musicUpForVote.remove(at: Int(randomIndex))
            eventInFirebase.child(persistID).child("first").setValue(true)
            self.checkIfValueExist(persistID: persistID)
            tempMusicUpForVote.append(persistID)
        }
        musicUpForVote = tempMusicUpForVote
    }
    
    func votingStarted() {
        let eventInFirebase = DataService.connect.REF_EVENTS.child(eventID).child("status")
        eventInFirebase.child("1").setValue("votingStarted")
    }
    
    func votingEnded() {
        let eventInFirebase = DataService.connect.REF_EVENTS.child(eventID).child("status")
        eventInFirebase.child("2").setValue("votingEnded")
        setVoteCountToMusicVoteArray()
    }
    
    func getMusicWinner() {
        getVoteWinnerFromMusicVoteArray()
    }
    
    func setMusicWinner(){
        let eventInFirebase = DataService.connect.REF_EVENTS.child(eventID).child("status")
        eventInFirebase.child("3").setValue("votingWinner")
    }
    
    func playMusicWinner() {
        let eventInFirebase = DataService.connect.REF_EVENTS.child(eventID).child("status")
        eventInFirebase.child("4").setValue("votingWinnerPlaying")
        removeDatabaseValues(at: .voting)
        removeDatabaseValues(at: .status)
        musicVotedArray.removeAll()
        let collection = MPMediaItemCollection(items: musicPlaylist)
        if let winnerID = musicWinnerID {
            musicPlayer.nowPlayingItem = collection.items[getIndex(from: winnerID)]
            self.scrollToIndex(at: self.getIndex(from: winnerID), select: true, andDeselectRow: true)
            musicWinnerID = nil
            playAction()
        } else {
            musicPlayer.skipToNextItem()
            playAction()
            changedNowPlaying()
        }
    }
    
    func setVoteCountToMusicVoteArray() {
        for (i, music) in musicVotedArray.enumerated() {
            let eventInFirebase = DataService.connect.REF_EVENTS.child(eventID).child("voting").child(music.persistID)
            eventInFirebase.observeSingleEvent(of: .value, with: { (snapshot) in
                let count = Int(snapshot.childrenCount)
                print(count)
                self.musicVotedArray[i].votes = count
            })
        }
    }
    
    func getVoteWinnerFromMusicVoteArray() {
        var voteCount: Int = 0
        print(musicVotedArray.count)
        for music in musicVotedArray {
            if let vote = music.votes {
                if vote >= voteCount {
                    voteCount = music.votes!
                    self.musicWinnerID = music.persistID
                }
            }
        }
        musicVotedArray.removeAll()
    }
    
    // MARK: - Timer Engine
    func setMusicTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCommandsInTime), userInfo: nil, repeats: true)
        updateMusicTimer()
        musicProgress.setProgress(0.0, animated: false)
    }
    
    func updateMusicTimer() {
        if timer.isValid {
            timeCurrent = timeFull - timeLeft
            timeLeft = Int(musicPlayer.currentPlaybackTime)
            timeFull = Int((musicPlayer.nowPlayingItem?.playbackDuration)!)
            musicProgress.setProgress(0.0, animated: false)
            progressStep = 1.0 / Float(timeFull)
            progressCurrent = 0.0
        } else {
            setMusicTimer()
        }
    }
    
    func updateTitle() {
        self.artistLabel.rotation = timeCurrent
        self.titleLabel.rotation = -timeCurrent
    }
    
    @objc func updateCommandsInTime() {
        print("updateCommand")
        updateTitle()
        progressCurrent += progressStep
        musicProgress.setProgress(progressCurrent, animated: true)
        timeCurrent = Int(musicPlayer.currentPlaybackTime)
        timeLeft = timeFull - timeCurrent
        print(timeLeft)
        if timeLeft == 195 {
            setMusicUpForVote()
        }
        if timeLeft == 194 {
            sendMusicUpForVote()
        }
        if timeLeft == 190 {
            votingStarted()
        }
        if timeLeft == 178 {
            votingEnded()
        }
        if timeLeft == 175 {
            getMusicWinner()
        }
        if timeLeft == 172 {
            setMusicWinner()
        }
        if timeLeft == 170 {
            if let winnerID = self.musicWinnerID {
                self.scrollToIndex(at: self.getIndex(from: winnerID), select: false, andDeselectRow: false)
            }
        }
        if timeLeft == 165 {
            musicProgress.setProgress(0.0, animated: false)
            playMusicWinner()
        }
    }
    
    // MARK: - Check & Get Tools
    func getIndex(from persistID: String) -> Int {
        var index: Int = 0
        for song in musicPlaylist {
            if persistID == String(song.persistentID) {
                index = musicPlaylist.index(of: song)!
            }
        }
        return index
    }
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        for item in mediaItemCollection.items {
            musicPlaylist.append(item)
            if let artist = item.artist {
                if let title = item.title {
                    
                    let songInfo: [String: String] = [
                        "Artist": artist,
                        "Title": title
                    ]
                    let persistIDString = String(item.persistentID)
                    let eventInFirebase = DataService.connect.REF_EVENTS.child(eventID)
                    eventInFirebase.child("playlist").child(persistIDString).setValue(songInfo)
                    
                    let maxScore = songsPlayed + minimumSongsBetweenSongs
                    musicPlaylistOrder.updateValue(maxScore, forKey: persistIDString)
                }
            }
        }
        musicPlayer.setQueue(with: mediaItemCollection)
        musicPlayer.prepareToPlay()
        pauseAction()
        tableView.reloadData()
        mediaPicker.dismiss(animated: true, completion: nil)
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true, completion: nil)
    }
    
    private func setProgress(progress: Float = 1.0, animated: Bool = true, alpha: CGFloat = 1.0) {
        if let progressView = self.playlistProgress {
            if animated {
                progressView.setProgress(progress, animated: animated)
                UIView.animate(withDuration: 0.90, delay: 0.75, usingSpringWithDamping: 0.70, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
                    progressView.alpha = alpha
                })
            } else {
                progressView.setProgress(progress, animated: animated)
                progressView.alpha = alpha
            }
        }
    }
    
    var remoteMiniMized = true
    var remoteMidiMized = false
    var scrollActive = false
    
    func maxiMizeRemote() {
        self.tableBackView.frame = CGRect(x: 0, y: 68, width: 375, height: 601)
    }
    
    func midiMizeRemote() {
        hapticButton(.medium)
        // SHOW REMOTE
        // -----------
        UIView.animate(withDuration: 0.58, delay: 0.00, usingSpringWithDamping: 0.50, initialSpringVelocity: 0.34, options: .curveEaseOut, animations: {
            self.tableBackView.frame = CGRect(x: 0, y: 339, width: 375, height: 330)
            self.tableBackView.layer.cornerRadius = 28
        })
        setProgress(progress: 0.9, animated: true, alpha: 1.0)
        self.remoteMiniMized = false
        self.remoteMidiMized = true
        UIView.animate(withDuration: 0.71, delay: 0.034, usingSpringWithDamping: 0.50, initialSpringVelocity: 0.34, options: .curveEaseOut, animations: {
            
        })
        setProgress(progress: 1.0, animated: true, alpha: 0.0)
    }
    
    func miniMizeRemote() {
        hapticButton(.medium)
        // SHOW REMOTE
        // -----------
        UIView.animate(withDuration: 0.58, delay: 0.00, usingSpringWithDamping: 0.50, initialSpringVelocity: 0.34, options: .curveEaseOut, animations: {
            self.tableBackView.frame = CGRect(x: 0, y: 564, width: 375, height: 105)
            self.tableBackView.layer.cornerRadius = 28
        })
        
        setProgress(progress: 0.5, animated: true, alpha: 1.0)
        self.remoteMiniMized = true
        self.remoteMidiMized = false
        UIView.animate(withDuration: 0.71, delay: 0.034, usingSpringWithDamping: 0.50, initialSpringVelocity: 0.34, options: .curveEaseOut, animations: {
            
        })
        setProgress(progress: 0.0, animated: true, alpha: 0.0)
    }
    
    func basicSetup() {
        
        self.playlistProgress.backgroundColor = UIColor.clear
        self.playlistProgress.layer.shadowColor = PINK_DARK_SOLID.cgColor
        self.playlistProgress.layer.shadowOffset = CGSize(width: 1.3, height: 5.8)
        self.playlistProgress.layer.shadowOpacity = 0.95
        self.playlistProgress.layer.shadowRadius = 11.0
        
        self.musicProgress.backgroundColor = UIColor.clear
        self.musicProgress.layer.shadowColor = PINK_DARK_SOLID.cgColor
        self.musicProgress.layer.shadowOffset = CGSize(width: 1.3, height: 5.8)
        self.musicProgress.layer.shadowOpacity = 0.95
        self.musicProgress.layer.shadowRadius = 11.0
    }
    
    func setupFDWave() {
        if let playingURL = musicPlayer.nowPlayingItem?.assetURL {
            // Animate the waveform view in when it is rendered
            fdWaveFormView.delegate = self
            fdWaveFormView.alpha = 0.0
            fdWaveFormView.audioURL = playingURL
            fdWaveFormView.zoomSamples = 0 ..< fdWaveFormView.totalSamples / 3
            fdWaveFormView.doesAllowScrubbing = true
            fdWaveFormView.doesAllowStretch = true
            fdWaveFormView.doesAllowScroll = true
        }
    }
    
    func showFDWave() {
        UIView.animate(withDuration: 0.3, animations: {
            print(self.fdWaveFormView.totalSamples)
            let random = Int(arc4random()) % self.fdWaveFormView.totalSamples
            self.fdWaveFormView.highlightedSamples = 0 ..< random
        })
    }
    
    // MARK: - Actions
    
    @IBAction func browseAction(_ sender: Any) {
        let mediaPickerVC = MPMediaPickerController(mediaTypes: .music)
        mediaPickerVC.allowsPickingMultipleItems = true
        mediaPickerVC.popoverPresentationController?.sourceView = view
        mediaPickerVC.delegate = self
        present(mediaPickerVC, animated: true, completion: nil)
    }
    
    @IBAction func resetPlaylistAction(_ sender: Any) {
        musicPlaylist.removeAll()
        musicPlaylistOrder.removeAll()
        
        tableView.reloadData()
    }
    
    
    @IBAction func playButton(_ sender: Any) {
        if musicPlayer.playbackState == .paused {
            playAction()
        } else {
            pauseAction()
        }
    }
    

    
    @IBAction func nextAction(_ sender: Any) {
        musicPlayer.skipToNextItem()
        nowPlaying()
        updateMusicTimer()
    }
    
    @IBAction func previousAction(_ sender: Any) {
        musicPlayer.skipToPreviousItem()
        nowPlaying()
        updateMusicTimer()
    }
    
    @IBAction func shuffleAction(_ sender: UIButton) {
        setupFDWave()
    }
    

    
    
    @IBAction func showRemoteAction(_ sender: UIButton) {
        setProgress(progress: 0.4, animated: true, alpha: 0.8)
        // self.tableBackView.transform
        if self.remoteMiniMized {
            self.midiMizeRemote()
        } else if self.remoteMidiMized {
            self.miniMizeRemote()
        }
    }
    
    @IBAction func tapCoverImage(_ sender: UITapGestureRecognizer) {
        if self.remoteMidiMized {
            self.miniMizeRemote()
        } else if self.remoteMiniMized {
            self.midiMizeRemote()
        }
    }
}

extension PlayViewController : UIScrollViewDelegate {
    // Search for: scrollViewDidScroll UIVisualEffect
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == self.scrollView {
            let contentOffset = scrollView.contentOffset.y < 0 ? -scrollView.contentOffset.y : scrollView.contentOffset.y
            let scaleMIN:CGFloat = 1.0
            let scaleMAX = (contentOffset * 0.00100) + (scaleMIN - 0.00100)
            self.coverImageView.transform = CGAffineTransform(scaleX: scaleMAX, y: scaleMAX)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("scrollViewWillBeginDragging")
        self.scrollActive = true
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print("scrollViewWillEndDragging: \(velocity) with -80 in offset ")
        
        if scrollView == self.scrollView {
            if scrollView.contentOffset.y <= -80 {
                if self.scrollActive {
                    self.miniMizeRemote()
                }
            } else if scrollView.contentOffset.y >= 80 {
                if self.scrollActive {
                    self.midiMizeRemote()
                }
            }
            self.scrollActive = false
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("scrollViewDidEndDragging")
        print("decelerate: \(decelerate)")
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewWillBeginDecelerating")
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // self.scrollContentOffset = 0.0
        if scrollView.contentOffset.y <= -80 {
            print("scrollViewDidEndDecelerating and -80 y. offset")
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print("scrollViewDidEndScrollingAnimation")
    }
    
}

extension PlayViewController: UITableViewDataSource, UITableViewDelegate {
    
    func scrollToIndex(at: Int, select: Bool, andDeselectRow: Bool) {
        let winnerIndex = IndexPath(row: at, section: 0)
        if select { self.tableView.selectRow(at: winnerIndex, animated: true, scrollPosition: .middle)
            if andDeselectRow { self.tableView.deselectRow(at: winnerIndex, animated: true) }
        } else if andDeselectRow { self.tableView.deselectRow(at: winnerIndex, animated: true) } else {
            self.tableView.scrollToRow(at: winnerIndex, at: UITableViewScrollPosition.middle, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath) as? MusicPlaylistTableViewCell {
            let item = musicPlaylist[indexPath.row]
            cell.loadData(from: item)
            return cell
        } else {
            return MusicPlaylistTableViewCell()
        }
    }
    
    func changedNowPlaying() {
        musicVotedArray.removeAll()
        removeDatabaseValues(at: .status)
        removeDatabaseValues(at: .voting)
        if let persistID = musicPlayer.nowPlayingItem?.persistentID.description {
            checkIfValueExist(persistID: persistID)
            let eventInFirebase = DataService.connect.REF_EVENTS.child(eventID).child("status")
            eventInFirebase.child("5").setValue(persistID)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.setProgress(progress: 0.3, animated: true, alpha: 1.0)
        // musicPlayer.setQueue(with: MPMediaItemCollection(items: musicPlaylist))
        let collection = MPMediaItemCollection(items: musicPlaylist)
        musicPlayer.nowPlayingItem = collection.items[indexPath.row]
        playAction()
        changedNowPlaying()
        tableView.deselectRow(at: indexPath, animated: true)
        self.setProgress(progress: 1.0, animated: true, alpha: 0.0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicPlaylist.count
    }
}

extension PlayViewController: FDWaveformViewDelegate {
    func waveformViewWillRender(_ waveformView: FDWaveformView) {
        startRendering = Date()
    }
    
    func waveformViewDidRender(_ waveformView: FDWaveformView) {
        endRendering = Date()
        NSLog("FDWaveformView rendering done, took %0.3f seconds", endRendering.timeIntervalSince(startRendering))
        profileResult.append(String(format: " render %0.3f ", endRendering.timeIntervalSince(startRendering)))
        UIView.animate(withDuration: 0.25, animations: {() -> Void in
            waveformView.alpha = 1.0
        })
    }
    
    func waveformViewWillLoad(_ waveformView: FDWaveformView) {
        startLoading = Date()
    }
    
    func waveformViewDidLoad(_ waveformView: FDWaveformView) {
        endLoading = Date()
        NSLog("FDWaveformView loading done, took %0.3f seconds", endLoading.timeIntervalSince(startLoading))
        profileResult.append(String(format: " load %0.3f ", endLoading.timeIntervalSince(startLoading)))
    }
}
