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
    
    let imagePicker = UIImagePickerController()
    var scrollEnd = CGFloat()
    var scrollNext = CGFloat()
    var isScrolling = false
    var speed = 0.01
    var isRewinding = false
    var scrollInc = CGFloat(1)
    
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
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func uploadMusic(sender: AnyObject) {
        
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
    
    
    
    func imagePickerController(_ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .ScaleAspectFit
            imageView.image = resizeImage(pickedImage, newHeight: 300)
            
        }
            
            
        print(imageView.bounds.size)
        
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
        
        startScrollingButton.setTitle("Stop Scrolling", forState: UIControlState.Normal)
        
    }
    
    func stopScrolling() {
        timer.invalidate()
        isScrolling = false
        startScrollingButton.setTitle("Start Scrolling", forState: UIControlState.Normal)
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


}

