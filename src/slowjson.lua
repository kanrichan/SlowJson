local encoder = require 'SlowJson.encoder'
local decoder = require 'SlowJson.decoder'

return {
	encode = encoder,
	decode = decoder,
}