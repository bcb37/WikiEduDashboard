# frozen_string_literal: true

require_dependency "#{Rails.root}/lib/wikitext"
require_dependency "#{Rails.root}/lib/utils"
require_dependency "#{Rails.root}/lib/training/wiki_table_parser"

#= Takes wikitext for an on-wiki library page and extracts categories heirarchy
class WikiLibraryParser
  def initialize(wikitext)
    @wikitext = wikitext&.dup || +''
    set_utf8_encoding
    remove_noinclude
    remove_translation_markers
    remove_translate_tags
  end

  # The first translated line is the slide title
  def name
    return '' if @wikitext.blank?
    name = @wikitext.lines.first.chomp
    # remove header markup for level 2 or lower
    name.gsub(/==+/, '').strip
  end

  def introduction
    return '' if @wikitext.blank?
    @wikitext.lines[1].chomp
  end

  # Everything after the first translated line is the slide content
  def content
    return '' if @wikitext.blank?
    wikitext = @wikitext.lines[1..-1].join # Line 0 is the title
    #wikitext[0] = '' while wikitext[0] == "\n" # Remove leading newlines
    #wikitext[-1] = '' while wikitext[-1] == "\n"
    table = WikiTableParser.new(wikitext)
    table.root
  end

  def parse_table_into_categories
    Utils.parse_json(self.content)
  end

  def library_hash
    hash = {}
    hash['name'] = self.name
    hash['introduction'] = self.introduction
    hash['categories'] = self.parse_table_into_categories
    hash
  end

  private

  def set_utf8_encoding
    @wikitext = @wikitext.force_encoding('UTF-8')
  end

  def remove_noinclude
    @wikitext.gsub!(%r{<noinclude>.*?</noinclude>\n*}m, '')
  end

  def remove_translation_markers
    # Remove both marker and any trailing whitespace after it,
    # which may interfere with correct markdown conversion.
    # Matches any amount of horizontal whitespace (\h) but at most
    # one newline, to prevent concatenating the title with the contents.
    @wikitext.gsub!(/<!--.+?-->\h*\n??/, '')
  end

  def remove_translate_tags
    # Remove both the tags and any excess whitespace within them,
    # which may interfere with correct markdown conversion.
    @wikitext.gsub!(/<translate>\s*/, '')
    @wikitext.gsub!(%r{\s*</translate>}, '')
    @wikitext.gsub!(/<tvar.*?>/, '')
    @wikitext.gsub!(%r{</>}, '')
  end

  def parse_wiki_table

    retrun json
  end

end
