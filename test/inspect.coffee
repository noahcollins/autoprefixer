Browsers = require('../lib/autoprefixer/browsers')
Prefixes = require('../lib/autoprefixer/prefixes')
inspect  = require('../lib/autoprefixer/inspect')

data =
  browsers:
    chrome:
      prefix:   '-webkit-'
      versions: ['chrome 1']
    ff:
      prefix:   '-moz-'
      versions: ['ff 2', 'ff 1']
    ie:
      prefix:   '-ms-'
      versions: ['ie 2']
  prefixes:
    a:
      browsers: ['ff 2', 'ff 1', 'chrome 1']
      transition: true
    b:
      browsers: ['ie 2', 'ff 1']
      props:    ['a', '*']

describe 'inspect', ->

  it 'should return selected browsers and prefixes', ->
    browsers = new Browsers(data.browsers, ['chrome 1', 'ff 2', 'ff 1', 'ie 2'])
    prefixes = new Prefixes(data.prefixes, browsers)

    inspect(prefixes).should.eql "Browsers:\n" +
                                 "  Chrome: 1\n" +
                                 "  Firefox: 2, 1\n" +
                                 "  IE: 2\n" +
                                 "\n" +
                                 "Properties:\n" +
                                 "  a: webkit, moz\n" +
                                 "\n" +
                                 "Values:\n" +
                                 "  b: moz, ms\n"

  it 'should return string for empty prefixes', ->
    browsers = new Browsers(data.browsers, ['ie 1'])
    prefixes = new Prefixes(data.prefixes, browsers)

    inspect(prefixes).should.eql "Browsers:\n" +
                                 "  IE: 1\n"

  it 'should return string for empty browsers', ->
    browsers = new Browsers(data.browsers, [])
    prefixes = new Prefixes(data.prefixes, browsers)

    inspect(prefixes).should.eql "No browsers selected"
