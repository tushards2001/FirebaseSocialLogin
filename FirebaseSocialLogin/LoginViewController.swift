//
//  ViewController.swift
//  FirebaseSocialLogin
//
//  Created by MacBookPro on 1/11/18.
//  Copyright © 2018 basicdas. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import GoogleSignIn

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate {
    
    let customFBButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Connect to Facebook", for: .normal)
        button.backgroundColor = UIColor.blue
        button.setTitleColor(UIColor.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 2
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.addTarget(self, action: #selector(handleCustomFBButton), for: .touchUpInside)
        return button
    }()
    
    @objc func handleCustomFBButton() {
        if FBSDKAccessToken.current() != nil {
            print("logged in")
            FBSDKLoginManager().logOut()
            self.customFBButton.setTitle("Connect to Facebook", for: .normal)
        } else {
            FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, error) in
                if error != nil {
                    print("Error: ", error!)
                    return
                }
                
                /*if let tokenString = result?.token!.tokenString {
                 print(tokenString)
                 }*/
                
                self.customFBButton.setTitle("Logout", for: .normal)
                
                self.showEmailAddress()
            }
        }
        
        
    }
    
    private func showEmailAddress() {
        let accessToken = FBSDKAccessToken.current()
        
        guard let accessTokenString = accessToken?.tokenString else {
            return
        }
        
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        Auth.auth().signIn(with: credentials) { (user, error) in
            if error != nil {
                print("Something went wrong with our fb user: ", error!)
                return
            }
            
            print("Successfully logged in with user ", user!)
        }
        
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start { (connection, result, error) in
            if error != nil {
                print("Graph request error: ", error!)
                return
            }
            
            print(result!)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationItem.title = "Social Login"
        self.view.backgroundColor = UIColor.white
        
        setupFacebookButtons()
        
        // add google button
        setupGoogleButton()
    }
    
    fileprivate func setupFacebookButtons() {
        let loginButton = FBSDKLoginButton()
        //loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.frame = CGRect(x: 16, y: 100, width: self.view.frame.width - 32, height: 50)
        loginButton.delegate = self
        loginButton.readPermissions = ["email", "public_profile"]
        self.view.addSubview(loginButton)
        
        
        self.view.addSubview(customFBButton)
        
        if FBSDKAccessToken.current() != nil {
            self.customFBButton.setTitle("Logout", for: .normal)
        }
        
        customFBButton.leftAnchor.constraint(equalTo: loginButton.leftAnchor).isActive = true
        customFBButton.rightAnchor.constraint(equalTo: loginButton.rightAnchor).isActive = true
        customFBButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 16).isActive = true
        customFBButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    fileprivate func setupGoogleButton() {
        let googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x: 16, y: 182 + 50, width: self.view.frame.width - 32, height: 50)
        self.view.addSubview(googleButton)
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        let customButton = UIButton(type: .system)
        customButton.frame = CGRect(x: 16, y: 182 + 50 + 66, width: self.view.frame.width - 32, height: 50)
        customButton.backgroundColor = UIColor.orange
        customButton.setTitle("Connect to Google", for: .normal)
        customButton.setTitleColor(UIColor.white, for: .normal)
        customButton.layer.cornerRadius = 2
        customButton.layer.masksToBounds = true
        customButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        customButton.addTarget(self, action: #selector(handleCustomGoogleButton), for: .touchUpInside)
        self.view.addSubview(customButton)
    }
    
    @objc func handleCustomGoogleButton() {
        GIDSignIn.sharedInstance().signIn()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Logged Out")
        self.customFBButton.setTitle("Connect to Facebook", for: .normal)
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print("Login Error: ", error!)
        }
        self.customFBButton.setTitle("Logout", for: .normal)
        
        showEmailAddress()
    }


}

