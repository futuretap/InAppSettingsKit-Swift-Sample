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
        self.presentViewController(aNavController, animated: true, completion: nil);
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
        popover!.presentPopoverFromBarButtonItem(self.navigationItem.rightBarButtonItem!, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        self.currentPopoverController = popover;
    }
    
    override internal func awakeFromNib()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.settingDidChange(_:)), name: kIASKAppSettingChanged, object: nil)

        if UIDevice.currentDevice().userInterfaceIdiom == .Pad
        {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: #selector(MainViewController.showSettingsPopover(_:)))
        }
    }
    
    // MARK:View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let barViewControllers = self.tabBarController?.viewControllers
        let navigationController = (barViewControllers![1] as! UINavigationController)
        _tabAppSettingsViewController = (navigationController.topViewController as! IASKAppSettingsViewController)
        _tabAppSettingsViewController?.delegate = self
        
        let enabled = NSUserDefaults.standardUserDefaults().boolForKey("AutoConnect")
        if enabled
        {
            self.tabAppSettingsViewController().setHiddenKeys(nil, animated: false)
        }
        else
        {
            var keys = Set<NSObject>();
            keys.insert("AutoConnectLogin")
            keys.insert("AutoConnectPassword")
            self.tabAppSettingsViewController().setHiddenKeys(keys, animated: false)
        }
    }
    
    override func viewWillDisappear(animated:Bool)
    {
        if (self.currentPopoverController != nil)
        {
            dismissCurrentPopover()
        }
        super.viewWillDisappear(animated)
    }
    
    func dismissCurrentPopover()
    {
        self.currentPopoverController?.dismissPopoverAnimated(true);
        self.currentPopoverController = nil;
    }
    
    // MARK: IASKAppSettingsViewControllerDelegate protocol
    func settingsViewControllerDidEnd(sender:IASKAppSettingsViewController)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!)
    {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Table View
    
    func settingsViewController(settingsViewController: IASKViewController, tableView: UITableView!, heightForHeaderForSection section: Int) -> CGFloat
    {
        let key:String = settingsViewController.settingsReader.keyForSection(section);
        
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
        let key: String? = settingsViewController.settingsReader.keyForSection(section);
        if key == "IASKLogo"
        {
            let imageName = "Icon.png"
            let image = UIImage(named: imageName)
            let imageView = UIImageView(image: image!)
            imageView.contentMode = UIViewContentMode.Center
            return imageView;
        }
        else if key == "IASKCustomHeaderStyle"
        {
            let label = UILabel(frame: CGRectZero)
            label.backgroundColor = UIColor.clearColor()
            label.textAlignment = NSTextAlignment.Center
            label.textColor = UIColor.redColor()
            label.shadowColor = UIColor.whiteColor()
            label.shadowOffset = CGSizeMake(0, 1)
            label.numberOfLines = 0
            label.font = UIFont.boldSystemFontOfSize(16)
            label.text = settingsViewController.settingsReader.titleForSection(section)
            return label;
        }
        else
        {
            return nil;
        }
    }
    
    
    func tableView(tableView: UITableView!, heightForSpecifier specifier: IASKSpecifier!) -> CGFloat
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
    
    func tableView(tableView: UITableView!, cellForSpecifier specifier: IASKSpecifier!) -> UITableViewCell!
    {
        
        var cell = tableView.dequeueReusableCellWithIdentifier(specifier.key() as String) as? CustomViewCell
        
        if cell == nil {
            
            cell = NSBundle.mainBundle().loadNibNamed("CustomViewCell", owner: self, options: nil).first as? CustomViewCell
            
        }
        
        let txt: String? = NSUserDefaults.standardUserDefaults().stringForKey(specifier.key())
        
        if  txt != nil
        {
            cell!.textView!.text = NSUserDefaults.standardUserDefaults().stringForKey(specifier.key())
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
        if notification.object?.description == "AutoConnect"
        {
            let activeController:IASKAppSettingsViewController = self.tabBarController!.selectedIndex == 1 ?
                self.tabAppSettingsViewController() : self.appSettingsViewController()
            let enabled = NSUserDefaults.standardUserDefaults().boolForKey("AutoConnect")
            if (enabled)
            {
                activeController.setHiddenKeys(nil, animated: true)
            }
            else
            {
                var keys = Set<NSObject>();
                keys.insert("AutoConnectLogin")
                keys.insert("AutoConnectPassword")
                activeController.setHiddenKeys(keys, animated: true)
            }
        }
    }
    
    
    // MARK: - UITextViewDelegate (for CustomViewCell)
    func textViewDidChange(textView: UITextView)
    {
        NSUserDefaults.standardUserDefaults().setObject(textView.text, forKey: "customCell")
        NSNotificationCenter.defaultCenter().postNotificationName(kIASKAppSettingChanged, object:"customCell", userInfo:nil)
    }
    
    
    // MARK: - UIPopoverControllerDelegate
    func popoverControllerDidDismissPopover(popoverController: UIPopoverController)
    {
        self.currentPopoverController = nil
    }
    
    // MARK: -
    
    func settingsViewController(sender: IASKAppSettingsViewController!, buttonTappedForSpecifier specifier: IASKSpecifier!)
    {
        if specifier.key() == "ButtonDemoAction1"
        {
            let alert = UIAlertController(title: "Demo Action 1 called", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else if specifier.key() == "ButtonDemoAction2"
        {
            let newTitle = NSUserDefaults.standardUserDefaults().stringForKey(specifier.key())
            if newTitle == "Logout"
            {
                NSUserDefaults.standardUserDefaults().setObject("Login", forKey: specifier.key())
            }
            else
            {
                NSUserDefaults.standardUserDefaults().setObject("Logout", forKey: specifier.key())
            }
        }
    }
}