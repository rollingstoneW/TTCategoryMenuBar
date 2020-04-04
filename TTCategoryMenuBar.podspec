Pod::Spec.new do |s|
  s.name             = 'TTCategoryMenuBar'
  s.version          = '0.0.1'
  s.summary          = '多级列表菜单'

  s.description      = <<-DESC
功能丰富的多级列表菜单，支持丰富的自定义
                       DESC

  s.homepage         = 'https://github.com/rollingstoneW/TTCategoryMenuBar'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'rollingstoneW' => '190268198@qq.com' }
  s.source           = { :git => 'https://github.com/rollingstoneW/TTCategoryMenuBar.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'TTCategoryMenuBar/**/*'
  s.public_header_files = 'TTCategoryMenuBar/*.h'
  s.frameworks = 'UIKit', 'Foundation'
  s.dependency 'Masonry'


end
