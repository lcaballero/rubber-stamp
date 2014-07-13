

module.exports = ->
  nject         = require 'nject'
  chai          = require 'chai'

  global._      = require 'lodash'
  global.Tree   = nject.Tree
  global.chai   = chai
  global.expect = chai.expect