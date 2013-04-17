mocha = require "mocha"
assert = require "assert"
fs = require "fs"
jsdom = require("jsdom").jsdom
_ = require "underscore"

describe "waiter.js", ->
  window = null

  before (done) ->
    jsdom.env 
      html:fs.readFileSync("#{__dirname}/page_specs/index.html").toString()
      src: [
        fs.readFileSync("#{__dirname}/page_specs/jquery-1.8.3.min.js").toString()
        fs.readFileSync("#{__dirname}/page_specs/underscore-1.4.4.min.js").toString()
        fs.readFileSync("#{__dirname}/page_specs/backbone-1.0.0.min.js").toString()
        fs.readFileSync("#{__dirname}/../dist/waiter.js").toString()
        fs.readFileSync("#{__dirname}/page_specs/test_data.js").toString()
      ]
      done: (errors, _window) ->
        window = _window
        done()

  it "is a backbone plugin", -> 
    assert window.Backbone.Waiter?,true

  #Value Tests
  it "supports a config with just 'name' specified", ->
    config =
      collection: window.collection
      columns: [
        name: "index" #Only specify name
      ,
        name: "letter"
      ,
        name: "concat"
      ]
    window.jQuery("body").empty().append (new window.Backbone.Waiter(config)).el

    assert window.jQuery("table").length is 1, "No table was added to the DOM"
    assert window.jQuery("tr").length is window.collection.models.length + 1, "Number of table rows didn't equal the number of models in the collection."
    window.jQuery("tr").each (row_number) ->
      cells = window.jQuery(@).children("td,th")
      vals = window.jQuery.map(cells, (cell) -> window.jQuery(cell).text())

      if row_number is 0 #Header row
        for value, index in vals
          assert.equal value, config.columns[index].name, "Header value is not equal to the column name"
      else
        for value, index in vals
          column_name = config.columns[index].name
          assert.equal value, window.collection.models[row_number - 1].get(column_name), "Cell value is not equal to the column value"

  it "supports a config with a 'name' string 'value' specified", ->
    config =
      collection: window.collection
      columns: [
        name: "Index" #Only specify name
        value: "index"
      ,
        name: "To Letter"
        value: "letter"
      ,
        name: "Doubled"
        value: "concat"
      ]
    window.jQuery("body").empty().append (new window.Backbone.Waiter(config)).el

    assert window.jQuery("table").length is 1, "No table was added to the DOM"
    assert window.jQuery("tr").length is window.collection.models.length + 1, "Number of table rows didn't equal the number of models in the collection."
    window.jQuery("tr").each (row_number) ->
      cells = window.jQuery(@).children("td,th")
      vals = window.jQuery.map(cells, (cell) -> window.jQuery(cell).text())

      if row_number is 0 #Header row
        for value, index in vals
          assert.equal value, config.columns[index].name, "Header value is not equal to the column name"
      else
        for value, index in vals
          column_val = config.columns[index].value
          assert.equal value, window.collection.models[row_number - 1].get(column_val), "Cell value is not equal to the column value"

  it "supports a config with a 'name' function 'value' specified", ->
    config =
      collection: window.collection
      columns: [
        name: "Number of Attributes" #Only specify name
        value: -> _(@attributes).keys().length
      ,
        name: "To Letter"
        value: -> @get("letter")
      ]
    window.jQuery("body").empty().append (new window.Backbone.Waiter(config)).el

    assert window.jQuery("table").length is 1, "No table was added to the DOM"
    assert window.jQuery("tr").length is window.collection.models.length + 1, "Number of table rows didn't equal the number of models in the collection."
    window.jQuery("tr").each (row_number) ->
      cells = window.jQuery(@).children("td,th")
      vals = window.jQuery.map(cells, (cell) -> window.jQuery(cell).text())

      if row_number is 0 #Header row
        for value, index in vals
          assert.equal value, config.columns[index].name, "Header value is not equal to the column name"
      else
        assert.equal vals[0], _(window.collection.models[row_number - 1].attributes).keys().length, "Cell value is not equal to the column value"
        assert.equal vals[1], window.collection.models[row_number - 1].get("letter"), "Cell value is not equal to the column value"

  #Sorting Tests
  describe "sorting", ->
    sort_config =
      columns: [
        name: "index" #Only specify name, no sort options
      ,
        name: "letter"
        sort: "letter" #sort by letter
      ,
        name: "concat"
        sort: false #don't sort
      ,
        name: "random"
        sort: -> @get("random")
      ]
    before -> 
      sort_config.collection = window.collection #add the collection here because of how mocha handles scope
      window.jQuery("body").empty().append (new window.Backbone.Waiter(sort_config)).el

    it "creates a table", ->
      assert window.jQuery("table").length is 1, "No table was added to the DOM"
      assert window.jQuery("tr").length is window.collection.models.length + 1, "Number of table rows didn't equal the number of models in the collection."

    it "sorts by the first column by default", ->
      sorted_index = _(window.collection.pluck("index")).sortBy (item) -> item
      
      window.jQuery("tr").each (row_number) ->
        return if row_number is 0
        cells = window.jQuery(@).children("td,th")
        vals = window.jQuery.map(cells, (cell) -> window.jQuery(cell).text())
        assert.equal vals[0], sorted_index[row_number - 1]

    it "shows the correct heading classes", ->      
      window.jQuery("tr").first().children("th").each (heading_index) ->
        if sort_config.columns[heading_index].sort is false
          assert not window.jQuery(@).hasClass "sortable"
        else
          assert window.jQuery(@).hasClass "sortable"
        assert window.jQuery(@).hasClass "sorted down" if heading_index is 0 #first column should be sorted

    it "changes the sort to 'up' when you click on a sorted down heading", ->
      reverse_sorted_index = _(window.collection.pluck("index")).sortBy((item) -> item).reverse()
      
      window.jQuery("tr th").first().click() #click on the first heading (index)

      assert window.jQuery("tr th").first().hasClass "sorted up"

      window.jQuery("tr").each (row_number) ->
        return if row_number is 0
        cells = window.jQuery(@).children("td,th")
        vals = window.jQuery.map(cells, (cell) -> window.jQuery(cell).text())
        assert.equal vals[0], reverse_sorted_index[row_number - 1], "Sorting was not reversed"

    it "clicking on another sortable heading changes the sort", ->
      sorted_random = _(window.collection.pluck("random")).sortBy((item) -> item)
      
      window.jQuery("tr th").last().click() #click on the first heading (index)


      assert not window.jQuery("tr th").first().hasClass "sorted"
      assert window.jQuery("tr th").last().hasClass "sorted down"

      window.jQuery("tr").each (row_number) ->
        return if row_number is 0
        cells = window.jQuery(@).children("td,th")
        vals = window.jQuery.map(cells, (cell) -> window.jQuery(cell).text())
        assert.equal vals[3], sorted_random[row_number - 1], "Sorting was not changed"

    it "clicking on a non sortable heading does nothing", ->
      sorted_random = _(window.collection.pluck("random")).sortBy((item) -> item)
      
      window.jQuery("tr th:not(.sortable)").click() #click on the first heading (index)

      assert not window.jQuery("tr th:not(.sortable)").hasClass "sorted"
      assert window.jQuery("tr th").last().hasClass "sorted down"

      window.jQuery("tr").each (row_number) ->
        return if row_number is 0
        cells = window.jQuery(@).children("td,th")
        vals = window.jQuery.map(cells, (cell) -> window.jQuery(cell).text())
        assert.equal vals[3], sorted_random[row_number - 1], "Sorting was changed"

    it "passing default sort and default sort by options change the default sort", ->
      sorted_random_reverse = _(window.collection.pluck("random")).sortBy((item) -> item).reverse()
      
      _(sort_config).extend 
        default_sort: 3 #last column
        default_sort_direction: "up"

      window.jQuery("body").empty().append (new window.Backbone.Waiter(sort_config)).el

      assert window.jQuery("tr th").last().hasClass "sorted up"

      window.jQuery("tr").each (row_number) ->
        return if row_number is 0
        cells = window.jQuery(@).children("td,th")
        vals = window.jQuery.map(cells, (cell) -> window.jQuery(cell).text())
        assert.equal vals[3], sorted_random_reverse[row_number - 1], "Did not sort by the right column"