#= require spec_helper
#= require mercury/core/region
#= require mercury/regions/modules/content_editable

describe "Mercury.Region.Modules.ContentEditable", ->

  Klass = null
  Module = Mercury.Region.Modules.ContentEditable
  subject = null

  beforeEach ->
    Mercury.configure 'regions:identifier', 'id'
    class Klass extends Mercury.Region
      @include Module
    subject = new Klass('<div id="foo">')

  describe "#buildContentEditable (via the build event)", ->

    it "sets @editableDropBehavior", ->
      subject.trigger('build')
      expect( subject.editableDropBehavior ).to.be.true
      subject.editableDropBehavior = false
      subject.trigger('build')
      expect( subject.editableDropBehavior ).to.be.false

    it "gets the @document from the element", ->
      subject.trigger('build')
      expect( subject.document ).to.eq(document)

    it "calls #makeContentEditable", ->
      spyOn(subject, 'makeContentEditable')
      subject.trigger('build')
      expect( subject.makeContentEditable ).called

    it "calls #forceContentEditableDisplay", ->
      spyOn(subject, 'forceContentEditableDisplay')
      subject.trigger('build')
      expect( subject.forceContentEditableDisplay ).called

    it "calls #setContentEditablePreferences", ->
      spyOn(subject, 'setContentEditablePreferences')
      subject.trigger('build')
      expect( subject.setContentEditablePreferences ).called


  describe "#releaseContentEditable (via the release event)", ->

    it "sets content editable to false on the element", ->
      expect( subject.el.get(0).contentEditable ).to.eq('true')
      subject.trigger('release')
      expect( subject.el.get(0).contentEditable ).to.eq('false')

    it "sets the display back to the original", ->
      subject.originalDisplay = 'none'
      subject.trigger('release')
      expect( subject.el.css('display') ).to.eq('none')


  describe "#makeContentEditable", ->

    it "sets content editable on the element", ->
      expect( subject.el.get(0).contentEditable ).to.eq('true')


  describe "#forceContentEditableDisplay", ->

    it "sets display to inline block if the display is inline", ->
      subject.el.css(display: 'inline')
      subject.forceContentEditableDisplay()
      expect( subject.originalDisplay ).to.eq('inline')
      expect( subject.el.css('display') ).to.eq('inline-block')

    it "leaves other display types alone", ->
      subject.el.css(display: 'block')
      subject.forceContentEditableDisplay()
      expect( subject.el.css('display') ).to.eq('block')


  describe "#setContentEditablePreferences", ->

    it "sets the various preferences using execCommand", ->
      subject.document = execCommand: spy()
      subject.setContentEditablePreferences()
      expect( subject.document.execCommand ).calledWith('styleWithCSS', false, false)
      expect( subject.document.execCommand ).calledWith('insertBROnReturn', false, true)
      expect( subject.document.execCommand ).calledWith('enableInlineTableEditing', false, false)
      expect( subject.document.execCommand ).calledWith('enableObjectResizing', false, false)

    it "doesn't throw if there's a problem", ->
      subject.document = execCommand: -> throw new Error('foo')
      expect(-> subject.setContentEditablePreferences() ).not.to.throw(Error, 'foo')