//
//  CustomCellController.swift
//  InAppStoryExample
//
//  For more information see: https://github.com/inappstory/ios-sdk/blob/main/Samples/CustomCell.md
//

import UIKit
import InAppStorySDK

class CustomCellController: UIViewController
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

extension CustomCellController
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
        storyView.delegate = self
        // set delegate for layout of StoryView
        storyView.deleagateFlowLayout = self
        
        // set custom cell
        storyView.storyCell = CustomStoryCell()
        
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

extension CustomCellController: StoryViewDelegate
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

// methods of delegate, like in UICollectionViewDelegateFlowLayout
extension CustomCellController: StoryViewDelegateFlowLayout
{
    func sizeForItem() -> CGSize
    {
        return CGSize(width: 120.0, height: 120.0)
    }
    
    func insetForSection() -> UIEdgeInsets
    {
        return UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
    }
    
    func minimumLineSpacingForSection() -> CGFloat
    {
        return 16.0
    }
    
    func minimumInteritemSpacingForSection() -> CGFloat
    {
        return 16.0
    }
}
