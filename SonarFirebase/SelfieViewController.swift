//
//  SelfieViewController.swift
//  
//
//  Created by Brian Endo on 10/2/15.
//
//

import UIKit
import AWSS3
import AVFoundation
import MobileCoreServices

import UIKit

extension UIImage {
    public func imageRotatedByDegrees(degrees: CGFloat, flip: Bool) -> UIImage {
        let radiansToDegrees: (CGFloat) -> CGFloat = {
            return $0 * (180.0 / CGFloat(M_PI))
        }
        let degreesToRadians: (CGFloat) -> CGFloat = {
            return $0 / 180.0 * CGFloat(M_PI)
        }
        
        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPointZero, size: size))
        let t = CGAffineTransformMakeRotation(degreesToRadians(degrees));
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        CGContextTranslateCTM(bitmap, rotatedSize.width / 2.0, rotatedSize.height / 2.0);
        
        //   // Rotate the image context
        CGContextRotateCTM(bitmap, degreesToRadians(degrees));
        
        // Now, draw the rotated/scaled image into the context
        var yFlip: CGFloat
        
        if(flip){
            yFlip = CGFloat(-1.0)
        } else {
            yFlip = CGFloat(1.0)
        }
        
        CGContextScaleCTM(bitmap, yFlip, -1.0)
        CGContextDrawImage(bitmap, CGRectMake(-size.width / 2, -size.height / 2, size.width, size.height), CGImage)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

class SelfieViewController: UIViewController {

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var takeAnotherButton: UIButton!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    var profileImageData: NSData?
    
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.cameraView.frame = CGRectMake(0, 0, 150, 150)
        self.cameraView.layer.cornerRadius = self.cameraView.frame.size.height/2
        self.cameraView.layer.borderWidth = 0.5
        self.cameraView.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.cameraView.clipsToBounds = true
        
        self.imageView.frame = CGRectMake(0, 0, 150, 150)
        self.imageView.layer.cornerRadius = self.cameraView.frame.size.height/2
        self.imageView.layer.borderWidth = 0.5
        self.imageView.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.imageView.clipsToBounds = true
        
        
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        
        var captureDevice: AVCaptureDevice?
        
        var backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        let devices = AVCaptureDevice.devices()
        for device in devices {
            if (device.hasMediaType(AVMediaTypeVideo)) {
                if (device.position == AVCaptureDevicePosition.Back) {
                    
                } else {
                    captureDevice = device as? AVCaptureDevice
                }
            }
        }
        
        var error: NSError?
        var input = AVCaptureDeviceInput(device: captureDevice, error: &error)
        
        if error == nil && captureSession!.canAddInput(input) {
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if captureSession!.canAddOutput(stillImageOutput) {
                captureSession?.addInput(input)
                
                captureSession!.addOutput(stillImageOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
                cameraView.layer.addSublayer(previewLayer)
                
                captureSession!.startRunning()
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if previewLayer?.frame != nil {
            previewLayer!.frame = cameraView.bounds
        } else {
            self.imageView.image = UIImage(named: "BatPic")
            self.messageLabel.text = "Looks like your camera isn't working. It's fine we have a Bat Pic you can use in the meantime."
            self.takeAnotherButton.enabled = false
            self.takePhotoButton.enabled = false
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func takePhotoButtonPressed(sender: UIButton) {
        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    var imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    

                    // Crop Image to the bounds of preview layer
                    var takenImage: UIImage = UIImage(data: imageData)!
                    var outputRect: CGRect = self.previewLayer!.metadataOutputRectOfInterestForRect(self.previewLayer!.bounds)
                    var takenCGImage: CGImageRef = takenImage.CGImage
                    var width = CGFloat(CGImageGetWidth(takenCGImage))
                    var height = CGFloat(CGImageGetHeight(takenCGImage))
                    var cropRect: CGRect = CGRectMake(outputRect.origin.x * width, outputRect.origin.y * height, outputRect.size.width * width, outputRect.size.height * height)
                    var cropCGImage: CGImageRef = CGImageCreateWithImageInRect(takenCGImage, cropRect)
                    takenImage = UIImage(CGImage: cropCGImage, scale: 1, orientation: takenImage.imageOrientation)!
                    
                    var dataProvider = CGDataProviderCreateWithCFData(imageData)
                    var cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, kCGRenderingIntentDefault)
                    var image = UIImage(CGImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.Right)
                    

                    var rotatedPhoto = takenImage.imageRotatedByDegrees(-90, flip: true)
                    let rotatedData = UIImageJPEGRepresentation(rotatedPhoto, 0.01)
                    self.profileImageData = rotatedData
                    
                    let sizeOfImage = image?.size
                    println(sizeOfImage)
                    self.imageView.image = rotatedPhoto
//                    self.imageView.transform = CGAffineTransformMakeScale(-1, 1)
                    self.captureSession?.stopRunning()
                }
            })
        }
    }
    
    
    @IBAction func didPressTakeAnother(sender: AnyObject) {
        self.imageView.image = nil
        
        captureSession!.startRunning()
    }

    
    @IBAction func doneButtonPressed(sender: UIButton) {
        
        if self.profileImageData == nil {
            println("No photo")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainVC = storyboard.instantiateInitialViewController() as! UIViewController
            self.presentViewController(mainVC, animated: true, completion: nil)
        } else {
        // Save image in S3 with the userID
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        let testFileURL1 = NSURL(fileURLWithPath: (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("temp"))
        let uploadRequest1 : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
        
        let data = self.profileImageData
        data!.writeToURL(testFileURL1!, atomically: true)
        uploadRequest1.bucket = S3BucketName
        uploadRequest1.key =  currentUser
        uploadRequest1.body = testFileURL1
        
        
        let task = transferManager.upload(uploadRequest1)
        task.continueWithBlock { (task) -> AnyObject! in
            if task.error != nil {
                print("Error: \(task.error)")
            } else {
                print("Upload successful")
            }
            return nil
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateInitialViewController() as! UIViewController
        self.presentViewController(mainVC, animated: true, completion: nil)
        }
    }
    

}
