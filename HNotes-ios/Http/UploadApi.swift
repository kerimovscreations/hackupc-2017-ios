//
//  UploadApi.swift
//  HNotes-ios
//
//  Created by Karim Karimov on 10/14/17.
//  Copyright © 2017 Karim Karimov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class UploadApi {
    var commonData: CommonData;
    
    init() {
        self.commonData = CommonData();
    }
    
    func upload (
        image: UIImage,
        onComplete: ((_ result: Int, _ message: String, _ note: Note) -> Void)? = nil) {
        
        let imgData = UIImageJPEGRepresentation(image, 0.5)!
        var resultNote = Note()
        
        let parameters = ["name": "test"]
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData, withName: "fileset", fileName: "file.jpg", mimeType: "image/jpg")
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        },
                         to: commonData.getServerUrl() + "upload")
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { responseJson in
                    print(responseJson.result.value ?? "")
                    
                    let json = JSON(responseJson.data as Any)
                    
                    if Response().checkResponseFromJson(json: json.rawValue) == 1 {
                        onComplete?(1, "", resultNote)
                    }else{
                        onComplete?(Response().checkResponseFromJson(json: json.rawValue), Response().getErrorMessageFromJson(json: json), resultNote)
                    }
                }
                
            case .failure(let encodingError):
                print(encodingError)
                onComplete?(0, "Encoding error has been occurred, please retry later", resultNote)
            }
        }
    }
}