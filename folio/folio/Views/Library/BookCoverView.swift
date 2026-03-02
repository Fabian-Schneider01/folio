//
//  BookCoverView.swift
//  Folio
//
//  Created by Fabian Schneider on 02.03.26.
//

import SwiftUI
import PDFKit

struct BookCoverView: View {
    let fileURL: URL
    @State private var thumbnail: UIImage? = nil
    
    var body: some View {
        ZStack {
            if let image = thumbnail {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Color.secondary.opacity(0.1)
                    .overlay(Image(systemName: "book.closed").foregroundColor(.secondary))
            }
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .onAppear {
            if thumbnail == nil { generateThumbnail() }
        }
    }
    
    func generateThumbnail() {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let document = PDFDocument(url: fileURL),
                  let page = document.page(at: 0) else { return }
            
            let image = page.thumbnail(of: CGSize(width: 300, height: 400), for: .artBox)
            DispatchQueue.main.async {
                self.thumbnail = image
            }
        }
    }
}
