//
//  CustomSubviewController.swift
//  InAppSettingsKitSampleApp
//
//  Created by Devesh Mevada on 2/25/15.
//
//

import Foundation

class CustomSubviewController: UIViewController
{
    init() {
        super.init(nibName: "CustomSubviewController", bundle: NSBundle.mainBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}