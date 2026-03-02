//
//  LibraryView.swift
//  Folio
//
//  Created by Fabian Schneider on 02.03.26.
//

import SwiftUI
import UniformTypeIdentifiers

struct LibraryView: View {
    @ObservedObject var viewModel: LibraryViewModel
    @State private var isImporting = false
    
    @State private var showRenameAlert = false
    @State private var bookToRename: Book?
    @State private var newTitleInput = ""
    
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.books.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "books.vertical")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        Text("Your library is empty")
                            .font(.headline)
                        Text("Tap the plus icon to add books.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 100)
                } else {
                    LazyVGrid(columns: columns, spacing: 25) {
                        ForEach(viewModel.books) { book in
                            VStack(alignment: .leading, spacing: 8) {
                                ZStack(alignment: .topTrailing) {
                                    NavigationLink(destination: ReaderView(book: book, viewModel: viewModel)) {
                                        BookCoverView(fileURL: book.fileURL)
                                    }
                                    
                                    Button {
                                        bookToRename = book
                                        newTitleInput = book.title
                                        showRenameAlert = true
                                    } label: {
                                        Image(systemName: "pencil.circle.fill")
                                            .symbolRenderingMode(.palette)
                                            .foregroundStyle(.white, .blue)
                                            .font(.title2)
                                            .shadow(radius: 2)
                                    }
                                    .padding(8)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(book.title)
                                        .font(.caption).bold()
                                        .foregroundColor(.primary)
                                        .lineLimit(2)
                                    
                                    Text("Page \(book.lastPage + 1) of \(book.totalPages)")
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                    
                                    if !book.notes.isEmpty {
                                        Label("\(book.notes.count)", systemImage: "note.text")
                                            .font(.system(size: 10))
                                            .foregroundColor(.blue)
                                    }
                                }
                                
                                ProgressView(value: book.progress)
                                    .tint(.blue)
                                    .scaleEffect(x: 1, y: 0.5)
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    viewModel.deleteBook(book)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Folio")
            .toolbar {
                Button { isImporting = true } label: {
                    Image(systemName: "plus.circle.fill").font(.title2)
                }
            }
            .alert("Rename Book", isPresented: $showRenameAlert) {
                TextField("New title", text: $newTitleInput)
                Button("Cancel", role: .cancel) { }
                Button("Save") {
                    if let book = bookToRename {
                        viewModel.renameBook(at: book.id, newTitle: newTitleInput)
                    }
                }
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [UTType.pdf],
                allowsMultipleSelection: false
            ) { result in
                if let urls = try? result.get(), let url = urls.first {
                    viewModel.addBook(at: url)
                }
            }
        }
    }
}
