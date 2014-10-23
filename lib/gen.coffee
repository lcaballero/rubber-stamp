path      = require 'path'
fs        = require 'fs'
_         = require 'lodash'
async     = require 'async'
proc      = require 'child_process'
spawn     = proc.spawn
{ Glob }  = require 'glob'


module.exports = do ->

  UTF8 = 'utf8'


  class Generator
    constructor: (source, target, model, name, root) ->
      @source     = source
      @target     = target
      @model      = model
      @_execs     = []
      @_name      = name
      @_isApplied = false
      @_isRoot    = not root?
      @_root      = root || @

    getRoot   : -> @_root
    isRoot    : -> @_isRoot
    getName   : -> @_name
    getModel  : -> @model
    getTarget : -> @target
    getSource : -> @source
    from      : (dir) -> path.resolve(@source, dir)
    to        : (dir) -> path.resolve(@target, dir)

    runTemplating = (from, to) -> (gen) ->
      if fs.existsSync(from)
        raw     = fs.readFileSync(from, UTF8)
        content = _.template(raw, gen.model)
        fs.writeFileSync(to, content, UTF8)
      else
        throw new Error("The source template file does not exist: " + from)

    copy = (from) -> (gen) ->
      file = gen.from(from)
      if fs.existsSync(file)
        content = fs.readFileSync(file, UTF8)
        fs.writeFileSync(gen.to(from), content, UTF8)
      else
        throw new Error('.copy() source template file does not exist: ' + file)

    mkdir = (dir) -> (gen) ->
      if !fs.existsSync(dir)
        fs.mkdirSync(dir)

    cd = (g) -> -> g

    mkdir: (dirs...) ->
      if dirs.length >= 1
        for d in dirs
          @add(mkdir(@to(d)))
      else
        @add(mkdir(@getTarget()))
      this

    mkdirs: (dirs...) ->
      for dir in dirs
        f = @to(dir)
        if !fs.existsSync(f)
          @mkdirs(path.dirname(f))
          @add(mkdir(f))
      this

    in : (dir) ->
      g = new Generator(
        @from(dir),
        @to(dir),
        @getModel(),
        @getName()
        @getRoot())
      @add(cd(g))
      g

    add: (fn) ->
      @_execs.push(fn)
      this

    apply: (done) ->

      async.mapSeries(@_execs, (f, cb) =>
        ng = new Generator(@getSource(), @getTarget(), @getModel(), @getName(), @getRoot())

        if f.length <= 1
          applied = f(ng)
          if applied? and _.isFunction(applied.apply) and !applied._isApplied
            applied.apply()
            applied._isApplied = true
          cb(null, true)
        else
          f(ng, cb)

      , (err, res) =>
        @_isApplied = true
        if done? then done()
      )

    hasApplications: () ->
      @_execs.length > 0

    ###
      process(files) assumes that the name of the target file is either the same as the
      source file or can be translated.  For instance, some-file.ftl.xml can be
      translated as some-file.xml.
    ###
    process: (files...) ->
      @add(runTemplating(@from(f), @to(f))) for f in files
      this

    ###
      translate(from, to) causes the contents of the 'from' file to be processed as a
      template and then written to the the 'to' file.  This is useful if one would
      like to rename the file in-flight.
    ###
    translate: (from, to) ->
      @add(runTemplating(@from(from), @to(to)))
      this

    copy: (from...) ->
      for f in from
        @mkdirs(path.dirname(f))
        @add(copy(f))

      this


    ###
      This command takes an object with the properties { options, commands }.
      Options are those passed to child_process.spawn setting up the current
      working directory (cwd), and io which is defaulted to [stdin, stdout, stderr]
      if no other options are provided.

      The commands property is an array of objects of the form
      { name: 'command', args: [...args...] }

      So, something like this:

      {
        options:
          cwd   : path.resolve(process.cwd(), target)
          stdio : [ process.stdin, process.stdout, process.stderr ]
        commands: [
          { name: 'git', args: ['init'] }
        ]
      }

      Each command is ran in series synchronously.  This is to prevent multiple
      processes trying to write to a file at the same time.  Every process
      is expected to return 0 when exiting normally and non-zero which
      the process handler will consider as an error and prevent further
      commands if one in the series fails.
    ###
    run : (opts) ->
      @add(run(opts))

    run = (opts) -> (gen, _done) =>

      { options, commands } = (opts or {})

      options       ?= {}
      options.cwd   ?= path.resolve(process.cwd(), gen.getTarget())
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

    # isFile uses the node fs package and stat to determine if the provided
    # file is indeed a file and not a directory or symbolic link, etc.
    isFile = (f) ->
      fs.statSync(f).isFile()

    # isDirectory uses the node fs package and stat to determine if the file
    # provided is indeed a directory and not a file or symbolic link, etc.;l
    isDirectory = (f) ->
      fs.statSync(f).isDirectory()

    deepCopy: (accept, translate) ->

      opts = { cwd: @getSource(), sync: true }
      glob = new Glob('**/*', opts, (err, matches) =>

        for match in matches
          if accept(match)
            xfm = translate(match)
            src = @from(match)

            if isDirectory(src)
              @mkdir(match)
            else if isFile(src)
              if xfm
                @translate(match, xfm)
              else
                @copy(match)
      )

      @

  return {
    using : (source, target, model, name) ->
      new Generator(source, target, model, name)
  }



