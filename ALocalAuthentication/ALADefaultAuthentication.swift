//
//  AOSAuthentication.swift
//  Level
//
//  Created by Ihor Myroniuk on 9/24/18.
//  Copyright © 2018 Brander. All rights reserved.
//

import Foundation
import LocalAuthentication

open class ALADefaultAuthentication: ALAAuthentication {
  
  // MARK: Data
  
  private var context = LAContext()
  
  // MARK: Initializer
  
  public init() {
    
  }
  
  // MARK: Support
  
  open func isMethodSupported(_ method: ALAAuthenticationMethod) -> Bool {
    let unavailableReason = isMethodUnavailable(method)
    return unavailableReason != .notSupported
  }
  
  // MARK: Set Up
  
  open func isMethodSetUp(_ method: ALAAuthenticationMethod) -> Bool {
    let unavailableReason = isMethodUnavailable(method)
    return unavailableReason != .notSetUp && unavailableReason != .notSupported
  }
  
  // MARK: Lockout
  
  open func isMethodLockout(_ method: ALAAuthenticationMethod) -> Bool {
    let unavailableReason = isMethodUnavailable(method)
    return unavailableReason == .lockout
  }
  
  // MARK: Availability
  
  open func isMethodAvailable(_ method: ALAAuthenticationMethod) -> Bool {
    let policy: LAPolicy = method == .biometryOrPasscode ? .deviceOwnerAuthentication : .deviceOwnerAuthenticationWithBiometrics
    let canEvaluatePolicy = context.canEvaluatePolicy(policy, error: nil)
    return canEvaluatePolicy
  }
  
  open func isMethodUnavailable(_ method: ALAAuthenticationMethod) -> ALAAuthenticationMethodUnavailableReason? {
    let policy: LAPolicy = method == .biometryOrPasscode ? .deviceOwnerAuthentication : .deviceOwnerAuthenticationWithBiometrics
    var error: NSError?
    let canEvaluatePolicy = context.canEvaluatePolicy(policy, error: &error)
    if !canEvaluatePolicy {
      if let laError = error as? LAError {
        if #available(iOS 11, *), #available(iOS 12, *), #available(iOS 13, *) {
          if LAError.passcodeNotSet == laError.code { return .notSetUp }
          else if LAError.biometryNotAvailable == laError.code { return .notSupported }
          else if LAError.touchIDNotAvailable == laError.code { return .denied }
          else if LAError.biometryNotEnrolled == laError.code { return .notSetUp }
          else if LAError.biometryLockout == laError.code { return .lockout }
        }
        if #available(iOS 10, *) {
          if LAError.passcodeNotSet == laError.code { return .notSetUp }
          else if LAError.touchIDNotAvailable == laError.code { return .notSupported }
          else if LAError.touchIDNotEnrolled == laError.code {return .notSetUp }
          else if LAError.touchIDLockout == laError.code { return .lockout }
        }
      }
    }
    return nil
  }
  
  // MARK: Biometry
  
  open var supportedBiometryType: ALAAuthenticationBiometryType? {
    if isMethodSupported(.biometry) {
      if #available(iOS 11, *) {
        return context.biometryType == .faceID ? .face : .fingerprint
      } else {
        return .fingerprint
      }
    }
    return nil
  }
  
  // MARK: Authentication
  
  open func authenticate(method: ALAAuthenticationMethod, customization: ALAAuthenticationCustomization, onComplete completion: @escaping (ALAAuthenticationResult) -> Void) {
    context = LAContext()
    context.localizedCancelTitle = customization.cancelTitle
    if #available(iOS 11, *) {
      context.localizedReason = customization.reason
    }
    context.localizedFallbackTitle = customization.fallbackTitle
    let policy: LAPolicy = method == .biometryOrPasscode ? .deviceOwnerAuthentication : .deviceOwnerAuthenticationWithBiometrics
    context.evaluatePolicy(policy, localizedReason: customization.reason) { (isSuccess, error) in
      let result: ALAAuthenticationResult
      if isSuccess {
        result = .success
      } else {
        if let error = error {
          if let laError = error as? LAError {
            if LAError.authenticationFailed == laError.code { result = .failed }
            else if LAError.userCancel == laError.code { result = .canceledByUser }
            else if LAError.appCancel == laError.code { result = .canceledByApplication }
            else if LAError.systemCancel == laError.code { result = .canceledByOperatingSystem }
            else if LAError.userFallback == laError.code { result = .fallback }
            else {
              result = .error(error)
            }
          } else {
            result = .error(error)
          }
        } else {
          result = .canceledByOperatingSystem
        }
      }
      DispatchQueue.main.async { completion(result) }
    }
  }
  
}
