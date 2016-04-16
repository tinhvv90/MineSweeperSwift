//
//  Cell.swift
//  MineSweeperSwift
//
//  Created by Tinh on 4/16/16.
//  Copyright © 2016 Tinh. All rights reserved.
//

import UIKit

// This Cell class is the individual blocks in minesweeper game
class Cell : UIView{
    
    //capture the value of cell
    var value:Int!
    //to check the revealed status
    var isRevealed:Bool! = false
    //to check if flagged
    var isFlagged:Bool! = false
    //store the status of mine
    var isMine:Bool! = false
    //captures row number of cell
    var row:Int!
    //capture column number of cell
    var col:Int!
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    init(rect:CGRect){
        super.init(frame: rect)
        //default value
        self.value = 100
    }
    //to set the background color of cell
    func setBG(color :UIColor){
        self.backgroundColor = color
    }
    
    // to set image to cell when revealed
    func setImage(imaged:UIImage){
        self.removeSubView()
        let imageView = UIImageView(image: imaged)
        imageView.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.width, self.bounds.height)
        self.addSubview(imageView)
        
    }
    
    //to remove added sub-views for flags
    func removeSubView(){
        let theSubviews : Array = self.subviews
        for view  in theSubviews {
            view.removeFromSuperview()
        }
    }
}

