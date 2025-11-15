---@param opts SpriteStateOpts
return function(opts)
  return {
    sprite = Res.sprites.PLAYER:state(opts),
    prev_box = Box.zero(),
    input_x = 0,
    speed = 0.4 * S.camera.box.w,
  }
end
