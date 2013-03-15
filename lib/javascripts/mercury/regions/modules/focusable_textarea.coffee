Mercury.Region.Modules.FocusableTextarea =

  included: ->
    @autoSize = false

    @preview = $("""<div class="mercury-#{@constructor.type}-region-preview">""")
    @focusable = $("""<textarea class="mercury-#{@constructor.type}-region-textarea">""")

    @on('build', @buildFocusable)
    @on('action', @resizeFocusable)
    @on('preview', @toggleFocusablePreview)
    @on('release', @releaseFocusable)


  buildFocusable: ->
    @autoSize = @config("regions:#{@constructor.type}:autoSize")

    value = @html().replace('&gt;', '>').replace('&lt;', '<')
    resize = if @autoSize then 'none' else 'vertical'

    @el.empty()
    @append(@preview, @focusable.val(value).css(width: '100%', height: @el.height(), resize: resize))
    @resizeFocusable()

    @delegateEvents
      'keydown textarea': 'handleKeyEvent'


  releaseFocusable: ->
    @html(@convertedValue?() ? @value())


  resizeFocusable: ->
    return unless @autoSize
    focusable = @focusable.get(0)
    body = $('body')
    current = body.scrollTop()
    @focusable.css(height: 1).css(height: focusable.scrollHeight)
    $('body').scrollTop(current)


  toggleFocusablePreview: ->
    if @previewing
      @focusable.hide()
      @preview.html(@convertedValue?() || @value()).show()
    else
      @preview.hide()
      @focusable.show()


  handleKeyEvent: (e) ->
    return if e.keyCode >= 37 && e.keyCode <= 40 # arrows
    @delay(1, @resizeFocusable)

    return if e.metaKey && e.keyCode == 90 # undo / redo
    @onReturnKey?(e) if e.keyCode == 13 # enter / return

    # common actions
    if e.metaKey then switch e.keyCode
      when 66 # b
        e.preventDefault()
        return @handleAction('bold')
      when 73 # i
        e.preventDefault()
        return @handleAction('italic')
      when 85 # u
        e.preventDefault()
        return @handleAction('underline')

    @resizeFocusable()
    @pushHistory(e.keyCode)