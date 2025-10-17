//
//  String+Extensions.swift
//  kath
//
//  Created by faheem yousuf malla on 17/10/25.
//

import Foundation

extension String {
    var isEmptyOrWhitespace: Bool {
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
