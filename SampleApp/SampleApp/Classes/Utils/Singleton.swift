//
//  Stuff.swift
//  SampleApp
//
//  Created by Gentner, Sebastian on 09.10.19.
//  Copyright © 2019 Datagroup Mobile Solutions AG. All rights reserved.
//

import UIKit

///
/// unique created object: singleton
///
class Singleton {
    
    // static access to shared instance
    static let sharedInstance = Singleton()
    
    // block init
    private init() {}
    
    func doStuff() {
        
    }
}


private func explainSingleton() {
    
    // init blocked
    // -> 'Singleton' initializer is inaccessible due to 'private' protection level
    //let singleton = Singleton()
    
    let s = Singleton.sharedInstance
    s.doStuff()
}
