Backbone.WaiterHeaderView = class extends Backbone.View
  tagName:"tr"
  events:
    "click th.sortable":"sort"
  
  current_sort: 
    by: null
    direction: null

  initialize: (options) -> 
    @config = options.config
    @current_sort = options.config.default_sort if options.config.default_sort?

  sort: (e) -> 
    index = $(e.currentTarget).index()
    @current_sort.direction = if @current_sort.by is index and @current_sort.direction is "down" then "up" else "down"
    @current_sort.by = index
    @trigger "resort", @current_sort

  render: ->
    @$el.empty()
    _.each @config.columns, (column, index) =>
      classes = if column.sortable then "sortable" else ""
      classes+=" sorted up" if @current_sort.by is index and @current_sort.direction is "up"
      classes+=" sorted down" if @current_sort.by is index and @current_sort.direction is "down"
      @$el.append "<th class='#{classes}'>#{column.name}</th>"
    @delegateEvents()
    @

Backbone.WaiterRowView = class extends Backbone.View
  tagName:"tr"
  initialize:(options) ->
    @listenTo @model, "change", @render
    @config = options.config
    @render()
  render: ->
    @$el.empty()
    _.each @config.columns, (column) => 
      @$el.append (new column.cellView(
        value: column.value(@model)
        model: @model
      )).render().el
    @

Backbone.WaiterCellView = class extends Backbone.View
  tagName:"td"
  initialize:(options) -> @value = options.value
  render: -> 
    @$el.html(@value)
    @

Backbone.Waiter = class extends Backbone.View
  tagName: "table"
  config: 
    headerView: null
    rowView: null
    columns: []

  #Options processing
  _compose_fn: (value) -> #Takes a value string or function, returns a function that takes a model and returns a value
    if _.isString value
      return (model) -> model.get(value)
    else
      return (model) ->
        value.call model
  
  setup: (options) ->
    @config = 
      headerView: options.headerView or Backbone.WaiterHeaderView
      rowView: options.rowView or Backbone.WaiterRowView
      default_sort: 
        by: options.default_sort or 0
        direction: options.default_sort_direction or "down" 
      columns: _(options.columns).chain().map((column_spec) =>
        return unless column_spec.name
        column = 
          name: column_spec.name
          value: @_compose_fn(column_spec.value or column_spec.name)
          sortable: if column_spec.sort isnt false then true else false
          cellView: column_spec.cellView or Backbone.WaiterCellView
        if column.sortable
          column.sortBy = unless column_spec.sort then column.value else @_compose_fn(column_spec.sort)
        column
      ).compact().value()

  resort: (sort_config) ->
    @collection.comparator = @config.columns[sort_config.by].sortBy
    @collection.sort({quiet:true})
    @collection.models.reverse() if sort_config.direction is "up" #backbone wat r u doing?
    @collection.trigger "sort"

  #Glue
  initialize:(options) -> 
    @listenTo @collection,"reset sort change", @render
    @config = @setup options
    
    @headerView = new @config.headerView({config:@config})
    @listenTo @headerView, "resort", @resort

    @resort @config.default_sort

  render: ->
    @$el.empty()
    @$el.append @headerView.render().el
    @collection.each (model) =>
      @$el.append (new @config.rowView
        model: model
        config: @config
      ).render().el
    @