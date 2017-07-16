//
//  SigninVC.swift
//  SocialApp
//
//  Created by Lassale Elmahdi on 11/07/2017.
//  Copyright © 2017 Lassale Elmahdi. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth
import SwiftKeychainWrapper

class SigninVC: UIViewController {

    
    @IBOutlet weak var emailText: FancyField!
    @IBOutlet weak var pwdText: FancyField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let _ =  KeychainWrapper.standard.string(forKey: KEY_UID){
        
            print("Mehdi: id found in keyChain")
            performSegue(withIdentifier: "ToFeed", sender: nil)
        }
    }

    @IBAction func fbLooginBtnTapped(_ sender: Any) {
        
        let facebookLign = FBSDKLoginManager()
        facebookLign.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            
            if error != nil{
            
                print("Mehdi: Inable to authenticate with facebook - \(String(describing: error))")
                
            }else if result?.isCancelled == true{
                
               print("Mehdi: User cancelled facebeook Authentification")
                
            }else{
            
                print("Mehdi: Successfully authentificate with facebook")
                let credential = FirebaseAuth.FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
                
        }
    }
    
    func firebaseAuth(_ credential: AuthCredential){
    
        FirebaseAuth.Auth.auth().signIn(with: credential) { (user, err) in
            
            if err != nil{
            
                print("Mehdi: Unable to authentificate with firebase - \(String(describing: err))")
                
            }else{
            
                print("Mehdi: Successfully authentificate with firbase")
                if let user = user {
                    
                    self.completeSignIn(id: user.uid)
                }
            }
        }
    }

    
    @IBAction func signInBtnTapped(_ sender: Any) {
        
        if let email = emailText.text, let password = pwdText.text{
        
            FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { (user, err) in
                
                if err == nil {
                
                    print("Mehdi: Successfull email authentification")
                    if let user = user{
                    
                        self.completeSignIn(id: user.uid)
                    }
                }else{
                
                    FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { (user, err) in
                        if err != nil{
                        
                            print("Mehdi: Unable to authentificate with firebase")
                            
                        }else{
                        
                            print("Mehdi: Successfully authentificate with firbase")
                            if let user = user {
                                self.completeSignIn(id: user.uid)
                            }
                        }
                    })
                }
            })
        }
    }
    
    func completeSignIn(id:String){
        let keychain = KeychainWrapper.standard.set((id), forKey: KEY_UID)
        print("Mehdi: Data saved to keychain \(keychain)")
        performSegue(withIdentifier: "ToFeed", sender: nil)
    }

}









