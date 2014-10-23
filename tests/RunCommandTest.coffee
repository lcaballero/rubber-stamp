require('./Deps')();

Gen   = require('../lib/gen')
path  = require('path')
fs    = require 'fs'


describe 'RunCommandTest =>', ->

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
