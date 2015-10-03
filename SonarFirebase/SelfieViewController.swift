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

class SelfieViewController: UIViewController {

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.cameraView.frame = CGRectMake(0, 0, 150, 150)
        self.cameraView.layer.cornerRadius = self.cameraView.frame.size.height/2
        self.cameraView.clipsToBounds = true
        
        self.imageView.frame = CGRectMake(0, 0, 150, 150)
        self.imageView.layer.cornerRadius = self.cameraView.frame.size.height/2
        self.imageView.clipsToBounds = true
        
        let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        println(status)
        
        
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
        
        previewLayer!.frame = cameraView.bounds
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
                    
//                    let frame = CGRectMake(self.previewLayer!.bounds.origin.x ,self.previewLayer!.bounds.origin.y , 150, 150)
//                    var pSize = CGSize(width: 150, height: 150)
//                    let bRect = AVMakeRectWithAspectRatioInsideRect(pSize, frame)
                    
                    
                    var dataProvider = CGDataProviderCreateWithCFData(imageData)
                    var cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, kCGRenderingIntentDefault)
                    var image = UIImage(CGImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.Right)
                    
//                    self.imageView.image = self.cropImage(image!, rect: frame)
                    let sizeOfImage = image?.size
                    println(sizeOfImage)
                    self.imageView.image = image
                    self.imageView.transform = CGAffineTransformMakeScale(-1, 1)
                    self.captureSession?.stopRunning()
                }
            })
        }
    }
    
    
    func cropImage(srcImage:UIImage,rect:CGRect) -> UIImage
    {
        var cgImageConv = srcImage.CGImage
//        var cgSizeConv:CGSize = CGSize(width: 150,height: 150)
        var cr:CGImageRef = CGImageCreateWithImageInRect(cgImageConv, rect)
        var cropped:UIImage = UIImage(CGImage: cr)!
        
        return cropped
    }
    
    @IBAction func didPressTakeAnother(sender: AnyObject) {
        self.imageView.image = nil
        
        captureSession!.startRunning()
    }

    
    func RBSquareImage(image: UIImage) -> UIImage {
        var originalWidth  = image.size.width
        var originalHeight = image.size.height
        
        var edge: CGFloat
        if originalWidth > originalHeight {
            edge = originalHeight
        } else {
            edge = originalWidth
        }
        
        var posX = (originalWidth  - edge) / 2.0
        var posY = (originalHeight - edge) / 2.0
        
        var cropSquare = CGRectMake(posX, posY, edge, edge)
        
        var imageRef = CGImageCreateWithImageInRect(image.CGImage, cropSquare);
        return UIImage(CGImage: imageRef, scale: UIScreen.mainScreen().scale, orientation: image.imageOrientation)!
    }

}
