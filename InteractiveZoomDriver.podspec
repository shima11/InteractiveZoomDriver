Pod::Spec.new do |s|

  s.name         = "InteractiveZoomDriver"
  s.version      = "1.0.0"
  s.summary      = "UIView to zoomable by pinch gesture."

  s.description  = <<-DESC
        This repo is view to zoomable by pinch gesture.
    DESC

  s.ios.deployment_target = '9.0'
  s.homepage     = "https://github.com/shima11/InteractiveZoomDriver"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Shima" => "shima.jin@icloud.com" }

  s.source       = { :git => "https://github.com/shima11/InteractiveZoomDriver.git", :tag => s.version.to_s }
  s.source_files = "Sources/InteractiveZoomDriver/*.swift"

end
