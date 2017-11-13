CiteManager = require('./cite-manager')
path = require 'path'

module.exports =
class CiteProvider
  selector: '.text.tex.latex'
  disableForSelector: '.comment'
  inclusionPriority: 2
  suggestionPriority: 3
  excludeLowerPriority: false
  commandList: [
    "cite"
    "citet"
    "citep"
    "citeautor"
    "citeyear"
    "citeyearpar"
    "citealt"
    "citealp"
    "citetext"
  ]

  constructor: ->
    @manager = new CiteManager()
    bibFile = path.join( (atom.config.get 'autocomplete-latex-cite.globalBibtexPath') ,'library.bib')
    @manager.addBibtexFile(bibFile)

  getSuggestions: ({editor, bufferPosition}) ->
    prefix = @getPrefix(editor, bufferPosition)
    return unless prefix?.length
    new Promise (resolve) =>
      results = @manager.searchForPrefixInDatabase(prefix)
      console.log(results)
      suggestions = []
      for result in results
        suggestion = @suggestionForResult(result, prefix)
        suggestions.push suggestion
      resolve(suggestions)

  suggestionForResult: (result, prefix) ->
    suggestion =
      text: result.id
      replacementPrefix: prefix
      type: result.type
      descriptionMarkdown: result.fullcite
      iconHTML: '<i class="icon-mortar-board"></i>'

  onDidInsertSuggestion: ({editor, triggerPosition, suggestion}) ->

  dispose: ->
    @manager = []

  getPrefix: (editor, bufferPosition) ->
    cmdprefixes = @commandList.join '|'

    # Whatever your prefix regex might be
    regex = ///
            \\(#{cmdprefixes}) #comand group
            (\*)? #starred commands
            (\[[\\\w-]*\])? # optional paramters
            {([\w-:]+)$ # machthing the prefix
            ///
    # Get the text for the line up to the triggered buffer position
    line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])
    # Match the regex to the line, and return the match
    line.match(regex)?[4] or ''
