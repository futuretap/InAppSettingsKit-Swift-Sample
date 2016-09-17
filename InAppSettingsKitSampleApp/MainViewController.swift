//
//  MainViewController.swift
//  InAppSettingsKitSampleApp
//
//  Created by Devesh Mevada on 2/24/15.
//
//

import Foundation



class MainViewController: UIViewController, UITextViewDelegate, UIPopoverControllerDelegate, IASKSettingsDelegate
{
    private var _appSettingsViewController : IASKAppSettingsViewController? = nil
    private var _tabAppSettingsViewController : IASKAppSettingsViewController? = nil
    
    func appSettingsViewController() -> IASKAppSettingsViewController {
        if _appSettingsViewController == nil {
            _appSettingsViewController = IASKAppSettingsViewController()
            _appSettingsViewController!.delegate = self
        }
        
        return _appSettingsViewController!
    }
    
    func tabAppSettingsViewController() -> IASKAppSettingsViewController {
        return _tabAppSettingsViewController!
    }
    
    var currentPopoverController: UIPopoverController?
    
    //@IBOutlet weak var tabAppSettingsViewController: IASKAppSettingsViewController?
    
    
    
    @IBAction func showSettingsPush(sender: UIButton)
    {
        self.appSettingsViewController().showDoneButton = false;
        self.appSettingsViewController().navigationItem.rightBarButtonItem = nil;
        self.navigationController?.pushViewController(self.appSettingsViewController(), animated: true)
    }
    
    @IBAction func showSettingsModal(sender: UIButton)
    {
        let aNavController:UINavigationController = UINavigationController(rootViewController: self.appSettingsViewController());
        self.appSettingsViewController().showDoneButton = true;
        self.present(aNavController, animated: true, completion: nil);
    }
    
