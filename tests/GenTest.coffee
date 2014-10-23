require('./Deps')();

Gen   = require('../lib/gen')
path  = require('path')
fs    = require 'fs'

describe 'GenTest =>', ->

  it 'should find globals', ->
    expect(_).to.be.ok
    expect(chai).to.be.ok
    expect(Tree).to.be.ok

  it 'should instantiate a new instance of a Generator with target, source, and model.', ->
    g = Gen.using('source', 'target', 'model')
    expect(g.source).to.equal('source')
    expect(g.target).to.equal('target')
    expect(g.model).to.equal('model')

  describe 'mkdir =>', ->

    it 'should make the source directory in the target directory', ->
      dir = 'files/targets/t1'
      Gen.using('source', dir, {}).mkdir().apply()
      expect(fs.existsSync(dir)).to.be.true

  describe 'to =>', ->
    gen = null
    target = 'files/targets'
    source = 'files/src'

    beforeEach ->
      gen = Gen.using(source, target, {})

    it 'to(dir) should resolve directory relative to the target', ->
      dir = 't1'
      p = gen.to(dir)
      expect(p).to.equal(path.resolve(target, dir))

  describe 'from =>', ->

    gen = null
    target = 'files/targets'
    source = 'files/src'

    beforeEach ->
      gen = Gen.using(source, target, {})

    it 'from(dir) should resolve directory relative to the source', ->
      dir = 't1'
      p = gen.from(dir)
      expect(p).to.equal(path.resolve(source, dir))

  describe 'getName() =>', ->

    it 'should remain empty if no name is provided', ->
      g = Gen.using('', '', {})
      expect(g.getName()).to.not.be.ok

    it 'generator should save the name it is given', ->
      name = 'getName'
      g = Gen.using('', '', {}, name)
      expect(g.getName()).to.equal(name)

  describe 'apply', ->
    gen     = null
    target  = 'files/targets'
    source  = 'files/src'
    name    = 'apply test'

    beforeEach ->
      gen = Gen.using(source, target, {}, name)

    describe 'apply() =>', ->

      it 'hasApplications should start with no applications',  ->
        expect(gen.hasApplications()).to.be.false

      it 'hasApplications should hold an application after adding one', ->
        expect(gen.add(->).hasApplications()).to.be.true

      it 'applied function should receive the parent Generator ', (done) ->
        gen.add((g) ->
            expect(g, 'parent exists').to.be.ok
            expect(g.getName(), 'has parent name').to.equal(name)
            done())
          .apply()

  describe 'translate(file) =>', ->

    gen      = null
    target   = 'files/targets/t2'
    source   = 'files/src/t2'
    name     = 'apply test'
    template = 'template.tpl'
    json     = 'template.json'

    beforeEach ->
      gen = Gen.using(source, target, {name:name}, name)

    afterEach ->
      if fs.existsSync(gen.to(json))
        fs.unlinkSync(gen.to(json))

    it 'should find the source template file and create the target file', ->
      gen.mkdir().translate(template, json).apply()

      sourceTemplate = path.resolve(source, template)
      targetTemplate = path.resolve(target, json)

      expect(fs.existsSync(sourceTemplate), 'should find source template: ' + sourceTemplate).to.be.true
      expect(fs.existsSync(targetTemplate), 'should find target template: ' + targetTemplate).to.be.true

    it 'should have processed the source template', ->
      gen.mkdir().translate(template, json).apply()
      expect(fs.readFileSync(gen.to(json), 'utf8')).to.string(name)

    it 'should have no applications prior to processing a file', ->
      expect(gen.hasApplications()).to.be.false
      gen.translate(template, json)
      expect(gen.hasApplications()).to.be.true

      # w/o .apply() called the target processed file should not be created
      targetTemplate = path.resolve(target, json)
      expect(fs.existsSync(targetTemplate), 'should find target template: ' + targetTemplate).to.be.false

  describe 'copy(file) =>', ->

    gen     = null
    target  = 'files/targets/t3'
    source  = 'files/src/t3'
    name    = 'apply test'
    json    = 'package.json'

    beforeEach ->
      gen = Gen.using(source, target, {name:name}, name)

    afterEach ->
      if fs.existsSync(gen.to(json))
        fs.unlinkSync(gen.to(json))

    it 'should have created the target file', ->
      gen.copy(json).apply()

      # w/o .apply() called the target processed file should not be created
      targetJson = path.resolve(target, json)
      expect(fs.existsSync(targetJson), 'should find target template: ' + targetJson).to.be.true

