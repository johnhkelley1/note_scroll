//
//  ViewController.swift
//  NoteScroll
//
//  Created by John Kelley on 11/10/15.
//  Copyright © 2015 John Kelley. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var startScrollingButton: UIButton!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var speedSlider: UISlider!
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var fastForwardButton: UIButton!
    @IBOutlet weak var bigUploadMusicButton: UIButton!
    
    let imagePicker = UIImagePickerController()
    var scrollEnd = CGFloat()
    var scrollNext = CGFloat()
    var isScrolling = false
    var speed = 0.01
    var isRewinding = false
    var scrollInc = CGFloat(1)
    
    var playImage = UIImage(named: "play.png") as UIImage?
    var pauseImage = UIImage(named: "pause.png") as UIImage?
    var rewindImage = UIImage(named: "rewind.png") as UIImage?
    var fastForwardImage = UIImage(named: "forward.png") as UIImage?
    
    var timer = NSTimer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        
        scrollView.contentSize = imageView.bounds.size
        
        speedSlider.minimumValue = 1
        speedSlider.maximumValue = 10
        speedSlider.setValue(5.5, animated: false)
        var interval  = NSTimeInterval(speedSlider.value)
        updateSpeed(interval)
        
        //Navigation bar setup
        
        var titleView : UIImageView
        // set the dimensions you want here
        titleView = UIImageView(frame:CGRectMake(0, 0, 40, 70))
        // Set how do you want to maintain the aspect
        titleView.contentMode = .ScaleAspectFit
        titleView.image = UIImage(named: "logo.png")
        titleView.image = resizeImage(titleView.image!, newHeight: 42)
        self.navigationItem.titleView = titleView
        
        //Create upload music button
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Upload Music", style: UIBarButtonItemStyle.Plain, target: self, action: "uploadMusic")
        
        //Create reset music button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: UIBarButtonItemStyle.Plain, target: self, action: "reset")
        
        
        
        playImage = resizeImage(playImage!, newHeight: 120)
        pauseImage = resizeImage(pauseImage!, newHeight: 120)
        rewindImage = resizeImage(rewindImage!, newHeight: 100)
        fastForwardImage = resizeImage(fastForwardImage!, newHeight: 100)
        
        
        changeButtonBg(startScrollingButton, bg: playImage!)
        
        changeButtonBg(rewindButton, bg: rewindImage!)
        changeButtonBg(fastForwardButton, bg: fastForwardImage!)

        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func uploadMusic() {
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    //START SCROLLING BUTTON
    
    @IBAction func startScrollingClicked(sender: AnyObject) {
        if(isScrolling) {
            stopScrolling()
        }
        else {
            startScrolling(speed)
        }

    }
    
    //FAST FORWARD BUTTON
    
    @IBAction func fastForwardClicked(sender: AnyObject) {
        fastForward()
    }
    @IBAction func fastForwardReleased(sender: AnyObject) {
        stopFastForward()
    }
    
    //REWIND BUTTON
    @IBAction func rewindClicked(sender: AnyObject) {
        rewind()
    }
    
    @IBAction func rewindReleased(sender: AnyObject) {
        stopRewind()
    }
    
    //SPEED SLIDER
    @IBAction func speedSliderChanged(sender: AnyObject) {
        var interval = NSTimeInterval(speedSlider.value)
        updateSpeed(interval)
    }
    
    @IBAction func uploadMusicClicked(sender: AnyObject) {
        uploadMusic()
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .ScaleAspectFit
            imageView.image = resizeImage(pickedImage, newHeight: 300)
            bigUploadMusicButton.hidden = true
            
        }
            
            
        print(imageView.bounds.size)
            
        reset()
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func resizeImage(image: UIImage, newHeight: CGFloat) -> UIImage {
        
        let scale = newHeight / image.size.height
        let newWidth = image.size.width * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        scrollView.contentSize = CGSize(width: newWidth, height: newHeight)
        
        return newImage
    }
    
    func startScrolling(speed: NSTimeInterval) {
        print("offset ",scrollView.contentOffset.x)
        print("viewwidth ",scrollView.frame.width)
        print("size ",scrollView.contentSize.width)
        
        scrollEnd = scrollView.contentSize.width - scrollView.frame.width
        
        scrollNext = scrollView.contentOffset.x
    
        timer = NSTimer.scheduledTimerWithTimeInterval(speed, target: self, selector: "scrollMusic", userInfo: nil, repeats: true)
        
        isScrolling = true
        
        scrollInc = 1
        if(isRewinding) {
            scrollInc = -1
        }
        
        changeButtonBg(startScrollingButton, bg: pauseImage!)
        
        //startScrollingButton.setTitle("Stop Scrolling", forState: UIControlState.Normal)
        
    }
    
    func stopScrolling() {
        timer.invalidate()
        isScrolling = false
        
        changeButtonBg(startScrollingButton, bg: playImage!)
        //startScrollingButton.setTitle("Start Scrolling", forState: UIControlState.Normal)
    }
    
    func scrollMusic() {
        if(scrollNext < scrollEnd) {
            scrollView.setContentOffset(CGPoint(x: scrollNext,y: 0), animated: false)
            scrollNext += scrollInc
        }
        else {
            stopScrolling()
        }
    }
    
    //FAST FORWARD
    
    func fastForward() {
        print("yo")
        stopScrolling()
        var doubleSpeed = speed / 3
        startScrolling(doubleSpeed)
    }
    
    func stopFastForward() {
        stopScrolling()
        startScrolling(speed)
    }
    
    //REWIND
    
    func rewind() {
        stopScrolling()
        isRewinding = true
        startScrolling(speed)
    }
    
    func stopRewind() {
        stopScrolling()
        isRewinding = false
        startScrolling(speed)
    }
    
    //SPEED
    func updateSpeed(speedVal: NSTimeInterval) {
        var wasScrolling = isScrolling
        speed = 0.05 / speedVal
        speedLabel.text = String(format: "%.2f", speedVal)
        print(speedLabel.text!)
        stopScrolling()
        if(wasScrolling) {
            startScrolling(speed)
        }
    }
    
    //START SCROLLING BUTTON
    
    func changeButtonBg(button: UIButton, bg: UIImage) {
        
        button.setImage(bg, forState: .Normal)
        button.setTitle("", forState: UIControlState.Normal)
    }
    
    //RESET
    
    func reset() {
        stopScrolling()
        scrollView.setContentOffset(CGPoint(x: 0,y: 0), animated: false)
    }


}

