//
//  MainController.swift
//  RayBreak
//
//  Created by Augusto Alonso on 11/22/20.
//

import Foundation
import UIKit
import MetalKit

class MainController: UIViewController {
    lazy var metalView: MTKView = MTKView()
    private var renderer: Render!
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Proyecto final"
        label.textColor = .label
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .largeTitle)
        return label
    }()
    
    lazy var slidersLabel: UILabel = {
        let label = UILabel()
        label.text = "Desliza los colores para light shade"
        label.textColor = .label
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .subheadline)
        return label
    }()
    
    lazy var grayScaleButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Gray Scale", for: .normal)
        btn.tintColor = .label
        return btn
    }()
    
    lazy var invertColorBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle(" Invert ", for: .normal)
        btn.tintColor = .label
        return btn
    }()
    
    lazy var lightShadeBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle(" LightShade ", for: .normal)
        btn.tintColor = .label
        
        return btn
    }()
    
    lazy var redSlider: UISlider = {
        let slider = UISlider()
        slider.maximumValue = 255
        slider.minimumValue = 0
        slider.value = 255/2
        slider.tintColor = .systemRed
        return slider
    }()
    
    lazy var blueSlider: UISlider = {
        let slider = UISlider()
        slider.maximumValue = 255
        slider.minimumValue = 0
        slider.value = 255/2
        slider.tintColor = .systemBlue
        return slider
    }()
    
    lazy var greenSlider: UISlider = {
        let slider = UISlider()
        slider.maximumValue = 255
        slider.minimumValue = 0
        slider.value = 255/2
        slider.tintColor = .systemGreen
        return slider
    }()
    
    
    
    override func viewDidLoad() {
        self.renderer = try! Render(view: metalView)
        view.backgroundColor = .systemBackground
        grayScaleButton.addTarget(self, action: #selector(scaleToGray), for: .touchUpInside)
        invertColorBtn.addTarget(self, action: #selector(invert), for: .touchUpInside)
        lightShadeBtn.addTarget(self, action: #selector(lightsShade), for: .touchUpInside)
        redSlider.addTarget(self, action: #selector(updat eRed), for: .valueChanged)
        blueSlider.addTarget(self, action: #selector(updateBlue), for: .valueChanged)
        greenSlider.addTarget(self, action: #selector(updateGreen), for: .valueChanged)
        
        let slidersContainer = UIStackView.init(arrangedSubviews: [redSlider, blueSlider, greenSlider])
        slidersContainer.axis = .vertical
        let buttonsContainer = UIStackView.init(arrangedSubviews: [UIView(),grayScaleButton, invertColorBtn, lightShadeBtn, UIView()])
        buttonsContainer.spacing = 8
        buttonsContainer.constrainHeight(constant: 45)
        buttonsContainer.alignment = .center
        let verticalStackView = UIStackView.init(arrangedSubviews: [slidersContainer, slidersLabel, titleLabel,metalView, buttonsContainer])
        
        verticalStackView.axis = .vertical
        let safe = view.safeAreaLayoutGuide
        
        view.addSubview(verticalStackView)
        verticalStackView.anchor(top: safe.topAnchor, leading: safe.leadingAnchor, bottom: safe.bottomAnchor, trailing: safe.trailingAnchor)
        
        
        
        metalView.delegate = self.renderer
        setUpGestures()
        
    }
    
    func setUpGestures() {
        // Gesture that define a left swipe.
        let gesture = Gesture()
        gesture.onTouchMoved = {
            dx, dy in
            
//            if abs(dx) <= 0.5 {
//                print("dx", dx)
//
            self.renderer.rotate(dX: Float(dx/50), dY: Float(dy/50))
//            }

        }
        gesture.addTarget(self, action: #selector(onSwipeLeft))
        metalView.addGestureRecognizer(gesture)
    }

    @objc func onSwipeLeft(gesture: UISwipeGestureRecognizer) {
//        gesture.
//        renderer.rotate(dX: )
        print("lol")
    }
    
    @objc func scaleToGray(){
        renderer.scaleToGray()
        if renderer.activeShaders[0] == 1 {
            grayScaleButton.layer.backgroundColor = UIColor.systemGray.cgColor
            grayScaleButton.layer.cornerRadius = 5
        }else{
            grayScaleButton.layer.backgroundColor = UIColor.clear.cgColor
            grayScaleButton.layer.cornerRadius = 0
        }
    }
    @objc func invert(){
        renderer.invertImage()
        if renderer.activeShaders[1] == 1 {
            invertColorBtn.layer.backgroundColor = UIColor.systemBlue.cgColor
            invertColorBtn.layer.cornerRadius = 5
        }else{
            invertColorBtn.layer.backgroundColor = UIColor.clear.cgColor
            invertColorBtn.layer.cornerRadius = 0
        }
    }
    
    @objc func lightsShade(){
        renderer.lightShade = renderer.lightShade == 0 ? 1 : 0
        if renderer.lightShade == 1 {
            lightShadeBtn.layer.backgroundColor = UIColor.systemPink.cgColor
            lightShadeBtn.layer.cornerRadius = 5
        }else{
            lightShadeBtn.layer.backgroundColor = UIColor.clear.cgColor
            lightShadeBtn.layer.cornerRadius = 0
        }
        
    }
    
    @objc func updateBlue(){
        renderer.blueShade = blueSlider.value/255
    }
    @objc func updateGreen(){
        renderer.greenShade = greenSlider.value/255
    }
    @objc func updateRed(){
        renderer.redShade = redSlider.value/255
    }
    
}

