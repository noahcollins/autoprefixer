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

Value = require('../value')
utils = require('../utils')

class Gradient extends Value
  constructor: (@name, @prefixes) ->
    name    = utils.escapeRegexp(@name)
    @regexp = new RegExp('(^|\\s|,)' + name + '\\(([^)]+)\\)', 'gi')

  # Change degrees for webkit prefix
  addPrefix: (prefix, string) ->
    string.replace @regexp, (all, before, params) =>
      params = params.trim().split(/\s*,\s*/)
      if params.length > 0
        if params[0][0..2] == 'to '
          params[0] = @fixDirection(params[0])
        else if prefix == '-webkit-' and params[0].match(/^-?\d+deg/)
          params[0] = @fixAngle(params[0])
      before + prefix + @name + '(' + params.join(', ') + ')'

  # Direction to replace
  directions:
    top:    'bottom'
    left:   'right'
    bottom: 'top'
    right:  'left'

  # Replace `to top left` to `bottom right`
  fixDirection: (param) ->
    param = param.split(' ')
    param.splice(0, 1)
    param = for value in param
      @directions[value.toLowerCase()] || value
    param.join(' ')

  # Add 90 degrees
  fixAngle: (param) ->
    param  = parseInt(param)
    param += 90
    param -= 360 if param > 360
    "#{param}deg"

module.exports = Gradient
