//
//  SetInitialQuestions.swift
//  realmDemo
//
//  Created by 杉本翼 on 2020/01/20.
//  Copyright © 2020 Tsubasa Sugimoto. All rights reserved.
//

import Foundation
import RealmSwift

class SetInitialQuestions {
    
    func setInitial(){
        let questions = ["志望動機を教えてください",
                        "あなたの長所を教えてください",
                        "あなたの短所を教えてください",
                        "学生時代一番頑張ったことは何ですか？",
                        "あなたの自慢できることを教えてください",
                        "弊社で何を成し遂げたいですか？",
                        "チーム内で衝突した場合あなたはどうしますか？",
                        "なぜこの業界を志望したのですか？",
                        "この街のピアノ調律師は何人いますか？",
                        "米中貿易戦争の行方はどうなると思いますか？"]
        
        
        var question = Question()
    
        
        for i in 0 ..< questions.count{
            question = Question()
            
            question.id = i
            question.content = questions[i]
            try! realm.write {
                realm.add(question)
            }
        }
    }
}
