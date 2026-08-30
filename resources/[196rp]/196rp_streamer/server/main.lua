local streamers = {}

RegisterNetEvent('196rp_streamer:server:set', function(enabled)
    if enabled then
        streamers[source] = true
    else
        streamers[source] = nil
    end
end)

exports('IsStreamer', function(src)
    return streamers[src] == true
end)
