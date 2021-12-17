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


class GoogleDriveViewModel: NSObject, ObservableObject {
    // var for making Google Drive API requests
    let googleDriveService = GTLRDriveService()
    var googleUser: GIDGoogleUser?
    
    // var for Google Drive functions (@Published means that the view that use these variables will reloadif the variables change)
    @Published var currentFolderID: String = "root"
    @Published var files: [GTLRDrive_File] = []
    @Published var isLoaded: Bool = false
    

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

extension GoogleDriveViewModel: GIDSignInDelegate {

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



// -------------------------------------------- Google Drive functions (queries) --------------------------------------------
extension GoogleDriveViewModel {
    // List files with folder ID
    public func listFiles(_ folderID: String, onCompleted: @escaping (GTLRDrive_FileList?, Error?) -> ()) {
        let query = GTLRDriveQuery_FilesList.query()
        query.pageSize = 100
        query.q = "'\(folderID)' in parents"
        query.fields = "files(id,name,parents,mimeType,thumbnailLink,iconLink,webContentLink,webViewLink)"
            
        googleDriveService.executeQuery(query) { (ticket, result, error) in
            onCompleted(result as? GTLRDrive_FileList, error)
        }
    }
    
    // Update the files of the current folder
    public func updateFiles(enableProgressView: Bool) {
        if enableProgressView {
            self.isLoaded = false
        }
        self.listFiles(currentFolderID) {(file_list, error) in
            guard let l = file_list else {
                return
            }
            //print("------- File List:", l.files!)
        
            self.files = l.files!
            
            self.isLoaded = true
        }
    }
    
    // Create a folder
    public func createFolder(name: String, parent: String) {
        let file = GTLRDrive_File()
        file.name = name
        file.parents = [parent]
        file.mimeType = "application/vnd.google-apps.folder"
            
        let query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: nil)
            
        googleDriveService.executeQuery(query)
    }
    
    // Delete a file using its id
    public func delete(_ fileID: String, onCompleted: ((Error?) -> ())?) {
        let query = GTLRDriveQuery_FilesDelete.query(withFileId: fileID)
        googleDriveService.executeQuery(query) { (ticket, nilFile, error) in
            onCompleted?(error)
        }
    }
    
    // Update the name of a file using its id
    public func updateFileName(fileID: String , newName: String, onCompleted: ((Error?) -> ())?) {
        let newFile = GTLRDrive_File()
        newFile.name = newName
        
        let query = GTLRDriveQuery_FilesUpdate.query(withObject: newFile, fileId: fileID, uploadParameters: nil)
        
        googleDriveService.executeQuery(query) { (ticket, nilFile, error) in
            onCompleted?(error)
        }
    }
    
    // Watch files/folder to enable Push Notifications
    public func watchChanges(onCompleted: ((Error?) -> ())?) {
        let uuid = UUID().uuidString
        let channel = GTLRDrive_Channel(json: [
            "id": uuid,
            "type": "web_hook",
            "address": "https://us-central1-bsp5-329715.cloudfunctions.net/BSP5Notifications",
        ])
        let query = GTLRDriveQuery_ChangesWatch.query(withObject: channel, pageToken: "target=BSP5-ChangesNotification")
        googleDriveService.executeQuery(query) { (ticket, nilFile, error) in
            onCompleted?(error)
        }
    }
}
