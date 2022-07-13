require 'xcodeproj'

module Pod
    
    class ProjectManipulator
        attr_reader :configurator, :xcodeproj_path, :platform, :remove_demo_target, :string_replacements, :prefix
        
        def self.perform(options)
            new(options).perform
        end
        
        def initialize(options)
            @xcodeproj_path = options.fetch(:xcodeproj_path)
            @configurator = options.fetch(:configurator)
            @platform = options.fetch(:platform)
            @remove_demo_target = options.fetch(:remove_demo_project)
            @prefix = options.fetch(:prefix)
        end
        
        def run
            @string_replacements = {
                "PROJECT_OWNER" => @configurator.project_owner,
                "USER_NAME" => @configurator.user_name,
                "TODAYS_DATE" => @configurator.date,
                "TODAYS_YEAR" =>  @configurator.year,
                "PROJECT" => @configurator.pod_name,
                "CPD" => @prefix
            }
            replace_internal_project_settings
            
            @project = Xcodeproj::Project.open(@xcodeproj_path)
            add_podspec_metadata
            @project.save
            
            rename_files
            rename_project_folder
        end
        
        def project_folder
            File.dirname @xcodeproj_path
        end
        
        
        def add_podspec_metadata
          project_metadata_item = @project.root_object.main_group.children.select { |group| group.name == "Podspec Metadata" }.first
          project_metadata_item.new_file "../" + @configurator.pod_name  + ".podspec"
          project_metadata_item.new_file "../README.md"
          project_metadata_item.new_file "../LICENSE"
        end
        
        def rename_files
            # shared schemes have project specific names
            scheme_path = project_folder + "/PROJECT.xcodeproj/xcshareddata/xcschemes/"
            File.rename(scheme_path + "PROJECT-Example.xcscheme", scheme_path +  @configurator.pod_name + "-Example.xcscheme")
            
            # rename xcproject
            File.rename(project_folder + "/PROJECT.xcodeproj", project_folder + "/" +  @configurator.pod_name + ".xcodeproj")
            File.rename(project_folder + "/Example for PROJECT", project_folder + "/Example for " +  @configurator.pod_name)
            
            ["CPDAppDelegate.h", "CPDAppDelegate.m", "CPDViewController.h", "CPDViewController.m"].each do |file|
                before = project_folder + "/PROJECT/" + file
                next unless File.exists? before
                
                after = project_folder + "/PROJECT/" + file.gsub("CPD", prefix)
                File.rename before, after
            end
             
        end
        
        def rename_project_folder
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
