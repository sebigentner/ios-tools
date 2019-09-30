//
//  TextService.swift
//  SampleApp
//
//  Created by Gentner, Sebastian on 30.09.19.
//  Copyright © 2019 Datagroup Mobile Solutions AG. All rights reserved.
//

import Foundation

class TextService {
    
    static func loadTextFromBackend(completion: @escaping (String?) -> Void) {
        delay(2.0) {
            var text: String?
            
            if coinflip {
                text = "Lorem ipsum"
            }
            
            completion(text)
        }
    }
}

var coinflip: Bool {
    return Int.random(in: 0...1) % 2 == 0
}

func delay(_ duration: TimeInterval, stuff: @escaping () -> Void) {
    DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + duration) {
        stuff()
    }
}
