//
//  AuthenticationViewModel.swift
//  BSP5
//
//  Created by Tim Kieffer on 22/10/2021.
//

import Foundation
import Firebase
import GoogleSignIn

class AuthenticationViewModel: NSObject, ObservableObject {

  // define the sign-in and sign-out state for Google Sign-In
  enum SignInState {
    case signedIn
    case signedOut
  }

  // Manage the authenication state
  @Published var state: SignInState = .signedOut

  // Set up the Google Sign-In funtion
  override init() {
    super.init()

    setupGoogleSignIn()
  }

  // SignIn method that shows the Google Sign-In screen as a model
  func signIn() {
    if GIDSignIn.sharedInstance().currentUser == nil {
      GIDSignIn.sharedInstance().presentingViewController = UIApplication.shared.windows.first?.rootViewController
      GIDSignIn.sharedInstance().signIn()
    }
  }

  // SignOut method
  func signOut() {
    GIDSignIn.sharedInstance().signOut()

    do {
      try Auth.auth().signOut()

      state = .signedOut
    } catch let signOutError as NSError {
      print(signOutError.localizedDescription)
    }
  }

  // Set the delegate of GIDSignIn to self so that AuthenticationViewModel receives the update from this class
  private func setupGoogleSignIn() {
    GIDSignIn.sharedInstance().delegate = self
  }
}


extension AuthenticationViewModel: GIDSignInDelegate {

  // When the user finishes the sign-in flow, GIDSignInDelegate calls this method.
  func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
    if error == nil {
      firebaseAuthentication(withUser: user)
    } else {
      print(error.debugDescription)
    }
  }

  // Authenticate the user using firebase and sign in to firebase
  private func firebaseAuthentication(withUser user: GIDGoogleUser) {
    if let authentication = user.authentication {
      let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)

      Auth.auth().signIn(with: credential) { (_, error) in
        if let error = error {
          print(error.localizedDescription)
        } else {
          self.state = .signedIn
        }
      }
    }
  }
}
