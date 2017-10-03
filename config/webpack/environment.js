const { environment } = require('@rails/webpacker')

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

module.exports = environment
