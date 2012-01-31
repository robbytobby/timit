# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
  $('#new_booking select').live 'change', ->
    form = $(@).parents('form:first')
    $.get form.attr('action').replace(/(\/\w+)(\/?\w*)/g,'$1/update_options'), form.serialize(), null, 'script'
$ ->
  $('#new_booking input').live 'change', ->
    form = $(@).parents('form:first')
    $.get form.attr('action').replace(/(\/\w+)(\/?\w*)/g,'$1/update_options'), form.serialize(), null, 'script'
