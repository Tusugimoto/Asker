//
//  Cat.swift
//  realmDemo
//
//  Created by 杉本翼 on 2020/01/14.
//  Copyright © 2020 Tsubasa Sugimoto. All rights reserved.
//

import Foundation
import RealmSwift

class Question: Object {
    
    @objc dynamic var id = 0
    @objc dynamic var content: String?
    @objc dynamic var star: Bool = false
    @objc dynamic var isAudio: Bool = false
}


//questionLabel.text = "\(results[getIndexpath].content!)"
