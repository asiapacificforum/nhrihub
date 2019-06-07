const { environment } = require('@rails/webpacker')
// I have a customized version of @rails webpacker that is tweaked to work with engines
//const { environment } = require('../../app/assets/javascripts/local_node_modules/@rails/webpacker')
const webpack = require('webpack')

environment.loaders.append('ractive_component', {
  test: /\.ractive\.html$/,
  use: 'ractive-bin-loader'
})

environment.loaders.append('ractive_pug_component', {
  test: /\.ractive\.pug$/,
  use: ['ractive-bin-loader', 'pug-html-loader']
})

environment.loaders.append('locales', {
 test: /\.ya?ml$/,
 loaders: ['json-loader', 'yaml-loader']
})


module.exports = environment
