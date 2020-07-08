import UIKit
import Foundation
import Alamofire

//Block
typealias ResponseBlock = (_ success : Bool, _ request: Request, _ errorMessage: NSString) -> (Void)

public enum RequestMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    
}


class Request: NSObject {
    var methodType : RequestMethod = RequestMethod(rawValue: "GET")!
    var params:[String:Any] = [:]
    var responseBlock: ResponseBlock  = {_,_,_ in }
    var _urlPart = NSString()
    var postParameters: [String:Any] = [:]
    var isSuccess = Bool()
    var serverData = [String :Any]()
    var headers = HTTPHeaders()
    var isMediaType = String()
    
    init(url urlString: String, method: RequestMethod, block: @escaping ResponseBlock) {
        super.init()
        _urlPart = urlString as NSString
        methodType = method
        postParameters = [String:Any]()
        responseBlock = block
    }
    
    func setParameter(_ parameter: Any, forKey key: String) {
        postParameters[key] = parameter
    }
    
    func startRequest()  {
    
        if methodType == RequestMethod.get{
            self .requestGETURL(_urlPart as String, success: { (JSON) in
                if (JSON.dictionaryObject as NSDictionary?) != nil {
                    print("json is a dictionary")
                    self.serverData = JSON.dictionaryObject!
                } else if (JSON.arrayObject as NSArray?) != nil {
                    self.serverData = ["data": JSON.arrayObject! as NSArray]
                    print("json is an array")
                } else {
                    
                }
                
                self.isSuccess = true
                self.requestSuccess(msg: "")
                
            }, failure: { (Error) in
                self.isSuccess = false
                self.requestFailedWithError(error: Error as NSError)
            })
        }
    }
    
    func requestGETURL(_ strURL: String, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        
        Alamofire.request(strURL, method: .get, parameters: postParameters, headers: headers).responseJSON { (responseObject) -> Void in
            if responseObject.response?.statusCode == 401{
                if #available(iOS 10.0, *) {
                } else { }
                return
            }
            if responseObject.result.isSuccess {
                let resJson = JSON(responseObject.result.value!)
                success(resJson)
            }
            if responseObject.result.isFailure {
                let error : Error = responseObject.result.error!
                failure(error)
            }
        }
    }
    
   
    
    func requestSuccess(msg:String)  {
        responseBlock(true,self,msg as NSString)
    }
    func requestFailedWithError (error: NSError){
        responseBlock(false, self,error.localizedDescription as NSString)
    }
}
