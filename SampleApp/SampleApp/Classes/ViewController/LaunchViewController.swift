//
//  LaunchViewController.swift
//  SampleApp
//
//  Created by Gentner, Sebastian on 30.09.19.
//  Copyright © 2019 Datagroup Mobile Solutions AG. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
    
    private let lbl = UILabel()
    private var text: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(lbl)
        lbl.text = "Launching App..."
        lbl.textColor = .black
        lbl.textAlignment = .center
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        lbl.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        TextService.loadTextFromBackend { [weak self] loadedString in
            
            // perform UI stuff on main thread!
            DispatchQueue.main.sync {
                
                // unwrap optional loadedString
                
                if let str: String = loadedString {
                    self?.lbl.text = str
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
        UIView.animate(withDuration: 5.0, animations: {
            self.lbl.textColor = .white
            self.view.backgroundColor = .black
        }, completion: { finished in
            if finished {
                let home = HomeViewController()
                let nav = UINavigationController(rootViewController: home)
                AppDelegate.swap(rootViewController: nav)
            }
        })
    }
}
