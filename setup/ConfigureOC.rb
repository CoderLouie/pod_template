module Pod
    
    class ConfigureOC
        attr_reader :configurator
        
        def self.perform(options)
            new(options).perform
        end
        
        def initialize(options)
            @configurator = options.fetch(:configurator)
        end
        
        def perform
            
            prefix = nil
            
            loop do
                prefix = configurator.ask("What is your class prefix").upcase
                
                if prefix.include?(' ')
                    puts 'Your class prefix cannot contain spaces.'.red
                else
                    break
                end
            end
            
            Pod::ProjectManipulator.new({
                                        :configurator => @configurator,
                                        :xcodeproj_path => "templates/oc/Example/PROJECT.xcodeproj",
                                        :platform => :ios,
                                        :remove_demo_project => false,
                                        :prefix => prefix
                                        }).run
                                        
                                        # There has to be a single file in the Classes dir
                                        # or a framework won't be created, which is now default
                                        
                                        `mv ./templates/oc/Example/* ./`
                                         
        end
    end
    
end
