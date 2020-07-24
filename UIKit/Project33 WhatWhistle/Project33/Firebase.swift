//
//  Firebase.swift
//  Project33
//
//  Created by Jakub Charvat on 20/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Foundation
import KeychainSwift

class Firebase {
    static let shared = Firebase()
    
    private let keychain = KeychainSwift()
    
    private(set) var isAuthed = false
    private var refreshToken: String?
    private var idToken: String?
    private var expiry: Date?
    
    init() {
        load()
    }
}


//MARK: - Firebase Auth
extension Firebase {
    func signup(withEmail email: String, password: String, then completion: @escaping (Bool, Error?) -> ()) {
        guard let url = URL(string: firebaseSignupURL) else {
            completion(false, FirebaseError.FailedToCreateUrl)
            return
        }
        
        sendFirebaseAuthRequest(to: url, withEmail: email, password: password, then: completion)
    }
    
    func signin(withEmail email: String, password: String, then completion: @escaping (Bool, Error?) -> ()) {
        guard let url = URL(string: firebaseSigninURL) else {
            completion(false, FirebaseError.FailedToCreateUrl)
            return
        }
        
        sendFirebaseAuthRequest(to: url, withEmail: email, password: password, then: completion)
    }
    
    private func sendFirebaseAuthRequest(
        to url: URL,
        withEmail email: String,
        password: String,
        then completion: @escaping (Bool, Error?) -> ()
    ) {
        let payload = FirebaseAuthPayload(email: email, password: password, returnSecureToken: true)
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue("Application/JSON", forHTTPHeaderField: "Content-Type")
        
        do {
            let body = try JSONEncoder().encode(payload)
            request.httpBody = body
            request.timeoutInterval = 20
            URLSession.shared.dataTask(with: request) { [weak self] (data: Data?, response: URLResponse?, error: Error?) in
                guard let self = self else { return }
                
                guard error == nil else {
                    completion(false, error)
                    return
                }
                
                guard let response = response as? HTTPURLResponse else {
                    completion(false, FirebaseError.NoResponse)
                    return
                }
                
                guard let data = data else {
                    completion(false, FirebaseError.NoData)
                    return
                }
                
                guard response.statusCode == 200 else {
                    if let error = try? JSONDecoder().decode(FirebaseAuthErrorResponse.self, from: data) {
                        completion(false, error)
                        return
                    }
                    
                    completion(false, FirebaseError.Non200ResponseCode)
                    return
                }
                
                do {
                    let signupResponse = try JSONDecoder().decode(FirebaseAuthResponse.self, from: data)
                    
                    guard let expiresIn = Double(signupResponse.expiresIn) else {
                        completion(false, FirebaseError.InvalidExpiry)
                        return
                    }
                    
                    self.isAuthed = true
                    self.refreshToken = signupResponse.refreshToken
                    self.expiry = Date().advanced(by: expiresIn)
                    self.idToken = signupResponse.idToken
                    self.save()
                    completion(true, nil)
                } catch {
                    completion(false, error)
                }
                
            }.resume()
        } catch {
            completion(false, error)
        }
    }
    
    private func save() {
        if isAuthed {
            guard let refreshToken = refreshToken, let idToken = idToken, let expiry = expiry else { return }
            guard let dateData = try? JSONEncoder().encode(expiry) else { return }
            
            keychain.set(isAuthed, forKey: KeychainKeys.IsAuthed.rawValue)
            keychain.set(refreshToken, forKey: KeychainKeys.RefreshToken.rawValue)
            keychain.set(idToken, forKey: KeychainKeys.IdToken.rawValue)
            keychain.set(dateData, forKey: KeychainKeys.Expiry.rawValue)
        } else {
            keychain.set(isAuthed, forKey: KeychainKeys.IsAuthed.rawValue)
            keychain.delete(KeychainKeys.RefreshToken.rawValue)
            keychain.delete(KeychainKeys.IdToken.rawValue)
            keychain.delete(KeychainKeys.Expiry.rawValue)
        }
    }
    
    private func load() {
        guard let isAuthed = keychain.getBool(KeychainKeys.IsAuthed.rawValue) else { return }
        
        if isAuthed {
            guard let refreshToken = keychain.get(KeychainKeys.RefreshToken.rawValue),
                let idToken = keychain.get(KeychainKeys.IdToken.rawValue),
                let expiryData = keychain.getData(KeychainKeys.Expiry.rawValue) else { return }
            guard let expiry = try? JSONDecoder().decode(Date.self, from: expiryData) else { return }
            
            if expiry < Date() {
                self.isAuthed = false
                save()
                return
            }
            
            self.isAuthed = isAuthed
            self.refreshToken = refreshToken
            self.idToken = idToken
            self.expiry = expiry
        } else {
            self.isAuthed = isAuthed
            self.refreshToken = nil
            self.idToken = nil
            self.expiry = nil
        }
    }
    
    func signout() {
        isAuthed = false
        save()
    }
}


//MARK: - Keychain Keys
extension Firebase {
    enum KeychainKeys: String {
        case IsAuthed
        case RefreshToken
        case IdToken
        case Expiry
    }
}

enum FirebaseError: LocalizedError {
    case FailedToCreateUrl
    case NoResponse
    case Non200ResponseCode
    case NoData
    case InvalidExpiry
    
    var errorDescription: String? {
        switch self {
        case .FailedToCreateUrl:
            return "Unable to create request URL"
        case .NoResponse:
            return "Did not receive a response from the server"
        case .Non200ResponseCode:
            return "There is an unknown error with this request"
        case .NoData:
            return "This request didn't return any data"
        case .InvalidExpiry:
            return "The server reported an invalid token expiration time."
        }
    }
}
