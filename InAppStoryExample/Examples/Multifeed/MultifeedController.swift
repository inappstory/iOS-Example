//
//  MultifeedController.swift
//  InAppStoryExample
//

import UIKit
import InAppStorySDK

/// Example of using Multi-feed functionality
///
/// In order to display several different ribbons on the screen, it is necessary to specify different feeds for them during initialization.
/// ```
/// StoryView(feed: "custom_feed")
/// ```
///
/// In order to distinguish events coming in closures, for example ``StoriesClosureHandler/storiesDidUpdated(_:_:)``,
/// in the `storyType` parameter, where possible, the feed from the list that caused the given closure will come.
/// ```
/// func storiesDidUpdated(_ isContent: Bool, _ storyType: StoriesType) {
///     switch storyType {
///     case .list(let feed):
///         print("StoryView with feed \(feed ?? "")")
///     case .single:
///         print("SingleStory has no feed")
///     case .onboarding(let feed):
///         print("Onboarding with feed \(feed)")
///     case .ugcList:
///         print("UGC StoryView has no feed")
///     @unknown default:
///         break
///     }
/// }
/// ```
///
/// - Note: When updating tags or changing users, you must call `.refresh()` on each list individually.
///
/// For more information see: [Multi-feed](https://docs.inappstory.com/sdk-guides/ios/multi-feed.html#multi-feed)
class MultifeedController: UIViewController {
    /// List of stories
    fileprivate var storyView: StoryView!
    /// List of another stories
    fileprivate var customFeedStoryView: StoryView!
    /// Closure handler from `StoryView`
    fileprivate var closureHandler: StoriesClosureHandler!
    /// Closure handler from `StoryView`
    fileprivate var storiesFeedClosure: StoriesClosureHandler!
    
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
        setupStoryViews()
    }
}

extension MultifeedController{
    /// Configuring InAppStory before use
    fileprivate func setupInAppStory() {
        /// setup `InAppStorySDK` for user with ID
        InAppStory.shared.settings = Settings(userID: "")
    }
    
    /// Create and add a list of stories to the screen
    fileprivate func setupStoryViews() {
        /// create instance of `StoryView`
        storyView = StoryView()
        storyView.translatesAutoresizingMaskIntoConstraints = false
        /// adding a point from where the reader will be shown
        storyView.target = self
        /// creating a closure handler for `storyView`
        closureHandler = StoriesClosureHandler(storyView: storyView)
        /// adding a storyView as a subview to the controller
        self.view.addSubview(storyView)
        
        /// create instance of StoryView with custom feed id - "custom_feed"
        customFeedStoryView = StoryView(feed: "custom_feed")
        customFeedStoryView.translatesAutoresizingMaskIntoConstraints = false
        /// adding a point from where the reader will be shown
        customFeedStoryView.target = self
        /// creating a closure handler for `storyView`
        storiesFeedClosure = StoriesClosureHandler(storyView: customFeedStoryView)
        /// adding a storyView as a subview to the controller
        self.view.addSubview(customFeedStoryView)
        
        /// configuring the constants to display the list correctly
        var allConstraints: [NSLayoutConstraint] = []
        /// horizontally - from edge to edge
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[storyView]-(0)-|",
                                                         options: [.alignAllLeading, .alignAllTrailing],
                                                         metrics: nil,
                                                         views: ["storyView": storyView!])
        /// horizontally - from edge to edge
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[customFeedStoryView]-(0)-|",
                                                         options: [.alignAllLeading, .alignAllTrailing],
                                                         metrics: nil,
                                                         views: ["customFeedStoryView": customFeedStoryView!])
        /// vertically - height 180pt with a 16pt indent at the top and other
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(16)-[storyView(180)]-(16)-[customFeedStoryView(180)]",
                                                         options: [.alignAllLeft],
                                                         metrics: nil,
                                                         views: ["storyView": storyView!, "customFeedStoryView": customFeedStoryView!])
        /// constraints activation
        NSLayoutConstraint.activate(allConstraints)
        
        /// running internal `StoryView` logic
        storyView.create()
        /// running internal `StoryView` logic
        customFeedStoryView.create()
    }
}
