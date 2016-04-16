//
//  ViewController.swift
//  MineSweeperSwift
//
//  Created by Tinh on 4/16/16.
//  Copyright © 2016 Tinh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var nowScore: UILabel!//to display score
    @IBOutlet weak var highScore: UILabel!//to display number of mines
    //handle for easy button
    @IBOutlet weak var easyButton: UIButton!
    //handle for medium button
    @IBOutlet weak var mediumButton: UIButton!
    //handle for hard button
    @IBOutlet weak var hardButton: UIButton!
    // Number of cells per row/column
    var number = 15
    // Percentage og mine cells
    var percent_Mines = 15
    //to capture total number of mines
    var total_mines = 0
    //to capture the maximum height of the board
    var b_height:CGFloat = 0.0
    //to capture the width of the board
    var b_width:CGFloat = 0.0
    //height of each cell
    var db_height:CGFloat = 0.0
    //width of each cell
    var db_width:CGFloat = 0.0
    //the board view
    let newRec = UIView()
    //capture cells
    var array = [[Cell]]()
    //to know the number of cells revealed
    var numberRevealed = 0
    //if game over
    var gameOver:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.number = 15
        
        self.hardButton.backgroundColor = UIColor.lightGrayColor()
        //percent_Mines % of the cells are mines
        total_mines = ((number * number) * percent_Mines)/100
        
        let screen = self.view.bounds
        b_height = screen.size.height - 100
        b_width = screen.size.width-10
        db_height = b_height/CGFloat(number)
        db_width = b_width/CGFloat(number)
        
        //populate array dummy one
        initalize()
        
        newRec.frame = CGRectMake(5, 125, b_width,b_width)
        newRec.backgroundColor = UIColor.whiteColor()
        
        //add individual cells to newRect
        setLayout()
        
        self.view.addSubview(newRec)
        //set Mines in the cells ramdomly
        setMines()
        //set numbers to cells that are adjacent to mines
        setNumbers()
        //show the number of mines and no of games won
        self.updateUI()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //to add cells to board layout
    func setLayout(){
        for(var i=0;i<number;i++){
            for(var j=0;j<number;j++){
                let rect :CGRect = CGRectMake((CGFloat(i) * db_width)+1, (CGFloat(j) * db_width)+1, db_width-2,db_width-2)
                
                let cell = Cell(rect: rect)
                
                cell.setBG(UIColor.grayColor())
                self.newRec.addSubview(cell)
                
                let tap_d = UITapGestureRecognizer(target: self, action: Selector("board_Doubletap:"))
                tap_d.numberOfTapsRequired = 2
                cell.userInteractionEnabled = true
                cell.addGestureRecognizer(tap_d)
                
                let tap_s = UITapGestureRecognizer(target: self, action: Selector("board_Singletap:"))
                tap_s.numberOfTapsRequired = 1
                tap_s.requireGestureRecognizerToFail(tap_d)
                cell.userInteractionEnabled = true
                cell.addGestureRecognizer(tap_s)
                
                cell.row = i
                cell.col = j
                array[i][j]=(cell)
            }
        }
    }
    
    //system call when memory warning is received
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //to reset game manually
    @IBAction func buttonTapped(sender: UIButton) {
        self.reset()
        //array[0][0].view.backgroundColor = UIColor.greenColor()
    }
    
    //to handle single tap gestures
    func board_Singletap(sender: UITapGestureRecognizer) {
        let cell =  sender.view as! Cell
        if(cell.isRevealed ==  false){
            if(cell.isFlagged == false){
                if let image = UIImage(named: "flag.png") {
                    cell.setImage(image)
                }
                cell.isFlagged = true
            }
            else{
                cell.removeSubView()
                cell.isFlagged = false
            }
        }
    }
    
    //to handle double tap gestures
    func board_Doubletap(sender: UITapGestureRecognizer) {
        let cell =  sender.view as! Cell
        if(cell.isRevealed ==  false){
            if(cell.isMine ==  false){
                if(isPropagate(cell)){
                    inPropogate(cell)
                }
                else{
                    reveal(cell)
                }
            }
            else{
                cell.setImage(UIImage(named: "mine.png")!)
                blast()
                cell.isRevealed =  true
            }
        }
        if(checkIfWon()){
            gameWon();
        }
        
    }
    
    //to revel the cell value
    func reveal(cell:Cell){
        if(cell.value>0){
            print(cell.value)
            cell.setImage(getNumberFlag(cell.value))
        }
        else{
            cell.setImage(UIImage(named: "empty.jpg")!)
        }
        cell.isRevealed =  true
        numberRevealed++;
    }
    
    //for initial propagate when the adjacent cells are not revealed
    func inPropogate(cell:Cell){
        
        if(cell.isMine == false && cell.isRevealed == false ){
            reveal(cell)
            if(cell.row != 0){
                propogate(array[cell.row-1][cell.col])
            }
            if(cell.row != number - 1){
                propogate(array[cell.row+1][cell.col])
            }
            if(cell.col != number - 1){
                propogate(array[cell.row][cell.col+1])
            }
            if(cell.col != 0){
                propogate(array[cell.row][cell.col-1])
            }
        }
    }
    
    //recursive reveal call for the double tap when the adjacent cells are not revea;ed
    func propogate(cell:Cell){
        
        if(cell.isMine == false && cell.isRevealed == false ){
            reveal(cell)
            if(cell.value == 0){
                if(cell.row != 0){
                    propogate(array[cell.row-1][cell.col])
                }
                if(cell.row != number - 1){
                    propogate(array[cell.row+1][cell.col])
                }
                if(cell.col != number - 1){
                    propogate(array[cell.row][cell.col+1])
                }
                if(cell.col != 0){
                    propogate(array[cell.row][cell.col-1])
                }
            }
        }
    }
    
    //cehck if to call propogate, when its adjacent cells are not revealed
    func isPropagate(cell:Cell)->Bool{
        if(cell.isMine == false){
            
            if(cell.value == 0){
                if(cell.row != 0){
                    if(array[cell.row-1][cell.col].isRevealed == true){
                        return false
                    }
                }
                if(cell.row != number - 1){
                    if(array[cell.row+1][cell.col].isRevealed == true){
                        return false
                    }
                }
                if(cell.col != number - 1){
                    if(array[cell.row][cell.col+1].isRevealed == true){
                        return false
                    }
                }
                if(cell.col != 0){
                    if(array[cell.row][cell.col-1].isRevealed == true){
                        return false
                    }
                }
            }
        }
        return true
    }
    
    
    //Random number generation method with in some bounds
    func random(var start:Int,end:Int)->Int{
        let num=end - start
        if(start == -1){ start = 0}
        return start+Int(arc4random_uniform(UInt32(num)))
    }
    
    //randomly place percent_Mines% of the mines in different locations
    func setMines(){
        var row:Int
        var col:Int
        var i = 0
        while(i != total_mines){
            row=random(0, end: number)
            col=random(0, end: number)
            if(array[row][col].isMine == false ){
                array[row][col].isMine = true
                i++
            }
        }
    }
    
    //to set numbers to adjacent cells of mines
    func setNumbers(){
        for(var i=0;i<number;i++){
            for(var j=0;j<number;j++){
                if(array[i][j].isMine != true){
                    array[i][j].value = findCount(i,j:j)
                }
            }
        }
    }
    
    //to get the numbered flag image
    func getNumberFlag(number:Int)->UIImage{
        var image:UIImage!
        switch number {
        case 0:
            image = UIImage()
        case 1..<9:
            image = UIImage(named: String(number)+".png");
            
        default:
            image = UIImage()
        }
        return image
    }
    
    //to find the number of mines surrounding a cell
    func findCount(i:Int,j:Int)->Int{
        var count = 0
        if(i != 0 ){
            if(j != 0){
                if(array[i-1][j-1].isMine == true){
                    count++
                }
            }
            if(array[i-1][j].isMine == true){
                count++
            }
            if(j != number - 1){
                if(array[i-1][j+1].isMine == true){
                    count++
                }
            }
        }
        if(i != number - 1 ){
            if(j != 0){
                if(array[i+1][j-1].isMine == true){
                    count++
                }
            }
            if(array[i+1][j].isMine == true){
                count++
            }
            if(j != number - 1){
                if(array[i+1][j+1].isMine == true){
                    count++
                }
            }
        }
        if(j != 0){
            if(array[i][j-1].isMine == true){
                count++
            }
        }
        if(j != number - 1){
            if(array[i][j+1].isMine == true){
                count++
            }
        }
        return count
    }
    
    //initialize cell capture array with dummy values
    func initalize()    {
        self.array = [[Cell]]()
        for _ in 0 ..< number {
            var arrayRow:[Cell] = []
            for _ in 0 ..< number {
                let cell = Cell(rect: CGRectMake((CGFloat(0) * db_width)+1, (CGFloat(0) * db_width)+1, db_width-2,db_width-2))
                arrayRow.append(cell)
            }
            self.array.append(arrayRow)
        }
    }
    
    //to handle a case of when the user tried to reveal mine cell
    func blast(){
        for(var i=0;i<number;i++){
            for(var j=0;j<number;j++){
                if(array[i][j].isMine == true){
                    array[i][j].setImage(UIImage(named: "mine.png")!)
                    array[i][j].isRevealed = true
                }
            }
        }
        gameOver = true
        toast("Game Over",message: "You can play better!")
        
    }
    
    //toast Message for game over, win or lose
    func toast(title:String,message:String){
        let alert = UIAlertController( title:title,
            message: message,
            preferredStyle: UIAlertControllerStyle.Alert )
        let defaultAction = UIAlertAction( title: "Reset Game",
            style: UIAlertActionStyle.Default,
            handler: { (UIAlertAction  action) in self.reset() } )
        
        alert.addAction( defaultAction )
        self.presentViewController( alert, animated: true, completion: nil )
        
    }
    
    //check if all the mines are identified
    func checkIfWon()->Bool{
        let totalCount = number*number
        if(totalCount - numberRevealed == total_mines){
            return true
        }
        else{
            return false
        }
    }
    
    //uodate score and number of mines initially
    func updateUI(){
        let defaults = NSUserDefaults.standardUserDefaults()
        let Score = defaults.integerForKey( "Score" )
        
        nowScore.text = String(Score)
        highScore.text = String(total_mines)
        
    }
    
    //handle the case if games is won
    func gameWon(){
        let defaults = NSUserDefaults.standardUserDefaults()
        let Score = defaults.integerForKey( "Score" )
        defaults.setInteger( Score+1, forKey: "Score" )
        toast("Game Over",message: "Yay! you won!!")
    }
    
    //manual or automatic reset after the game is iver
    func reset(){
        initalize()
        gameOver = false
        numberRevealed = 0
        newRec.frame = CGRectMake(5, 125, b_width,b_width)
        newRec.backgroundColor = UIColor.whiteColor()
        setLayout()
        self.view.addSubview(newRec)
        setMines()
        setNumbers()
        self.updateUI()
    }
    
    //to remove the sumview if added any, no used here
    func removeSubView(view:UIView){
        let theSubviews : Array = view.subviews
        for view  in theSubviews {
            view.removeFromSuperview()
        }
    }
    
    //easy button Implementation
    @IBAction func easyButtonHandle(sender: UIButton) {
        sender.backgroundColor = UIColor.lightGrayColor()
        mediumButton.backgroundColor = UIColor.whiteColor()
        hardButton.backgroundColor = UIColor.whiteColor()
        self.number = 5
        self.removeSubView(newRec)
        //percent_Mines % of the cells are mines
        total_mines = ((number * number) * percent_Mines)/100
        
        db_height = b_height/CGFloat(number)
        db_width = b_width/CGFloat(number)
        print("\(db_height)   \(db_width)")
        self.reset()
    }
    
    //medium button Implementation
    @IBAction func mediumButtonHandle(sender: UIButton) {
        sender.backgroundColor = UIColor.lightGrayColor()
        easyButton.backgroundColor = UIColor.whiteColor()
        hardButton.backgroundColor = UIColor.whiteColor()
        self.number = 10
        self.removeSubView(newRec)
        //percent_Mines % of the cells are mines
        total_mines = ((number * number) * percent_Mines)/100
        
        db_height = b_height/CGFloat(number)
        db_width = b_width/CGFloat(number)
        print("\(db_height)   \(db_width)")
        self.reset()
    }
    
    //medium button Implementation
    @IBAction func hardButtonHandle(sender: UIButton) {
        sender.backgroundColor = UIColor.lightGrayColor()
        easyButton.backgroundColor = UIColor.whiteColor()
        mediumButton.backgroundColor = UIColor.whiteColor()
        self.number = 15
        self.removeSubView(newRec)
        //percent_Mines % of the cells are mines
        total_mines = ((number * number) * percent_Mines)/100
        
        db_height = b_height/CGFloat(number)
        db_width = b_width/CGFloat(number)
        print("\(db_height)   \(db_width)")
        self.reset()
    }
}