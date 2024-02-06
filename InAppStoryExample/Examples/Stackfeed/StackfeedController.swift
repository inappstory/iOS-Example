//
//  StackfeedController.swift
//  InAppStoryExample
//

import UIKit
import InAppStorySDK

/// Example of using the Stack feed
class StackfeedController: UIViewController {
    /// Stack feed view, since InAppStorySDK only presents data, it is necessary to implement a UI view.
    fileprivate var stackView: StackView!
    /// Stack feed data object received from SDK
    fileprivate var stackFeed: StackFeedObject? {
        didSet {
            if stackView != nil {
                stackView.updateFeed(newStackFeed: stackFeed!)
            }
        }
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Configuring `InAppStory` before use
        setupInAppStory()
        /// Create and add a stack of stories to the screen
        setupStackView()
        
        self.view.addSubview(stackView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /// Creating the screen interface
        setupInterface()
    }
}

extension StackfeedController {
    /// Creating a button to refresh the list
    fileprivate func setupInterface() {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Refresh", for: .normal)
        button.setTitleColor(.black, for: .normal)
        
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        view.addSubview(button)
        
        /// creating button constants
        let centerXConstraint = NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        let centerYConstraint = NSLayoutConstraint(item: button, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 130)
        let heightConstraint = NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30)
        
        NSLayoutConstraint.activate([centerXConstraint, centerYConstraint, widthConstraint, heightConstraint])
    }
    
    /// Create and add a list of stories to the screen
    fileprivate func setupStackView() {
        /// create instance of `StoryView`
        stackView = StackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        /// adding a storyView as a subview to the controller
        self.view.addSubview(stackView)
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(stackViewTouch))
        stackView.addGestureRecognizer(gesture)
        
        /// configuring the constants to display the list correctly
        var allConstraints: [NSLayoutConstraint] = []
        /// horizontally - from edge to edge
        let horConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:[stackView(180)]",
                                                           options: [.alignAllLeading, .alignAllTrailing],
                                                           metrics: nil,
                                                           views: ["stackView": stackView!])
        allConstraints += horConstraint
        /// vertically - height 180pt with a 16pt indent at the top
        let vertConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(16)-[stackView(180)]",
                                                            options: [.alignAllTop, .alignAllBottom],
                                                            metrics: nil,
                                                            views: ["stackView": stackView!])
        allConstraints += vertConstraint
        
        let centerXConstraint = NSLayoutConstraint(item: stackView!, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        
        allConstraints.append(centerXConstraint)
        /// constraints activation
        NSLayoutConstraint.activate(allConstraints)
        
        if stackFeed != nil {
            stackView.updateFeed(newStackFeed: stackFeed!)
        }
    }
}

extension StackfeedController {
    /// Configuring InAppStory before use
    fileprivate func setupInAppStory() {
        /// setup `InAppStorySDK` for user with ID
        InAppStory.shared.settings = Settings(userID: "")
        
        /// Receive object with data from SDK
        InAppStory.shared.getStackFeed { [weak self] result in
            guard let weakSelf = self else { return }
            
            switch result {
            case .success(let newStackFeed):
                /// if the result is successful, write the value of the local variable
                weakSelf.stackFeed = newStackFeed
                break
            case .failure(_):
                /// in case of an error, you can display a notification or do other actions
                break
            }
        }
        
        /// Adding closures called when an object with Stack feed data from SDK is updated.
        /// Called while opening stories, not necessarily from stack feed, all openings between feeds are synchronized
        InAppStory.shared.stackFeedUpdate = { [weak self] newStackFeed in
            guard let weakSelf = self else { return }
            /// write the value of the local variable
            weakSelf.stackFeed = newStackFeed
        }
        
        /// setting a closure on user action in stories
        InAppStory.shared.onActionWith = onActionWith
        /// setting the reader opening closure
        InAppStory.shared.storyReaderWillShow = storyReaderWillShow(_:)
        /// setting the reader closing closure
        InAppStory.shared.storyReaderDidClose = storyReaderDidClose(_:)
    }
}

