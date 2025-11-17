---@param s SpriteState
return function(s)
  return {
    sprite = Res.sprites.BALL:state(s),
    prev_box = Box.zero(),
    velocity = Vec2.zero(),
    speed = 0.4 * S.camera.box.w,
  }
end
