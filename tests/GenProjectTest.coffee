require('./Deps')();

Gen   = require('../lib/gen')
path  = require('path')
fs    = require 'fs'

describe 'GenProjectTest =>', ->

  exists = (root, dir) ->
    file = path.resolve(root, dir)
    expect(fs.existsSync(file), 'should have created: ' + file).to.be.true

  describe 'Gen target/t4 =>', ->

    source = 'files/src/t4'
    target = 'files/targets/t4'

    beforeEach ->
      Gen.using(source, target, {}, 'GenProjectTest 1')
        .mkdir()
        .add((gn) -> gn.in('lib').mkdir().copy('NewLib.coffee'))
        .add((gn) -> gn.in('tests').mkdir().copy('NewLibTest.coffee'))
        .copy('index.js', 'package.json')
        .apply()

    it 'should have created the target directory t4/', ->
      exists('.', target)

    it 'should have create the directory t4/lib/', ->
      exists(target, 'lib/NewLib.coffee')
      exists(target, 'tests/NewLibTest.coffee')
      exists(target, 'index.js')
      exists(target, 'package.json')

  ###
    Example of renaming a file in flight using the 'translate' function.
  ###
  describe 'Gen target/t5 =>', ->

    source = 'files/src/t5'
    target = 'files/targets/t5'

    beforeEach ->
      Gen.using(source, target, {}, 'GenProjectTest 1')
      .mkdir()
      .add((gn) -> gn.in('lib').mkdir().translate('NewLib.coffee', 'new-lib.coffee'))
      .add((gn) -> gn.in('tests').mkdir().translate('NewLibTest.coffee', 'new-lib-test.coffee'))
      .translate('index.js', 'main.js')
      .translate('package.ftl.json', 'package.json')
      .apply()

    it 'should have renamed the file NewLib.coffee to new-lib.coffee', ->
      exists(target, 'lib/new-lib.coffee')
      exists(target, 'tests/new-lib-test.coffee')
      exists(target, 'main.js')
      exists(target, 'package.json')