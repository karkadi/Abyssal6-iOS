//
//  GIFImage.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 15/05/2026.
//
import SwiftUI
import WebKit

struct GIFImage: UIViewRepresentable {
    /// Can be a full URL ("https://...") or a local file name ("my-image")
    let source: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.isUserInteractionEnabled = false

        loadGIF(into: webView)

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // The .id() modifier on the parent view handles recreations during transitions.
    }

    private func loadGIF(into webView: WKWebView) {
        // Base HTML template to ensure the image scales to cover the viewport cleanly
        let htmlTemplate = { (urlPath: String) in
            """
            <html>
            <head>
            <style>
            body, html { margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden; background-color: transparent; }
            img { width: 100%; height: 100%; object-fit: cover; }
            </style>
            </head>
            <body>
            <img src="\(urlPath)">
            </body>
            </html>
            """
        }

        // Case 1: Check if the source is a remote URL
        if source.lowercased().hasPrefix("http://") || source.lowercased().hasPrefix("https://") {
            if URL(string: source) != nil {
                webView.loadHTMLString(htmlTemplate(source), baseURL: nil)
            }
        }
        // Case 2: Treat source as a local bundle file name
        else {
            // Normalize name removing any accidental extensions the user might pass
            let cleanName = source.replacingOccurrences(of: ".gif", with: "", options: .caseInsensitive)

            if let bundleURL = Bundle.main.url(forResource: cleanName, withExtension: "gif") {
                webView.loadHTMLString(htmlTemplate(bundleURL.lastPathComponent), baseURL: bundleURL.deletingLastPathComponent())
            }
        }
    }
}
