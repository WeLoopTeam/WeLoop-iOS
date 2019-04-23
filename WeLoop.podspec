#
# Be sure to run `pod lib lint WeLoop.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WeLoop'
  s.version          = '0.2.3'
  s.summary          = 'Integrate WeLoop to your iOS project'

  s.description      = <<-DESC
Integrate WeLoop to your iOS project.
Allow direct feedback from users while they are using apps.
Provoke interactions between users in a conversational mode: who likes the last suggestion? Who amends with better ideas? Leverage lead users expertise.
Manage your community and reward the most engaged employees with a direct status report.
                       DESC

  s.homepage         = 'https://github.com/WeLoopTeam/WeLoop-iOS'
  s.license          = { type: 'MIT', file: 'LICENSE' }
  s.author           = { 'WeLoop' => 'contact@weloop.io' }
  s.source           = { git: 'https://github.com/WeLoopTeam/WeLoop-iOS.git', tag: s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.source_files = 'WeLoop/Classes/**/*'
  s.resources = 'WeLoop/Assets/**/*'
  s.swift_version = '5.0'

end
