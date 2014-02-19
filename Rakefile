desc "Runs tests."
task :test do
  exit system("xcodebuild -workspace SLExpandableTableViewTests.xcworkspace -scheme SLExpandableTableViewTests test -destination 'platform=iOS Simulator,name=iPhone Retina (4-inch)' | xcpretty -c; exit ${PIPESTATUS[0]}")
end

task :default => 'test'
