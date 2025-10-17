//
//  Model.swift
//  kath
//
//  Created by faheem yousuf malla on 17/10/25.
//

import Foundation
import FirebaseAuth
import Combine
@MainActor
class Model: ObservableObject{
    
    func updateDisplayname(for user: User,displayName: String) async throws {
        let request = user.createProfileChangeRequest()
        request.displayName = displayName
        try await request.commitChanges()
    }
}
