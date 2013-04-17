#waiter.js
Waiter.js serves your Backbone tables

Waiter.js is a simple [Backbone.js](http://backbonejs.org/) plugin for rendering your collections as tables. It was designed to be as lightweight and easy to use as possible, while still being able to handle most situations you could think of.

I wrote waiter.js because I found myself duplicating a lot of boilerplate code for doing a simple task - rendering a backbone collection as a table (with sorting and other options). Waiter.js takes care of all of that, allowing you to simply pass in a list of columns with some options. It also is built solely as Backbone views, so you can (and should) extend and subclass them to meet your needs.

##Features
- Lightweight - waiter.js is currently around 100 lines of coffeescript, and around 4KB of compiled source.
- Flexible - waiter.js was designed to be flexible enough to adapt to your projects and powerful enough that you can use it without any customization if you want.
- Simple - I think the usage and setup could not be any easier. If you disagree, file an issue :)


##Installation 
Because waiter.js is a Backbone plugin it requires Backbone (and all the prereqs) to be included on the page.

```html
<script type="text/javascript" src="jquery-1.8.3.min.js"></script>
<script type="text/javascript" src="underscore-1.4.4.min.js"></script>
<script type="text/javascript" src="backbone-1.0.0.min.js"></script> 
<script type="text/javascript" src="path/to/waiter.js"></script>
```

We use `listenTo` to avoid memory leaks in your views, which was added in `v1.0.0` of backbone. In the future I may write a backwards compatible branch, but for now that is required. 

## Basic Usage
In the most simple usage simply initialize a new `Backbone.Waiter` class with some options. This behaves like a normal backbone view, so you can access the `View.el` property to insert into the DOM.

The only options that are required are
- `collection` - The Backbone collection to use
- `columns` - An array of columns for the table. These take several options
  - `name` - The name of the column. This is displayed in the table header. This is required
  - `value` - This is how you specify the value for the column. This is optional
    If it is not provided then the value is fetched by calling ```js Model.get(column.name)``` on the model for the row. 

    If this is a string then the value is fetched by ```js Model.get(column.value)``` on the model for the row. 

    Waiter.js also support custom getters. You can set value to be a function, and the returned value will be used. For example you can do
    ```js
    value: function(){
      return this.get("first_name") + " " + this.get("last_name")
    }
    ```

    `this` is the Backbone model for the row.
You can see the rest of the options [here](#options).
Below you can see a basic example.

```html
<script type="text/javascript">
  var config = {
    collection: window.collection,
    columns: [
      {
        name: "ID" //The value will be loaded by Model.get("ID")
      }, {
        name: "User Number",
        value: "number" //The value will be loaded by Model.get("number")
      }, {
        name: "User Name",
        value: function() { //The value will be what this function returns, this is the Model
          return this.get('first_name') + " " + this.get('last_name');
        }
      }
    ]
  };

  table_view = new window.Backbone.Waiter(config);

  $("body").append(table_view.el);
</script>
```

##Options
The full list of options that you can pass while initializing a view are as follows:
- `collection` - The Backbone collection to use
- `default_sort` - The column to sort by by default. For example if you want to sort by the third column use `2` (0 indexed). If not provided then defaults to `0`.
- `default_sort_direction` - The default sort direction. Can be `up` or `down`. Defaults to `down`.
- `headerView` - The Backbone view used for rendering the header. See the [advanced usage](#advanced-usage) section.
- `rowView` - The Backbone view used for rendering rows. See the [advanced usage](#advanced-usage) section.
- `columns` - An array of columns for the table. These take several options
  - `name` - The name of the column. This is displayed in the table header. This is required
  - `value` - This is how you specify the value for the column. This is optional
    If it is not provided then the value is fetched by calling ```js Model.get(column.name)``` on the model for the row. 

    If this is a string then the value is fetched by ```js Model.get(column.value)``` on the model for the row. 

    Waiter.js also support custom getters. You can set value to be a function, and the returned value will be used. For example you can do
    ```js
    value: function(){
      return this.get("first_name") + " " + this.get("last_name")
    }
    ```
  - `sort` - This is how you specify the sort functionality for the column. This is optional
    If it is not provided then the column will be sorted by the value

    If it's `false` then sorting the column will not be allowed.

    You can also pass a string or a function and it will behave exactly like the `value` option.
  - `cellView` - The Backbone view used for rendering cells in this column. See the [advanced usage](#advanced-usage) section.

##Sorting
Waiter.js makes it easy to provide sortable tables. In fact it does it by default. If you don't want to be able to sort columns, pass `sort: false` in their config. Otherwise columns will be sorted as specified in their config. 

Waiter uses a few classes on the header elements to indicate sorting data. These include

- `th.sortable` - A column that is sortable. This could be used to show arrows or some visual hint. 
- `th.sorted.up` and `th.sorted.down` - These classes indicate that the column is currently sorted up or down. 

A column that can't be sorted (due to `sort: false` in the config) will have no classes.

##Advanced Usage
Todo

## Development
Development is done in [coffeescript](http://coffeescript.org/). You can view the development source in the `src` directory. 

After making any changes, please add or run any required tests. Tests are located in the `test/spec.coffee` file, and can be run via npm:
```
npm test
``` 

After testing any changes, you can compile the production version by running 
```
npm run-script build
```

- Source hosted at [GitHub](https://github.com/templaedhel/waiter.js)
- Report issues, questions, feature requests on [GitHub Issues](https://github.com/templaedhel/waiter.js/issues)

Pull requests are welcome! Please ensure your patches are well tested. Please create seperate branches for seperate features/patches.

## Authors

[Cosmo Wolfe](http://templaedhel.com)