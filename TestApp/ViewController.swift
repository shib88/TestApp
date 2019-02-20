//
//  ViewController.swift
//  TestApp
//
//  Created by Haruna  on 2019/02/20.
//  Copyright © 2019 Haruna . All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var quoteTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    //文章参照のオブジェクトを通してデータをクラウドに保存する
    var docRef: DocumentReference!
    var quoteListener: ListenerRegistration!
    // saveボタンの機能
    @IBAction func saveTapped(_ sender: Any) {
        //自分のテキストフィールドからテキストを取得、それらが空でないか点検する(quoteもauthorも行う)
        guard let quoteText = quoteTextField.text, !quoteText.isEmpty else { return }
        guard let quoteAuthor = authorTextField.text, !quoteText.isEmpty else { return }
        //string(文字列)のanyというdictionaryをdocumentに保存する、その中身は["キー名": 取得したテキストが入っている定数]
        let dataToSave: [String: Any] = ["quote": quoteText, "author": quoteAuthor]
        docRef.setData(dataToSave) { (error) in
            if let error = error {
                print("エラーです: \(error.localizedDescription)")
            } else {
                print("データを保存しました")
            }
        }
        
    }
    
    //データを表示させる
    @IBAction func fetchTapped(_ sender: Any) {
        docRef.getDocument { (docSnapshot, error) in
            guard let docSnapshot = docSnapshot, docSnapshot.exists else { return }
            let myData = docSnapshot.data()
            let latestQuote = myData?["quote"] as? String ?? ""
            let quoteAuthor = myData?["author"] as? String ?? "(none)"
            self.quoteLabel.text = "\"\(latestQuote)\" -- \(quoteAuthor)"
        }
    }
    
    //リアルタイムに同期して、表示させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        quoteListener = docRef.addSnapshotListener { (docSnapshot, error) in
            guard let docSnapshot = docSnapshot, docSnapshot.exists else { return }
            let myData = docSnapshot.data()
            let latestQuote = myData?["quote"] as? String ?? ""
            let quoteAuthor = myData?["author"] as? String ?? "(none)"
            self.quoteLabel.text = "\"\(latestQuote)\" -- \(quoteAuthor)"
        }
    }
    
    //画面に表示されている時のみ、データを保持する
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        quoteListener.remove()
    }
    
    //データを取得する
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //保存するdocumentを指定するパスは(collection/document)で記述
        docRef = Firestore.firestore().document("sampledata/inspiration")
    }


}

