<%= symbol %> = require("../src/<%= symbol %>")

describe '<%= symbol %> =>', ->

  describe 'contructor =>', ->

    it 'should instantiate without error', ->
      expect(-> new <%= symbol %>()).to.not.throw(Error)