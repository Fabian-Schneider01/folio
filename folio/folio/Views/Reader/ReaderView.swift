//
//  ReaderView.swift
//  Folio
//
//  Created by Fabian Schneider on 02.03.26.
//

import SwiftUI
import PDFKit

struct ReaderView: View {
    let book: Book
    @ObservedObject var viewModel: LibraryViewModel
    @State private var pdfView = PDFView()
    
    @State private var showNotesEditor = false
    @State private var showNotesList = false
    @State private var notesText: String = ""
    @State private var currentPageIndex: Int = 0
    
    var body: some View {
        ZStack {
            PDFKitRepresentedView(url: book.fileURL, pdfView: pdfView, startPage: book.lastPage)
                .ignoresSafeArea()
            
            HStack {
                Color.clear.contentShape(Rectangle()).onTapGesture { if pdfView.canGoToPreviousPage { pdfView.goToPreviousPage(nil) } }
                Spacer()
                Color.clear.contentShape(Rectangle()).onTapGesture { if pdfView.canGoToNextPage { pdfView.goToNextPage(nil) } }
            }
        }
        .navigationTitle(book.title)
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(NotificationCenter.default.publisher(for: .PDFViewPageChanged)) { _ in
            if let page = pdfView.currentPage, let doc = pdfView.document {
                let index = doc.index(for: page)
                currentPageIndex = index
                viewModel.updateProgress(for: book.id, page: index, total: doc.pageCount)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                // Button 1: Index of all notes
                Button { showNotesList = true } label: {
                    Image(systemName: "list.bullet.rectangle.portrait")
                }
                
                Button {
                    notesText = book.notes[currentPageIndex] ?? ""
                    showNotesEditor = true
                } label: {
                    Image(systemName: "note.text")
                }
            }
        }
        .sheet(isPresented: $showNotesEditor) {
            NavigationStack {
                VStack(alignment: .leading) {
                    TextEditor(text: $notesText)
                        .padding(4)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.1)))
                        .padding()
                }
                .toolbar {
                    Button("Done") {
                        viewModel.updateNotes(for: book.id, pageIndex: currentPageIndex, text: notesText)
                        showNotesEditor = false
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showNotesList) {
            NavigationStack {
                List {
                    let sortedPages = book.notes.keys.sorted()
                    if sortedPages.isEmpty {
                        Text("No notes found in this book.")
                            .foregroundColor(.secondary)
                    }
                    ForEach(sortedPages, id: \.self) { pageIdx in
                        Button {
                            if let page = pdfView.document?.page(at: pageIdx) {
                                pdfView.go(to: page)
                                showNotesList = false
                            }
                        } label: {
                            VStack(alignment: .leading) {
                                Text("Page \(pageIdx + 1)")
                                    .font(.headline)
                                Text(book.notes[pageIdx] ?? "")
                                    .lineLimit(2)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .navigationTitle("Notes")
                .toolbar { Button("Close") { showNotesList = false } }
            }
        }
    }
}
