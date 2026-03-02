//
//  Book.swift
//  Folio
//
//  Created by Fabian Schneider on 02.03.26.
//

import Foundation

struct Book: Identifiable, Codable {
    var id = UUID()
    var title: String
    let fileName: String
    var lastPage: Int = 0
    var totalPages: Int = 1
    var notes: [Int: String] = [:]
    
    var fileURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(fileName)
    }
    
    var progress: Double {
        return Double(lastPage) / Double(max(1, totalPages - 1))
    }
}
