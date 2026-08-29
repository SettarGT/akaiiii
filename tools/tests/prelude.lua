-- 196 RP | Unit test prelüdiyası
-- FiveM mühitini təqlid edir ki, konfiq/məntiq faylları server olmadan test olunsun.

-- ---------- vector3 təqlidi ----------
vector3 = function(x, y, z)
    local v = { x = x or 0.0, y = y or 0.0, z = z or 0.0 }
    local mt = {}

    mt.__add = function(a, b) return vector3(a.x + b.x, a.y + b.y, a.z + b.z) end
    mt.__sub = function(a, b) return vector3(a.x - b.x, a.y - b.y, a.z - b.z) end
    mt.__mul = function(a, b)
        if type(b) == 'number' then return vector3(a.x * b, a.y * b, a.z * b) end
        return vector3(a.x * b.x, a.y * b.y, a.z * b.z)
    end
    mt.__len = function(a) return math.sqrt(a.x ^ 2 + a.y ^ 2 + a.z ^ 2) end
    mt.__unm = function(a) return vector3(-a.x, -a.y, -a.z) end
    mt.__eq = function(a, b) return a.x == b.x and a.y == b.y and a.z == b.z end
    mt.__tostring = function(a)
        return ('vector3(%.1f, %.1f, %.1f)'):format(a.x, a.y, a.z)
    end

    return setmetatable(v, mt)
end

-- ---------- test çərçivəsi ----------
TEST_RESULTS = {}

test = function(name, fn)
    local ok, err = pcall(fn)

    TEST_RESULTS[#TEST_RESULTS + 1] = {
        name = name,
        ok = ok,
        err = ok and nil or tostring(err),
    }
end

assertEq = function(actual, expected, msg)
    if actual ~= expected then
        error(('%s: gözlənilən %s, alınan %s'):format(
            msg or 'assertEq', tostring(expected), tostring(actual)), 2)
    end
end

assertNear = function(actual, expected, eps, msg)
    if math.abs((actual or 0) - expected) > (eps or 0.001) then
        error(('%s: gözlənilən ~%s, alınan %s'):format(
            msg or 'assertNear', tostring(expected), tostring(actual)), 2)
    end
end

assertTrue = function(value, msg)
    if not value then
        error(msg or 'assertTrue: false alındı', 2)
    end
end

assertFalse = function(value, msg)
    if value then
        error(msg or 'assertFalse: true alındı', 2)
    end
end

-- FiveM qlobal funksiyaları (konfiq faylları işlətməsə də, təhlükəsizlik üçün)
CreateThread = function() end
Wait = function() end
RegisterCommand = function() end
RegisterNetEvent = function() end
AddEventHandler = function() end
exports = setmetatable({}, { __call = function() return function() end end })
