cases        = require('./lib/cases')

Rule         = require('../lib/autoprefixer/rule')
Value        = require('../lib/autoprefixer/value')
Declaration  = require('../lib/autoprefixer/declaration')


describe 'Declaration', ->
  decl = null

  beforeEach ->
    @nodes = cases.load('declaration')
    @list  = @nodes.stylesheet.rules[0].declarations
    @rule  = new Rule(@list)

    decl = (number) =>
      @rule.number = number
      new Declaration(@rule, number, @list[number])

  describe 'unprefixed', ->

    it 'should split prefix and property name', ->
      decl(0).unprefixed.should.eql 'transform'
      decl(0).prefix.should.eql     '-moz-'
      decl(0).prop.should.eql       '-moz-transform'

  describe 'valueContain()', ->

    it 'should check value to contain ant of strings', ->
      decl(0).valueContain(['-webkit-', '-moz-']).should.be.true
      decl(0).valueContain(['-ms-', '-o-']).should.be.false

  describe 'prefixProp()', ->

    it 'should insert new rule with prefix', ->
      decl(1).prefixProp('-webkit-')
      cases.compare(@nodes, 'declaration.prefix')

    it 'should not insert double prefixed value', ->
      decl(1).insertBefore('-webkit-display', 'inline')
      decl(2).prefixProp('-webkit-')
      @list.length.should.eql 4

    it 'should not doucle prefixes', ->
      decl(0).prefixProp('-webkit-')
      decl(0).prop.should.eql('-webkit-transform')

  describe 'insertBefore()', ->

    it 'should insert clone before', ->
      display = decl(1)
      display.node.one = 1
      display.insertBefore('color', 'black')

      @list[1].one.should.eql 1
      @list[1].property.should.eql 'color'
      @list[1].value.should.eql 'black'

      @list.length.should.eql 4

    it 'should not insert same declaration', ->
      decl(1).insertBefore('display', 'block')
      cases.compare(@nodes, 'declaration')

  describe 'remove()', ->

    it 'should remove self', ->
      decl(0).remove()
      cases.compare(@nodes, 'declaration.remove')

  describe 'setValue()', ->

    it 'should update local and node values', ->
      margin = decl(2)
      margin.setValue('0')
      margin.value.should.eql '0'
      margin.node.value.should.eql '0'

  describe 'prefixValue()', ->

    it 'should combine value changes', ->
      margin = decl(2)
      calc   = new Value('calc', ['-moz-', '-o-'])
      step   = new Value('step', ['-o-'])

      margin.prefixValue('-moz-', calc)
      margin.prefixValue('-o-',   calc)
      margin.prefixValue('-o-',   step)
      margin.saveValues()

      cases.compare(@nodes, 'declaration.values')

    it 'should combine value changes', ->
      @rule.prefix = '-o-'
      margin = decl(2)
      calc   = new Value('calc', ['-o-'])

      margin.prefixValue('-o-', calc)
      margin.saveValues()

      cases.compare(@nodes, 'declaration.prefix-value')
