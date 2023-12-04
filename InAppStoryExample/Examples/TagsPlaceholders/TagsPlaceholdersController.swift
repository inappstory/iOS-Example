//
//  TagsPlaceholdersController.swift
//  InAppStoryExample
//

import UIKit
import InAppStorySDK

/// Example of using tags and placeholders
///
/// # Tags
/// A set of tags can be used for segmenting the display of stories lists. 
/// Tags for specific stories are set in the console when creating or editing them.
///
/// > For example, if for an unauthorized user you want to show a story with a call to register and
/// > not show special offers. You can set the tag "unauthorize" in the console, and "authorize" for all other users,
/// > thus dividing the feed into two parts. When creating a feed, check if the user is authorized and add a corresponding list of tags.
/// > ```
/// > if user.isAuthorize {
/// >     InAppStory.shared.settings = Settings(userID: user.id, tags: ["authorize"])
/// > } else {
/// >     InAppStory.shared.settings = Settings(userID: "", tags: ["unauthorize"])
/// > }
/// > ```
///
/// - Remark: Split the display of stories can also be done using the "Multifeed" tool,
/// you can see an example of how to use it ``MultifeedController``
///
/// There are several options for setting up a tag list:
/// - setting the list in the `Settings` object during `InAppStory` initialization
/// ```
/// InAppStory.shared.initWith(serviceKey: "serviceKey", settings: Settings(userID: "userID", tags: ["one", "two"]))
/// ```
/// - setting tags before using the `StoryView` list of stories
/// ```
/// InAppStory.shared.settings = Settings(userID: "userID", tags: ["one", "two"])
/// ```
/// - adding or deleting tag lists using `addTags` and `removeTags` methods
/// ```
/// InAppStory.shared.addTags(["three", "four"])
/// InAppStory.shared.removeTags(["three"])
/// ```
/// - override tag list for Onboardings. For more details see ``OnboardingController``
/// - refresh tag list via `.refresh` method
/// ```
/// storyView.refresh(newTags: ["newTag_1", "newTag_2"])
/// ```
///
/// - Note: After setting new tags via the `Settings` object or changing the list of `addTags` 
/// and `removeTags`, if the `StoryView` list is already created and displayed on the screen,
/// the `.refresh()` method must be called to make the changes take effect.
///
/// For more information about tags see: [Tags](https://docs.inappstory.com/sdk-guides/ios/tags.html#tags)
///
/// # Placeholders
///
/// Placeholders are used to personalize and modify displayed stories directly on the device.
/// For correct operation, placeholders must be started in the console and specified in `InAppStory.shared`
///  before creating `StoryView` or displaying Single/Onboarding.
///
/// ## Text placeholders
/// Text placeholders are set in `InAppStory` as `Dictionary<String, String>`,
/// with the key specified without curly braces, and the value can be anything.
/// If no value is specified for a placeholder, the default value set in the console when
/// it was created will be shown in the story.
/// ```
/// InAppStory.shared.placeholders = ["one" : "Replace one", "two" : "Replace two"]
/// ```
///
/// ## Images placeholders
/// Image placeholders are set in `InAppStory` as `Dictionary<String, String>`,
/// the key is specified without curly brackets, and the value must contain a link to the image that will be displayed in the story.
/// ```
/// InAppStory.shared.imagesPlaceholders = ["img_1" : "imageURL_1", "img_2" : "imageURL_1"]
/// ```
///
/// - Note: The link to the story can be either local or external. SDK in any case will download it to its own cache for correct work.
///
/// For more information about placeholders see: [Placeholders](https://docs.inappstory.com/sdk-guides/ios/placeholders.html#placeholders)
class TagsPlaceholdersController: UIViewController {
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
}

extension TagsPlaceholdersController {
    /// Configuring InAppStory before use
    fileprivate func setupInAppStory() {
        /// setup InAppStorySDK for user with ID & tags
        InAppStory.shared.settings = Settings(userID: "", tags: ["one", "two"])
        /// add tags after set settings
        InAppStory.shared.addTags(["three", "four"])
        /// remove tags if needed
        InAppStory.shared.removeTags(["three"])
        
        /// if the `StoryView` has already been created, after adding or removing tags, you need to refresh the `StoryView`
        /// `storyView.refresh()`
        
        /// set replacing placeholders list
        InAppStory.shared.placeholders = ["one" : "Replace one", "two" : "Replace two"]
        
        /// set replacing images placeholders list
        InAppStory.shared.imagesPlaceholders = ["img_1" : "imageURL_1", "img_2" : "imageURL_1"]
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
