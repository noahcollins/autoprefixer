# Copyright 2013 Andrey Sitnik <andrey@sitnik.ru>,
# sponsored by Evil Martians.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http:#www.gnu.org/licenses/>.

utils = require('./utils')

Processor = require('./processor')
Value     = require('./value')

Value.register 'linear-gradient', 'repeating-linear-gradient',
               'radial-gradient', 'repeating-radial-gradient',
               require('./hacks/gradient')

class Prefixes
  constructor: (@data, @browsers) ->
    [@add, @remove] = @preprocess(@select(@data))
    @otherCache     = { }
    @processor      = new Processor(@)

  transitionProps: ['transition', 'transition-property']

  # Select prefixes from data, which is necessary for selected browsers
  select: (list) ->
    selected = { add: { }, remove: { } }

    for name, data of list
      add = data.browsers.
        filter(  (i) => @browsers.isSelected(i) ).
        map(     (i) => @browsers.prefix(i) ).
        sort( (a, b) -> b.length - a.length )

      all = utils.uniq data.browsers.map( (i) => @browsers.prefix(i) )
      if add.length
        add = utils.uniq(add)
        selected.add[name] = add
        if add.length < all.length
          selected.remove[name] = all.filter (i) -> add.indexOf(i) == -1
      else
        selected.remove[name] = all

    selected

  # Cache prefixes data to fast CSS processing
  preprocess: (selected) ->
    add = { }
    for name, prefixes of selected.add
      props = if @data[name].transition
        @transitionProps
      else
        @data[name].props

      if props
        value = Value.load(name, prefixes)
        for prop in props
          add[prop] = { }       unless add[prop]
          add[prop].values = [] unless add[prop].values
          add[prop].values.push(value)

      unless @data[name].props
        add[name] = { } unless add[name]
        add[name].prefixes = prefixes

    remove = { }
    for name, prefixes of selected.remove
      props = if @data[name].transition
        @transitionProps
      else
        @data[name].props

      if props
        value = Value.load(name)
        for prefix in prefixes
          regexp = value.prefixed(prefix)
          for prop in props
            remove[prop] = { }       unless remove[prop]
            remove[prop].values = [] unless remove[prop].values
            remove[prop].values.push(regexp)

      unless @data[name].props
        for prefix in prefixes
          prefixed = prefix + name
          remove[prefixed] = {} unless remove[prefixed]
          remove[prefixed].remove = true

    [add, remove]

  # Return all possible prefixes, expect selected
  other: (prefix) ->
    @otherCache[prefix] ||= @browsers.prefixes().filter( (i) -> i != prefix )

  # Execute callback on every prefix for selected property
  each: (prop, callback) ->
    if @add[prop] and @add[prop].prefixes
      callback(prefix) for prefix in @add[prop].prefixes

  # Return values, which must be prefixed in selected property
  values: (type, prop) ->
    data = @[type]

    values = data['*']?.values || []
    values = values.concat(data[prop].values) if data[prop]?.values
    utils.uniq values

  # Is prefixed property must be removed
  toRemove: (prop) ->
    @remove[prop]?.remove

module.exports = Prefixes
