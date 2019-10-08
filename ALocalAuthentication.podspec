Pod::Spec.new do |s|

  s.name         = "ALocalAuthentication"
  s.version      = "0.0.1"
  s.summary      = "Advanced Local Authentication."
  s.description  = "Advanced Local Authentication approach."
  s.homepage     = "https://github.com/ihormyroniuk/AUIKit"

  s.license      = "MIT"

  s.author       = { "Ihor Myroniuk" => "ihormyroniuk@gmail.com" }

  s.platform     = :ios, "10.0"

  s.source       = { :git => "https://github.com/ihormyroniuk/ALocalAuthentication.git", 
:tag => "0.0.1" }

  s.source_files = "ALocalAuthentication/**/*.{swift}"

  s.swift_version = "4.2"

end
