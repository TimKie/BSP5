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
    
    // Case-insensitive search for a specified folder by name
    func getFolderID(
        name: String,
        service: GTLRDriveService,
        user: GIDGoogleUser,
        completion: @escaping (String?) -> Void) {
        
        let query = GTLRDriveQuery_FilesList.query()

        // Comma-separated list of areas the search applies to. E.g., appDataFolder, photos, drive.
        query.spaces = "drive"
        
        // Comma-separated list of access levels to search in. Some possible values are "user,allTeamDrives" or "user"
        query.corpora = "user"
            
        let withName = "name = '\(name)'" // Case insensitive!
        let foldersOnly = "mimeType = 'application/vnd.google-apps.folder'"
        let ownedByUser = "'\(user.profile!.email!)' in owners"
        query.q = "\(withName) and \(foldersOnly) and \(ownedByUser)"
        
        service.executeQuery(query) { (_, result, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
                                     
            let folderList = result as! GTLRDrive_FileList

            // For brevity, assumes only one folder is returned.
            completion(folderList.files?.first?.identifier)
        }
    }
    
    
    
    // Create a folder
    func createFolder(
        name: String,
        service: GTLRDriveService,
        completion: @escaping (String) -> Void) {
        
        let folder = GTLRDrive_File()
        folder.mimeType = "application/vnd.google-apps.folder"
        folder.name = name
        
        // Google Drive folders are files with a special MIME-type.
        let query = GTLRDriveQuery_FilesCreate.query(withObject: folder, uploadParameters: nil)
        
        service.executeQuery(query) { (_, file, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            
            let folder = file as! GTLRDrive_File
            completion(folder.identifier!)
        }
    }
    
    // Upload a file
    func uploadFile(
        name: String,
        folderID: String,
        fileURL: URL,
        mimeType: String,
        service: GTLRDriveService) {
        
        let file = GTLRDrive_File()
        file.name = name
        file.parents = [folderID]
        
        // Optionally, GTLRUploadParameters can also be created with a Data object.
        let uploadParameters = GTLRUploadParameters(fileURL: fileURL, mimeType: mimeType)
        
        let query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: uploadParameters)
        
        service.uploadProgressBlock = { _, totalBytesUploaded, totalBytesExpectedToUpload in
            // This block is called multiple times during upload and can
            // be used to update a progress indicator visible to the user.
        }
        
        service.executeQuery(query) { (_, result, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            
            // Successful upload if no error is returned.
        }
    }
    
    
    // Create Folder Example
    func populateFolderID(folder_name: String) {
        getFolderID(
            name: folder_name,
            service: googleDriveService,
            user: googleUser!) { folderID in
            if folderID == nil {
                self.createFolder(
                    name: folder_name,
                    service: self.googleDriveService) {
                    self.uploadFolderID = $0
                }
            } else {
                // Folder already exists
                self.uploadFolderID = folderID
            }
        }
    }
    
    
    
    // Testing Lisiting Folder and Files
    public func search(_ fileName: String, onCompleted: @escaping (String?, Error?) -> ()) {
        let query = GTLRDriveQuery_FilesList.query()
        query.pageSize = 1
        query.q = "name contains '\(fileName)'"
            
        googleDriveService.executeQuery(query) { (ticket, results, error) in
            onCompleted((results as? GTLRDrive_FileList)?.files?.first?.identifier, error)
        }
    }
        
    public func listFiles(_ folderID: String, onCompleted: @escaping (GTLRDrive_FileList?, Error?) -> ()) {
        let query = GTLRDriveQuery_FilesList.query()
        query.pageSize = 100
        query.q = "'\(folderID)' in parents"
            
        googleDriveService.executeQuery(query) { (ticket, result, error) in
            onCompleted(result as? GTLRDrive_FileList, error)
        }
    }
    
    public func listFilesInFolder(_ folder: String, onCompleted: @escaping (GTLRDrive_FileList?, Error?) -> ()) {
        search(folder) { (folderID, error) in
            guard let ID = folderID else {
                onCompleted(nil, error)
                return
            }
            self.listFiles(ID, onCompleted: onCompleted)
        }
    }
    
    public func download(_ fileID: String, onCompleted: @escaping (Data?, Error?) -> ()) {
        let query = GTLRDriveQuery_FilesGet.queryForMedia(withFileId: fileID)
        googleDriveService.executeQuery(query) { (ticket, file, error) in
            onCompleted((file as? GTLRDataObject)?.data, error)
        }
    }
    
}
