//
//  Closures.swift
//  SampleApp
//
//  Created by Gentner, Sebastian on 09.10.19.
//  Copyright © 2019 Datagroup Mobile Solutions AG. All rights reserved.
//

import Foundation

func doStuff(completion: () -> Void) {
    // to stuff, maybe asynchron
    // ...
    //
    // ...
    // ...
    
    // escape with closure
    completion()
}


typealias Callback = () -> Void

func doStuff1(completion: Callback) {
    // to stuff, maybe asynchron
    // ...
    //
    // ...
    // ...
    
    // escape with closure
    completion()
}

func callDoStuff() {
    
    doStuff {
        print("doStuff finished")
    }
    
    doStuff1 {
         print("doStuff1 finished")
    }
}


typealias SuccessCallback = (Bool) -> Void

func tryStuff(completion: SuccessCallback) {
    if coinflip {
        completion(true)
    } else {
        completion(false)
    }
}

func callTryStuff() {
    
    // call tryStuff ...
    tryStuff { didSucceed in
        
        // .. and handle completion with boolean didSuceed
        
        if didSucceed {
            print("didSucceed -> true :D")
        } else {
            print("didSucceed -> false :D")
        }
    }
}
