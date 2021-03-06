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

class Value
  # Add hack to selected names
  @register: (names..., klass) ->
    for name in names
      @hacks[name] = klass

  # Override classes for special values
  @hacks: { }

  # Detect right class by value name and create it instance
  @load: (name, prefixes) ->
    klass = @hacks[name] || Value
    new klass(name, prefixes)

  constructor: (@name, @prefixes) ->
    @regexp = utils.regexp(@name)

  # Is declaration need to be prefixed
  check: (decl) ->
    !!decl.value.match(@regexp)

  # Return regexp to test prefixed value
  prefixed: (prefix) ->
    utils.regexp(prefix + @name)

  # Add prefix to values in string
  addPrefix: (prefix, string) ->
    string.replace(@regexp, '$1' + prefix + '$2')

module.exports = Value
