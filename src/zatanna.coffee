defaults = require './defaults'
optionsValidator = require './validators/options'

module.exports = class Zatanna

  constructor: (aceEditor, options) ->
    @editor = aceEditor
    config = ace.require 'ace/config'

    options ?= {}
    validationResult = optionsValidator options
    unless validationResult
      throw new Error "Invalid Zatanna options: " + JSON.stringify(validationResult.errors, null, 4)

    defaultsCopy = _.extend {}, defaults
    @options = _.merge defaultsCopy, options

    ace.config.loadModule 'ace/ext/language_tools', () =>
      @snippetManager = ace.require('ace/snippets').snippetManager
      @setAceOptions()

  setAceOptions: () ->
    aceOptions = 
      'enableLiveAutocompletion': @options.liveCompletion 
      'enableBasicAutocompletion': @options.basic
      'enableSnippets': @options.snippets

    @editor.setOptions aceOptions

  addSnippets: (snippets, language) ->
    ace.config.loadModule 'ace/ext/language_tools', () =>
      @snippetManager = ace.require('ace/snippets').snippetManager
      snippetModulePath = 'ace/snippets/' + language
      ace.config.loadModule snippetModulePath, (m) => 
        if m?        
          @snippetManager.files[@options.language] = m 
          @snippetManager.unregister m.snippets
          m.snippets = @snippetManager.parseSnippetFile m.snippetText
          console.log 'snippets!!!', m
          m.snippets.push s for s in snippets
          @snippetManager.register m.snippets

  setLiveCompletion: (val) ->
    if val is true or val is false
      @options.liveCompletion = val
      @setAceOptions()

self.Zatanna = Zatanna if self?
window.Zatanna = Zatanna if window?