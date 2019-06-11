const { environment, config } = require('@rails/webpacker');
const coffee =  require('./loaders/coffee')
const { resolve } = require('path');

environment.config.set('output.path', resolve(config.public_root_path, config.public_output_path));

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

environment.plugins.append(
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

environment.loaders.prepend('coffee', coffee)
module.exports = environment
