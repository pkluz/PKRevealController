Pod::Spec.new do |spec|
    spec.name = 'PKRevealController'
    spec.version = '2.0.0'
    spec.authors = { 'Philip Kluz' => 'philip.kluz@zuui.org' }
    spec.homepage = 'https://github.com/pkluz/PKRevealController'
    spec.summary = 'The second version of one of the most popular view controller containers for iOS, enabling you to present multiple controllers on top of one another. It is easy to set-up and highly flexible.'
    spec.license = { :type => 'MIT', :file => 'LICENSE' }
    spec.requires_arc = true
    spec.source = { :git => 'https://github.com/pkluz/PKRevealController.git', :tag => "v#{spec.version}" }
    spec.source_files = 'Source/**/*.{h,m}'
end