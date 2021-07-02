//
//  UserChangeController.swift
//  InAppStoryExample
//
//  For more information see: https://github.com/inappstory/ios-sdk/blob/main/Samples/UserChange.md
//

import UIKit
import InAppStorySDK

class UserChangeController: UIViewController
{
    fileprivate var storyView: StoryView!
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupInAppStory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupInterface()
    }
}

extension UserChangeController
{
    fileprivate func setupInAppStory()
    {
        // setup InAppStorySDK for user with ID
        InAppStory.shared.settings = Settings(userID: "")
    }
    
    fileprivate func setupInterface()
    {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Change User", for: .normal)
        button.setTitleColor(.black, for: .normal)
        
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        view.addSubview(button)
        
        let centerXConstraint = NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        let centerYConstraint = NSLayoutConstraint(item: button, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 130)
        let heightConstraint = NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30)
        
        NSLayoutConstraint.activate([centerXConstraint, centerYConstraint, widthConstraint, heightConstraint])
        
        setupStoryView()
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

extension UserChangeController
{
    @objc func buttonAction(sender: UIButton!)
    {
        // set setting with new uesrID
        InAppStory.shared.settings = Settings(userID: "newUser")
        // for update data, need refres StoryView
        storyView.refresh()
    }
}

extension UserChangeController: StoryViewDelegate
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
