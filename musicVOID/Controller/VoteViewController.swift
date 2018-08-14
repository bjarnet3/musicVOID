//
//  VoteViewController.swift
//  musicVOID
//
//  Created by Bjarne Tvedten on 28.04.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit
import Firebase
import MBCircularProgressBar

class VoteViewController: UIViewController {
    
    // MARK: - Outlet Properties
    @IBOutlet weak var nowPlayingImageView: UIImageView!
    @IBOutlet weak var nowPlayingArtistLabel: UILabel!
    @IBOutlet weak var nowPlayingTitleLabel: UILabel!
    
    @IBOutlet weak var vote1SuperView: UIView!
    @IBOutlet weak var vote2SuperView: UIView!
    @IBOutlet weak var vote3SuperView: UIView!
    @IBOutlet weak var vote4SuperView: UIView!
    
    @IBOutlet weak var vote1View: MBCircularProgressBarView!
    @IBOutlet weak var vote2View: MBCircularProgressBarView!
    @IBOutlet weak var vote3View: MBCircularProgressBarView!
    @IBOutlet weak var vote4View: MBCircularProgressBarView!
    
    @IBOutlet weak var vote1Image: UIImageView!
    @IBOutlet weak var vote2Image: UIImageView!
    @IBOutlet weak var vote3Image: UIImageView!
    @IBOutlet weak var vote4Image: UIImageView!
    
    @IBOutlet weak var voteSwitch: UISwitch!
    
    // MARK: - Basic Properties and Array
    var musicPlaylistArray = [Music]()
    var musicVotedArray = [Music]()
    
    // var musicVoteCountPossible = 4
    var musicWinnerID: String? = nil
    var canVote: Bool = false
    var voteCasted = 0
    
    // var timer = Timer()
    
    // var artistString = "Welcome to Hey-DJ!   "
    // var titleString = "   Vote on favorite song   "
    
    /*
     func setTimer() {
     timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(titleBoard), userInfo: nil, repeats: true)
     }
     
     @objc func titleBoard() {
     let lastFirst = self.artistString.characters.first
     self.artistString.characters.removeFirst()
     self.artistString.characters.append(lastFirst!)
     self.nowPlayingArtistLabel.text = self.artistString
     
     let firstLast = self.titleString.characters.first
     self.titleString.characters.removeFirst()
     self.titleString.characters.append(firstLast!)
     self.nowPlayingTitleLabel.text = self.titleString
     }
     */
    
    func voteViewImage(num: Int) -> UIImageView {
        switch num {
        case 0:
            return vote1Image
        case 1:
            return vote2Image
        case 2:
            return vote3Image
        default:
            return vote4Image
        }
    }
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.vote1Image.layer.cornerRadius = vote1Image.layer.frame.height / 2
        self.vote1Image.layer.borderWidth = 1.0
        self.vote1Image.layer.borderColor = hexStringToUIColor("000000", 1.0).cgColor
        
        self.vote2Image.layer.cornerRadius = vote2Image.layer.frame.height / 2
        self.vote2Image.layer.borderWidth = 1.0
        self.vote2Image.layer.borderColor = hexStringToUIColor("000000", 1.0).cgColor
        
        self.vote3Image.layer.cornerRadius = vote3Image.layer.frame.height / 2
        self.vote3Image.layer.borderWidth = 1.0
        self.vote3Image.layer.borderColor = hexStringToUIColor("000000", 1.0).cgColor
        
        self.vote4Image.layer.cornerRadius = vote4Image.layer.frame.height / 2
        self.vote4Image.layer.borderWidth = 1.0
        self.vote4Image.layer.borderColor = hexStringToUIColor("000000", 1.0).cgColor
        
        observeDatabaseOneTime()
        resetVoteView(true, false, false)
        hideVoteSuperView(hide: true, animate: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let tab = self.tabBarController?.tabBar as? FrostyTabBar {
            tab.setEffect(blurEffect: .light)
        }
    }
    
