# frozen_string_literal: true

require_dependency "#{Rails.root}/lib/training/training_base"

class TrainingLibrary < TrainingBase
  attr_accessor  :modules, :introduction, :categories, :id, :translations, :description
  attr_writer :name
  # attr_accessor :name, :modules, :introduction, :categories, :id, :translations, :description
  alias raw_modules modules
  alias raw_categories categories

  #################
  # Class methods #
  #################
  def self.cache_key
    'libraries'
  end

  def self.path_to_yaml
    "#{base_path}/libraries/*.yml"
  end

  def self.wiki_base_page
    ENV['training_libraries_wiki_page']
  end

  def self.trim_id_from_filename
    false
  end
  ####################
  # Instance methods #
  ####################

  # transform categories hash into nested objects for view simplicity
  def categories
    raw_categories.to_hashugar
  end

  def translate_attribute(att)
    if (self.translations && self.translations[I18n.locale])
      self.translations[I18n.locale][att]
    else
       instance_variable_get("@"+att)
     end
  end

  def name
    translate_attribute('name')
  end

  def valid?
    required_attributes = [id, name, slug, introduction, categories]
    required_attributes.all?
  end
end
