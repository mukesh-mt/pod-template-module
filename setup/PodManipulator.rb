require 'xcodeproj'

module Pod

  class PodManipulator
    attr_reader :configurator, :xcodeproj_path, :platform, :string_replacements

    def self.perform(options)
      new(options).perform
    end

    def initialize(options)
      @xcodeproj_path = options.fetch(:xcodeproj_path)
      @configurator = options.fetch(:configurator)
      @platform = options.fetch(:platform)
    end

    def run
      @string_replacements = {
        "PROJECT_OWNER" => @configurator.user_name,
        "TODAYS_DATE" => @configurator.date,
        "TODAYS_YEAR" => @configurator.year,
        "PROJECT" => @configurator.pod_name
      }
      replace_internal_project_settings

      # Add sample file to target
      system "touch " + project_folder + "/" + @configurator.pod_name + "/ReplaceMe.swift"
      # Rename files and folders
      rename_files
      rename_project_folder
    end

    def project_folder
      File.dirname @xcodeproj_path
    end

    def rename_files
      # shared schemes have project specific names
      scheme_path = project_folder + "/PROJECT.xcodeproj/xcshareddata/xcschemes/"
      File.rename(scheme_path + "PROJECT.xcscheme", scheme_path +  @configurator.pod_name + ".xcscheme")

      # rename xcproject
      File.rename(project_folder + "/PROJECT.xcodeproj", project_folder + "/" +  @configurator.pod_name + ".xcodeproj")

      # rename Doc file
      doc_path = project_folder + "/PROJECT/PROJECT.docc/"
      File.rename(doc_path + "PROJECT.md", doc_path +  @configurator.pod_name + ".md")

      # rename header file
      File.rename(project_folder + "/PROJECT/PROJECT.h", project_folder + "/PROJECT/" +  @configurator.pod_name + ".h")

      # rename test files
      File.rename(project_folder + "/PROJECTTests/PROJECTTests.swift", project_folder + "/PROJECTTests/" +  @configurator.pod_name + "Tests.swift")
    end

    def rename_project_folder

      if Dir.exist? project_folder + "/PROJECT/PROJECT.docc"
        File.rename(project_folder + "/PROJECT/PROJECT.docc", project_folder + "/PROJECT/" + @configurator.pod_name + ".docc")
      end

      if Dir.exist? project_folder + "/PROJECTTests"
        File.rename(project_folder + "/PROJECTTests", project_folder + "/" + @configurator.pod_name + "Tests")
      end

      if Dir.exist? project_folder + "/PROJECT"
        File.rename(project_folder + "/PROJECT", project_folder + "/" + @configurator.pod_name)
      end
    end

    def replace_internal_project_settings
      Dir.glob(project_folder + "/**/**/**/**").each do |name|
        next if Dir.exists? name
        text = File.read(name)

        for find, replace in @string_replacements
            text = text.gsub(find, replace)
        end

        File.open(name, "w") { |file| file.puts text }
      end
    end

  end

end
