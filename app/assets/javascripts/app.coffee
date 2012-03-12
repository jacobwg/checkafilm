window.AppRouter = Backbone.Router.extend
  content: '#content'
  Model: {}
  Collection: {}
  Router: {}
  View: {}
  isMobile: ->
    this.is_mobile ||= !!(/Android/i.test( navigator.userAgent ) or /iP[ao]d|iPhone/i.test( navigator.userAgent ) or /Mobile/i.test( navigator.userAgent ))
  mobileOnly: (func) ->
    func() if this.isMobile()

window.App = new AppRouter