    // MARK: - Vote View Functions
    func vote(voteValue: CGFloat, voteSuper: UIView, voteView: MBCircularProgressBarView, voteImageView: UIImageView, animate: Bool = false) {
        removeParallaxEffectOnView(voteSuper)
        let value = 80 + (voteValue * 1.65)
        if animate {
            UIView.animate(withDuration: 0.65, delay: 0.055, usingSpringWithDamping: 0.55, initialSpringVelocity: 0.6, options: .curveEaseOut, animations: {
                voteSuper.bounds = CGRect(x: 0, y: 0, width: value, height: value)
                voteView.frame = CGRect(x: 0, y: 0, width: value, height: value)
                voteImageView.frame = CGRect(x: (value / 10) / 2, y: (value / 10) / 2, width: value - ((value / 10)), height: value - (value / 10))
                voteImageView.layer.cornerRadius = ((value - (value / 10)) / 2 )
                addParallaxEffectOnView(voteSuper, Int(value * 0.25))
            })
            UIView.animate(withDuration: 0.65, delay: 0.055, options: .curveEaseOut, animations: {
                voteView.value = voteValue
            })
        } else {
            // voteSuper.frame = CGRect(x: voteSuper.frame.origin.x, y: voteSuper.frame.origin.y, width: value, height: value)
            voteSuper.bounds = CGRect(x: 0, y: 0, width: value, height: value)
            voteView.frame = CGRect(x: 0, y: 0, width: value, height: value)
            voteImageView.frame = CGRect(x: (value / 10) / 2, y: (value / 10) / 2, width: value - ((value / 10)), height: value - (value / 10))
            voteImageView.layer.cornerRadius = ((value - (value / 10)) / 2 )
            addParallaxEffectOnView(voteSuper, Int(value * 0.25))
        }
    }
    
    func voteRandom() {
        var voteValue = [CGFloat]()
        var lastValue: CGFloat = 100.0
        for _ in 0...3 {
            if lastValue <= 0.0 {
                voteValue.append(0)
            } else {
                let random = CGFloat(arc4random_uniform(UInt32(lastValue) + 1))
                print(random)
                voteValue.append(random)
                lastValue -= random
            }
            voteValue.shuffle()
        }
        self.vote(voteValue: voteValue[0], voteSuper: vote1SuperView, voteView: vote1View, voteImageView: vote1Image, animate: true)
        self.vote(voteValue: voteValue[1], voteSuper: vote2SuperView, voteView: vote2View, voteImageView: vote2Image, animate: true)
        self.vote(voteValue: voteValue[2], voteSuper: vote3SuperView, voteView: vote3View, voteImageView: vote3Image, animate: true)
        self.vote(voteValue: voteValue[3], voteSuper: vote4SuperView, voteView: vote4View, voteImageView: vote4Image, animate: true)
    }
    
