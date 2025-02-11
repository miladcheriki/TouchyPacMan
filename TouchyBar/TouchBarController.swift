//
//  TouchBarController.swift
//  TouchyBar
//
//  Created by Milad Cheriki on 1/30/25.
//

import Cocoa

class TouchBarController: NSResponder, NSTouchBarDelegate {

    var timer: Timer?
    var pacManView: NSView?
    var pacManLayer: CAShapeLayer?
    var position: CGFloat = 0
    var pacManState: Bool = false
    let pacManSize: CGFloat = 30
    var touchBarWidth: CGFloat = 0
    var characters: [String] = []
    var characterLabels: [NSTextField] = []
    var currentCharacterIndex: Int = 0
    var maxCharacters: Int = 0

    override init() {
        super.init()
        print("TouchBarController initialized!")
        NSApp.touchBar = makeTouchBar()
        startAnimation()
    }

    required init?(coder: NSCoder) {
        print("TouchBarController should not be initialized from a coder.")
        fatalError("init(coder:) has not been implemented")
    }

    override func makeTouchBar() -> NSTouchBar {
        print("Creating Touch Bar...")
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.defaultItemIdentifiers = [.animatedTextItem]
        return touchBar
    }

    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        print("Creating item for identifier: \(identifier)")
        if identifier == .animatedTextItem {
            let customItem = NSCustomTouchBarItem(identifier: identifier)

            let containerView = NSView()
            containerView.wantsLayer = true
            containerView.layer?.backgroundColor = NSColor.black.cgColor // Black background for the Touch Bar

            pacManView = NSView()
            pacManView?.wantsLayer = true
            pacManView?.layer?.backgroundColor = NSColor.clear.cgColor

            updateLayout(containerView: containerView)

            DispatchQueue.main.async {
                self.touchBarWidth = containerView.bounds.width
                self.updateLayout(containerView: containerView)
                self.drawPacMan(in: self.pacManView, state: self.pacManState)
            }

            if let pacManView = pacManView {
                containerView.addSubview(pacManView)
            }

            customItem.view = containerView
            return customItem
        }
        return nil
    }

    func updateLayout(containerView: NSView) {
        if touchBarWidth > 0 {
            let dotWidth = ".".size(withAttributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 28, weight: .bold)]).width
            let dotSpacing: CGFloat = 20.0
            maxCharacters = Int(touchBarWidth / (dotWidth + dotSpacing))
            characters = []
            characterLabels = []

            for _ in 0..<maxCharacters {
                characters.append(".")
            }

            // Define rainbow colors
            let rainbowColors: [NSColor] = [
                .systemRed, .systemOrange, .systemYellow, .systemGreen, .systemBlue, .systemPurple
            ]

            for (index, char) in characters.enumerated() {
                let charLabel = NSTextField(labelWithString: char)
                charLabel.font = NSFont.systemFont(ofSize: 28, weight: .bold) // Bigger dots
                charLabel.textColor = rainbowColors[index % rainbowColors.count] // Assign rainbow colors
                charLabel.sizeToFit()
                characterLabels.append(charLabel)
                containerView.addSubview(charLabel)
            }

            // Center the dots in the Touch Bar
            let totalWidth = CGFloat(characterLabels.count) * (dotWidth + dotSpacing) - dotSpacing
            let xPosStart = (touchBarWidth - totalWidth) / 2

            var xPos = xPosStart
            for label in characterLabels {
                label.frame = NSRect(x: xPos, y: (30 - label.intrinsicContentSize.height) / 2, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
                xPos += dotWidth + dotSpacing
            }

            pacManView?.frame = NSRect(x: position, y: (30 - pacManSize) / 2, width: pacManSize, height: pacManSize)
        }
    }

    func startAnimation() {
        print("Starting animation...")
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updatePosition), userInfo: nil, repeats: true)
    }

    @objc func updatePosition() {
        guard let pacManView = pacManView, let pacManLayer = pacManLayer else {
            print("Pac-Man view or layer is not initialized!")
            return
        }

        position += 2

        let pacManFrame = NSRect(x: position, y: (30 - pacManSize) / 2, width: pacManSize, height: pacManSize)

        if position > touchBarWidth + pacManSize {
            position = -pacManSize
            currentCharacterIndex = 0
            for label in characterLabels {
                label.alphaValue = 1.0 // Reset dots
            }
        }

        pacManState.toggle()
        pacManView.frame = pacManFrame
        updatePacManPath(state: pacManState)

        // Check for intersection with dots
        if currentCharacterIndex < characterLabels.count {
            let currentLabel = characterLabels[currentCharacterIndex]
            if let labelFrame = currentLabel.superview?.convert(currentLabel.frame, to: pacManView.superview),
               pacManFrame.intersects(labelFrame) && currentLabel.alphaValue == 1.0 {

                // Change Pac-Man's color to the color of the dot it just ate
                pacManLayer.fillColor = currentLabel.textColor?.cgColor

                NSAnimationContext.runAnimationGroup({ (context) in
                    context.duration = 0.2
                    currentLabel.animator().alphaValue = 0.0 // Hide the dot
                }, completionHandler: {
                    self.currentCharacterIndex += 1 // Move to the next dot
                })
            }
        }
    }

    func drawPacMan(in view: NSView?, state: Bool) {
        guard let view = view, let layer = view.layer else {
            print("Pac-Man view or layer is not initialized!")
            return
        }

        pacManLayer = CAShapeLayer()
        pacManLayer?.fillColor = NSColor.yellow.cgColor
        pacManLayer?.strokeColor = NSColor.black.cgColor
        pacManLayer?.lineWidth = 2.0
        layer.addSublayer(pacManLayer!)
        updatePacManPath(state: state)
    }

    func updatePacManPath(state: Bool) {
        guard let pacManLayer = pacManLayer else {
            print("Pac-Man layer is not initialized!")
            return
        }

        let path = CGMutablePath()
        let center = CGPoint(x: pacManSize / 2, y: pacManSize / 2)
        let radius = pacManSize / 2
        let startAngle: CGFloat = state ? .pi / 6 : 0
        let endAngle: CGFloat = state ? 11 * .pi / 6 : 2 * .pi

        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()

        pacManLayer.path = path
    }
}

extension NSTouchBarItem.Identifier {
    static let animatedTextItem = NSTouchBarItem.Identifier("com.yourdomain.animatedTextItem")
}
