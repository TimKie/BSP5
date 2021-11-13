//
//  AuthenticationViewModel.swift
//  BSP5
//
//  Created by Tim Kieffer on 22/10/2021.
//

import Foundation
import Firebase
import GoogleSignIn
import GoogleAPIClientForREST


class AuthenticationViewModel: NSObject, ObservableObject {
    // var for making Google Drive API requests
    let googleDriveService = GTLRDriveService()
    var googleUser: GIDGoogleUser?
    var uploadFolderID: String?
    

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
      GIDSignIn.sharedInstance().scopes = [kGTLRAuthScopeDrive]
  }
}


import GTMSessionFetcher

extension AuthenticationViewModel: GIDSignInDelegate {

  // When the user finishes the sign-in flow, GIDSignInDelegate calls this method.
  func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
    if error == nil {
        firebaseAuthentication(withUser: user)
        self.googleDriveService.authorizer = user.authentication.fetcherAuthorizer()
        self.googleUser = user
    } else {
        print(error.debugDescription)
        self.googleDriveService.authorizer = nil
        self.googleUser = nil
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



// -------------------------------------------- Google Drive functions --------------------------------------------
extension AuthenticationViewModel {

    // Search for a folder/file
    public func search(_ fileName: String, onCompleted: @escaping (String?, Error?) -> ()) {
        let query = GTLRDriveQuery_FilesList.query()
        query.pageSize = 1
        query.q = "name contains '\(fileName)'"
            
        googleDriveService.executeQuery(query) { (ticket, results, error) in
            onCompleted((results as? GTLRDrive_FileList)?.files?.first?.identifier, error)
        }
    }
    
    // List Files with folder ID
    public func listFiles(_ folderID: String, onCompleted: @escaping (GTLRDrive_FileList?, Error?) -> ()) {
        let query = GTLRDriveQuery_FilesList.query()
        query.pageSize = 100
        query.q = "'\(folderID)' in parents"
        query.fields = "files(id,name,parents,mimeType)"
            
        googleDriveService.executeQuery(query) { (ticket, result, error) in
            onCompleted(result as? GTLRDrive_FileList, error)
        }
    }
    
    // List files with folder name
    public func listFilesInFolder(_ folder: String, onCompleted: @escaping (GTLRDrive_FileList?, Error?) -> ()) {
        search(folder) { (folderID, error) in
            guard let ID = folderID else {
                onCompleted(nil, error)
                return
            }
            self.listFiles(ID, onCompleted: onCompleted)
        }
    }
    
    // Create a folder
    public func createFolder(_ name: String, parent: String, onCompleted: @escaping (String?, Error?) -> ()) {
        let file = GTLRDrive_File()
        file.name = name
        file.parents = [parent]
        file.mimeType = "application/vnd.google-apps.folder"
            
        let query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: nil)
        query.fields = "id"
            
        googleDriveService.executeQuery(query) { (ticket, folder, error) in
            onCompleted((folder as? GTLRDrive_File)?.identifier, error)
        }
    }
    
    // Download a file using its id
    public func download(_ fileID: String, onCompleted: @escaping (Data?, Error?) -> ()) {
        let query = GTLRDriveQuery_FilesGet.queryForMedia(withFileId: fileID)
        googleDriveService.executeQuery(query) { (ticket, file, error) in
            onCompleted((file as? GTLRDataObject)?.data, error)
        }
    }
    
    // Delete a file using its id
    public func delete(_ fileID: String, onCompleted: ((Error?) -> ())?) {
        let query = GTLRDriveQuery_FilesDelete.query(withFileId: fileID)
        googleDriveService.executeQuery(query) { (ticket, nilFile, error) in
            onCompleted?(error)
        }
    }
}