    func resetLocation(_ superViewSize: Int = 100,_ imageViewSize: Int = 80) {
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        let imageViewOffset = (superViewSize - imageViewSize) / 2
        
        vote1SuperView.center = CGPoint(x: screenWidth * 0.28, y: screenHeight * 0.28)
        vote1SuperView.bounds = CGRect(x: 0, y: 0, width: superViewSize, height: superViewSize)
        vote1View.frame = CGRect(x: 0, y: 0, width: superViewSize, height: superViewSize)
        vote1Image.frame = CGRect(x: imageViewOffset, y: imageViewOffset, width: imageViewSize, height: imageViewSize)
        vote1Image.layer.cornerRadius = vote1Image.frame.height / 2
        addParallaxEffectOnView(vote1SuperView, 0)
        
        vote2SuperView.center = CGPoint(x: screenWidth * 0.28, y: screenHeight * 0.60)
        vote2SuperView.bounds = CGRect(x: 0, y: 0, width: superViewSize, height: superViewSize)
        vote2View.frame = CGRect(x: 0, y: 0, width: superViewSize, height: superViewSize)
        vote2Image.frame = CGRect(x: imageViewOffset, y: imageViewOffset, width: imageViewSize, height: imageViewSize)
        vote2Image.layer.cornerRadius = vote2Image.frame.height / 2
        addParallaxEffectOnView(vote2SuperView, 0)
        
        vote3SuperView.center = CGPoint(x: screenWidth * 0.72, y: screenHeight * 0.28)
        vote3SuperView.bounds = CGRect(x: 0, y: 0, width: superViewSize, height: superViewSize)
        vote3View.frame = CGRect(x: 0, y: 0, width: superViewSize, height: superViewSize)
        vote3Image.frame = CGRect(x: imageViewOffset, y: imageViewOffset, width: imageViewSize, height: imageViewSize)
        vote3Image.layer.cornerRadius = vote3Image.frame.height / 2
        addParallaxEffectOnView(vote3SuperView, 0)
        
        vote4SuperView.center = CGPoint(x: screenWidth * 0.72, y: screenHeight * 0.60)
        vote4SuperView.bounds = CGRect(x: 0, y: 0, width: superViewSize, height: superViewSize)
        vote4View.frame = CGRect(x: 0, y: 0, width: superViewSize, height: superViewSize)
        vote4Image.frame = CGRect(x: imageViewOffset, y: imageViewOffset, width: imageViewSize, height: imageViewSize)
        vote4Image.layer.cornerRadius = vote4Image.frame.height / 2
        addParallaxEffectOnView(vote4SuperView, 0)
    }
    
    func hideVoteSuperView(hide: Bool = true, animate: Bool = false) {
        if animate {
            if hide {
                UIView.animate(withDuration: 0.65, delay: 0.055, usingSpringWithDamping: 0.55, initialSpringVelocity: 0.6, options: .curveEaseOut, animations: {
                    self.vote1SuperView.alpha = 0.0
                    self.vote2SuperView.alpha = 0.0
                    self.vote3SuperView.alpha = 0.0
                    self.vote4SuperView.alpha = 0.0
                }, completion: { (true) in
                    self.vote1SuperView.isHidden = true
                    self.vote2SuperView.isHidden = true
                    self.vote3SuperView.isHidden = true
                    self.vote4SuperView.isHidden = true
                })
            } else {
                self.vote1SuperView.isHidden = false
                self.vote2SuperView.isHidden = false
                self.vote3SuperView.isHidden = false
                self.vote4SuperView.isHidden = false
                UIView.animate(withDuration: 0.65, delay: 0.055, usingSpringWithDamping: 0.55, initialSpringVelocity: 0.6, options: .curveEaseOut, animations: {
                    self.vote1SuperView.alpha = 1.0
                    self.vote2SuperView.alpha = 1.0
                    self.vote3SuperView.alpha = 1.0
                    self.vote4SuperView.alpha = 1.0
                })
            }
        } else {
            self.vote1SuperView.isHidden = hide
            self.vote2SuperView.isHidden = hide
            self.vote3SuperView.isHidden = hide
            self.vote4SuperView.isHidden = hide
        }
    }
    
    func resetVoteView(_ animate: Bool = false,_ showValueString: Bool = false,_ readyToVote: Bool = false) {
        removeParallaxEffectOnView(vote1SuperView)
        removeParallaxEffectOnView(vote2SuperView)
        removeParallaxEffectOnView(vote3SuperView)
        removeParallaxEffectOnView(vote4SuperView)
        if animate {
            UIView.animate(withDuration: 0.65, delay: 0.055, options: .curveEaseOut, animations: {
                if showValueString {
                    self.vote1View.showValueString = true
                    self.vote2View.showValueString = true
                    self.vote3View.showValueString = true
                    self.vote4View.showValueString = true
                }
                self.vote1View.value = 0
                self.vote2View.value = 0
                self.vote3View.value = 0
                self.vote4View.value = 0
            })
            UIView.animate(withDuration: 0.65, delay: 0.055, usingSpringWithDamping: 0.55, initialSpringVelocity: 0.6, options: .curveEaseOut, animations: {
                if readyToVote {
                    self.resetLocation(120, 100)
                } else {
                    self.resetLocation()
                }
            })
        } else {
            if showValueString {
                self.vote1View.showValueString = true
                self.vote2View.showValueString = true
                self.vote3View.showValueString = true
                self.vote4View.showValueString = true
            }
            self.vote1View.value = 0
            self.vote2View.value = 0
            self.vote3View.value = 0
            self.vote4View.value = 0
            if readyToVote {
                self.resetLocation(120, 100)
            } else {
                self.resetLocation()
            }
        }
    }
    