extension StackfeedController {
    /// closure, called when a button or SwipeUp event is triggered in the reader
    /// - Parameters:
    ///   - target: the action by which the link was obtained
    ///   - type: type of action that called this method
    ///   - storyType: the type of stories that have been opened, depending on the source
    ///
    /// ### ActionType
    /// - `.button` - push the button in story;
    /// - `.swipe` - swipe up slide in story;
    /// - `.game` - link from Game;
    /// - `.deeplink` - deeplink from cell in story list.
    ///
    /// ### StoriesType
    /// - `.list(feed: <String>?)` - type for StoryView, *feed* - id stories list;
    /// - `.single` - type for single story reader;
    /// - `.onboarding(feed: <String>)` - type for onboarding story reader, *feed* - id stories list.
    func onActionWith(_ target: String, _ type: ActionType, _ storyType: StoriesType?) {
        if let url = URL(string: target) {
            UIApplication.shared.open(url)
        }
    }
    
    /// closure, is called each time the reader is opened
    /// - Parameter storyType: the type of stories that have been opened, depending on the source
    ///
    /// ### StoriesType
    /// - `.list(feed: <String>?)` - type for StoryView, *feed* - id stories list;
    /// - `.single` - type for single story reader;
    /// - `.onboarding(feed: <String>)` - type for onboarding story reader, *feed* - id stories list.
    func storyReaderWillShow(_ storyType: StoriesType) {
        switch storyType {
        case .list:
            print("StoryView reader will show")
        case .single:
            print("SingleStory reader will show")
        case .onboarding:
            print("Onboarding reader will show")
        case .ugcList:
            print("UGC reader will show")
        }
    }
    
    /// is called each time the reader is closed
    /// - Parameter storyType: the type of stories that have been opened, depending on the source
    ///
    /// ### StoriesType
    /// - `.list(feed: <String>?)` - type for StoryView, *feed* - id stories list;
    /// - `.single` - type for single story reader;
    /// - `.onboarding(feed: <String>)` - type for onboarding story reader, *feed* - id stories list.
    ///
    /// > Opening a link within a stories leading to another stories also closes the reader and causes this closure.
    /// > There are cases when the reader may not close when trying to open stories, if the given story is already in the list,
    /// > in this case it is simply flipping to the necessary index.
    /// >
    /// > Also the reader will not be closed if there is an attempt to open the game from stories.
    func storyReaderDidClose(_ storyType: StoriesType) {
        switch storyType {
        case .list:
            print("StoryView reader did close")
        case .single:
            print("SingleStory reader did close")
        case .onboarding:
            print("Onboarding reader did close")
        case .ugcList:
            print("UGC reader did close")
        }
    }
}

extension StackfeedController {
    /// Processing of user change button pressing
    @objc func buttonAction(sender: UIButton!) {
        /// To update the data in Stack feed, getStackFeed must be called again.
        /// In this case, a new list will be obtained.
        InAppStory.shared.getStackFeed { [weak self] result in
            guard let weakSelf = self else { return }
            
            switch result {
            case .success(let newStackFeed):
                weakSelf.stackFeed = newStackFeed
                break
            case .failure(_):
                break
            }
        }
    }
    
    /// Handling a click on the Stack feed view in the interface
    @objc func stackViewTouch(sender: UITapGestureRecognizer) {
        /// Check that there is Stack feed data obtained from `getStackFeed` or `stackFeedUpdate`
        guard let stackFeed = stackFeed else { return }
        
        /// Display Stack feed reader with data
        InAppStory.shared.showStackReader(with: stackFeed, with: PanelSettings(like: true, share: true)) { show in
            /// If all data matches, the reader will be shown and closure will return show == true.
        }
    }
}
