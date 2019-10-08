//
//  AOSAuthentication.swift
//  Level
//
//  Created by Ihor Myroniuk on 11/6/18.
//  Copyright © 2018 Brander. All rights reserved.
//

import Foundation

public enum ALAAuthenticationMethod {
  case biometry
  case biometryOrPasscode
}

public enum ALAAuthenticationBiometryType {
  case fingerprint
  case face
}

public enum ALAAuthenticationMethodUnavailableReason {
  case notSupported
  case notSetUp
  case lockout
  case denied
}

public enum ALAAuthenticationResult {
  case success
  case canceledByUser
  case canceledByApplication
  case canceledByOperatingSystem
  case fallback
  case failed
  case error(Error)
}

public protocol ALAAuthentication {
  
  // MARK: Biometry
  
  var supportedBiometryType: ALAAuthenticationBiometryType? { get }
  
}
