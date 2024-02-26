/* eslint no-console:0 */
require("@rails/ujs").start()

const css = require.context("../../assets/stylesheets")
css.keys().forEach(css)

const js = require.context("../../assets/javascripts")
js.keys().forEach(js)
