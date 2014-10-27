require('./Deps')();

Gen   = require('../lib/gen')
path  = require('path')
fs    = require 'fs'
{ exists, rm, mkdir }    = require './Helpers'

setup     = (f) -> (done) -> mkdir('files/targets', f, done)
tearDown  = (f) -> (done) -> rm('files/targets', f, done)


describe 'RunCommandTest =>', ->

  afterEach tearDown('t9')

  it 'should run the command specified', (done) ->

    dir = path.resolve('files/targets/t9')

    Gen.using('source', dir, {})
      .mkdir() # make the directory where the command will run
      .run({
        options:
          cwd: path.resolve(".", dir)
        commands: [
          { name: 'git', args: ['init'] }
        ]
      })
      .apply(->
        git = path.resolve(dir, '.git')
        expect(fs.existsSync(dir)).to.be.true
        expect(fs.existsSync(git)).to.be.true
        done()
      )

