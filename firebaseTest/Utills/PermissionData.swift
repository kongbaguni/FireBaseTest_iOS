//
//  PermissionData.swift
//  test
//
//  Created by 서창열 on 2019/11/01.
//  Copyright © 2019 서창열. All rights reserved.
//

import UIKit
import AVKit
import Photos
import Contacts
import EventKit

class Permission : NSObject {
    enum `Type` {
        /**카메라*/
        case camera
        /**마이크 접근 */
        case microphone
        /**포토라이브러리 접근*/
        case photoLibrary
        /** 연락처*/
        case contact
        /** 위치정보*/
        case location
        /** 달력*/
        case event
        /** 할일목록*/
        case reminder
    }
    
    enum Status {
        /** 응답 전*/
        case notDetermined
        /** 거절됨*/
        case denined
        /** 허가됨*/
        case authorized
        
        case restricted
    }
    
    struct Data:Hashable {
        let type:Type
        let title:String
        let desc:String
        let iconImage:UIImage?
        let isRequired:Bool
        let order:Int
    }
    
    static let shared = Permission()
    
    private var complete:()->Void = {}
    
    /** 권한 상태 체크*/
    func check(type:Type)->Status {
        switch type {
        case .camera:
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                return .authorized
            case .denied:
                return .denined
            case .notDetermined:
                return .notDetermined
            default:
                return .restricted
            }
        case .photoLibrary:
            switch PHPhotoLibrary.authorizationStatus() {
            case .authorized:
                return .authorized
            case .denied:
                return .denined
            case .notDetermined:
                return .notDetermined
            default:
                return .restricted
            }
        case .location:
            return LocationManager.shared.status
        case .contact:
            switch CNContactStore.authorizationStatus(for: .contacts) {
            case .authorized:
                return .authorized
            case .denied:
                return .denined
            case .notDetermined:
                return .notDetermined
            default:
                return .restricted
            }
        case .event:
            switch EKEventStore.authorizationStatus(for: .event) {
            case .authorized:
                return .authorized
            case .denied:
                return .denined
            case .notDetermined:
                return .notDetermined
            default:
                return .restricted
            }
        case .reminder:
            switch EKEventStore.authorizationStatus(for: .reminder) {
            case .authorized:
                return .authorized
            case .denied:
                return .denined
            case .notDetermined:
                return .notDetermined
            default:
                return .restricted
            }
        default:
            return .restricted
        }
    }
    
    /** 권한 요청*/
    func request(type:Type, complete:@escaping()->Void) {
        switch type {
        case .camera:
            AVCaptureDevice.requestAccess(for: .video) { (sucess) in
                DispatchQueue.main.async {
                    complete()
                }
            }
        case .photoLibrary:
            PHPhotoLibrary.requestAuthorization { (status) in
                DispatchQueue.main.async {
                    complete()
                }
            }
        case .location:
//            LocationManager.shared.requestAuth { _ in
//                complete()
//            }
            break
        case .contact:
            CNContactStore().requestAccess(for: .contacts) { (_, _) in
                complete()
            }
        case .event:
            EKEventStore().requestAccess(to: .event) { (_, _) in
                complete()
            }
        case .reminder:
            EKEventStore().requestAccess(to: .reminder) { (_, _) in
                complete()
            }
        default:
            break
        }
    }
}

