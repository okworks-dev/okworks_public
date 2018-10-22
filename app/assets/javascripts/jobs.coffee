# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


ellipsis = (target) ->
  # オリジナルの文章を取得する
  html = target.html()
  # 対象の要素を、高さにautoを指定し非表示で複製する
  $clone = target.clone()
  $clone.css(
    display: 'none'
    position: 'absolute'
    overflow: 'visible').width(target.width()).height 'auto'
  # DOMを一旦追加
  target.after $clone
  # 指定した高さになるまで、1文字ずつ消去していく
  while html.length > 0 and $clone.height() > target.height()
    html = html.substr(0, html.length - 1)
    $clone.html html + '...'
  # 文章を入れ替えて、複製した要素を削除する
  target.html $clone.html()
  $clone.remove()

$(document).on 'turbolinks:load', ->
  $('.card-title').each ->
    $target = $(this)
    ellipsis $target
    #console.log($target);
    return
  return

$(document).on 'turbolinks:load', ->
  $('.card-text').each ->
    $target = $(this)
    ellipsis $target
    #console.log($target);
    return
  return


