path  = require 'path'
fs    = require 'fs'
_     = require 'lodash'

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

    mkdir: (dirs...) ->
      if dirs.length >= 1
        for d in dirs
          @add(mkdir(@to(d)))
      else
        @add(mkdir(@getTarget()))
      this

    mkdirs: (dirs...) ->
      for dir in dirs
        if !fs.existsSync(dir)
          @mkdirs(path.dirname(dir))
          @add(mkdir(@to(dir)))
      this

    cd = (g) -> -> g

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

    apply: () ->
      for f in @_execs
        applied = f(new Generator(@getSource(), @getTarget(), @getModel(), @getName(), @getRoot()))
        if applied? and _.isFunction(applied.apply) && !applied._isApplied
          applied.apply()

      @_isApplied = true

    hasApplications: () ->
      @_execs.length > 0

    ###
      process(files) assumes that the name of the target file is either the same as the
      source file or can be translated.  For instance, some-file.ftl.xml can be
      translated as some-file.xml.
    ###
    process: (files...) ->
      @add(runTemplating(@from(f), @to(f))) for f in files

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

  return {
    using : (source, target, model, name) ->
      new Generator(source, target, model, name)
  }



