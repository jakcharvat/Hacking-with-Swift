//
//  FirebaseSignup.swift
//  Project33
//
//  Created by Jakub Charvat on 20/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Foundation


struct FirebaseAuthResponse: Codable {
    let idToken: String
    let email: String
    let refreshToken: String
    let expiresIn: String
    let localId: String
}


struct FirebaseAuthPayload: Codable {
    let email: String
    let password: String
    let returnSecureToken: Bool
}

struct FirebaseAuthErrorResponse: Codable, LocalizedError {
    let error: Error
    
    struct Error: Codable {
        let code: Int
        let message: String
    }
    
    var errorDescription: String? {
        switch error.message {
        case "EMAIL_EXISTS":
            return "A user account with this email address already exists. Did you mean to log in instead?"
        case "OPERATION_NOT_ALLOWED":
            return "Signup has been disallowed"
        case "TOO_MANY_ATTEMPTS_TRY_LATER":
            return "We have blocked all requests from this device due to unusual activity. Try again later"
        case "EMAIL_NOT_FOUND":
            return "Couldn't find a user account with the specified email address"
        case "INVALID_PASSWORD":
            return "The password you entered is wrong"
        case "USER_DISABLED":
            return "Your account was disabled"
        default:
            return error.message
        }
    }
}