    func showSettingsPopover(sender: AnyObject)
    {
        if self.currentPopoverController != nil
        {
            dismissCurrentPopover();
            return;
        }
        
        self.appSettingsViewController().showDoneButton = false;
        let aNavController:UINavigationController = UINavigationController(rootViewController: self.appSettingsViewController());
        var popover: UIPopoverController? = nil
        popover = UIPopoverController(contentViewController: aNavController)
        popover!.delegate = self
        popover!.present(from: self.navigationItem.rightBarButtonItem!, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
        self.currentPopoverController = popover;
    }
    
    override internal func awakeFromNib()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.settingDidChange), name: NSNotification.Name(rawValue: kIASKAppSettingChanged), object: nil)

        if UIDevice.current.userInterfaceIdiom == .pad
        {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(MainViewController.showSettingsPopover))
        }
    }
    
    // MARK:View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let barViewControllers = self.tabBarController?.viewControllers
        let navigationController = (barViewControllers![1] as! UINavigationController)
        _tabAppSettingsViewController = (navigationController.topViewController as! IASKAppSettingsViewController)
        _tabAppSettingsViewController?.delegate = self
        
        let enabled = UserDefaults.standard.bool(forKey: "AutoConnect")
        if enabled
        {
            self.tabAppSettingsViewController().setHiddenKeys(nil, animated: false)
        }
        else
        {
            var keys = Set<NSObject>();
            keys.insert("AutoConnectLogin" as NSObject)
            keys.insert("AutoConnectPassword" as NSObject)
            self.tabAppSettingsViewController().setHiddenKeys(keys, animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated:Bool)
    {
        if (self.currentPopoverController != nil)
        {
            dismissCurrentPopover()
        }
        super.viewWillDisappear(animated)
    }
    
    func dismissCurrentPopover()
    {
        self.currentPopoverController?.dismiss(animated: true);
        self.currentPopoverController = nil;
    }
    
    // MARK: IASKAppSettingsViewControllerDelegate protocol
    func settingsViewControllerDidEnd(_ sender:IASKAppSettingsViewController)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!)
    {
        controller.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table View
    
    func settingsViewController(settingsViewController: IASKViewController, tableView: UITableView!, heightForHeaderForSection section: Int) -> CGFloat
    {
        let key:String = settingsViewController.settingsReader.key(forSection: section);
        
        if key == "IASKLogo"
        {
            return (UIImage(named:"Icon.png")?.size.height)!+25;
        }
        else if key == "IASKCustomHeaderStyle"
        {
            return 55.0;
        }
        else
        {
            return 0;
        }
    }
    
    func settingsViewController(settingsViewController: IASKViewController, tableView: UITableView!, viewForHeaderForSection section: Int) -> UIView!
    {
        let key: String? = settingsViewController.settingsReader.key(forSection: section);
        if key == "IASKLogo"
        {
            let imageName = "Icon.png"
            let image = UIImage(named: imageName)
            let imageView = UIImageView(image: image!)
            imageView.contentMode = UIViewContentMode.center
            return imageView;
        }
        else if key == "IASKCustomHeaderStyle"
        {
            let label = UILabel(frame: CGRect.zero)
            label.backgroundColor = UIColor.clear
            label.textAlignment = NSTextAlignment.center
            label.textColor = UIColor.red
            label.shadowColor = UIColor.white
            label.shadowOffset = CGSizeMake(0, 1)
            label.numberOfLines = 0
            label.font = UIFont.boldSystemFont(ofSize: 16)
            label.text = settingsViewController.settingsReader.title(forSection: section)
            return label;
        }
        else
        {
            return nil;
        }
    }
    
    
    func tableView(_ tableView: UITableView!, heightFor specifier: IASKSpecifier!) -> CGFloat
    {
        if specifier.key() == "customCell"
        {
            return 44*3;
        }
        else
        {
            return 0;
        }
    }
    
    func tableView(_ tableView: UITableView!, cellFor specifier: IASKSpecifier!) -> UITableViewCell!
    {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: specifier.key() as String) as? CustomViewCell
        
        if cell == nil {
            
            cell = Bundle.main.loadNibNamed("CustomViewCell", owner: self, options: nil)?.first as? CustomViewCell
            
        }
        
        let txt: String? = UserDefaults.standard.string(forKey: specifier.key())
        
        if  txt != nil
        {
            cell!.textView!.text = UserDefaults.standard.string(forKey: specifier.key())
        }
        else
        {
            cell!.textView!.text = specifier.defaultStringValue() as? String
        }
        
        cell!.textView?.delegate = self
        
//        cell!.textLabel?.delete(self)
//        cell!.setNeedsDisplay()
        return cell;
    }
    
    // MARK: - kIASKAppSettingChanged notification
    
    func settingDidChange(notification: NSNotification!)
    {
        if (notification.object as AnyObject).description == "AutoConnect"
        {
            let activeController:IASKAppSettingsViewController = self.tabBarController!.selectedIndex == 1 ?
                self.tabAppSettingsViewController() : self.appSettingsViewController()
            let enabled = UserDefaults.standard.bool(forKey: "AutoConnect")
            if (enabled)
            {
                activeController.setHiddenKeys(nil, animated: true)
            }
            else
            {
                var keys = Set<NSObject>();
                keys.insert("AutoConnectLogin" as NSObject)
                keys.insert("AutoConnectPassword" as NSObject)
                activeController.setHiddenKeys(keys, animated: true)
            }
        }
    }
    
    
    // MARK: - UITextViewDelegate (for CustomViewCell)
    func textViewDidChange(textView: UITextView)
    {
        UserDefaults.standard.set(textView.text, forKey: "customCell")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kIASKAppSettingChanged), object:"customCell")
    }
    
    
    // MARK: - UIPopoverControllerDelegate
    func popoverControllerDidDismissPopover(_ popoverController: UIPopoverController)
    {
        self.currentPopoverController = nil
    }
    
    // MARK: -
    
    func settingsViewController(_ sender: IASKAppSettingsViewController!, buttonTappedFor specifier: IASKSpecifier!)
    {
        if specifier.key() == "ButtonDemoAction1"
        {
            let alert = UIAlertController(title: "Demo Action 1 called", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            sender.present(alert, animated: true, completion: nil)
        }
        else if specifier.key() == "ButtonDemoAction2"
        {
            let newTitle = UserDefaults.standard.string(forKey: specifier.key())
            if newTitle == "Logout"
            {
                UserDefaults.standard.set("Login", forKey: specifier.key())
            }
            else
            {
                UserDefaults.standard.set("Logout", forKey: specifier.key())
            }
        }
    }
}
