if env == 'test'
  FadeDefaults =
    delay: 0
    duration:0
    easing: 'linear'
else
  FadeDefaults =
    delay: 0
    duration: 300
    easing: 'linear'

fade = (t, params) ->
  targetOpacity = undefined
  params = t.processParams(params, FadeDefaults)
  if t.isIntro
    targetOpacity = t.getStyle('opacity')
    t.setStyle 'opacity', 0
  else
    targetOpacity = 0
  t.animateStyle('opacity', targetOpacity, params).then t.complete
  return

Ractive.transitions.fade = fade
