//
//  CustomViewCell.swift
//  InAppSettingsKitSampleApp
//
//  Created by Devesh Mevada on 2/25/15.
//
//

import Foundation


open class CustomViewCell: UITableViewCell
{
    @IBOutlet weak var textView: UITextView?

    override public init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func setSelected(_ selected: Bool, animated: Bool)
    {
        
    }
}
