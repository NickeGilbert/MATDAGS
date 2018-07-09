//  CameraVC.swift
//  Matdags
//  Created by Kevin Henriksson on 2017-10-10.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit
import AVFoundation

class CameraVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var image: UIImage?
    
    @IBOutlet var CameraView: UIView!
    @IBOutlet weak var AllowCameraViewOutlet: UIView!
    @IBOutlet weak var flashBtn: UIButton!
    @IBOutlet weak var AllowCameraViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var useOfCameraTitle: UILabel!
    @IBOutlet weak var useOfCameraDescription: UILabel!
    @IBOutlet weak var useOfCameraApproval: UILabel!
    @IBOutlet weak var denyLabel: UILabel!
    @IBOutlet weak var approveLabel: UILabel!
    @IBOutlet weak var thanksLabel: UILabel!
    
    
    
    let imagePicker = UIImagePickerController()
    
    var flashControlState: FlashState = .off
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        useOfCameraTitle.text = NSLocalizedString("useOfCameraTitle", comment: "")
        useOfCameraDescription.text = NSLocalizedString("useOfCameraDescription", comment: "")
        useOfCameraApproval.text = NSLocalizedString("useOfCameraApproval", comment: "")
        denyLabel.text = NSLocalizedString("denyLabel", comment: "")
        approveLabel.text = NSLocalizedString("approveLabel", comment: "")
        thanksLabel.text = NSLocalizedString("thanksLabel", comment: "")
        
        AllowCameraViewTopConstraint.constant = view.frame.height
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            
            self.setupCaptureSession()
            self.setupDevice()
            self.setupInputOutput()
            self.setupPreviewLayer()
            self.startRunningCaptureSession()

        case .notDetermined:
            
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
                self.AllowCameraViewTopConstraint.constant = 0
                self.view.layoutIfNeeded()
            })
            
        case .denied:
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.createAlertCamera(title: "Kan inte använda kameran", message: "För att kunna använda kameran måste du gå in i dina inställningar på telefonen och ge Superfoodie rättigheter till din kamera.")
            }
            return
            
        case .restricted:
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.createAlertCamera(title: "Kan inte använda kameran", message: "Det finns begränsningar som gör att du inte får använda kameran")
            }
            return
            
        }
    }
    
    @IBAction func AllowButtonAction(_ sender: Any) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                DispatchQueue.main.asyncAfter(deadline: .now()) { UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
                    self.AllowCameraViewTopConstraint.constant = self.view.frame.height
                    self.view.layoutIfNeeded()
                    self.setupCaptureSession()
                    self.setupDevice()
                    self.setupInputOutput()
                    self.setupPreviewLayer()
                    self.startRunningCaptureSession()
                })
                }
                
            }else{
                print("NEJ TACK!")
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    @IBAction func DeclineButtonAction(_ sender: Any) {
        print("NEJ TACK IGEN")
        self.dismiss(animated: true, completion: nil)
    }
    

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func captureButton(_ sender: Any) {
        let settings = AVCapturePhotoSettings()
        
        if flashControlState == .off {
            settings.flashMode = .off
        } else {
            settings.flashMode = .on
        }
        
        photoOutput?.capturePhoto(with: settings, delegate: self)

    }
    
    @IBAction func openPhotoLibraryButton(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self
            imagePicker.modalPresentationStyle = .overCurrentContext
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.image = editedImage.self
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.image = originalImage.self
        }
        else {
            print("Error, not original image")
        }
        
        self.imagePicker.dismiss(animated: false) {
            self.performSegue(withIdentifier: "showPhoto", sender: nil)
        }
    }
    
    func setupCaptureSession(){
        print("one")
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func setupDevice() {
        print("two")
        
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices

        for device in devices{
            if device.position == AVCaptureDevice.Position.back{
                backCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                frontCamera = device
            }
        }
        currentCamera = backCamera
    }
    
    func setupInputOutput(){
        
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
            print("three")
        } catch {
            print("\n \(error) \n")
        }
    }
    func setupPreviewLayer(){
        print("four")
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session:captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    func startRunningCaptureSession(){
        print("five")
        captureSession.startRunning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhoto" {
            let previewVC = segue.destination as! ImagePreVC
            previewVC.image = self.image
        }
    }
    
    @IBAction func flashBtnPressed(_ sender: Any) {
        switch flashControlState {
        case .off:
            flashBtn.setBackgroundImage(#imageLiteral(resourceName: "CameraVCFlash"), for: .normal)
            flashControlState = .on
        case .on:
            flashBtn.setBackgroundImage(#imageLiteral(resourceName: "CameraVCFlashOff"), for: .normal)
            flashControlState = .off
        }
    }
}

extension CameraVC: AVCapturePhotoCaptureDelegate{
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(){
            print(imageData)
            image = UIImage(data: imageData)
            performSegue(withIdentifier: "showPhoto", sender: nil)
        }
    }
}
