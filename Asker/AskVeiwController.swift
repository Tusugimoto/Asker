//
//  ViewController.swift
//  realmDemo
//
//  Created by 杉本翼 on 2020/01/14.
//  Copyright © 2020 Tsubasa Sugimoto. All rights reserved.
//

import UIKit
import RealmSwift

//realmのインスタンス生成
let realm = try! Realm()
//relamの取得
var results = realm.objects(Question.self)
var shuffled = results.shuffled()
//質問の数
var questionNumber:Int = results.count

//スターだけが選択されたときのフラグ
var starOnlyFlag = false
//順番通りが選択されたときのフラグ
var orderFlag = true
//ランダムが選択されたときのフラグ
var randomFlag = false


class AskViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
//    質問数を設定する項目 [Label, slider]
    @IBOutlet weak var displayNumber: UILabel!
    @IBOutlet weak var numberSlider: UISlider!
    
//    スターだけかどうかを設定する項目 [Switch]
    @IBOutlet weak var starOnlySwitch: UISwitch!
    
//    順番を設定する項目 [Picker]
    @IBOutlet weak var orderPickerView: UIPickerView!
    var dataSourceOrder = ["順番通り", "ランダム"]
    
//    スライダーが変更されたとき
    @IBAction func numberSlider(_ sender: UISlider) {
        questionNumber = Int(sender.value)
        displayNumber.text = String(questionNumber)
    }
    
    
//    スタースイッチが押された時
    @IBAction func starOnlySwitch(_ sender: Any) {
        starOnlySwitchFunc()
    }
    
    
    
    
    
    
    
//    スタースイッチが押された時の処理をする関数
    func starOnlySwitchFunc() {
    //        スタースイッチがオンならスターフラグをtrueにして質問数を更新
            if starOnlySwitch.isOn{
                starOnlyFlag = true
                numberChange()
    //        スタースイッチがオフならスターフラグをfalseにして質問数を更新
            }else {
                //Questionを再取得
                results = realm.objects(Question.self)
                starOnlyFlag = false
                numberChange()
            }
        
    }
    
//    スタースイッチが押された時に質問数を更新する関数
    func numberChange() {
        if starOnlyFlag{
            let starResults = realm.objects(Question.self).filter("star == true")
            numberSlider.maximumValue = Float(starResults.count)
            numberSlider.setValue(Float(starResults.count), animated: false)
            displayNumber.text = String(starResults.count)
            questionNumber = starResults.count
            print(questionNumber)
        }else{
            numberSlider.maximumValue = Float(results.count)
            numberSlider.setValue(Float(results.count), animated: false)
            displayNumber.text = String(results.count)
            questionNumber = results.count
            print(questionNumber)
        }
    }
    
    
    
    
//*****    PickerViewに関する関数
    //ひとつのPickerViewに対して、横にいくつドラムロールを並べるかを指定。
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    //PickerViewの選択肢の個数を返す処理
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSourceOrder.count
    }
    //PickerViewの選択肢として表示する文字列を設定（これがないと、?として表示されてしまう）
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(dataSourceOrder[row])
    }
    
    //順番が変更されたときに各フラグを立てる
    func pickerView(_ pickerView: UIPickerView,didSelectRow row: Int,inComponent component: Int) {
        if dataSourceOrder[row] == "ランダム"{
            randomFlag = true
            orderFlag = false
            shuffled = results.shuffled()
        }else {
            randomFlag = false
            orderFlag = true
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        self.orderPickerView.dataSource = self
        self.orderPickerView.delegate = self
        
        //realmのパスを表示
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
       
    }

    
//    初回のみ起動
    override func viewDidAppear(_ animated: Bool) {
        //初回起動判定
        let ud = UserDefaults.standard
        if ud.bool(forKey: "firstLaunch") {
            
            // 初回起動時の処理
            let setQuestions = SetInitialQuestions()
            setQuestions.setInitial()
           print("hello,world")
            // 2回目以降の起動では「firstLaunch」のkeyをfalseに
            ud.set(false, forKey: "firstLaunch")
        }
        
        //スライダーの初期値
        displayNumber.text = "\(results.count)"
        numberChange()
    }

    
}
