//
//  LibraryViewModel.swift
//  Folio
//
//  Created by Fabian Schneider on 02.03.26.
//

import SwiftUI
import Combine

class LibraryViewModel: ObservableObject {
    @Published var books: [Book] = [] {
        didSet { save() }
    }
    
    private let saveKey = "Folio_Library"
    
    init() {
        load()
    }
    
    func addBook(at url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        
        let fileName = "\(UUID().uuidString).pdf"
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let destURL = paths[0].appendingPathComponent(fileName)
        
        do {
            try FileManager.default.copyItem(at: url, to: destURL)
            
            let newBook = Book(
                title: url.deletingPathExtension().lastPathComponent,
                fileName: fileName
            )
            
            DispatchQueue.main.async {
                self.books.append(newBook)
            }
        } catch {
            print("Fehler beim Kopieren: \(error)")
        }
    }
    
    func updateProgress(for bookID: UUID, page: Int, total: Int) {
        if let index = books.firstIndex(where: { $0.id == bookID }) {
            books[index].lastPage = page
            books[index].totalPages = total
        }
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(books) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Book].self, from: data) {
            self.books = decoded
        }
    }
    
    func renameBook(at id: UUID, newTitle: String) {
        if let index = books.firstIndex(where: { $0.id == id }) {
            books[index].title = newTitle
        }
    }

    func updateNotes(for bookID: UUID, pageIndex: Int, text: String) {
        if let index = books.firstIndex(where: { $0.id == bookID }) {
            if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                books[index].notes.removeValue(forKey: pageIndex)
            } else {
                books[index].notes[pageIndex] = text
            }
        }
    }
    func deleteBook(_ book: Book) {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            try? FileManager.default.removeItem(at: book.fileURL)
            books.remove(at: index)
        }
    }
}
