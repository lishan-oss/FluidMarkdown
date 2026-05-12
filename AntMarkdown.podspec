Pod::Spec.new do |spec|
  spec.name = 'AntMarkdown'
  spec.version = '0.1.1'
  spec.summary = 'iOS Markdown rendering (FluidMarkdown / Ant fork)'
  spec.description = <<-DESC
    Markdown rendering with code highlighting, math, tables, and streaming AMXMarkdownTextView.
    Derived from antgroup/FluidMarkdown; packaged for CocoaPods.
  DESC

  spec.homepage = 'https://github.com/shengjunxiangban/FluidMarkdown'
  spec.license = { :type => 'Apache-2.0', :file => 'LICENSE' }
  spec.author = { 'FluidMarkdown Authors' => 'shengjunxiangban@example.com' }

  spec.platform = :ios, '11.0'
  spec.requires_arc = true

  spec.source = { :git => 'https://github.com/shengjunxiangban/FluidMarkdown.git', :tag => spec.version.to_s }

  # Public headers must include CocoaMarkdown: AMTextStyles.h (Public) imports "CocoaMarkdown.h",
  # otherwise Swift explicit modules fail with 'CocoaMarkdown.h' file not found.
  spec.public_header_files = [
    'AntMarkdown/Sources/Public/*.h',
    'AntMarkdown/Sources/External/CocoaMarkdown/**/*.h',
    'Sources/**/*.h'
  ]

  spec.source_files = [
    'AntMarkdown/Sources/Public/**/*.{h,m}',
    'AntMarkdown/Sources/External/**/*.{h,m,c}',
    'Sources/**/*.{h,m}'
  ]

  spec.exclude_files = [
    'AntMarkdown/Sources/External/**/Info.plist',
    '**/*.plist'
  ]

  spec.resource_bundles = {
    'AntMarkdown' => [
      'AntMarkdown/Resources/AntMarkdown.bundle/**/*',
      'AntMarkdown/Resources/highlightjs.bundle/**/*',
      'AntMarkdown/Resources/mathFonts.bundle/**/*'
    ]
  }

  spec.frameworks = 'UIKit', 'Foundation', 'JavaScriptCore', 'CoreText', 'CoreGraphics'

  spec.pod_target_xcconfig = {
    'HEADER_SEARCH_PATHS' => '$(inherited) "$(PODS_TARGET_SRCROOT)/AntMarkdown/Sources/External/**"',
    'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited)'
  }
end