    func setVoteView(_ artist: String? = nil,_ title: String? = nil, imageLocation: String?, voteImageView: UIImageView, index: Int? = nil) {
        // self.artistLabel.text = artist
        // self.titleLabel.text = title
        if let imageURL = imageLocation, imageLocation != nil {
            let ref = Storage.storage().reference(forURL: imageURL)
            ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                } else {
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            voteImageView.image = img
                            self.animateVote(at: index!, scaleFactor: 1.3, castVote: false)
                        }
                    }
                }
            })
        } else {
            voteImageView.image = UIImage(named: "40B52118-FA0A-4978-8A6F-47A5E2137F95")
        }
    }
    
    func setVoteImageView() {
        for (i, val) in musicVotedArray.enumerated() {
            setVoteView(imageLocation: val.imageLocation, voteImageView: voteViewImage(num: i), index: i)
        }
    }
    
    // MARK: - Actions
    @IBAction func voteAction(_ sender: Any) {
        voteRandom()
    }
    
    @IBAction func resetAction(_ sender: Any) {
        self.resetVoteView(true)
    }
    
    @IBAction func voteSwitchAction(_ sender: Any) {
        if voteSwitch.isOn {
            observeStatusInVoting()
        } else {
            DataService.connect.REF_EVENTS.child(eventID).child("voting").removeAllObservers()
        }
    }
    
    func animateVote(at: Int, scaleFactor: CGFloat = 0.7, castVote: Bool = false) {
        if castVote {
            self.castVoteToIndex(at: at)
        }
        switch at {
        case 0:
            hapticButton(.selection)
            let superViewBounds = vote1SuperView.bounds
            let superViewCenter = vote1SuperView.center
            let viewFrame = vote1View.frame
            let imageFrame = vote1Image.frame
            
            UIView.animate(withDuration: 0.12, delay: 0.0, options: .curveEaseOut, animations: {
                self.vote1SuperView.alpha = 1
                self.vote1SuperView.bounds = CGRect(x: 0, y: 0, width: superViewBounds.width * scaleFactor, height: superViewBounds.height * scaleFactor)
                self.vote1SuperView.center = superViewCenter
                self.vote1View.frame = CGRect(x: 0, y: 0, width: viewFrame.width * scaleFactor, height: viewFrame.height * scaleFactor)
                self.vote1Image.frame = CGRect(x:imageFrame.origin.x * scaleFactor, y: imageFrame.origin.y * scaleFactor, width: imageFrame.width * scaleFactor, height: imageFrame.height * scaleFactor)
                self.vote1Image.layer.cornerRadius = (imageFrame.height * scaleFactor) / 2
            }, completion: { (animation) in
                UIView.animate(withDuration: 0.22, delay: 0.0, usingSpringWithDamping: 0.68, initialSpringVelocity: 0.9, options: .curveEaseOut, animations: {
                    self.vote1SuperView.bounds = superViewBounds
                    self.vote1SuperView.center = superViewCenter
                    self.vote1View.frame = viewFrame
                    self.vote1Image.frame = imageFrame
                    self.vote1Image.layer.cornerRadius = imageFrame.height / 2
                })
            })
        case 1:
            hapticButton(.selection)
            let superViewBounds = vote2SuperView.bounds
            let superViewCenter = vote2SuperView.center
            let viewFrame = vote2View.frame
            let imageFrame = vote2Image.frame
            
            UIView.animate(withDuration: 0.12, delay: 0.0, options: .curveEaseOut, animations: {
                self.vote2SuperView.alpha = 1
                self.vote2SuperView.bounds = CGRect(x: 0, y: 0, width: superViewBounds.width * scaleFactor, height: superViewBounds.height * scaleFactor)
                self.vote2SuperView.center = superViewCenter
                self.vote2View.frame = CGRect(x: 0, y: 0, width: viewFrame.width * scaleFactor, height: viewFrame.height * scaleFactor)
                self.vote2Image.frame = CGRect(x:imageFrame.origin.x * scaleFactor, y: imageFrame.origin.y * scaleFactor, width: imageFrame.width * scaleFactor, height: imageFrame.height * scaleFactor)
                self.vote2Image.layer.cornerRadius = (imageFrame.height * scaleFactor) / 2
            }, completion: { (animation) in
                UIView.animate(withDuration: 0.22, delay: 0.0, usingSpringWithDamping: 0.68, initialSpringVelocity: 0.9, options: .curveEaseOut, animations: {
                    self.vote2SuperView.bounds = superViewBounds
                    self.vote2SuperView.center = superViewCenter
                    self.vote2View.frame = viewFrame
                    self.vote2Image.frame = imageFrame
                    self.vote2Image.layer.cornerRadius = imageFrame.height / 2
                })
            })
        case 2:
            hapticButton(.selection)
            let superViewBounds = vote3SuperView.bounds
            let superViewCenter = vote3SuperView.center
            let viewFrame = vote3View.frame
            let imageFrame = vote3Image.frame
            UIView.animate(withDuration: 0.12, delay: 0.0, options: .curveEaseOut, animations: {
                self.vote3SuperView.alpha = 1
                self.vote3SuperView.bounds = CGRect(x: 0, y: 0, width: superViewBounds.width * scaleFactor, height: superViewBounds.height * scaleFactor)
                self.vote3SuperView.center = superViewCenter
                self.vote3View.frame = CGRect(x: 0, y: 0, width: viewFrame.width * scaleFactor, height: viewFrame.height * scaleFactor)
                self.vote3Image.frame = CGRect(x:imageFrame.origin.x * scaleFactor, y: imageFrame.origin.y * scaleFactor, width: imageFrame.width * scaleFactor, height: imageFrame.height * scaleFactor)
                self.vote3Image.layer.cornerRadius = (imageFrame.height * scaleFactor) / 2
            }, completion: { (animation) in
                UIView.animate(withDuration: 0.22, delay: 0.0, usingSpringWithDamping: 0.68, initialSpringVelocity: 0.9, options: .curveEaseOut, animations: {
                    self.vote3SuperView.bounds = superViewBounds
                    self.vote3SuperView.center = superViewCenter
                    self.vote3View.frame = viewFrame
                    self.vote3Image.frame = imageFrame
                    self.vote3Image.layer.cornerRadius = imageFrame.height / 2
                })
            })
        case 3:
            hapticButton(.selection)
            let superViewBounds = vote4SuperView.bounds
            let superViewCenter = vote4SuperView.center
            let viewFrame = vote4View.frame
            let imageFrame = vote4Image.frame
            UIView.animate(withDuration: 0.12, delay: 0.0, options: .curveEaseOut, animations: {
                self.vote4SuperView.alpha = 1
                self.vote4SuperView.bounds = CGRect(x: 0, y: 0, width: superViewBounds.width * scaleFactor, height: superViewBounds.height * scaleFactor)
                self.vote4SuperView.center = superViewCenter
                self.vote4View.frame = CGRect(x: 0, y: 0, width: viewFrame.width * scaleFactor, height: viewFrame.height * scaleFactor)
                self.vote4Image.frame = CGRect(x:imageFrame.origin.x * scaleFactor, y: imageFrame.origin.y * scaleFactor, width: imageFrame.width * scaleFactor, height: imageFrame.height * scaleFactor)
                self.vote4Image.layer.cornerRadius = (imageFrame.height * scaleFactor) / 2
            }, completion: { (animation) in
                UIView.animate(withDuration: 0.22, delay: 0.0, usingSpringWithDamping: 0.68, initialSpringVelocity: 0.9, options: .curveEaseOut, animations: {
                    self.vote4SuperView.bounds = superViewBounds
                    self.vote4SuperView.center = superViewCenter
                    self.vote4View.frame = viewFrame
                    self.vote4Image.frame = imageFrame
                    self.vote4Image.layer.cornerRadius = imageFrame.height / 2
                })
            })
        default:
            print("ERROR")
        }
    }
    
    @IBAction func vote1Action(_ sender: Any) {
        animateVote(at: 0, castVote: true)
    }
    
    @IBAction func vote2Action(_ sender: Any) {
        animateVote(at: 1, castVote: true)
    }
    
    @IBAction func vote3Action(_ sender: Any) {
        animateVote(at: 2, castVote: true)
    }
    
    @IBAction func vote4Action(_ sender: Any) {
        animateVote(at: 3, castVote: true)
    }
    
    // MARK: - Music Array Functions
    func castVoteToIndex(at: Int) {
        if self.canVote {
            let persistID = musicVotedArray[at].persistID
            let voting = DataService.connect.REF_EVENTS.child(eventID).child("voting").child(persistID)
            let myVote = [userID:true]
            voting.updateChildValues(myVote)
            self.canVote = false
        }
    }
    
    func appendToMusicVoteArray(from: String) {
        for music in musicPlaylistArray {
            if music.persistID == from {
                musicVotedArray.append(music)
            }
        }
    }
    
    func setVoteCountToMusicVoteArray() {
        for (i, music) in musicVotedArray.enumerated() {
            let eventInFirebase = DataService.connect.REF_EVENTS.child(eventID).child("voting").child(music.persistID)
            eventInFirebase.observeSingleEvent(of: .value, with: { (snapshot) in
                let count = Int(snapshot.childrenCount)
                self.musicVotedArray[i].votes = count
            })
        }
    }
    
    func getVoteCountFromMusicVoteArray() {
        var voteCount: CGFloat = 0.0
        var voteTotalValue: CGFloat = 0.0
        var voteValue = [CGFloat]()
        for music in musicVotedArray {
            let result = music.votes! - 1
            voteCount += 1.0
            voteTotalValue += CGFloat(result)
            voteValue.append(CGFloat(result))
        }
        for (i, value) in voteValue.enumerated() {
            voteValue[i] = (value / voteTotalValue) * 100
        }
        if voteTotalValue == 0.0 {
            self.resetVoteView(true)
        } else {
            self.vote(voteValue: voteValue[0], voteSuper: vote1SuperView, voteView: vote1View, voteImageView: vote1Image, animate: true)
            self.vote(voteValue: voteValue[1], voteSuper: vote2SuperView, voteView: vote2View, voteImageView: vote2Image, animate: true)
            self.vote(voteValue: voteValue[2], voteSuper: vote3SuperView, voteView: vote3View, voteImageView: vote3Image, animate: true)
            self.vote(voteValue: voteValue[3], voteSuper: vote4SuperView, voteView: vote4View, voteImageView: vote4Image, animate: true)
        }
    }
    
    // MARK: - Voting Server Functions
    
    func votingSet() {
        canVote = true
        voteCasted = 1
        self.musicVotedArray.removeAll()
        resetVoteView(true, true, false)
    }
    
    func votingStarted() {
        observeDatabaseOneTime()
        DataService.connect.REF_EVENTS.child(eventID).child("voting").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    let persistID = snap.key as String
                    self.appendToMusicVoteArray(from: persistID)
                }
            }
            self.hideVoteSuperView(hide: false, animate: true)
            self.resetVoteView(true, true, true)
            self.setVoteImageView()
        })
    }
    
    func votingEnded() {
        if voteCasted == 1 {
            voteCasted += 1
            print("votingEnded")
            canVote = false
            self.setVoteCountToMusicVoteArray()
        }
    }
    
    func votingWinner() {
        if voteCasted == 2 {
            voteCasted += 1
            self.getVoteCountFromMusicVoteArray()
        }
    }
    
    func votingWinnerPlaying() {
        if voteCasted == 3 {
            voteCasted += 1
            self.getVoteWinnerFromMusicVoteArray()
            self.hideVoteSuperView(hide: true, animate: true)
            self.resetVoteView(true, false, false)
            self.vote1Image.image = UIImage(named: "hey-dj-black-back")
            self.vote2Image.image = UIImage(named: "hey-dj-black-back")
            self.vote3Image.image = UIImage(named: "hey-dj-black-back")
            self.vote4Image.image = UIImage(named: "hey-dj-black-back")
        } else {
            musicVotedArray.removeAll()
        }
    }
    
    func getImageFromLocation(_ imageLocation: String?) {
        if let imageURL = imageLocation, imageLocation != nil {
            let ref = Storage.storage().reference(forURL: imageURL)
            ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                } else {
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.nowPlayingImageView.image = img
                        }
                    }
                }
            })
        } else {
            self.nowPlayingImageView.image = UIImage(named: "40B52118-FA0A-4978-8A6F-47A5E2137F95")
        }
    }
    
    func changedPlayingSongBeforeVotingEnded(_ persistID: String) {
        musicVotedArray.removeAll()
        for music in musicPlaylistArray {
            if music.persistID == persistID {
                self.nowPlayingArtistLabel.text = music.artist
                self.nowPlayingTitleLabel.text = music.title
                self.getImageFromLocation(music.imageLocation)
            }
        }
    }
    
    func getVoteWinnerFromMusicVoteArray() {
        var voteCount: Int = 0
        for music in musicVotedArray {
            if music.votes! >= voteCount {
                voteCount = music.votes!
                self.musicWinnerID = music.persistID
            }
        }
        var count = 0
        for music in musicVotedArray {
            if music.persistID == self.musicWinnerID {
                self.nowPlayingImageView.image = self.voteViewImage(num: count).image
                self.nowPlayingArtistLabel.text = music.artist
                self.nowPlayingTitleLabel.text = music.title
            } else {
                count += 1
            }
        }
        musicVotedArray.removeAll()
    }
    
    // MARK: - Observe Firebase Database Functions
    func observeStatusInVoting() {
        let ref = DataService.connect.REF_EVENTS.child(eventID).child("status")
        ref.queryLimited(toLast: 1).queryOrderedByKey().observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let value = snap.value as? String {
                        switch value {
                        case "votingSet":
                            self.votingSet()
                        case "votingStarted":
                            self.votingStarted()
                        case "votingEnded":
                            self.votingEnded()
                        case "votingWinner":
                            self.votingWinner()
                        case "votingWinnerPlaying":
                            self.votingWinnerPlaying()
                        default:
                            self.changedPlayingSongBeforeVotingEnded(value)
                        }
                    }
                }
            }
        })
    }
    
    func observeDatabaseOneTime() {
        musicPlaylistArray.removeAll()
        DataService.connect.REF_EVENTS.child(eventID).child("playlist").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    let key = snap.key as String
                    if let musicDict = snap.value as? [String:Any] {
                        let artist = musicDict["Artist"] as? String
                        let title = musicDict["Title"] as? String
                        let imageLocation = musicDict["imageLocation"] as? String
                        let music = Music(
                            persistID: key,
                            artist: artist,
                            title: title,
                            imageLocation: imageLocation
                        )
                        self.musicPlaylistArray.append(music)
                    }
                }
            }
        })
    }
    
}
