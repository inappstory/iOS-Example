//
//  MainTableController.swift
//  InAppStoryExample
//

import UIKit
import InAppStorySDK

class MainTableController: UITableViewController {
    
    let examples = ["Simple integration",
                    "Cell customization",
                    "Custom Cell",
                    "Favorites",
                    "Reader Customization",
                    "Onboarding",
                    "Single Story",
                    "User Change",
                    "Tags & Placeholders",
                    "Notifications"]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isTranslucent = false
        
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        resetInAppStory()
    }
    
    fileprivate func setupTableView()
    {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "exampleCell")
    }
}

// MARK: - Navigation
extension MainTableController
{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        
    }
}

// MARK: - Table view data source
extension MainTableController
{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return examples.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "exampleCell", for: indexPath)
        
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        cell.textLabel?.text = examples[indexPath.row]
        
        return cell
    }
}

// MARK: - Table view delegate
extension MainTableController
{
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch indexPath.row {
        case 0:
            showExample(with: SimpleIntegrationController())
            break
        case 1:
            showExample(with: CellCustomizationController())
            break
        case 2:
            showExample(with: CustomCellController())
            break
        case 3:
            showExample(with: FavoritesController())
            break
        case 4:
            showExample(with: ReaderCustomizationController())
            break
        case 5:
            showExample(with: OnboardingController())
            break
        case 6:
            showExample(with: SingleStoryController())
            break
        case 7:
            showExample(with: UserChangeController())
            break
        case 8:
            showExample(with: TagsPlaceholdersController())
            break
        case 9:
            showExample(with: NotificationsController())
            break
        default:
            break
        }
    }
}

extension MainTableController
{
    fileprivate func showExample(with exampleController: UIViewController)
    {
        self.show(exampleController, sender: nil)
    }
    
    // This method is used to clean up examples and is not recommended for use in real projects.
    fileprivate func resetInAppStory()
    {
        InAppStory.shared.showCellTitle = true
        InAppStory.shared.showCellSource = false
        
        InAppStory.shared.cellBorderColor = .purple
        
        InAppStory.shared.cellFont = UIFont.systemFont(ofSize: 12.0)
        InAppStory.shared.cellTitleColor = .white
        
        InAppStory.shared.cellSourceFont = UIFont.systemFont(ofSize: 12.0)
        InAppStory.shared.cellSourceTitleColor = .black

        InAppStory.shared.swipeToClose = true
        InAppStory.shared.overScrollToClose = true
        
        InAppStory.shared.placeholderElementColor = .white
        InAppStory.shared.placeholderBackgroundColor = .clear
        
        InAppStory.shared.likePanel = false
        InAppStory.shared.favoritePanel = false
        InAppStory.shared.sharePanel = false
        
        InAppStory.shared.placeholderView = nil
        InAppStory.shared.gamePlaceholderView = nil
        
        InAppStory.shared.closeButtonPosition = .right
        InAppStory.shared.scrollStyle = .cover
        InAppStory.shared.presentationStyle = .crossDissolve
        
        InAppStory.shared.likeImage = UIImage(named: "like", in: Bundle(for: InAppStory.self), compatibleWith: nil)!
        InAppStory.shared.likeSelectedImage = UIImage(named: "likeSelected", in: Bundle(for: InAppStory.self), compatibleWith: nil)!
        InAppStory.shared.dislikeImage = UIImage(named: "dislike", in: Bundle(for: InAppStory.self), compatibleWith: nil)!
        InAppStory.shared.dislikeSelectedImage = UIImage(named: "dislikeSelected", in: Bundle(for: InAppStory.self), compatibleWith: nil)!
        InAppStory.shared.favoriteImage = UIImage(named: "bookmark", in: Bundle(for: InAppStory.self), compatibleWith: nil)!
        InAppStory.shared.favoriteSelectedImag = UIImage(named: "bookmarkSelected", in: Bundle(for: InAppStory.self), compatibleWith: nil)!
        InAppStory.shared.shareImage = UIImage(named: "share", in: Bundle(for: InAppStory.self), compatibleWith: nil)!
        InAppStory.shared.shareSelectedImage = UIImage(named: "shareSelected", in: Bundle(for: InAppStory.self), compatibleWith: nil)!
        InAppStory.shared.soundImage = UIImage(named: "sound", in: Bundle(for: InAppStory.self), compatibleWith: nil)!
        InAppStory.shared.soundSelectedImage = UIImage(named: "soundSelected", in: Bundle(for: InAppStory.self), compatibleWith: nil)!
    }
}
