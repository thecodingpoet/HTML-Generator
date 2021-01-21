require 'securerandom'

class ColorGenerator
  @@unique_colors = {}

  class << self 
    def unique_color
      loop do
        unless @@unique_colors[color] 
          @@unique_colors[color] = true 
          return color
        end
      end
    end
  
    def color
      "##{SecureRandom.hex(3)}"
    end
  end
end
 