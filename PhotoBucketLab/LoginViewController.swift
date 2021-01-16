//
//  LoginViewController.swift
//  PhotoBucketLab
//
//  Created by Hanyu Yang on 2021/1/15.
//

import UIKit
import Firebase
import Rosefire
import GoogleSignIn

class LoginViewController: UIViewController {
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var githubSignInButton: UIButton!
    
    let showListSegueIdentifier = "ShowListSegue"
    let REGISTRY_TOKEN = "addbbde2-8bf9-4dd7-af05-fb01e47a27dc"
    
    var provider = OAuthProvider(providerID: "github.com")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        signInButton.style = .wide
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
            print("Someone is already signed in! Just move on!")
            self.performSegue(withIdentifier: self.showListSegueIdentifier, sender: self)
        }
    }
    
    
    @IBAction func pressedRoseLogin(_ sender: Any) {
        Rosefire.sharedDelegate().uiDelegate = self // This should be your view controller
        Rosefire.sharedDelegate().signIn(registryToken: REGISTRY_TOKEN) { (err, result) in
            if let err = err {
                print("Rosefire sign in error! \(err)")
                return
            }
            //print("Result = \(result!.token!)")
            print("Result = \(result!.username!)")
            print("Result = \(result!.name!)")
            print("Result = \(result!.email!)")
            print("Result = \(result!.group!)")
            
            Auth.auth().signIn(withCustomToken: result!.token) { (authResult, error) in
                if let error = error {
                    print("Firebase sign in error! \(error)")
                    return
                }
                // User is signed in using Firebase!
                self.performSegue(withIdentifier: self.showListSegueIdentifier, sender: self)
            }
        }
    }
    @IBAction func pressedGithubLoginButton(_ sender: Any) {
        provider.getCredentialWith(nil) { credential, error in
            if error != nil {
                // Handle error.
            }
            if credential != nil {
                Auth.auth().signIn(with: credential!) { (authResult, error) in
                    if error != nil {
                        // Handle error.
                    }
                    // User is signed in.
                    // IdP data available in authResult.additionalUserInfo.profile.
                    self.performSegue(withIdentifier: self.showListSegueIdentifier, sender: self)
                    //guard let oauthCredential = authResult!.credential as? OAuthCredential else { return }
                    // GitHub OAuth access token can also be retrieved by:
                    // oauthCredential.accessToken
                    // GitHub OAuth ID token can be retrieved by calling:
                    // oauthCredential.idToken
//                    Auth.auth().currentUser?.link(with: oauthCredential, completion: { (authResult, error) in
//                        if let error = error {
//                            print("Firebase github sign in error! \(error)")
//                            return
//                        }
//                        // User is signed in using Firebase!
//                        self.performSegue(withIdentifier: self.showListSegueIdentifier, sender: self)
//                    })
                }
            }
        }
    }
}
