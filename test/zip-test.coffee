require 'mocha'
mocha.setup 'bdd'

expect = require('chai').expect
    
ZIPExporter = require '../lib/ZIPExporter'
    
class StorageMock
    constructor: (@data) ->

    get: (id, cb) ->
        cb null, @data[id] or null
        
    save: (id, doc, cb) ->
        @data[id] = doc
        cb null

describe "Zip Exporter", ->
    storage = new StorageMock {
            root:
                value: 1
            node_1_cells:
                '0/0': 2
                '0/1': 3
            cell_2:
                label: 'foo'
            cell_3:
                label: 'bar'
    }

    it "can be created", (done) ->
        expect(new ZIPExporter).to.exist
        done()

    it "produces a link and no error", (done) ->
        exporter = new ZIPExporter
        exporter.export storage, (err, link) ->
            try
                expect(err).not.to.exist
                expect(link).to.exist
                expect(link).to.include "data:"
                console.log link
                done()
            catch err
                done err

mocha.checkLeaks()
runner = mocha.run()
