//
//  ErrorHandler.swift
//  Madduck
//
//  Created by Furkan on 16.03.2023.
//

import Foundation

struct ErrorHandler {

    static let `default` = ErrorHandler()

    let genericMessage = "Sorry! Something went wrong"

    func handleError(_ error: Error) {
         presentToUser(message: genericMessage)
    }

    func handleError(_ error: LocalizedError) {
         if let errorDescription = error.errorDescription {
            presentToUser(message: errorDescription)
        } else {
            presentToUser(message: genericMessage)
        }
    }

    func presentToUser(message: String) {
         // Not depicted: Show alert dialog in iOS or OS X, or print to

        print(message) // Now you log the error to console.
    }

}
