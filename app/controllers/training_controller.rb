# frozen_string_literal: true

require_dependency "#{Rails.root}/lib/training_progress_manager"
require_dependency "#{Rails.root}/lib/training_library"
require_dependency "#{Rails.root}/lib/training_module"
require_dependency "#{Rails.root}/lib/data_cycle/training_update"

class TrainingController < ApplicationController
  layout 'training'

  def index
    @libraries = TrainingLibrary.all.sort_by(&:name)
  end

  def show
    add_training_root_breadcrumb

    fail_if_entity_not_found(TrainingLibrary, params[:library_id])
    @library = TrainingLibrary.find_by(slug: params[:library_id])
    add_library_breadcrumb(@library)
  end

  def training_module
    fail_if_entity_not_found(TrainingModule, params[:module_id])
    @pres = TrainingModulePresenter.new(current_user, params)
    add_training_root_breadcrumb
    fail_if_entity_not_found(TrainingLibrary, params[:library_id])
    add_library_breadcrumb(TrainingLibrary.find_by(slug: params[:library_id]))
    add_module_breadcrumb(@pres.training_module)
  end

  def slide_view
    training_module = TrainingModule.find_by(slug: params[:module_id])
    if current_user
      @tmu = TrainingModulesUsers.find_or_create_by(
        user_id: current_user.id,
        training_module_id: training_module.id
      )
    end
    add_training_root_breadcrumb
    add_module_breadcrumb(training_module)
  end

  def reload
    render plain: TrainingUpdate.new(module_slug: params[:module]).result
  rescue TrainingBase::DuplicateIdError, TrainingBase::DuplicateSlugError,
         TrainingModule::ModuleNotFound, TrainingLoader::NoMatchingWikiPagesFound => e
    render plain: e.message
  end

  private

  def add_training_root_breadcrumb
    add_breadcrumb(I18n.t('training.training_library'), :training_path)
  end

  def add_library_breadcrumb(training_library)
    name = (!training_library.translations.nil? && !training_library.translations[I18n.locale].nil?) \
      ? training_library.translations[I18n.locale].name : training_library.name
    add_breadcrumb name.titleize, :training_library_path
  end

  def add_module_breadcrumb(training_module)
    name = (!training_module.translations.nil? && !training_module.translations[I18n.locale].nil?) \
      ? training_module.translations[I18n.locale].name : training_module.name
    add_breadcrumb name, :training_module_path
  end

  def fail_if_entity_not_found(entity, finder)
    raise ModuleNotFound, "#{entity}: #{finder}" unless entity.find_by(slug: finder).present?
  end

  class ModuleNotFound < StandardError; end
end
