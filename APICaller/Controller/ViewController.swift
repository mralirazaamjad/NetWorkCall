//
//  ViewController.swift
//  APICaller
//
//  Created by Ali Raza Amjad on 24/12/2019.
//  Copyright © 2019 Ali Raza. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }

    @IBAction func actionPush(_ sender: UIButton) {
        postCall()
    }
    
    private func postCall() {
        let url = "https://postman-echo.com/post"
        let params = [
            "foo1": "bar1",
            "foo2": "bar2"] as Dictionary<String, Any>
        Utility.HelperFuntions.delegate.showProgessBar(self.view)
        APICaller().sendAPICall("POST",
            methodNameWithBaseURL: url,
            key: nil,
            params: params as AnyObject?,
            completed: {(succeeded: Bool, responceResult: AnyObject?) -> () in
                if succeeded {
                    DispatchQueue.main.async {
                        Utility.HelperFuntions.delegate.hideProgressBar(self.view)
                        let vc = Utility.HelperFuntions.storyBoard.instantiateViewController(withIdentifier: "ListViewController") as! ListViewController
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }else {
                    DispatchQueue.main.async {
                        Utility.HelperFuntions.delegate.hideProgressBar(self.view)
                    }
                }
                
        })
    }
    
    
}

