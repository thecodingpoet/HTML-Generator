require 'erb'
require_relative './color_generator'

class HtmlParser
  def initialize(content, highlights)
    @highlights = highlights.sort_by { |h| -h[:start] }
    @content = content
    @words = content.split(" ")
  end

  def build
    apply_highlights_to_paragraphs
    generate_html
  end

  private

  def apply_highlights_to_paragraphs
    @highlights.each_with_index do |highlight, index|
      start_index = highlight[:start] - 1
      end_index = (highlight[:end] < @words.count ? highlight[:end] : @words.count) - 1
      comment = highlight[:comment]
      color = ColorGenerator.new.generate_unique

      if highlights_accross_multiple_paragraph?(start_index, end_index)
        intervals = generate_intervals(start_index, end_index)

        intervals.each_with_index do |interval, index|
          break unless index < intervals.count - 1

          start_index = index == 0 ? interval : interval + 1
          end_index = intervals[index + 1] 
          
          insert_tooltip(start_index, end_index, color, comment)
        end
      else 
        insert_tooltip(start_index, end_index, color, comment)
      end
    end
  end

  def insert_tooltip(start_index, end_index, color, comment)
    text = @words[start_index..end_index].join(" ")
  
    @words[start_index..end_index] = tooltip(text, comment, color)
    @words.insert(start_index + 1, *[""] * ((start_index..end_index).count - 1))
  end 

  def generate_intervals(start_index, end_index)
    [
      start_index,
      *paragraphs_indexes.reject { |p| p < start_index || p > end_index},
      end_index
    ].uniq
  end

  def paragraphs_indexes
    acc = 0
    @paragraphs_indexes ||= @content.split("\n\n").map { |paragraph| acc += paragraph.split(" ").count }.map{ |n| n - 1 }
  end

  def highlights_accross_multiple_paragraph?(start_index, end_index)
    paragraphs_indexes.each do |index|
      if index.between?(start_index, end_index)
        return true
      end
    end
  end

  def generate_html 
    File.open("out.html", "w+") { |file| file.write(rhtml) }
  end

  def rhtml
    template = ERB.new File.new("./template.erb").read
    template.result(binding)
  end

  def paragraphs
    result = []
    start_index = 0

    paragraphs_indexes.each do |interval|
      end_index = interval
      result << p_tag(@words[start_index..end_index].join(" "))
      start_index = end_index
    end

    result
  end

  def tooltip(text, comment, color)
    <<~TOOLTIP
      <span class="tooltip" data-text="#{comment}"" style="background-color: #{color};">
        #{text}
      </span>
    TOOLTIP
  end

  def p_tag(content)
    "<p>#{content}</p>"
  end
end

content = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas consectetur malesuada velit, sit amet porta magna maximus nec. Aliquam aliquet tincidunt enim vel rutrum. Ut augue lorem, rutrum et turpis in, molestie mollis nisi. Ut dapibus erat eget felis pulvinar, ac vestibulum augue bibendum. Quisque sagittis magna nisi. Sed aliquam porttitor fermentum. Nulla consequat justo eu nulla sollicitudin auctor. Sed porta enim non diam mollis, a ullamcorper dolor molestie. Nam eu ex non nisl viverra hendrerit. Donec ante augue, eleifend vel eleifend quis, laoreet volutpat ipsum. Integer viverra aliquam nulla, ac rutrum dui sodales nec.

Sed turpis enim, porttitor nec maximus sed, lua.ctus pretium elit. Sed sodales imperdiet velit, vitae viverra erat commodo non. Nunc porttitor risus sit amet quam faucibus, et luctus ex fringilla. Mauris quis urna non lacus tempor iaculis vitae quis dolor. Nam vitae pulvinar lacus, quis varius erat. Etiam lobortis orci vitae elementum tempor. Praesent convallis euismod enim vel vestibulum. Proin vitae eros vitae nisi cursus dapibus vitae at ipsum. Phasellus sed tempor eros, non scelerisque nunc. Nullam condimentum ex ultrices, ultrices ante sit amet, rhoncus nibh. Aliquam fermentum vulputate fringilla. Ut risus orci, pharetra eu tellus vel, fringilla feugiat dolor.

Nunc quis elit quam. Sed aliquet, nibh ut sagittis egestas, lorem tortor laoreet diam, non maximus lectus dolor dignissim eros. Sed vehicula mi id aliquet aliquam. Vestibulum sed lacus et neque dictum convallis in vitae mauris. Etiam varius augue vel mattis tempor. Curabitur mattis facilisis metus, tempus consectetur quam aliquam sed. Mauris velit orci, efficitur sit amet nisl in, finibus dictum elit. In lectus augue, elementum eu sapien sed, auctor tincidunt urna.

Orci varius natoque penatibus et magnis dis paryturient montes, nascetur ridiculus mus. Integer lacinia accumsan velit. Duis vel facilisis libero. Cras consequat sit amet mauris ut ultrices. Ut pulvinar sit amet odio sit amet pretium. Nullam tortor ligula, consequat non nisl vitae, rutrum placerat est. Sed finibus interdum justo vel placerat. Cras varius tortor sed justo tempus scelerisque. Praesent facilisis ex vitae iaculis iaculis. Sed consectetur a lectus non condimentum. Etiam id lacus a nulla cursus laoreet. Vivamus ipsum purus, sodales vel metus varius, viverra mollis justo. Nulla facilisi. Vivamus volutpat nunc elit, quis sollicitudin velit ornare sit amet.

Nullam fringilla nisi nunc, vitae accumsan tortor luctus quis. Sed facilisis, est ut eleifend sagittis, felis dolor pellentesque lectus, in congue purus orci non nunc. Nunc finibus eu metus et volutpat. Integer hendrerit tortor et tellus euismod vulputate. Aliquam erat volutpat. Aenean gravida justo in risus feugiat, ut suscipit tortor ullamcorper. Nam a sapien dictum, vestibulum eros vitae, sodales turpis. Interdum et malesuada fames ac ante ipsum primis in faucibus. Sed ultricies at elit et rutrum. Sed placerat erat quis condimentum convallis. Duis ornare magna nec ante faucibus malesuada. Duis a erat sed sapien semper eleifend. Mauris consequat nibh sollicitudin mi euismod, non ultricies lectus bibendum. Cras a erat libero. Aliquam nisl ipsum, scelerisque at risus a, hendrerit vestibulum sapien. Proin luctus diam eu mi lobortis molestie id vel ante."

highlights = [{
  start: 20,
  end: 35,
  comment: 'Foo'
}, {
  start: 73,
  end: 100,
  comment: 'Bar'
}, {
  start: 85,
  end: 98,
  comment: 'Baz'
}]

parser = HtmlParser.new content, highlights
parser.build
