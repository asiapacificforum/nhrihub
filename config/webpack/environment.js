//const { environment } = require('@rails/webpacker')
// I have a customized version of @rails webpacker that is tweaked to work with engines
const { environment } = require('../../app/assets/javascripts/local_node_modules/@rails/webpacker')
const webpack = require('webpack')

environment.loaders.set('ractive_component', {
  test: /\.ractive\.html$/,
  use: 'ractive-bin-loader'
})

environment.loaders.set('ractive_pug_component', {
  test: /\.ractive\.pug$/,
  use: ['ractive-bin-loader', 'pug-html-loader']
})

environment.loaders.set('locales', {
 test: /\.ya?ml$/,
 loaders: ['json-loader', 'yaml-loader']
})

environment.plugins.set(
  'Provide',
  new webpack.ProvidePlugin({
    UserInput : ['user_input_manager.coffee','UserInput'],
    InpageEdit : ['in_page_edit.coffee','InpageEdit'],
    notes : ['notes.ractive.pug','notes'],
    I18n : 'i18n-js',
    Ractive : ['ractive','default'],
    $ : 'jquery',
    jQuery : 'jquery',
    jquery : 'jquery',
    _ : 'underscore'
  })
)

module.exports = environment
