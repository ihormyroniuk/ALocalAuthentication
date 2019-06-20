//
//  AOSAuthentication.swift
//  Level
//
//  Created by Ihor Myroniuk on 9/24/18.
//  Copyright © 2018 Brander. All rights reserved.
//

import Foundation
import LocalAuthentication

class ALADefaultAuthentication: ALAAuthentication {
  
  // MARK: Data
  
  private var context = LAContext()
  
  // MARK: Delegates
  
  weak var userCancelDelegate: ALAAuthenticationUserCancelDelegate?
  weak var userFallbackDelegate: ALAAuthenticationUserFallbackDelegate?
  
  weak var operatingSystemCancelDelegate: ALAAuthenticationOperatingSystemCancelDelegate?
  
  // MARK: Support
  
  func isMethodSupported(_ method: ALAAuthenticationMethod) -> Bool {
    let unavailableReason = isMethodUnavailable(method)
    return unavailableReason != .notSupported
  }
  
  // MARK: Set Up
  
  func isMethodSetUp(_ method: ALAAuthenticationMethod) -> Bool {
    let unavailableReason = isMethodUnavailable(method)
    return unavailableReason != .notSetUp && unavailableReason != .notSupported
  }
  
  // MARK: Lockout
  
  func isMethodLockout(_ method: ALAAuthenticationMethod) -> Bool {
    let unavailableReason = isMethodUnavailable(method)
    return unavailableReason == .lockout
  }
  
  // MARK: Availability
  
  func isMethodAvailable(_ method: ALAAuthenticationMethod) -> Bool {
    let policy: LAPolicy = method == .biometryOrPasscode ? .deviceOwnerAuthentication : .deviceOwnerAuthenticationWithBiometrics
    let canEvaluatePolicy = context.canEvaluatePolicy(policy, error: nil)
    return canEvaluatePolicy
  }
  
  func isMethodUnavailable(_ method: ALAAuthenticationMethod) -> ALAAuthenticationMethodUnavailableReason? {
    let policy: LAPolicy = method == .biometryOrPasscode ? .deviceOwnerAuthentication : .deviceOwnerAuthenticationWithBiometrics
    var error: NSError?
    let canEvaluatePolicy = context.canEvaluatePolicy(policy, error: &error)
    if !canEvaluatePolicy {
      if let laError = error as? LAError {
        if LAError.passcodeNotSet == laError.code { return .notSetUp }
        else if LAError.touchIDNotAvailable == laError.code {
          if #available(iOS 11, *) { return .denied }
          return .notSupported
        }
        else if #available(iOS 11, *), LAError.biometryNotAvailable == laError.code {
          if context.biometryType == .faceID { return .denied }
          return .notSupported
        }
        else if LAError.touchIDNotEnrolled == laError.code {return .notSetUp }
        else if #available(iOS 11, *), LAError.biometryNotEnrolled == laError.code { return .notSetUp }
        else if LAError.touchIDLockout == laError.code { return .lockout }
        else if #available(iOS 11, *), LAError.biometryLockout == laError.code { return .lockout }
      }
    }
    return nil
  }
  
  // MARK: Biometry
  
  var supportedBiometryType: ALAAuthenticationBiometryType? {
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
  
  enum AuthenticationResult {
    case success
    case canceledByUser
    case canceledByApplication
    case canceledByOperatingSystem
    case fallback
    case failed
    case error(Error)
  }
  func authenticate(_ method: ALAAuthenticationMethod, onComplete completion: @escaping (AuthenticationResult) -> Void) {
    context = LAContext()
    context.localizedCancelTitle = nil//"title for the cancel button"
    if #available(iOS 11, *) {
      context.localizedReason = "Log in to your account"//"explanation for authentication"
    }
    context.localizedFallbackTitle = nil//"title for the fallback button"
    let policy: LAPolicy = method == .biometryOrPasscode ? .deviceOwnerAuthentication : .deviceOwnerAuthenticationWithBiometrics
    context.evaluatePolicy(policy, localizedReason: "Log in to your account") { [weak self] (isSuccess, error) in
      guard let strongSelf = self else { return }
      let result: AuthenticationResult
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
              
            else if LAError.userCancel == laError.code {
              strongSelf.userFallbackDelegate?.didUserFallbackAuthentication(strongSelf)
              result = .canceledByUser
            }
              
            else { result = .error(error) }
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
