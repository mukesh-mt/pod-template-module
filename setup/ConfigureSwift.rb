module Pod

  class ConfigureSwift
    attr_reader :configurator

    def self.perform(options)
      new(options).perform
    end

    def initialize(options)
      @configurator = options.fetch(:configurator)
    end

    def perform
      keep_demo = configurator.ask_with_answers("Would you like to include a demo application with your library", ["Yes", "No"]).to_sym

#       framework = configurator.ask_with_answers("Which testing frameworks will you use", ["Quick", "None"]).to_sym
#       case framework
#         when :quick
#           configurator.add_pod_to_podfile "Quick', '~> 2.2.0"
#           configurator.add_pod_to_podfile "Nimble', '~> 10.0.0"
#           configurator.set_test_framework "quick", "swift", "swift"
#
#         when :none
          configurator.set_test_framework "xctest", "swift", "swift"
#       end

      Pod::ProjectManipulator.new({
        :configurator => @configurator,
        :xcodeproj_path => "templates/swift/Example/PROJECT.xcodeproj",
        :platform => :ios,
        :remove_demo_project => (keep_demo == :no),
        :prefix => ""
      }).run

      Pod::PodManipulator.new({
         :configurator => @configurator,
         :xcodeproj_path => "Pod/PROJECT.xcodeproj",
         :platform => :ios,
      }).run

      `mv ./templates/swift/* ./`
      `mv ./Pod/* ./`
      `rm -rf Pod`
      removeExmpleFolder if (keep_demo == :no)
    end

    def removeExmpleFolder
        `rm -rf Example`
    end
  end

end
