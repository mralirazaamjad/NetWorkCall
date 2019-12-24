//
//  ListViewController.swift
//  APICaller
//
//  Created by Ali Raza Amjad on 24/12/2019.
//  Copyright © 2019 Ali Raza. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblList: UITableView!
    
    var arrayToDos = [ToDosDC]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getApi()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: API
    private func getApi() {
        let url = "https://jsonplaceholder.typicode.com/todos"
        let params = [String: String]()
        
        Utility.HelperFuntions.delegate.showProgessBar(self.tblList)
        APICaller().sendAPICall("GET",
            methodNameWithBaseURL: url,
            key: nil,
            params: params as AnyObject?,
            completed: {(succeeded: Bool, responceResult: AnyObject?) -> () in
                if succeeded {
                    DispatchQueue.main.async {
                        Utility.HelperFuntions.delegate.hideProgressBar(self.tblList)
                        if let result = responceResult as? [NSDictionary]{
                            self.arrayToDos = ParsingDicFucntions().getToDos(result)
                            self.tblList.reloadData()
                        }
                    }
                }else {
                    DispatchQueue.main.async {
                        Utility.HelperFuntions.delegate.hideProgressBar(self.tblList)
                    }
                }
        })
    }
    
    //MARK: UITableView Delegate and DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayToDos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        cell?.textLabel?.text = arrayToDos[indexPath.row].title
        return cell!
    }

}
