//
//  ViewController.swift
//  RayBreak
//
//  Created by Augusto Alonso on 11/22/20.
//

import UIKit
import MetalKit

class ViewController: UIViewController {
    var metalView: MTKView {
        return view as! MTKView
    }
    
    private var renderer: Render!

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.renderer = try! Render(view: metalView)
//        metalView.delegate = self.renderer
    }


}
