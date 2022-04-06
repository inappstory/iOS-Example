//
//  MultifeedOnboardingController.swift
//  InAppStoryExample
//
//  For more information see: https://github.com/inappstory/ios-sdk/blob/main/Samples/OnboardingStory.md
//

import UIKit
import InAppStorySDK

class MultifeedOnboardingController: UIViewController
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // show onboarding reader with completion for custom feed id
        InAppStory.shared.showOnboardings(feed: "custom_feed", from: self, delegate: self) { show in
            print("Story reader \(show ? "is" : "not") showing")
        }
    }
}

extension MultifeedOnboardingController
{
    fileprivate func setupInAppStory()
    {
        // setup InAppStorySDK for user with ID
        InAppStory.shared.settings = Settings(userID: "")
    }
    
    fileprivate func setupStoryView()
    {
        // create instance of StoryView
        storyView = StoryView(frame: .zero, favorite: false)
        storyView.translatesAutoresizingMaskIntoConstraints = false
        // adding a point from where the reader will be shown
        storyView.target = self
        // set StoryView delegate
        storyView.storiesDelegate = self
        
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

extension MultifeedOnboardingController: InAppStoryDelegate
{
    // delegate method, called when the data is updated
    func storiesDidUpdated(isContent: Bool, from storyType: StoriesType)
    {
        guard let currentStoryView = storyView else {
            return
        }
        
        if currentStoryView.isContent {
            switch storyType {
            case .list(let feed):
                print("StoryView has content in feed \(feed ?? "")")
            case .single:
                print("SingleStory has content")
            case .onboarding(let feed):
                print("Onboarding has content in feed \(feed)")
            }
        } else {
            print("No content")
        }
    }
    
    // delegate method, called when a button or SwipeUp event is triggered in the reader
    // types is .button, .game, .deeplink, .swipe
    func storyReader(actionWith target: String, for type: ActionType, from storyType: StoriesType) {
        if let url = URL(string: target) {
            UIApplication.shared.open(url)
        }
    }
    
    // delegate method, called when the reader will show
    func storyReaderWillShow(with storyType: StoriesType)
    {
        switch storyType {
        case .list(let feed):
            print("StoryView reader will show from feed \(feed ?? "")")
        case .single:
            print("SingleStory reader will show")
        case .onboarding(let feed):
            print("Onboarding reader will show from feed \(feed)")
        }
    }
    
    // delegate method, called when the reader did close
    func storyReaderDidClose(with storyType: StoriesType)
    {
        switch storyType {
        case .list(let feed):
            print("StoryView reader did close to feed \(feed ?? "")")
        case .single:
            print("SingleStory reader did close")
        case .onboarding(let feed):
            print("Onboarding reader did close to feed \(feed)")
        }
    }
    
    // delegate method, called when the favorite cell has been selected
    func favoriteCellDidSelect()
    {
        // InAppStory.shared.favoritePanel is false, favorites cell is not displayed
        // method called only the method is called only when the favorite cell is selected
        // see FavoritesController.swift
    }
}