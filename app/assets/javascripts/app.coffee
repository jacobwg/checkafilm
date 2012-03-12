window.AppRouter = Backbone.Router.extend
  content: '#content'
  Model: {}
  Collection: {}
  Router: {}
  View: {}
  mobileOnly: (func) ->
    ua = navigator.userAgent
    func() if /Android/i.test( ua ) or /iP[ao]d|iPhone/i.test( ua ) or /Mobile/i.test( ua )

window.App = new AppRouter