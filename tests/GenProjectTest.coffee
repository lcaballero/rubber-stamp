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

  ###
    Example of using .in('file') and then .in('../file')
  ###
  describe 'Gen target/t6 =>', ->

    source = 'files/src/t6'
    target = 'files/targets/t6'

    beforeEach ->
      Gen.using(source, target, {}, 'GenProjectTest 1')
        .mkdir()
        .translate('index.js', 'main.js')
        .translate('package.ftl.json', 'package.json')
        .in('lib').mkdir().translate('NewLib.coffee', 'new-lib.coffee')
        .in('../tests').mkdir().translate('NewLibTest.coffee', 'new-lib-test.coffee')
        .getRoot()
        .apply()

    it 'should have renamed the file NewLib.coffee to new-lib.coffee', ->
      exists(target, '.')
      exists(target, 'lib/')
      exists(target, 'lib/new-lib.coffee')
      exists(target, 'tests/new-lib-test.coffee')
      exists(target, 'main.js')
      exists(target, 'package.json')

  ###
    Example of using .mkdirs('dir/not/yet/made/'), where all the parent directories
    are created.
  ###
  describe 'Gen target/t7 =>', ->

    source = 'files/src/t7'
    target = 'files/targets/t7'
    file   = "d1/d2/d3/d4/some-file.txt"

    beforeEach ->
      Gen.using(source, target, {}, 'GenProjectTest 1')
      .mkdir()
      .mkdirs("d1/d2/d3/d4/")
      .apply()


    it 'should have create all the directories required to copy the nested file', ->
      exists(target, 'd1/')
      exists(target, 'd1/d2')
      exists(target, 'd1/d2/d3/')
      exists(target, 'd1/d2/d3/d4')

  ###
    Example of using .mkdirs('dir/not/yet/made/'), where all the parent directories
    are created.
  ###
  describe 'Gen target/t8 =>', ->

    source = 'files/src/t8'
    target = 'files/targets/t8'
    file   = "d1/d2/d3/d4/some-file.txt"

    beforeEach ->
      Gen.using(source, target, {}, 'GenProjectTest 1')
        .mkdir()
        .copy("d1/d2/d3/d4/some-file.txt")
        .apply()

    it 'should have create all the directories required to copy the nested file', ->
      exists(target, 'd1/')
      exists(target, 'd1/d2')
      exists(target, 'd1/d2/d3/')
      exists(target, 'd1/d2/d3/d4')
      exists(target, 'd1/d2/d3/d4/some-file.txt')

