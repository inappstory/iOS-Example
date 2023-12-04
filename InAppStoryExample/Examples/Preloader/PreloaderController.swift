//
//  PreloaderController.swift
//  InAppStoryExample
//

import UIKit
import InAppStorySDK

/// Example of creating a placeholder for `StoryView`
///
/// In order to display the process of data loading in `StoryView`, it is necessary to specify the ``storiesDidUpdated(_:_:)`` closure, which will make it possible to track the moment when the SDK finishes receiving the story list data and hide the list from the screen if necessary.
///
/// - Note: This example can also be used to overlap `StoryView` with a skeleton.
///
/// For more information see: [List Placeholder (skeleton)](https://docs.inappstory.com/sdk-guides/ios/list-placeholder.html#list-placeholder-skeleton)
class PreloaderController: UIViewController {
    /// Load indicator displayed until the list is loaded
    fileprivate var loadingIndicator: UIActivityIndicatorView!
    /// List of stories
    fileprivate var storyView: StoryView!
    
    /// Customizing the appearance of the controller
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Configuring `InAppStory` before use
        setupInAppStory()
        /// Create and add a list of stories to the screen
        setupStoryView()
    }
}

extension PreloaderController {
    /// Configuring InAppStory before use
    fileprivate func setupInAppStory() {
        /// setup `InAppStorySDK` for user with ID
        InAppStory.shared.settings = Settings(userID: "")
    }
    
    /// Create and add a list of stories to the screen
    fileprivate func setupStoryView() {
        /// create instance of `StoryView`
        storyView = StoryView()
        storyView.translatesAutoresizingMaskIntoConstraints = false
        /// adding a point from where the reader will be shown
        storyView.target = self
        
        /// Setting the closure, to handle the list update
        storyView.storiesDidUpdated = storiesDidUpdated
        /// Closure set, to handle user actions
        storyView.onActionWith = onActionWith
        
        /// adding a storyView as a subview to the controller
        self.view.addSubview(storyView)
        
        /// configuring the constants to display the list correctly
        var allConstraints: [NSLayoutConstraint] = []
        /// horizontally - from edge to edge
        let horConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[storyView]-(0)-|",
                                                           options: [.alignAllLeading, .alignAllTrailing],
                                                           metrics: nil,
                                                           views: ["storyView": storyView!])
        allConstraints += horConstraint
        /// vertically - height 180pt with a 16pt indent at the top
        let vertConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(16)-[storyView(180)]",
                                                            options: [.alignAllTop, .alignAllBottom],
                                                            metrics: nil,
                                                            views: ["storyView": storyView!])
        allConstraints += vertConstraint
        /// constraints activation
        NSLayoutConstraint.activate(allConstraints)
        
        /// running internal `StoryView` logic
        storyView.create()
    }
    
    /// Create a placeholder to display while content is loaded in `StoryView`.
    fileprivate func setupPreloader() {
        /// create preloader activity indicator
        loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.large
        loadingIndicator.startAnimating()
        self.view.addSubview(loadingIndicator)
        
        var allConstraints: [NSLayoutConstraint] = []
        let horConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:[storyView]-(<=1)-[loadingIndicator]",
                                                         options: NSLayoutConstraint.FormatOptions.alignAllCenterX,
                                                         metrics: nil,
                                                         views: ["storyView": storyView!,"loadingIndicator": loadingIndicator!])
                
        allConstraints += horConstraint
        let vertConstraint = NSLayoutConstraint.constraints(withVisualFormat:"H:[superview]-(<=1)-[loadingIndicator]",
                                                     options: NSLayoutConstraint.FormatOptions.alignAllCenterY,
                                                     metrics: nil,
                                                     views: ["storyView": storyView!, "loadingIndicator": loadingIndicator!])
        
        allConstraints += vertConstraint
        NSLayoutConstraint.activate(allConstraints)
    }
}

extension PreloaderController {
    /// Closure, is called every time the content in the list is updated
    /// - Parameters:
    ///   - isContent: displays whether the content is present in the list
    ///   - storyType: the type of stories that have been opened, depending on the source
    ///
    /// ### StoriesType
    /// - `.list(feed: <String>?)` - type for StoryView, *feed* - id stories list;
    /// - `.single` - type for single story reader;
    /// - `.onboarding(feed: <String>)` - type for onboarding story reader, *feed* - id stories list.
    func storiesDidUpdated(_ isContent: Bool, _ storyType: StoriesType) {
        guard let currentStoryView = storyView else {
            return
        }
        
        /// Check if `StoryView` has content when the list is updated
        if isContent { /// `StoryView` has content
            loadingIndicator.stopAnimating()
        } else { /// `StoryView` has't content
            loadingIndicator.stopAnimating()
            currentStoryView.isHidden = true
        }
    }
    
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
    func onActionWith(_ target: String, _ type: ActionType, _ storyType: StoriesType) {
        if let url = URL(string: target) {
            UIApplication.shared.open(url)
        }
    }
}
