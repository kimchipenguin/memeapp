//
//  ViewController.swift
//  memeapp
//
//  Created by Mia Jaap on 12.09.17.
//  Copyright © 2017 Mia Jaap. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var textFieldTop: UITextField!
    @IBOutlet weak var textFieldDown: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var appToolbar: UIToolbar!
    
    let memeTextAttributes:[String:Any] = [
        NSStrokeColorAttributeName: UIColor.black,
        NSForegroundColorAttributeName: UIColor.white,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName: 4
    ]
    override func viewDidLoad() {
        textFieldTop.returnKeyType = UIReturnKeyType.done
        textFieldTop.delegate = self
        textFieldDown.returnKeyType = UIReturnKeyType.done
        textFieldDown.delegate = self
        super.viewDidLoad()

    }
    override func viewWillAppear(_ animated: Bool) {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        textFieldTop.defaultTextAttributes = memeTextAttributes
        textFieldDown.defaultTextAttributes = memeTextAttributes
        shareButton.isEnabled = false
        subscribeToKeyboardNotifications()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    func keyboardWillShow(_ notification:Notification) {
        view.frame.origin.y = 0 - getKeyboardHeight(notification)
    }
    func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    }
    @IBAction func pickAnImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            /// if user update it and already got it , just return it to 'self.imgView.image'
            self.imagePickerView.image = editedImage
            enableSharing()
        } else if let orginalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imagePickerView.image = orginalImage
            enableSharing()
        }
        else { print ("error")
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func enableSharing() {
        DispatchQueue.main.async(execute: {
            self.shareButton.isEnabled = true
        })
        
    }
    @IBAction func shareMeme(_ sender: Any) {
        let finishedMeme = save()
        
        let imageShare = [ finishedMeme.memedImage ]
        let activityView = UIActivityViewController(activityItems: imageShare, applicationActivities: nil)
        activityView.popoverPresentationController?.sourceView = self.view
        self.present(activityView, animated: true, completion: nil)
    }
    func generateMemedImage() -> UIImage {
        
        // Hide toolbar
        appToolbar.isHidden = true
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show toolbar
        appToolbar.isHidden = false
        
        return memedImage
    }
    func save() -> Meme {
        let memedImage = generateMemedImage()
        let meme = Meme(topText: textFieldTop.text!, bottomText: textFieldDown.text!, originalImage: imagePickerView.image!, memedImage: memedImage)
        return meme
    }
}

