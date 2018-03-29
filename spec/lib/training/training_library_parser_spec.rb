# frozen_string_literal: true

require 'rails_helper'
require "#{Rails.root}/lib/training/wiki_library_parser"

describe WikiLibraryParser do
  let(:source_wikitext) do
    <<~WIKIPAGE
      <translate>
      ==  Support and Safety == <!--T:1-->
      </translate>
      Support and Safety training modules
      {| class="wikitable"
      |-
      ! Category !! Description !! Modules
      |-
      | Keeping events safe || Training modules for people running in-person events ||
      {| class="wikitable"
      |-
      ! Name !! Description
      |-
      | Keeping events safe — event organizers || Training to prepare event organizers to handle incidents of harassment or abuse.
      |}
      |-
      | Dealing with online harassment || Training modules for Wikimedia project functionaries and others who might deal with harassment, be it short-term or involving cases ||
      {| class="wikitable"
      |-
      ! Name !! Description
      |-
      | Dealing with online harassment: Fundamentals || Fundamentals of dealing with abuse – what is harassment, and how can you respond to it immediately?
      |-
      | Dealing with online harassment: Other forms of harassment || Other forms of harassment, what they involve, and how they can be immediately dealt with. This is information that will be useful when you are fielding reports.
      |-
      | Dealing with online harassment: Communication best practices || Communicating with those who are experiencing harassment on the projects, and how best to provide them support.
      |-
      | Dealing with online harassment: Handling reports || DIFFERENT FROM JSON
      |-
      | Dealing with online harassment: Closing cases || How to close cases of harassment, and how to take care of yourself afterwards.
      |}
      |}
    WIKIPAGE


  end

  let(:source_json) do
    <<~JSONPAGE
      {
      "id": "10001",
      "name": "Support and Safety",
      "slug": "support-and-safety",
      "introduction": "Support and Safety training modules",
      "wiki_page": "Training_libraries/Support_and_Safety/description",
      "categories": [
          {
              "title": "Keeping events safe",
              "description": "Training modules for people running in-person events",
              "modules": [
                  {
                      "slug": "keeping-events-safe",
                      "name": "Keeping events safe — event organizers",
                      "description": "Training to prepare event organizers to handle incidents4 of harassment or abuse."
                  }
              ]
          },
          {
              "title": "Dealing with online harassment",
              "description": "Training modules for Wikimedia project functionaries and others who might deal with harassment, be it short-term or involving cases",
              "modules": [
                  {
                      "slug": "dealing-with-online-harassment-fundamentals",
                      "name": "Dealing with online harassment: Fundamentals",
                      "description": "Fundamentals of dealing with abuse – what is harassment, and how can you respond to it immediately?"
                  },
                  {
                      "slug": "dealing-with-online-harassment-other-forms",
                      "name": "Dealing with online harassment: Other forms of harassment",
                      "description": "Other forms of harassment, what they involve, and how they can be immediately dealt with. This is information that will be useful when you are fielding reports."
                  },
                  {
                      "slug": "dealing-with-online-harassment-communication-best-practices",
                      "name": "Dealing with online harassment: Communication best practices",
                      "description": "Communicating with those who are experiencing harassment on the projects, and how best to provide them support."
                  },
                  {
                      "slug": "dealing-with-online-harassment-handling-reports",
                      "name": "Dealing with online harassment: Handling reports",
                      "description": "How to handle reports of harassment, actionable or otherwise."
                  },
                  {
                      "slug": "dealing-with-online-harassment-closing-cases",
                      "name": "Dealing with online harassment: Closing cases",
                      "description": "How to close cases of harassment, and how to take care of yourself afterwards."
                  }
                  ]
              }
          ]
      }
    JSONPAGE

  end

  # let(:translated_wikitext) do
  #   <<~WIKISLIDE
  #     <noinclude><languages /></noinclude>
  #     ==  E3: Situaciones que podrías enfrentar  ==
  #     Aunque se hagan los mayores esfuerzos para asegurarse que los eventos sean espacios seguros en donde se reúnen y colaboran los contribuyentes, puede llegar a haber situaciones en las cuales tu o alguien mas se pueda sentir incomodo ya sea de forma ligera o grave. Todas estas transgresiones pueden, y deben de ser tratadas si son dirigidas hacia ti o alguien mas. Esta lista no es exhaustiva, se pueden llegar a dar casos extraordinarios.
  #
  #     * '''Transgresiones sutiles o moderadas a los espacios seguros''' por lo general consisten de comentarios no apropiados, argumentos en-wiki tornados hostil en persona o contenido inapropiado en una presentación. Estas situaciones en especial, no siempre tienen la intención de molestar o ofender a otros, sin embargo deben de ser tratadas.
  #     * '''Transgresiones graves a espacios seguros''' son situaciones en donde alguien esta en una situación de mucho estrés o se siente amenazado por conducta abusiva tal como acoso dirigido hacia el agredido, ataques verbales explícitos hacia la persona, amenazas físicas o sexuales implícitas o acciones no deseadas repetidas después de pedir explícitamente desistir a estas.
  #     * '''No es permitido que usuarios locales o globales suspendidos''' asistan a eventos. En caso de tener conocimiento de un usuario suspendido asistiendo un evento, este debera ser reportado al EOT, ya que esta situación es una transgresion al espacio seguro. Aun que no hayas sido agredido por el individuo, es posible que otras personas tengan problemas de los que no estes percatado.
  #     * '''Transgresiones criticas de seguridad''' tal como físicas, acoso sexual y abuso son muy poco comunes, sin embargo al ser percatadas o reportadas, estas deben ser tomadas con extrema seriedad.
  #     * '''Emergencias medicas''' también se pueden llegar a suscitar. Aunque no sean causadas por altercados entre personas en un evento, estas deben ser tratadas como una prioridad por el EOT.
  #
  #     Toma en mente que tu, en rol de organizador o voluntario, tienes el derecho a sentirte seguro en un evento. Incidentes que te involucren deben ser tratados con la misma seriedad. En estos casos es importante tener un investigador de apoyo. Trataremos este tema mas a fondo en la capacitación.
  #   WIKISLIDE
  # end
  #
  # let(:quiz_wikitext) do
  #   <<~WIKISLIDE
  #     == Five Pillars quiz ==
  #
  #     {{Training module quiz
  #
  #     | question = An editor has written to you saying that another editor has revealed personal information about them on-wiki in an attempt to intimidate them from working on an article about a contentious subject. They have supplied a link to a diff. Before investigating further, you want to acknowledge the report. Should you write:
  #     | correct_answer_id = 1
  #     | answer_1 = Present the facts in a careful way, to persuade readers to draw certain conclusions.
  #     | explanation_1 = Incorrect. Remember, a Wikipedia article should be neutral, balanced, and fair to all views. You want readers to have access to facts, and trust that those facts will lead them to their own conclusions. This is the policy known as Neutral Point of View.
  #     | answer_2 = Replicate the best information from published authors, word-for-word.
  #     | explanation_2 = Incorrect. You should be using reliable, published information, but you want to be very careful not to plagiarize, or closely paraphrase, those authors. Instead, you should seek out good information and summarize those facts using your own words.
  #
  #     }}
  #   WIKISLIDE
  # end
  #
  # let(:image_wikitext) do
  #   <<~WIKISLIDE
  #     == Five Pillars: The core rules of Wikipedia ==
  #
  #     {{Training module image
  #     | image = File:Palace_of_Fine_Arts%2C_five_pillars.jpg
  #     | source = https://upload.wikimedia.org/wikipedia/commons/thumb/e/ed/Palace_of_Fine_Arts%2C_five_pillars.jpg/640px-Palace_of_Fine_Arts%2C_five_pillars.jpg
  #     | layout = alt-layout-40-right
  #     | credit = Photo by Eryk Salvaggio
  #     }}
  #
  #     Wikipedia is the encyclopedia anyone can edit, but there's a lot of collaboration behind every article. You'll work with many people to build Wikipedia.
  #   WIKISLIDE
  # end
  #
  # let(:multi_image_wikitext) do
  #   <<~WIKISLIDE
  #     == Five Pillars: The core rules of Wikipedia ==
  #
  #     {{Training module image
  #     | image = File:Palace_of_Fine_Arts%2C_five_pillars.jpg
  #     | source = https://upload.wikimedia.org/wikipedia/commons/thumb/e/ed/Palace_of_Fine_Arts%2C_five_pillars.jpg/640px-Palace_of_Fine_Arts%2C_five_pillars.jpg
  #     | layout = alt-layout-40-right
  #     | credit = Photo by Eryk Salvaggio
  #     }}
  #
  #     {{Training module image
  #     | image = File:Find_a_program.png
  #     | source = https://upload.wikimedia.org/wikipedia/commons/4/48/Find_a_program.png
  #     | layout = alt-layout-40-right
  #     | credit = In the top right of the interface, next to the Log-out and User-name buttons, you can find the language switcher
  #     }}
  #
  #     Wikipedia is the encyclopedia anyone can edit, but there's a lot of collaboration behind every article. You'll work with many people to build Wikipedia.
  #   WIKISLIDE
  # end
  #
  # let(:video_wikitext) do
  #   <<~WIKISLIDE
  #     == Starting new programs ==
  #
  #     If you are the host of a program or event, you need to be able to create events. There are two different ways to create a program: through creating a new one, or cloning an existing event.
  #
  #     {{Training module image
  #     | image = File:Palace_of_Fine_Arts%2C_five_pillars.jpg
  #     | source = https://upload.wikimedia.org/wikipedia/commons/thumb/e/ed/Palace_of_Fine_Arts%2C_five_pillars.jpg/640px-Palace_of_Fine_Arts%2C_five_pillars.jpg
  #     | layout = alt-layout-40-right
  #     | credit = Photo by Eryk Salvaggio
  #     }}
  #
  #     {{Training module video
  #     | video = File:How to Use the Dashboard (2 of 5).webm
  #     | source = https://upload.wikimedia.org/wikipedia/commons/7/79/How_to_Use_the_Dashboard_%282_of_5%29.webm
  #     | caption = How to Use the Dashboard (2 of 5)
  #     }}
  #
  #   WIKISLIDE
  # end
  #
  # let(:translate_markup_variant) do
  #   <<~WIKISLIDE
  #     <noinclude><languages/></noinclude>
  #     <translate>== Five Pillars: The core rules of Wikipedia == <!--T:1-->
  #
  #     <!--T:2-->
  #     {{Training module image
  #     | image = File:Palace_of_Fine_Arts%2C_five_pillars.jpg
  #     | source = https://upload.wikimedia.org/wikipedia/commons/thumb/e/ed/Palace_of_Fine_Arts%2C_five_pillars.jpg/640px-Palace_of_Fine_Arts%2C_five_pillars.jpg
  #     | layout = alt-layout-40-right
  #     | credit = Photo by Eryk Salvaggio
  #     }}
  #
  #     <!--T:3-->
  #     Wikipedia is the encyclopedia anyone can edit, but there's a lot of collaboration behind every article. You'll work with many people to build Wikipedia. To collaborate effectively, you'll want to follow the five key principles, or pillars, of Wikipedia.
  #
  #     <!--T:4-->
  #     Wikipedia's Five Pillars are:
  #
  #     <!--T:5-->
  #     * Wikipedia is an online encyclopedia
  #     * Wikipedia has a neutral point of view
  #     * Wikipedia is free content
  #     * Wikipedians should interact in a respectful and civil manner
  #     * Wikipedia does not have firm rules
  #
  #     <!--T:6-->
  #     Let’s explore these a bit.</translate>
  #   WIKISLIDE
  # end

  describe '#name' do
    it 'extracts title and description from translation-enabled source wikitext' do
      output = WikiLibraryParser.new(source_wikitext.dup)
      expect(output.name).to eq('Support and Safety')
      expect(output.introduction).to eq('Support and Safety training modules')
    end
    # it 'extracts title from translation-enabled source wikitext' do
    #   output = WikiSlideParser.new(translated_wikitext.dup).title
    #   expect(output).to eq('E3: Situaciones que podrías enfrentar')
    # end
    it 'handles nil input' do
      output = WikiSlideParser.new(+'').title
      expect(output).to eq('')
    end
    # it 'extracts only the title from variant translation markup formats' do
    #   output = WikiSlideParser.new(translate_markup_variant.dup).title
    #   expect(output).to eq('Five Pillars: The core rules of Wikipedia')
    # end
  end
  #
  describe '#content' do
    it 'converts the wiki table to json' do
      output = WikiLibraryParser.new(source_wikitext.dup).content
      expect(output).to match(/^\[\{"title": "Keeping events safe"/)
    end

    it 'parses the table into categories' do
      categories = WikiLibraryParser.new(source_wikitext.dup).parse_table_into_categories
      expect(categories[0]['title']).to eq "Keeping events safe"
      expect(categories[1]['modules'][2]['description']).to eq "Communicating with those who are experiencing harassment on the projects, and how best to provide them support."
    end

    it 'merges loaded wiki resource with the corresponding json' do
      content = Oj.load(source_json.dup)
      expect(content['name']).to eq "Support and Safety"
      expect(content['categories'][1]['modules'][3]['description']).to eq "How to handle reports of harassment, actionable or otherwise."
      library_hash = WikiLibraryParser.new(source_wikitext.dup).library_hash
      expect(library_hash['name']).to eq "Support and Safety"
      expect(library_hash['categories'][1]['modules'][3]['description']).to eq "DIFFERENT FROM JSON"
      merged = content.merge library_hash
      expect(merged['name']).to eq "Support and Safety"
      expect(merged['categories'][1]['modules'][3]['description']).to eq "DIFFERENT FROM JSON"

    end
  #   it 'converts multiple image templates into distinct figure markups' do
  #     output = WikiSlideParser.new(multi_image_wikitext.dup).content
  #     expect(output).to include('five_pillars.jpg')
  #     expect(output).to include('Find_a_program.png')
  #   end
  #   it 'converts a video template into iframe markup' do
  #     output = WikiSlideParser.new(video_wikitext.dup).content
  #     expect(output).to include('iframe>')
  #   end
  #   it 'includes a forced newline after figure markup' do
  #     # Markdown conversion outputs just one newline after figure markup, which
  #     # can result in the next line getting misparsed. Two newlines ensures that
  #     # the following content gets parsed as a new paragraph.
  #     output = WikiSlideParser.new(image_wikitext.dup).content
  #     expect(output).to include("figure>\n\n")
  #   end
  #   it 'removes leading newlines' do
  #     output = WikiSlideParser.new(source_wikitext.dup).content
  #     expect(output[0..10]).to eq('Even though')
  #   end
  #   it 'handles nil input' do
  #     output = WikiSlideParser.new(''.dup).content
  #     expect(output).to eq('')
  #   end
  # end
  #
  # describe '#quiz' do
  #   it 'converts a wiki template into a hash representing a quiz' do
  #     output = WikiSlideParser.new(quiz_wikitext.dup).quiz
  #     expect(output[:correct_answer_id]).to eq(1)
  #     expect(output[:answers].count).to eq(2)
  #   end
  end
end
