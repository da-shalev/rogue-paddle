---@param s SpriteState
return function(s)
  return {
    sprite = Res.sprites.PLAYER:state(s),
    prev_box = Box.zero(),
    input_x = 0,
    speed = 0.4 * S.camera.box.w,
  }
end
