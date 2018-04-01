# frozen_string_literal: true

require 'rails_helper'
require "#{Rails.root}/lib/training_module"
require "#{Rails.root}/lib/training_library"
require "#{Rails.root}/lib/data_cycle/training_update"

def flush_training_caches
  TrainingModule.flush
  TrainingLibrary.flush
end

describe 'Training Translations', type: :feature, js: true do
  let(:basque_user) { create(:user, id: 2, username: 'ibarra', locale: 'eu') }

  before do
    page.driver.browser.url_blacklist = ['https://www.youtube.com', 'https://upload.wikimedia.org']
    allow(Features).to receive(:wiki_trainings?).and_return(true)
    flush_training_caches

    login_as(basque_user, scope: :user)
  end

  after { flush_training_caches }

  describe 'for slides' do

    before do
      VCR.use_cassette('training/slide_translations') do
        TrainingUpdate.new(module_slug: 'all')
      end
    end

    it 'shows the translated text of a quiz' do
      visit '/training/editing-wikipedia/wikipedia-essentials/five-pillars-quiz-1'
      expect(page).to have_content 'Wikipedia artikulu batek'
    end

    it 'shows the translated names in the table of contents' do
      visit '/training/editing-wikipedia/wikipedia-essentials/five-pillars-quiz-1'
      expect(page).to have_css('.slide__menu__nav__dropdown ol',
                               text: 'Bost euskarriei buruzko proba',
                               visible: false)
    end

  end

  describe 'for libraries' do
    let(:content_class) { TrainingLibrary }
    let(:content_class_foo) { TrainingModule }
    before do
      allow(content_class).to receive(:wiki_base_page)
        .and_return('Training modules/dashboard/libraries-i18nJSON-test')
      allow(content_class_foo).to receive(:wiki_base_page)
        .and_return('Training modules/dashboard/modules-i18n-test')

      VCR.use_cassette('training/library_translations') do
        TrainingUpdate.new(module_slug: 'all')
      end
    end

    it 'shows the translated text of a library' do
      visit '/training'
      expect(page).to have_content 'Laguntza eta Segurtasuna'
    end

    it 'shows the translated library breadcrumb' do
      visit '/training/support-and-safety'
      expect(find('.breadcrumbs')).to have_content 'Laguntza Eta Segurtasuna'
    end

    it 'shows the translated library breadcrumb on the module page' do
      visit '/training/support-and-safety/keeping-events-safe'
      expect(find('.breadcrumbs')).to have_content 'Laguntza Eta Segurtasuna'
    end

  end

  # Make sure default trainings get reloaded
  after(:all) { TrainingModule.load_all }
end
