async = require('async')
path  = require('path')
fs    = require('fs')
proc  = require('child_process')
spawn = proc.spawn


module.exports = do ->

  contains = (root, file, content) ->
    f = path.resolve(root, file)
    c = fs.readFileSync(f, { encoding: 'utf8' }).toString()
    re = new RegExp(content)
    expect(re.test(c)).to.be.true

  exists = (root, dirs...) ->
    for dir in dirs
      file = path.resolve(root, dir)
      expect(fs.existsSync(file), 'should have created file: ' + file).to.be.true

  run = (opts, _done) ->

    { options, commands, target } = opts or {}

    options       ?= {}
    options.cwd   ?= path.resolve(process.cwd(), target)
    options.stdio ?= [ process.stdin, process.stdout, process.stderr ]

    handleClose = (next) -> (code, signal) ->
      if code isnt 0
        next(new Error("code: #{code}, signal: #{signal}"))
      else if next? and code is 0
        next(null, code)

    handleProc = (e, cb) ->
      proc = spawn(e.name, e.args, options)
      proc.on('exit', handleClose(cb))

    async.mapSeries(commands, handleProc, (err, res) ->
      if err? then _done(err, null)
      else _done(null, res)
    )

  rm = (cwd, t, cb) ->
    cmds =
      target : cwd
      commands: [ { name: 'rm', args: ['-rf', t] } ]
    run(cmds, cb)

  mkdir = (cwd, t, cb) ->
    cmds =
      target : cwd
      commands: [ { name: 'mkdir', args: ['-p', t] } ]
    run(cmds, cb)

  contains  : contains
  rm        : rm
  exists    : exists
  run       : run
  mkdir     : mkdir