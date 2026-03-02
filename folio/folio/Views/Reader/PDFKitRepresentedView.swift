//
//  PDFKitRepresentedView.swift
//  Folio
//
//  Created by Fabian Schneider on 02.03.26.
//

import SwiftUI
import PDFKit

struct PDFKitRepresentedView: UIViewRepresentable {
    let url: URL
    let pdfView: PDFView
    let startPage: Int
    
    func makeUIView(context: Context) -> PDFView {
        guard let document = PDFDocument(url: url) else { return pdfView }
        
        pdfView.document = document
        
        pdfView.autoScales = true
        pdfView.displayMode = .singlePage
        pdfView.displayDirection = .horizontal
        pdfView.usePageViewController(true)
        
        pdfView.maxScaleFactor = 4.0
        pdfView.minScaleFactor = pdfView.scaleFactorForSizeToFit
        
        pdfView.displaysPageBreaks = false
        
        if let page = document.page(at: startPage) {
            pdfView.go(to: page)
        }
        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
    }
}
