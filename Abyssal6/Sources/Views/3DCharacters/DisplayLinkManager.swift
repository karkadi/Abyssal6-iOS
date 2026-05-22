//
//  DisplayLinkManager.swift
//  3dViewer
//
//  Created by Arkadiy KAZAZYAN on 04/03/2026.
//

import QuartzCore

class DisplayLinkManager {
    private var displayLink: CADisplayLink?
    var onUpdate: ((Double) -> Void)?

    func start() {
        stop()
        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink?.add(to: .main, forMode: .common)
    }

    func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func tick(_ link: CADisplayLink) {
        onUpdate?(link.duration)
    }
}
