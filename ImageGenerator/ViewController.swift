//
//  ViewController.swift
//  ImageGenerator
//
//  Created by Turner Eison on 7/26/20.
//  Copyright © 2020 Turner Eison. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

class ViewController: UIViewController, UIDragInteractionDelegate {
    let imageView = UIImageView()
    let statusLabel = UILabel()
    let spinner = UIActivityIndicatorView()
    
    let photoSettings: PhotoSettings
    
    init(photoSettings: PhotoSettings) {
        self.photoSettings = photoSettings
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        
        spinner.startAnimating()
        
        stackView.addArrangedSubview(spinner)
        stackView.addArrangedSubview(statusLabel)
        
        view.addSubview(stackView)
        view.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        statusLabel.text = "Generating..."
        statusLabel.textAlignment = .center
        
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderColor = UIColor.blue.cgColor
        imageView.layer.borderWidth = 1
        
        let width = Int(photoSettings.width)
        let height = Int(photoSettings.height)
        
        if self.photoSettings.colors.isEmpty {
            pic(width: width, height: height, colors: .all, completionHandler: self.completion)
        } else {
            pic(width: width, height: height, colors: .specific(self.photoSettings.colors), completionHandler: self.completion)
        }
        
        imageView.isUserInteractionEnabled = true
        let dragInteraction = UIDragInteraction(delegate: self)
        dragInteraction.isEnabled = true
        imageView.addInteraction(dragInteraction)
    }
    
    func completion(image: UIImage?, error: String?) -> Void {
        if let error = error {
            print("There was an error generating the image: \(error)")
            self.imageView.layer.borderColor = UIColor.red.cgColor
            return
        }
        
        guard let image = image else {
            print("The image didn't exist, but there was no error?")
            print("This shouldn't ever happen, but better safe than sorry.")
            self.imageView.layer.borderColor = UIColor.red.cgColor
            return
        }
        
        self.statusLabel.text = "Finished"
        
        self.spinner.stopAnimating()
        
        self.imageView.layer.borderColor = UIColor.green.cgColor
        self.imageView.image = image
        
        // Only save it if NOT running on Mac
        // Mac doesn't need this; the user can drag the photo to save it
        #if !targetEnvironment(macCatalyst)
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        #endif
    }
    
    // MARK: - Drag
    
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        guard let image = imageView.image else { return [] }
        let provider = NSItemProvider(object: image)
        let item = UIDragItem(itemProvider: provider)
        item.localObject = image
        // Returning a non-empty array, as shown here, enables dragging.
        // You can disable dragging by instead returning an empty array.
        return [item]
    }
    
    
    // MARK: - Image Generation
    
    func pic(width: Int, height: Int, colors: Colors, completionHandler: @escaping (UIImage?, String?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            
            var pixelArray: [UInt32] = []
            
            // Generate a color for every pixel
            for _ in 0 ..< width * height {
                let color: RGBA32
                switch colors {
                case .all:
                    color = RGBA32(red: .random(in: .min ... .max),
                                   green: .random(in: .min ... .max),
                                   blue: .random(in: .min ... .max),
                                   alpha: .max)
                case .specific(let choices):
                    color = choices.randomElement()!
                }
                
                pixelArray.append(color.color)
            }
            
            // Generate the image from the colors
            let cgImage = pixelArray.withUnsafeMutableBytes { (pointer) -> CGImage in
                let context = CGContext(
                    data: pointer.baseAddress,
                    width: width,
                    height: height,
                    bitsPerComponent: 8,
                    bytesPerRow: 4 * width,
                    space: CGColorSpace(name: CGColorSpace.sRGB)!,
                    bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue +
                        CGImageAlphaInfo.premultipliedLast.rawValue
                    )!
                return context.makeImage()!
            }
            
            // Send the image back to the UI
            let image = UIImage(cgImage: cgImage)
            DispatchQueue.main.async {
                completionHandler(image, nil)
            }
        }
    }
}

// MARK: - SwiftUI Compatibility

struct SwiftUIViewController: UIViewControllerRepresentable {
    typealias UIViewControllerType = ViewController
    
    var photoSettings: PhotoSettings
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SwiftUIViewController>) -> ViewController {
        return ViewController(photoSettings: photoSettings)
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: UIViewControllerRepresentableContext<SwiftUIViewController>) {
        // no implementation needed here!
    }
}
