//
//  ParsingDicFucntions.swift
//  OneTaxBariPhone
//
//  Created by Ali Raza on 12/10/2019.
//  Copyright © 2019 Ali Raza. All rights reserved.
//

import UIKit

class ParsingDicFucntions: NSObject {

//    func getProfileUserDetails(_ dic: NSDictionary) -> ProfileUserDetailsDC {
//        let keys = Utility.HelperFuntions.profileUserDetailsDC()
//        let obj = ProfileUserDetailsDC()
//        for j in 0 ..< keys.count {
//            if dic.value(forKey: keys[j]) != nil {
//                if !(dic.value(forKey: keys[j]) is NSNull) {
//                    obj.setValue(dic.value(forKey: keys[j]), forKey: keys[j])
//                }
//            }
//        }
//        return obj
//    }
    
    func getToDos(_ array: [NSDictionary]) -> [ToDosDC] {
        var data = [ToDosDC]()
        let keys = Utility.HelperFuntions.toDosListDC()
        
        for dic in array {
            let obj = ToDosDC()
            for key in keys {
                if dic.value(forKey: key) != nil {
                    if !(dic.value(forKey: key) is NSNull) {
                        if key == "id" {
                            obj.setValue(dic.value(forKey: key), forKey: "todos_id")
                        }else {
                            obj.setValue(dic.value(forKey: key), forKey: key)
                        }
                    }
                }
            }
            data.append(obj)
        }
        
        return data
    }
    
}
