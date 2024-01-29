//
//  SharingViewController.swift
//  InAppStoryExample
//
//  Created by StPashik on 29.01.2024.
//

import UIKit
import InAppStorySDK

class SharingViewController: UIViewController {
    
    /// object that contains data to be shared
    /// - `text` - plain text <String?>;
    /// - `images` - image array <Array<UIImage>?>;
    /// - `link` -  link <String?>;
    /// - `payload` - custom data set in the console when creating the widget "Share <String?>;
    var shareObject: SharingObject
    /// closure that must be called when unsharing is finished (e.g. closing the sharing window)
    var complete: ShareComplete
    /// This closure is called if the user wants to use system sharing and taps the relevant button.
    var defaultComplete: () -> Void
    
    /// View container for elements
    @IBOutlet var shareContainer: UIView!
    /// Close button
    @IBOutlet var closeButton: UIButton!
    /// list of actions
    @IBOutlet var collectionView: UICollectionView!
    /// Copy button
    @IBOutlet var copyButton: UIButton!
    
    /// Action set
    private var sharedActions: Array<SharingAction>!
    
    /// Initializing ViewController
    init(shareObject: SharingObject, complete: @escaping ShareComplete, defaultComplete: @escaping () -> Void) {
        self.shareObject = shareObject
        self.complete = complete
        self.defaultComplete = defaultComplete
        
        super.init(nibName: "SharingViewController", bundle: .main)
        /// generation of available actions
        self.sharedActions = self.generateActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// container roundings
        shareContainer.layer.cornerRadius = 16.0
        /// rounding for the "copy" button
        copyButton.layer.cornerRadius = 8
        /// clearing the title for the "Close" button
        closeButton.setTitle("", for: .normal)
        
        /// CollectionView setup
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        
        /// action cell registration
        let sharingCell = SharingCell()
        let sharingCellNib = type(of: sharingCell).nib
        collectionView.register(sharingCellNib, forCellWithReuseIdentifier: type(of: sharingCell).reuseIdentifier)
        
        /// if the sharing object contains a link, then show the button to copy it
        if shareObject.link != nil {
            copyButton.setTitle("Copy link", for: .normal)
        }
        /// if the sharing object contains images, show the button to copy it
        if let images = shareObject.images, !images.isEmpty {
            copyButton.setTitle("Copy image", for: .normal)
        }
    }
}

extension SharingViewController {
    /// Generating actions for the sharing window
    func generateActions() -> Array<SharingAction> {
        var actions: Array<SharingAction> = []
        /// Telegram
        /// if it was possible to get a link to open the application (url schema)
        if let telegramUrl = URL(string: SharingAction.telegram.url) {
            /// if the received link can be opened
            if UIApplication.shared.canOpenURL(telegramUrl) {
                /// if the object has a link field
                if shareObject.link != nil {
                    /// adding an action to the list
                    actions.append(.telegram)
                }
            }
        }
        /// WhatsApp
        /// /// if it was possible to get a link to open the application (url schema)
        if let whatsappUrl = URL(string: SharingAction.whatsapp.url) {
            /// if the received link can be opened
            if UIApplication.shared.canOpenURL(whatsappUrl) {
                /// if the object has a link field
                if shareObject.link != nil {
                    /// adding an action to the list
                    actions.append(.whatsapp)
                }
            }
        }
        /// Instagram
        /// /// if it was possible to get a link to open the application (url schema)
        if let instagramUrl = URL(string: SharingAction.instagram.url) {
            /// if the received link can be opened
            if UIApplication.shared.canOpenURL(instagramUrl) {
                /// if the object has an images field and the list of images is not empty
                if shareObject.images != nil && !shareObject.images!.isEmpty {
                    /// adding an action to the list
                    actions.append(.instagram)
                }
            }
        }
        /// iMessage system application
        /// /// if it was possible to get a link to open the application (url schema)
        if let smsUrl = URL(string: SharingAction.sms.url) {
            /// if the received link can be opened
            if UIApplication.shared.canOpenURL(smsUrl) {
                /// if the object has a link field
                if shareObject.link != nil {
                    /// adding an action to the list
                    actions.append(.sms)
                }
            }
        }
        
        return actions
    }
}

extension SharingViewController {
    /// closing the screen at the press of a button and sending a closure about sharing cancellation
    @IBAction func closeTouch(_ sender: UIButton) {
        self.dismiss(animated: true)
        self.complete(false)
    }
    
    /// copying of sharings content depending on the content
    @IBAction func copyTouch(_ sender: UIButton) {
        /// if the sharing object contains a link, then show the button to copy it
        if shareObject.link != nil {
            UIPasteboard.general.string = shareObject.link!
        }
        /// if the sharing object contains images, show the button to copy it
        if let images = shareObject.images, !images.isEmpty {
            UIPasteboard.general.images = shareObject.images
        }
    }
}

extension SharingViewController: UICollectionViewDelegate {
    /// selecting a cell click action
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item < sharedActions.count {
            let action = sharedActions[indexPath.item]
            /// when the button is pressed, a link is generated to open it in the corresponding application
            if let url = action.generateURL(sharingObject: shareObject) {
                /// opening the url schema link
                UIApplication.shared.open(url)
                /// close the sharing window
                self.dismiss(animated: true)
                /// call closure indicating successful sharing
                complete(true)
            }
        } else {
            /// close the sharing window
            self.dismiss(animated: true)
            /// call closure on which you want to show the system window of sharing
            defaultComplete()
        }
    }
}

extension SharingViewController: UICollectionViewDataSource {
    /// action item count
    /// adding one more element to call the default sharing window
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sharedActions.count + 1
    }
    
    /// action cell display
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SharingCell", for: indexPath) as! SharingCell
        
        cell.icon.clipsToBounds = true
        /// customizing a cell for an action from the list
        if indexPath.item < sharedActions.count {
            cell.icon.layer.cornerRadius = 0.0
            cell.icon.backgroundColor = .clear
            
            /// action picture
            if let iconImage = UIImage(named: sharedActions[indexPath.item].icon) {
                cell.icon.image = iconImage
            } else {
                cell.icon.image = nil
                cell.icon.backgroundColor = .lightGray
            }
        } else { /// setting of the cell for the action of displaying the default shading
            cell.icon.layer.cornerRadius = 14.0
            cell.icon.backgroundColor = .lightGray
            cell.icon.image = UIImage(systemName: "ellipsis")
        }
        
        return cell
    }
}

extension SharingViewController: UICollectionViewDelegateFlowLayout {
    /// cell size setting
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60.0, height: 60.0)
    }
}
