// Copyright 2016-2017 Cisco Systems Inc
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import SparkSDK


public class UserDefaultsUtil {
    private static let CALL_PERSON_HISTORY_KEY = "KSCallPersonHistory"
    private static let CALL_PERSON_HISTORY_ADDRESS_KEY = "KSCallPersonHistoryAddress"
    private static let CALL_VIDEO_ENABLE_KEY = "KSCallVideoEnable"
    private static let CALL_SELF_VIEW_ENABLE_KEY = "KSCallSelfViewEnable"
    static let userDefault = UserDefaults.standard
    static var callPersonHistory: [Person] {
        get {
            var resutlArray: [Person] = []
            if let selfId = SparkContext.sharedInstance.selfInfo?.id {
                let key = CALL_PERSON_HISTORY_KEY + selfId
                if let array = userDefault.array(forKey: key) {
                    for onePerson in array {
                        if let personString = onePerson as? String {
                            if var p = Person(JSONString: personString) {
                                p.emails = getPersonAddress(p)
                                if p.emails != nil {
                                    resutlArray.append(p)
                                }
                            }
                        }
                    }
                    
                }
            }
            return resutlArray
            
        }
    }
    
    static func addPersonHistory(_ person:Person) {
        //save address for person
        UserDefaultsUtil.savePersonAddress(person)
        
        let personString = person.toJSONString()
        
        guard personString != nil else {
            return
        }
        var resultArray: [Any] = Array.init()
        if let selfId = SparkContext.sharedInstance.selfInfo?.id {
            let key = CALL_PERSON_HISTORY_KEY + selfId
            if var array = userDefault.array(forKey: key) {
                
                for onePerson in array {
                    if let personString = onePerson as? String {
                        if let p = Person(JSONString: personString) {
                            if p.id == person.id {
                                return
                            }
                        }
                    }
                }
                
                array.append(personString!)
                if array.count > 10 {
                    array.removeFirst()
                }
                resultArray = array
            }
            else
            {
                resultArray.append(personString!)
            }
            userDefault.set(resultArray, forKey: key)
        }
        
        
    }
    
    private static func savePersonAddress(_ person:Person) {
        guard person.id != nil && person.emails?.first != nil else {
            return
        }
        
        guard !person.emails!.first!.toString().isEmpty else {
            return
        }
        
        var addressDic: Dictionary<String, Any>?
        if let dic = userDefault.dictionary(forKey: CALL_PERSON_HISTORY_ADDRESS_KEY) {
            addressDic = dic
            addressDic!.updateValue(person.id!, forKey: person.emails!.first!.toString())
            
        }
        else {
            addressDic = [person.id! : person.emails!.first!.toString()]
        }
        userDefault.set(addressDic, forKey: CALL_PERSON_HISTORY_ADDRESS_KEY)
    }
    
    private static func getPersonAddress(_ person:Person) -> [EmailAddress]? {
        guard person.id != nil else {
            return nil
        }
        
        var emails:[EmailAddress]?
        
        if let dic = userDefault.dictionary(forKey: CALL_PERSON_HISTORY_ADDRESS_KEY) {
            if let email = dic[person.id!] {
                if let str = email as? String {
                    if let ea = EmailAddress.fromString(str) {
                        emails = [ea]
                    }
                }
            }
        }
        return emails
    }
}
