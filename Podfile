platform :ios, "7.0"

workspace "AutoLayoutTextViews"
project "AutoLayoutTextViews"

target 'AutoLayoutTextViews' do
  use_frameworks!

  target 'AutoLayoutTextViewsTests' do
    inherit! :search_paths
    pod 'Expecta', '~> 1.0'
    pod 'OCMock', '~> 3.1'
  end
end

target 'AutoLayoutTextViewsDemo' do
  project "AutoLayoutTextViewsDemo/AutoLayoutTextViewsDemo"
  pod 'AutoLayoutTextViews', :path => '.'
end
