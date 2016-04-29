SlideDefaults = 
  duration: 300
  easing: 'easeInOut'

SlideProps = [
  'height'
  'borderTopWidth'
  'borderBottomWidth'
  'paddingTop'
  'paddingBottom'
  'marginTop'
  'marginBottom'
]

SlideCollapsed =
  height: 0
  borderTopWidth: 0
  borderBottomWidth: 0
  paddingTop: 0
  paddingBottom: 0
  marginTop: 0
  marginBottom: 0

slide = (t, params) ->
  targetStyle = undefined
  params = t.processParams(params, SlideDefaults)
  if t.isIntro
    targetStyle = t.getStyle(SlideProps)
    t.setStyle SlideCollapsed
  else
    # make style explicit, so we're not transitioning to 'auto'
    t.setStyle t.getStyle(SlideProps)
    targetStyle = SlideCollapsed
  t.setStyle 'overflowY', 'hidden'
  t.animateStyle(targetStyle, params).then t.complete
  return

Ractive.transitions.slide = slide
