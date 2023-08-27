//
//  addButton.swift
//  MyToDoApp
//
//  Created by Matias Martinelli on 26/08/2023.


import Foundation
import UIKit

class addButton: UIButton {

    let floatingButton: UIButton = {
        // Button dimensions
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        // Corner radius
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 30
        // Background Color
        button.backgroundColor = .systemBlue

        // Create a custom bold plus symbol image with white color
        let plusImage = UIGraphicsImageRenderer(size: CGSize(width: 28, height: 28)).image { context in
            let plusPath = UIBezierPath()
            plusPath.move(to: CGPoint(x: 7, y: 14))
            plusPath.addLine(to: CGPoint(x: 21, y: 14))
            plusPath.move(to: CGPoint(x: 14, y: 7))
            plusPath.addLine(to: CGPoint(x: 14, y: 21))
            plusPath.lineWidth = 3.0 // Adjust line width to make it bold

            UIColor.white.setStroke()
            plusPath.stroke()
        }

        button.setImage(plusImage, for: .normal)

        return button
    }()


}
