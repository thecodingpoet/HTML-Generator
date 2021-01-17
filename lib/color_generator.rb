require 'securerandom'

class ColorGenerator
  attr_reader :color

  @@unique_colors = {}

  def generate_unique
    generate

    loop do
      if @@unique_colors[color] 
        generate
      else 
        @@unique_colors[color] = true 
        return color
      end
    end
  end

  def generate
    @color = "##{SecureRandom.hex(3)}"
  end
end
 