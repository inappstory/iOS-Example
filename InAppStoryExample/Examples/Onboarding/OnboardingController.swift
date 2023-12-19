//
//  OnboardingController.swift
//  InAppStoryExample
//

import UIKit
import InAppStorySDK

/// Example of a screen using onboarding
///
/// Onboarding is used to show a single story or list of stories to a user.
/// The uniqueness of displays is determined by *UserID* set in `InAppStory.shared.settings`.
///
/// If this user was shown a story from the onboarding list and the same story exists in the `StoryView` list,
/// it will automatically set to read. Also, if a story from the `StoryView` list was read before the onboarding was shown,
/// it will not appear in the onboarding reader.
///
/// There are scenarios where the user ID cannot be obtained before displaying the onboarding (e.g. unauthorized user). 
/// In such cases, the uniqueness of the view is determined by `UIDevice.current.identifierForVendor`.
/// In this case, an unauthorized user with `ID==""` will not have the onboarding shown more than once.
///
/// - Attention: Since `UIDevice.current.identifierForVendor` is provided only as long as the application
/// or applications from this developer are installed on the device, after reinstalling the application and if there are no other
/// applications from this developer installed, `identifierForVendor` will change, which will cause the onboarding
/// for a user without an ID to be displayed again.
///
/// # A simple display of onboarding
/// To show onboardings, you must call the `showOnboardings` method
/// ```
/// InAppStory.shared.showOnboardings(from: self) { show in }
/// ```
/// As a target, it is desirable to specify the top controller in the screen hierarchy to properly display
/// the reader on top of all application elements.
///
/// # Custom feed
/// Through onboarding display, you can display any feed that you have created in your console, for this you need to specify
/// the name of the feed you want to display when calling `showOnboardings`. In this case, the logic of onboarding remains
/// unchanged and the reader will show only those stories that the user has not opened yet.
/// ```
/// InAppStory.shared.showOnboardings(feed: "custom_feed", from: self) { show in }
/// ```
///
/// # Limitations
/// If you want to limit the display of the onboarding feed to a few stories and not show the full feed at once, you need to set a limit when `showOnboardings` is called
/// ```
/// InAppStory.shared.showOnboardings(limit: 2, from: self) { show in }
/// ```
///
/// # Tags
/// To show onboarding, you can set a separate list of tags different from the one set in `Settings(userID: String, tags: Array<String>)`. In this case, onboarding will ignore the list of tags set in `InAppStory.shared.settings`.
/// ```
/// InAppStory.shared.showOnboardings(from: self, with: ["new_tag1", "new_tag2"]) { show in }
/// ```
///
/// # PanelSettings
/// For an onboarding reader instance, you can set unique bottom panel settings that will ignore those set for `StoryView`. In this way, you can disable the bottom panel functionality that is not required for onboarding.
/// ```
/// InAppStory.shared.showOnboardings(from: self, with: PanelSettings(like: false)) { show in }
/// ```
///
/// For more information see: [Onboarding](https://docs.inappstory.com/sdk-guides/ios/onboardings.html#onboardings)
class OnboardingController: UIViewController {
    /// List of stories
    fileprivate var storyView: StoryView!
    /// Closure handler from `StoryView`
    fileprivate var closureHandler: StoriesClosureHandler!
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /// show onboarding reader with completion
        InAppStory.shared.showOnboardings(limit: 2, from: self) { show in
            print("Story reader \(show ? "is" : "not") showing")
        }
    }
}

extension OnboardingController {
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
        /// creating a closure handler for `storyView`
        closureHandler = StoriesClosureHandler(storyView: storyView)
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
}

