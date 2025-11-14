--- @param opts SpriteStateOpts
return function(opts)
  return {
    sprite = Res.sprites.BALL:state(opts),
    prev_box = math.box.zero(),
    velocity = math.vec2.zero(),
    speed = 0.4 * S.camera.box.w,
  }
end
