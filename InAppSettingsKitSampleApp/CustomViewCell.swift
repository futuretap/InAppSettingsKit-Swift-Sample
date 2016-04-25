//
//  CustomViewCell.swift
//  InAppSettingsKitSampleApp
//
//  Created by Devesh Mevada on 2/25/15.
//
//

import Foundation


class CustomViewCell: UITableViewCell
{
    @IBOutlet weak var textView: UITextView?

    func initWithStyle(style: UITableViewCellStyle, reuseIdentifier: String) -> AnyObject
    {
        return self
    }
    
    override func setSelected(selected: CBool, animated: CBool)
    {
        
    }
}