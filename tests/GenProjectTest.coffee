require('./Deps')();

Gen           = require '../lib/gen'
path          = require 'path'
fs            = require 'fs'
{ Glob }      = require 'glob'
{ exists, rm, mkdir }    = require './Helpers'

setup     = (f) -> (done) -> mkdir('files/targets', f, done)
tearDown  = (f) -> (done) -> rm('files/targets', f, done)

describe 'GenProjectTest =>', ->

  describe 'Gen target/t4 =>', ->

    source = 'files/src/t4'
    target = 'files/targets/t4'

    beforeEach setup('t4')

    beforeEach ->
      Gen.using(source, target, {}, 'GenProjectTest 1')
        .mkdir()
        .add((gn) -> gn.in('lib').mkdir().copy('NewLib.coffee'))
        .add((gn) -> gn.in('tests').mkdir().copy('NewLibTest.coffee'))
        .copy('index.js', 'package.json')
        .apply()

    afterEach tearDown('t4')

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

    beforeEach setup('t5')
    beforeEach ->
      Gen.using(source, target, {}, 'GenProjectTest 1')
        .mkdir()
        .add((gn) -> gn.in('lib').mkdir().translate('NewLib.coffee', 'new-lib.coffee'))
        .add((gn) -> gn.in('tests').mkdir().translate('NewLibTest.coffee', 'new-lib-test.coffee'))
        .translate('index.js', 'main.js')
        .translate('package.ftl.json', 'package.json')
        .apply()

    afterEach tearDown('t5')

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

    beforeEach setup('t6')

    beforeEach ->
      Gen.using(source, target, {}, 'GenProjectTest 1')
        .mkdir()
        .translate('index.js', 'main.js')
        .translate('package.ftl.json', 'package.json')
        .in('lib').mkdir().translate('NewLib.coffee', 'new-lib.coffee')
        .in('../tests').mkdir().translate('NewLibTest.coffee', 'new-lib-test.coffee')
        .getRoot()
        .apply()

    afterEach tearDown('t6')

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

    beforeEach setup('t7')

    beforeEach ->
      Gen.using(source, target, {}, 'GenProjectTest 1')
      .mkdir()
      .mkdirs("d1/d2/d3/d4/")
      .apply()

    afterEach tearDown('t7')

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

    beforeEach setup('t8')

    beforeEach ->
      Gen.using(source, target, {}, 'GenProjectTest 1')
        .mkdir()
        .copy("d1/d2/d3/d4/some-file.txt")
        .apply()

    afterEach tearDown('t8')

    it 'should have create all the directories required to copy the nested file', ->
      exists(target, 'd1/')
      exists(target, 'd1/d2')
      exists(target, 'd1/d2/d3/')
      exists(target, 'd1/d2/d3/d4')
      exists(target, 'd1/d2/d3/d4/some-file.txt')


  describe '.deepCopy =>', ->

    it 'should deep copy the directory and translate the .ftl files as they are found', ->

    describe 'filter and renaming =>', ->

      source = 'files/src/t10'
      target = 'files/targets/t10'
      model  =
        symbol : 'symbol'

      beforeEach setup('t10')

      beforeEach ->
        Gen.using(source, target, model, 'Deep copy generator')
          .mkdir()
          .deepCopy((match) ->
            no_copy = ['src/no-copy.txt', 'tests/no-copy.txt', 'no-copy.txt']
            not (match in no_copy)
          , (match) ->
            switch (match)
              when 'index.js.ftl'                   then 'index.js'
              when 'src/FirstClass.coffee.ftl'      then 'src/TranslatedClass.coffee'
              when 'tests/FirstTest.coffee.ftl'     then 'tests/TranslatedTest.coffee'
              when 'gitignore'                      then '.gitignore'
              else
                false
          )
          .apply()

      afterEach tearDown('t10')

      it 'should call map function on each file as specified', ->
        exists(
          target
          '.gitignore'
          'index.js'
          'license'
          'readme.md'
          'index.js'
          'src/TranslatedClass.coffee'
          'tests/TranslatedTest.coffee'
        )


