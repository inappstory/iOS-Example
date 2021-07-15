//
//  ReaderCustomizationController.swift
//  InAppStoryExample
//
//  For more information see: https://github.com/inappstory/ios-sdk/blob/main/Samples/Reader.md
//

import UIKit
import InAppStorySDK

class ReaderCustomizationController: UIViewController
{
    fileprivate var storyView: StoryView!
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupInAppStory()
        
        setupStoryView()
    }
}

extension ReaderCustomizationController
{
    fileprivate func setupInAppStory()
    {
        // setup InAppStorySDK for user with ID
        InAppStory.shared.settings = Settings(userID: "")
        // disable swipe gesture for reader closing
        InAppStory.shared.swipeToClose = false
        // disabling closing the reader after scrolling through the last story
        InAppStory.shared.overScrollToClose = false
        // placeholder color when loading stories
        InAppStory.shared.placeholderElementColor = .lightGray
        // placeholder background color when loading stories
        InAppStory.shared.placeholderBackgroundColor = .white
        // placeholder color when loading game
        InAppStory.shared.gamePlaceholderTint = .lightGray
        
        // enable gradient shadow under timers in story
        InAppStory.shared.timerGradientEnable = false
        
        // set new icons for buttons in the reader
        InAppStory.shared.likeImage = UIImage(named: "like")!
        InAppStory.shared.likeSelectedImage = UIImage(named: "likeSelected")!
        InAppStory.shared.dislikeImage = UIImage(named: "dislike")!
        InAppStory.shared.dislikeSelectedImage = UIImage(named: "dislikeSelected")!
        InAppStory.shared.favoriteImage = UIImage(named: "favorite")!
        InAppStory.shared.favoriteSelectedImag = UIImage(named: "favoriteSelected")!
        InAppStory.shared.shareImage = UIImage(named: "sharing")!
        InAppStory.shared.shareSelectedImage = UIImage(named: "sharingSelected")!
        InAppStory.shared.soundImage = UIImage(named: "sound")!
        InAppStory.shared.soundSelectedImage = UIImage(named: "soundSelected")!
        
        InAppStory.shared.refreshImage = UIImage(named: "refresh")!
        // enable like function in reader
        InAppStory.shared.likePanel = true
        // enable favorite function in reader
        InAppStory.shared.favoritePanel = true
        // enable share function in reader
        InAppStory.shared.sharePanel = true
        // set position of close button in reader
        InAppStory.shared.closeButtonPosition = .bottomLeft
        // set animation for switching between stories in the reader
        InAppStory.shared.scrollStyle = .cube
        // set the animation for the reader
        InAppStory.shared.presentationStyle = .modal
    }
    
    fileprivate func setupStoryView()
    {
        // create instance of StoryView
        storyView = StoryView(frame: .zero, favorite: false)
        storyView.translatesAutoresizingMaskIntoConstraints = false
        // adding a point from where the reader will be shown
        storyView.target = self
        // set StoryView delegate
        storyView.delegate = self
        
        self.view.addSubview(storyView)
        
        var allConstraints: [NSLayoutConstraint] = []
        let horConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[storyView]-(0)-|",
                                                           options: [.alignAllLeading, .alignAllTrailing],
                                                           metrics: nil,
                                                           views: ["storyView": storyView!])
        allConstraints += horConstraint
        let vertConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(16)-[storyView(180)]",
                                                            options: [.alignAllTop, .alignAllBottom],
                                                            metrics: nil,
                                                            views: ["storyView": storyView!])
        allConstraints += vertConstraint
        NSLayoutConstraint.activate(allConstraints)
        
        // running internal StoryView logic
        storyView.create()
    }
}

extension ReaderCustomizationController: StoryViewDelegate
{
    // delegate method, called when the data in the StoryView is updated
    func storyViewUpdated(storyView: StoryView, widgetStories: Array<WidgetStory>?)
    {
        if storyView.isContent {
            print("StoryView has content")
        } else {
            print("No content")
        }
    }
    // delegate method, called when a button or SwipeUp event is triggered in the reader
    func storyView(_ storyView: StoryView, actionWith type: ActionType, for target: String)
    {
        if let url = URL(string: target) {
            UIApplication.shared.open(url)
        }
    }
    
    // delegate method, called when the reader will show
    func storyReaderWillShow()
    {
        print("StoryView reader will show")
    }
    
    // delegate method, called when the reader did close
    func storyReaderDidClose()
    {
        print("StoryView reader did close")
    }
    
    // delegate method, called when the favorite cell has been selected
    func favoriteCellDidSelect()
    {
        // InAppStory.shared.favoritePanel is false, favorites cell is not displayed
        // method called only the method is called only when the favorite cell is selected
        // see FavoritesController.swift
    }
}
