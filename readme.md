[![Build Status](https://travis-ci.org/lcaballero/rubber-stamp.svg?branch=master)](https://travis-ci.org/) [![NPM version](https://badge.fury.io/js/rubber-stamp.svg)](http://badge.fury.io/js/rubber-stamp)

# Introduction

Rubber-stamp is a library for generating project and project related files.

## Overview

`rubber-stamp` is a library used with `rstamp-cli` to create Node.js projects that
generate source code.  The idea is that this lib provides a number of utilities
needed during the creation of an initial project.

## Installation

This adds the `rubber-stamp` to a library:

`%> npm install rubber-stamp --save`

However, if you have installed `rstamp-cli` then the better approach is to use the
`gen-gen` template.  So called because it generates a generator.  That new generator
will include the `rubber-stamp` as a dependency.

## Usage

Within a new generator you'd write code of this variety:

```coffee

source = 'directory/containing/files/to/copy/or/translate/'
target = './destination/directory'
model  = {}

Gen = require 'rubber-stamp'

Gen.using(source, target, model, 'GenProjectTest 1')
  .mkdir()
  .add((gn) -> gn.in('lib').mkdir().copy('NewLib.coffee'))
  .add((gn) -> gn.in('tests').mkdir().copy('NewLibTest.coffee'))
  .copy('index.js', 'package.json')
  .apply()

```

It should be noted that the generator follows a slightly different pattern.
A generator typically needs to query the user for some input.  Generally speaking
the generator needs to know names of projects and files, and then from that derive
other things.  For instance, with just a 'name' you could create a directory,
generate a new package.json and use a template to inject the name into the
right property, etc.

The idea here is that running `gen-gen` will also include inquirer.js and setup
some initial code that queries the user.  With those answers, typically filling
in the 'target' and model, you could run templates inserting values provided by
the user, but also copy and process files to the target location using `rubber-stamp`.

The best example of this is the [new-npm][new-npm] project itself.

## API

**TODO**

## License

See license file.

The use and distribution terms for this software are covered by the
[Eclipse Public License 1.0][EPL-1], which can be found in the file 'license' at the
root of this distribution. By using this software in any fashion, you are
agreeing to be bound by the terms of this license. You must not remove this
notice, or any other, from this software.


[EPL-1]: http://opensource.org/licenses/eclipse-1.0.txt
[new-npm]: https://github.com/lcaballero/rstamp-new-npm
