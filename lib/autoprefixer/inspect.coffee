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

capitalize = (str) ->
  str.slice(0, 1).toUpperCase() + str.slice(1)

names =
  ie:  'IE'
  ff:  'Firefox'
  ios: 'iOS'

prefix = (name, transition, prefixes) ->
    out  = '  ' + name + (if transition then '*' else '') + ': '
    out += prefixes.map( (i) -> i.replace(/^-(.*)-$/g, '$1') ).join(', ')
    out += "\n"
    out

module.exports = (prefixes) ->
  return "No browsers selected" if prefixes.browsers.selected.length == 0

  versions = []
  for browser in prefixes.browsers.selected
    [name, version] = browser.split(' ')

    name = names[name] || capitalize(name)
    if versions[name]
      versions[name].push(version)
    else
      versions[name] = [version]

  out  = "Browsers:\n"
  for browser, list of versions
    out += '  ' + browser + ': ' + list.join(', ') + "\n"

  values = ''
  props  = ''
  transition = false
  for name, data of prefixes.add
    if data.prefixes
      transition &= data.transition
      props += prefix(name, data.transition, data.prefixes)
      continue unless data.values

      for value in data.values
        string = prefix(value.name, false, value.prefixes)
        if values.indexOf(string) == -1
          values += string

    if transition
      props += "* - can be used in transition\n"

  out += "\nProperties:\n"+ props if props  != ''
  out += "\nValues:\n" + values   if values != ''

  out
