//
//  Optionals.swift
//  SampleApp
//
//  Created by Gentner, Sebastian on 09.10.19.
//  Copyright © 2019 Datagroup Mobile Solutions AG. All rights reserved.
//

import Foundation

func test() {
    
    // optional string: could be nil at any time
    var optionalString: String? = nil
    
    print(optionalString!) // force unwrap nil -> this call will crash
    
    optionalString = makeStringOrFail()
    
    guard let unwrappedString = optionalString else {
        // abort, optinalString is nil and we cant do anything here
        return
    }
    
    // this call is safe
    print(unwrappedString)
}

///
///
///
func makeStringOrFail() -> String? {
    if coinflip {
        return "urfaust"
    } else {
        return nil
    }
}
