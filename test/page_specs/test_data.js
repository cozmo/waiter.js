var collection = new Backbone.Collection();

for (var i = 0; i < 26; i++) {
  collection.add({
    index: i, 
    letter: String.fromCharCode(97 + i), 
    concat: "" + i + i,
    random: Math.random()
  })
};