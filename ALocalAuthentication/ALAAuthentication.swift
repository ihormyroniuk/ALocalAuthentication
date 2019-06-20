//
//  AOSAuthentication.swift
//  Level
//
//  Created by Ihor Myroniuk on 11/6/18.
//  Copyright © 2018 Brander. All rights reserved.
//

import Foundation

protocol ALAAuthenticationUserCancelDelegate: class {
  func didUserCancelAuthentication(_ authentication: ALAAuthentication)
}

protocol ALAAuthenticationUserFallbackDelegate: class {
  func didUserFallbackAuthentication(_ authentication: ALAAuthentication)
}

protocol ALAAuthenticationApplicationCancelDelegate: class {
  func didOperatingApplicationCancelAuthentication(_ authentication: ALAAuthentication)
}

protocol ALAAuthenticationOperatingSystemCancelDelegate: class {
  func didOperatingSystemCancelAuthentication(_ authentication: ALAAuthentication)
}

enum ALAAuthenticationMethod {
  case biometry
  case biometryOrPasscode
}

enum ALAAuthenticationBiometryType {
  case fingerprint
  case face
}

enum ALAAuthenticationMethodUnavailableReason {
  case notSupported
  case notSetUp
  case lockout
  case denied
}

protocol ALAAuthentication {
  var userFallbackDelegate: ALAAuthenticationUserFallbackDelegate? { get set }
  var userCancelDelegate: ALAAuthenticationUserCancelDelegate? { get set }
  
  // MARK: Biometry
  
  var supportedBiometryType: ALAAuthenticationBiometryType? { get }
}
