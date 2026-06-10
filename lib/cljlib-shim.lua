package.preload["io.gitlab.andreyorst.cljlib.core"] = package.preload["io.gitlab.andreyorst.cljlib.core"] or function(...)
  local function _1_()
    return "#<namespace: core>"
  end
  --[[ "MIT License
  
  Copyright (c) 2022 Andrey Listopadov
  
  Permission is hereby granted‚ free of charge‚ to any person obtaining a copy
  of this software and associated documentation files (the “Software”)‚ to deal
  in the Software without restriction‚ including without limitation the rights
  to use‚ copy‚ modify‚ merge‚ publish‚ distribute‚ sublicense‚ and/or sell
  copies of the Software‚ and to permit persons to whom the Software is
  furnished to do so‚ subject to the following conditions：
  
  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.
  
  THE SOFTWARE IS PROVIDED “AS IS”‚ WITHOUT WARRANTY OF ANY KIND‚ EXPRESS OR
  IMPLIED‚ INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY‚
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM‚ DAMAGES OR OTHER
  LIABILITY‚ WHETHER IN AN ACTION OF CONTRACT‚ TORT OR OTHERWISE‚ ARISING FROM‚
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE." ]]
  local _local_838_ = {setmetatable({}, {__fennelview = _1_, __name = "namespace"}), require("io.gitlab.andreyorst.lazy-seq"), require("io.gitlab.andreyorst.itable"), require("io.gitlab.andreyorst.reduced"), require("io.gitlab.andreyorst.inst"), require("io.gitlab.andreyorst.async")}, nil
  local core = _local_838_[1]
  local lazy = _local_838_[2]
  local itable = _local_838_[3]
  local rdc = _local_838_[4]
  local lua_inst = _local_838_[5]
  local a = _local_838_[6]
  core.__VERSION = "0.1.239"
  local function unpack_2a(x, ...)
    if core["seq?"](x) then
      return lazy.unpack(x)
    else
      return itable.unpack(x, ...)
    end
  end
  local function pack_2a(...)
    local tmp_9_ = {...}
    tmp_9_["n"] = select("#", ...)
    return tmp_9_
  end
  local function pairs_2a(t)
    local case_840_ = getmetatable(t)
    if ((_G.type(case_840_) == "table") and (nil ~= case_840_.__pairs)) then
      local p = case_840_.__pairs
      return p(t)
    else
      local _ = case_840_
      return pairs(t)
    end
  end
  local function ipairs_2a(t)
    local case_842_ = getmetatable(t)
    if ((_G.type(case_842_) == "table") and (nil ~= case_842_.__ipairs)) then
      local i = case_842_.__ipairs
      return i(t)
    else
      local _ = case_842_
      return ipairs(t)
    end
  end
  local function length_2a(t)
    local case_844_ = getmetatable(t)
    if ((_G.type(case_844_) == "table") and (nil ~= case_844_.__len)) then
      local l = case_844_.__len
      return l(t)
    else
      local _ = case_844_
      return #t
    end
  end
  local apply
  do
    local v_27_auto
    local function apply0(...)
      local case_847_ = select("#", ...)
      if (case_847_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "apply"))
      elseif (case_847_ == 1) then
        return error(("Wrong number of args (%s) passed to %s"):format(1, "apply"))
      elseif (case_847_ == 2) then
        local f, args = ...
        return f(unpack_2a(args))
      elseif (case_847_ == 3) then
        local f, a0, args = ...
        return f(a0, unpack_2a(args))
      elseif (case_847_ == 4) then
        local f, a0, b, args = ...
        return f(a0, b, unpack_2a(args))
      elseif (case_847_ == 5) then
        local f, a0, b, c, args = ...
        return f(a0, b, c, unpack_2a(args))
      else
        local _ = case_847_
        local _let_848_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_848_.list
        local _let_849_ = list_38_auto(...)
        local f = _let_849_[1]
        local a0 = _let_849_[2]
        local b = _let_849_[3]
        local c = _let_849_[4]
        local d = _let_849_[5]
        local args = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_849_, 6)
        local flat_args = {}
        local len = (length_2a(args) - 1)
        for i = 1, len do
          flat_args[i] = args[i]
        end
        for i, a1 in pairs_2a(args[(len + 1)]) do
          flat_args[(i + len)] = a1
        end
        return f(a0, b, c, d, unpack_2a(flat_args))
      end
    end
    v_27_auto = apply0
    core["apply"] = v_27_auto
    apply = v_27_auto
  end
  local add
  do
    local v_27_auto
    local function add0(...)
      local case_851_ = select("#", ...)
      if (case_851_ == 0) then
        return 0
      elseif (case_851_ == 1) then
        local a0 = ...
        return a0
      elseif (case_851_ == 2) then
        local a0, b = ...
        return (a0 + b)
      elseif (case_851_ == 3) then
        local a0, b, c = ...
        return (a0 + b + c)
      elseif (case_851_ == 4) then
        local a0, b, c, d = ...
        return (a0 + b + c + d)
      else
        local _ = case_851_
        local _let_852_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_852_.list
        local _let_853_ = list_38_auto(...)
        local a0 = _let_853_[1]
        local b = _let_853_[2]
        local c = _let_853_[3]
        local d = _let_853_[4]
        local rest = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_853_, 5)
        return apply(add0, (a0 + b + c + d), rest)
      end
    end
    v_27_auto = add0
    core["add"] = v_27_auto
    add = v_27_auto
  end
  local sub
  do
    local v_27_auto
    local function sub0(...)
      local case_855_ = select("#", ...)
      if (case_855_ == 0) then
        return 0
      elseif (case_855_ == 1) then
        local a0 = ...
        return ( - a0)
      elseif (case_855_ == 2) then
        local a0, b = ...
        return (a0 - b)
      elseif (case_855_ == 3) then
        local a0, b, c = ...
        return (a0 - b - c)
      elseif (case_855_ == 4) then
        local a0, b, c, d = ...
        return (a0 - b - c - d)
      else
        local _ = case_855_
        local _let_856_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_856_.list
        local _let_857_ = list_38_auto(...)
        local a0 = _let_857_[1]
        local b = _let_857_[2]
        local c = _let_857_[3]
        local d = _let_857_[4]
        local rest = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_857_, 5)
        return apply(sub0, (a0 - b - c - d), rest)
      end
    end
    v_27_auto = sub0
    core["sub"] = v_27_auto
    sub = v_27_auto
  end
  local mul
  do
    local v_27_auto
    local function mul0(...)
      local case_859_ = select("#", ...)
      if (case_859_ == 0) then
        return 1
      elseif (case_859_ == 1) then
        local a0 = ...
        return a0
      elseif (case_859_ == 2) then
        local a0, b = ...
        return (a0 * b)
      elseif (case_859_ == 3) then
        local a0, b, c = ...
        return (a0 * b * c)
      elseif (case_859_ == 4) then
        local a0, b, c, d = ...
        return (a0 * b * c * d)
      else
        local _ = case_859_
        local _let_860_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_860_.list
        local _let_861_ = list_38_auto(...)
        local a0 = _let_861_[1]
        local b = _let_861_[2]
        local c = _let_861_[3]
        local d = _let_861_[4]
        local rest = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_861_, 5)
        return apply(mul0, (a0 * b * c * d), rest)
      end
    end
    v_27_auto = mul0
    core["mul"] = v_27_auto
    mul = v_27_auto
  end
  local div
  do
    local v_27_auto
    local function div0(...)
      local case_863_ = select("#", ...)
      if (case_863_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "div"))
      elseif (case_863_ == 1) then
        local a0 = ...
        return (1 / a0)
      elseif (case_863_ == 2) then
        local a0, b = ...
        return (a0 / b)
      elseif (case_863_ == 3) then
        local a0, b, c = ...
        return (a0 / b / c)
      elseif (case_863_ == 4) then
        local a0, b, c, d = ...
        return (a0 / b / c / d)
      else
        local _ = case_863_
        local _let_864_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_864_.list
        local _let_865_ = list_38_auto(...)
        local a0 = _let_865_[1]
        local b = _let_865_[2]
        local c = _let_865_[3]
        local d = _let_865_[4]
        local rest = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_865_, 5)
        return apply(div0, (a0 / b / c / d), rest)
      end
    end
    v_27_auto = div0
    core["div"] = v_27_auto
    div = v_27_auto
  end
  local le
  do
    local v_27_auto
    local function le0(...)
      local case_867_ = select("#", ...)
      if (case_867_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "le"))
      elseif (case_867_ == 1) then
        local _ = ...
        return true
      elseif (case_867_ == 2) then
        local a0, b = ...
        return (a0 <= b)
      else
        local _ = case_867_
        local _let_868_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_868_.list
        local _let_869_ = list_38_auto(...)
        local a0 = _let_869_[1]
        local b = _let_869_[2]
        local _let_870_ = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_869_, 3)
        local c = _let_870_[1]
        local d = _let_870_[2]
        local more = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_870_, 3)
        if (a0 <= b) then
          if d then
            return apply(le0, b, c, d, more)
          else
            return (b <= c)
          end
        else
          return false
        end
      end
    end
    v_27_auto = le0
    core["le"] = v_27_auto
    le = v_27_auto
  end
  local lt
  do
    local v_27_auto
    local function lt0(...)
      local case_874_ = select("#", ...)
      if (case_874_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "lt"))
      elseif (case_874_ == 1) then
        local _ = ...
        return true
      elseif (case_874_ == 2) then
        local a0, b = ...
        return (a0 < b)
      else
        local _ = case_874_
        local _let_875_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_875_.list
        local _let_876_ = list_38_auto(...)
        local a0 = _let_876_[1]
        local b = _let_876_[2]
        local _let_877_ = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_876_, 3)
        local c = _let_877_[1]
        local d = _let_877_[2]
        local more = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_877_, 3)
        if (a0 < b) then
          if d then
            return apply(lt0, b, c, d, more)
          else
            return (b < c)
          end
        else
          return false
        end
      end
    end
    v_27_auto = lt0
    core["lt"] = v_27_auto
    lt = v_27_auto
  end
  local ge
  do
    local v_27_auto
    local function ge0(...)
      local case_881_ = select("#", ...)
      if (case_881_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "ge"))
      elseif (case_881_ == 1) then
        local _ = ...
        return true
      elseif (case_881_ == 2) then
        local a0, b = ...
        return (a0 >= b)
      else
        local _ = case_881_
        local _let_882_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_882_.list
        local _let_883_ = list_38_auto(...)
        local a0 = _let_883_[1]
        local b = _let_883_[2]
        local _let_884_ = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_883_, 3)
        local c = _let_884_[1]
        local d = _let_884_[2]
        local more = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_884_, 3)
        if (a0 >= b) then
          if d then
            return apply(ge0, b, c, d, more)
          else
            return (b >= c)
          end
        else
          return false
        end
      end
    end
    v_27_auto = ge0
    core["ge"] = v_27_auto
    ge = v_27_auto
  end
  local gt
  do
    local v_27_auto
    local function gt0(...)
      local case_888_ = select("#", ...)
      if (case_888_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "gt"))
      elseif (case_888_ == 1) then
        local _ = ...
        return true
      elseif (case_888_ == 2) then
        local a0, b = ...
        return (a0 > b)
      else
        local _ = case_888_
        local _let_889_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_889_.list
        local _let_890_ = list_38_auto(...)
        local a0 = _let_890_[1]
        local b = _let_890_[2]
        local _let_891_ = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_890_, 3)
        local c = _let_891_[1]
        local d = _let_891_[2]
        local more = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_891_, 3)
        if (a0 > b) then
          if d then
            return apply(gt0, b, c, d, more)
          else
            return (b > c)
          end
        else
          return false
        end
      end
    end
    v_27_auto = gt0
    core["gt"] = v_27_auto
    gt = v_27_auto
  end
  local inc
  do
    local v_27_auto
    local function inc0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "inc"))
        else
        end
      end
      return (x + 1)
    end
    v_27_auto = inc0
    core["inc"] = v_27_auto
    inc = v_27_auto
  end
  local dec
  do
    local v_27_auto
    local function dec0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "dec"))
        else
        end
      end
      return (x - 1)
    end
    v_27_auto = dec0
    core["dec"] = v_27_auto
    dec = v_27_auto
  end
  local class
  do
    local v_27_auto
    local function class0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "class"))
        else
        end
      end
      local case_898_ = type(x)
      if (case_898_ == "table") then
        local case_899_ = getmetatable(x)
        if ((_G.type(case_899_) == "table") and (nil ~= case_899_["cljlib/type"])) then
          local t = case_899_["cljlib/type"]
          return t
        else
          local _ = case_899_
          return "table"
        end
      elseif (nil ~= case_898_) then
        local t = case_898_
        return t
      else
        return nil
      end
    end
    v_27_auto = class0
    core["class"] = v_27_auto
    class = v_27_auto
  end
  local constantly
  do
    local v_27_auto
    local function constantly0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "constantly"))
        else
        end
      end
      local function _903_()
        return x
      end
      return _903_
    end
    v_27_auto = constantly0
    core["constantly"] = v_27_auto
    constantly = v_27_auto
  end
  local complement
  do
    local v_27_auto
    local function complement0(...)
      local f = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "complement"))
        else
        end
      end
      local function fn_905_(...)
        local case_906_ = select("#", ...)
        if (case_906_ == 0) then
          return not f()
        elseif (case_906_ == 1) then
          local a0 = ...
          return not f(a0)
        elseif (case_906_ == 2) then
          local a0, b = ...
          return not f(a0, b)
        else
          local _ = case_906_
          local _let_907_ = require("io.gitlab.andreyorst.cljlib.core")
          local list_38_auto = _let_907_.list
          local _let_908_ = list_38_auto(...)
          local a0 = _let_908_[1]
          local b = _let_908_[2]
          local cs = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_908_, 3)
          return not apply(f, a0, b, cs)
        end
      end
      return fn_905_
    end
    v_27_auto = complement0
    core["complement"] = v_27_auto
    complement = v_27_auto
  end
  local identity
  do
    local v_27_auto
    local function identity0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "identity"))
        else
        end
      end
      return x
    end
    v_27_auto = identity0
    core["identity"] = v_27_auto
    identity = v_27_auto
  end
  local comp
  do
    local v_27_auto
    local function comp0(...)
      local case_911_ = select("#", ...)
      if (case_911_ == 0) then
        return identity
      elseif (case_911_ == 1) then
        local f = ...
        return f
      elseif (case_911_ == 2) then
        local f, g = ...
        local function fn_912_(...)
          local case_913_ = select("#", ...)
          if (case_913_ == 0) then
            return f(g())
          elseif (case_913_ == 1) then
            local x = ...
            return f(g(x))
          elseif (case_913_ == 2) then
            local x, y = ...
            return f(g(x, y))
          elseif (case_913_ == 3) then
            local x, y, z = ...
            return f(g(x, y, z))
          else
            local _ = case_913_
            local _let_914_ = require("io.gitlab.andreyorst.cljlib.core")
            local list_38_auto = _let_914_.list
            local _let_915_ = list_38_auto(...)
            local x = _let_915_[1]
            local y = _let_915_[2]
            local z = _let_915_[3]
            local args = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_915_, 4)
            return f(apply(g, x, y, z, args))
          end
        end
        return fn_912_
      else
        local _ = case_911_
        local _let_917_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_917_.list
        local _let_918_ = list_38_auto(...)
        local f = _let_918_[1]
        local g = _let_918_[2]
        local fs = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_918_, 3)
        return core.reduce(comp0, core.cons(f, core.cons(g, fs)))
      end
    end
    v_27_auto = comp0
    core["comp"] = v_27_auto
    comp = v_27_auto
  end
  local eq
  do
    local v_27_auto
    local function eq0(...)
      local case_920_ = select("#", ...)
      if (case_920_ == 0) then
        return true
      elseif (case_920_ == 1) then
        local _ = ...
        return true
      elseif (case_920_ == 2) then
        local a0, b = ...
        if rawequal(a0, b) then
          return true
        elseif ((a0 == b) and (b == a0)) then
          return true
        else
          local _921_ = type(a0)
          if (("table" == _921_) and (_921_ == type(b))) then
            local res, count_a = true, 0
            for k, v in pairs_2a(a0) do
              if not res then break end
              local function _922_(...)
                local res0, done = nil, nil
                for k_2a, v0 in pairs_2a(b) do
                  if done then break end
                  if eq0(k_2a, k) then
                    res0, done = v0, true
                  else
                  end
                end
                return res0
              end
              res = eq0(v, _922_(...))
              count_a = (count_a + 1)
            end
            if res then
              local count_b
              do
                local res0 = 0
                for _, _0 in pairs_2a(b) do
                  res0 = (res0 + 1)
                end
                count_b = res0
              end
              res = (count_a == count_b)
            else
            end
            return res
          else
            return false
          end
        end
      else
        local _ = case_920_
        local _let_926_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_926_.list
        local _let_927_ = list_38_auto(...)
        local a0 = _let_927_[1]
        local b = _let_927_[2]
        local cs = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_927_, 3)
        return (eq0(a0, b) and apply(eq0, b, cs))
      end
    end
    v_27_auto = eq0
    core["eq"] = v_27_auto
    eq = v_27_auto
  end
  local function deep_index(tbl, key)
    local res = nil
    for k, v in pairs_2a(tbl) do
      if res then break end
      if eq(k, key) then
        res = v
      else
        res = nil
      end
    end
    return res
  end
  local function deep_newindex(tbl, key, val)
    local done = false
    if ("table" == type(key)) then
      for k, _ in pairs_2a(tbl) do
        if done then break end
        if eq(k, key) then
          rawset(tbl, k, val)
          done = true
        else
        end
      end
    else
    end
    if not done then
      return rawset(tbl, key, val)
    else
      return nil
    end
  end
  local memoize
  do
    local v_27_auto
    local function memoize0(...)
      local f = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "memoize"))
        else
        end
      end
      local memo = setmetatable({}, {__index = deep_index})
      local function fn_934_(...)
        local _let_935_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_935_.list
        local _let_936_ = list_38_auto(...)
        local args = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_936_, 1)
        local case_937_ = memo[args]
        if (nil ~= case_937_) then
          local res = case_937_
          return unpack_2a(res, 1, res.n)
        else
          local _ = case_937_
          local res = pack_2a(f(...))
          memo[args] = res
          return unpack_2a(res, 1, res.n)
        end
      end
      return fn_934_
    end
    v_27_auto = memoize0
    core["memoize"] = v_27_auto
    memoize = v_27_auto
  end
  local deref
  do
    local v_27_auto
    local function deref0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "deref"))
        else
        end
      end
      local case_940_ = getmetatable(x)
      if ((_G.type(case_940_) == "table") and (nil ~= case_940_["cljlib/deref"])) then
        local f = case_940_["cljlib/deref"]
        return f(x)
      else
        local _ = case_940_
        return error("object doesn't implement cljlib/deref metamethod", 2)
      end
    end
    v_27_auto = deref0
    core["deref"] = v_27_auto
    deref = v_27_auto
  end
  local empty
  do
    local v_27_auto
    local function empty0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "empty"))
        else
        end
      end
      local case_943_ = getmetatable(x)
      if ((_G.type(case_943_) == "table") and (nil ~= case_943_["cljlib/empty"])) then
        local f = case_943_["cljlib/empty"]
        return f()
      else
        local _ = case_943_
        local case_944_ = type(x)
        if (case_944_ == "table") then
          return {}
        elseif (case_944_ == "string") then
          return ""
        else
          local _0 = case_944_
          return error(("don't know how to create empty variant of type " .. _0))
        end
      end
    end
    v_27_auto = empty0
    core["empty"] = v_27_auto
    empty = v_27_auto
  end
  local nil_3f
  do
    local v_27_auto
    local function nil_3f0(...)
      local case_947_ = select("#", ...)
      if (case_947_ == 0) then
        return true
      elseif (case_947_ == 1) then
        local x = ...
        return (x == nil)
      else
        local _ = case_947_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "nil?"))
      end
    end
    v_27_auto = nil_3f0
    core["nil?"] = v_27_auto
    nil_3f = v_27_auto
  end
  local zero_3f
  do
    local v_27_auto
    local function zero_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "zero?"))
        else
        end
      end
      return (x == 0)
    end
    v_27_auto = zero_3f0
    core["zero?"] = v_27_auto
    zero_3f = v_27_auto
  end
  local pos_3f
  do
    local v_27_auto
    local function pos_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "pos?"))
        else
        end
      end
      return (x > 0)
    end
    v_27_auto = pos_3f0
    core["pos?"] = v_27_auto
    pos_3f = v_27_auto
  end
  local neg_3f
  do
    local v_27_auto
    local function neg_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "neg?"))
        else
        end
      end
      return (x < 0)
    end
    v_27_auto = neg_3f0
    core["neg?"] = v_27_auto
    neg_3f = v_27_auto
  end
  local even_3f
  do
    local v_27_auto
    local function even_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "even?"))
        else
        end
      end
      return ((x % 2) == 0)
    end
    v_27_auto = even_3f0
    core["even?"] = v_27_auto
    even_3f = v_27_auto
  end
  local odd_3f
  do
    local v_27_auto
    local function odd_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "odd?"))
        else
        end
      end
      return not even_3f(x)
    end
    v_27_auto = odd_3f0
    core["odd?"] = v_27_auto
    odd_3f = v_27_auto
  end
  local string_3f
  do
    local v_27_auto
    local function string_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "string?"))
        else
        end
      end
      return (type(x) == "string")
    end
    v_27_auto = string_3f0
    core["string?"] = v_27_auto
    string_3f = v_27_auto
  end
  local boolean_3f
  do
    local v_27_auto
    local function boolean_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "boolean?"))
        else
        end
      end
      return (type(x) == "boolean")
    end
    v_27_auto = boolean_3f0
    core["boolean?"] = v_27_auto
    boolean_3f = v_27_auto
  end
  local true_3f
  do
    local v_27_auto
    local function true_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "true?"))
        else
        end
      end
      return (x == true)
    end
    v_27_auto = true_3f0
    core["true?"] = v_27_auto
    true_3f = v_27_auto
  end
  local false_3f
  do
    local v_27_auto
    local function false_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "false?"))
        else
        end
      end
      return (x == false)
    end
    v_27_auto = false_3f0
    core["false?"] = v_27_auto
    false_3f = v_27_auto
  end
  local int_3f
  do
    local v_27_auto
    local function int_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "int?"))
        else
        end
      end
      return ((type(x) == "number") and (x == math.floor(x)))
    end
    v_27_auto = int_3f0
    core["int?"] = v_27_auto
    int_3f = v_27_auto
  end
  local pos_int_3f
  do
    local v_27_auto
    local function pos_int_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "pos-int?"))
        else
        end
      end
      return (int_3f(x) and pos_3f(x))
    end
    v_27_auto = pos_int_3f0
    core["pos-int?"] = v_27_auto
    pos_int_3f = v_27_auto
  end
  local neg_int_3f
  do
    local v_27_auto
    local function neg_int_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "neg-int?"))
        else
        end
      end
      return (int_3f(x) and neg_3f(x))
    end
    v_27_auto = neg_int_3f0
    core["neg-int?"] = v_27_auto
    neg_int_3f = v_27_auto
  end
  local double_3f
  do
    local v_27_auto
    local function double_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "double?"))
        else
        end
      end
      return ((type(x) == "number") and (x ~= math.floor(x)))
    end
    v_27_auto = double_3f0
    core["double?"] = v_27_auto
    double_3f = v_27_auto
  end
  local empty_3f
  do
    local v_27_auto
    local function empty_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "empty?"))
        else
        end
      end
      local case_963_ = type(x)
      if (case_963_ == "table") then
        local case_964_ = getmetatable(x)
        if ((_G.type(case_964_) == "table") and (case_964_["cljlib/type"] == "seq")) then
          return nil_3f(core.seq(x))
        elseif ((case_964_ == nil) or ((_G.type(case_964_) == "table") and (case_964_["cljlib/type"] == nil))) then
          local next_2a = pairs_2a(x)
          return (next_2a(x) == nil)
        else
          return nil
        end
      elseif (case_963_ == "string") then
        return (x == "")
      elseif (case_963_ == "nil") then
        return true
      else
        local _ = case_963_
        return error("empty?: unsupported collection")
      end
    end
    v_27_auto = empty_3f0
    core["empty?"] = v_27_auto
    empty_3f = v_27_auto
  end
  local not_empty
  do
    local v_27_auto
    local function not_empty0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "not-empty"))
        else
        end
      end
      if not empty_3f(x) then
        return x
      else
        return nil
      end
    end
    v_27_auto = not_empty0
    core["not-empty"] = v_27_auto
    not_empty = v_27_auto
  end
  local map_3f
  do
    local v_27_auto
    local function map_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "map?"))
        else
        end
      end
      if ("table" == type(x)) then
        local case_970_ = getmetatable(x)
        if ((_G.type(case_970_) == "table") and (case_970_["cljlib/type"] == "hash-map")) then
          return true
        elseif ((_G.type(case_970_) == "table") and (case_970_["cljlib/type"] == "sorted-map")) then
          return true
        elseif ((case_970_ == nil) or ((_G.type(case_970_) == "table") and (case_970_["cljlib/type"] == nil))) then
          local len = length_2a(x)
          local nxt, t, k = pairs_2a(x)
          local function _971_(...)
            if (len == 0) then
              return k
            else
              return len
            end
          end
          return (nil ~= nxt(t, _971_(...)))
        else
          local _ = case_970_
          return false
        end
      else
        return false
      end
    end
    v_27_auto = map_3f0
    core["map?"] = v_27_auto
    map_3f = v_27_auto
  end
  local vector_3f
  do
    local v_27_auto
    local function vector_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "vector?"))
        else
        end
      end
      if ("table" == type(x)) then
        local case_975_ = getmetatable(x)
        if ((_G.type(case_975_) == "table") and (case_975_["cljlib/type"] == "vector")) then
          return true
        elseif ((case_975_ == nil) or ((_G.type(case_975_) == "table") and (case_975_["cljlib/type"] == nil))) then
          local len = length_2a(x)
          local nxt, t, k = pairs_2a(x)
          local function _976_(...)
            if (len == 0) then
              return k
            else
              return len
            end
          end
          if (nil ~= nxt(t, _976_(...))) then
            return false
          elseif (len > 0) then
            return true
          else
            return false
          end
        else
          local _ = case_975_
          return false
        end
      else
        return false
      end
    end
    v_27_auto = vector_3f0
    core["vector?"] = v_27_auto
    vector_3f = v_27_auto
  end
  local set_3f
  do
    local v_27_auto
    local function set_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "set?"))
        else
        end
      end
      local case_981_ = getmetatable(x)
      if ((_G.type(case_981_) == "table") and (case_981_["cljlib/type"] == "hash-set")) then
        return true
      else
        local _ = case_981_
        return false
      end
    end
    v_27_auto = set_3f0
    core["set?"] = v_27_auto
    set_3f = v_27_auto
  end
  local seq_3f
  do
    local v_27_auto
    local function seq_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "seq?"))
        else
        end
      end
      return lazy["seq?"](x)
    end
    v_27_auto = seq_3f0
    core["seq?"] = v_27_auto
    seq_3f = v_27_auto
  end
  local some_3f
  do
    local v_27_auto
    local function some_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "some?"))
        else
        end
      end
      return (x ~= nil)
    end
    v_27_auto = some_3f0
    core["some?"] = v_27_auto
    some_3f = v_27_auto
  end
  local function vec__3etransient(immutable)
    local function _985_(vec)
      local len = #vec
      local function _986_(_, i)
        if (i <= len) then
          return vec[i]
        else
          return nil
        end
      end
      local function _988_()
        return len
      end
      local function _989_()
        return error("can't `conj` onto transient vector, use `conj!`")
      end
      local function _990_()
        return error("can't `assoc` onto transient vector, use `assoc!`")
      end
      local function _991_()
        return error("can't `dissoc` onto transient vector, use `dissoc!`")
      end
      local function _992_(tvec, v)
        len = (len + 1)
        tvec[len] = v
        return tvec
      end
      local function _993_(tvec, ...)
        do
          local len0 = #tvec
          for i = 1, select("#", ...), 2 do
            local k, v = select(i, ...)
            if ((1 <= i) and (i <= len0)) then
              tvec[i] = v
            else
              error(("index " .. i .. " is out of bounds"))
            end
          end
        end
        return tvec
      end
      local function _995_(tvec)
        if (len == 0) then
          return error("transient vector is empty", 2)
        else
          local val = table.remove(tvec)
          len = (len - 1)
          return tvec
        end
      end
      local function _997_()
        return error("can't `dissoc!` with a transient vector")
      end
      local function _998_(tvec)
        local v
        do
          local tbl_26_ = {}
          local i_27_ = 0
          for i = 1, len do
            local val_28_ = tvec[i]
            if (nil ~= val_28_) then
              i_27_ = (i_27_ + 1)
              tbl_26_[i_27_] = val_28_
            else
            end
          end
          v = tbl_26_
        end
        while (len > 0) do
          table.remove(tvec)
          len = (len - 1)
        end
        local function _1000_()
          return error("attempt to use transient after it was persistet")
        end
        local function _1001_()
          return error("attempt to use transient after it was persistet")
        end
        setmetatable(tvec, {__index = _1000_, __newindex = _1001_})
        return immutable(itable(v))
      end
      return setmetatable({}, {__index = _986_, __len = _988_, ["cljlib/type"] = "transient", ["cljlib/conj"] = _989_, ["cljlib/assoc"] = _990_, ["cljlib/dissoc"] = _991_, ["cljlib/conj!"] = _992_, ["cljlib/assoc!"] = _993_, ["cljlib/pop!"] = _995_, ["cljlib/dissoc!"] = _997_, ["cljlib/persistent!"] = _998_})
    end
    return _985_
  end
  local function vec_2a(v, len)
    do
      local case_1002_ = getmetatable(v)
      if (nil ~= case_1002_) then
        local mt = case_1002_
        mt["__len"] = constantly((len or length_2a(v)))
        mt["cljlib/type"] = "vector"
        mt["cljlib/editable"] = true
        local function _1003_(t, v0)
          local len0 = length_2a(t)
          return vec_2a(itable.assoc(t, (len0 + 1), v0), (len0 + 1))
        end
        mt["cljlib/conj"] = _1003_
        local function _1004_(t)
          local len0 = (length_2a(t) - 1)
          local coll = {}
          if (len0 < 0) then
            error("can't pop empty vector", 2)
          else
          end
          for i = 1, len0 do
            coll[i] = t[i]
          end
          return vec_2a(itable(coll), len0)
        end
        mt["cljlib/pop"] = _1004_
        local function _1006_()
          return vec_2a(itable({}))
        end
        mt["cljlib/empty"] = _1006_
        mt["cljlib/transient"] = vec__3etransient(vec_2a)
        local function _1007_(coll, view, inspector, indent)
          if empty_3f(coll) then
            return "[]"
          else
            local lines
            do
              local tbl_26_ = {}
              local i_27_ = 0
              for i = 1, length_2a(coll) do
                local val_28_ = (" " .. view(coll[i], inspector, indent))
                if (nil ~= val_28_) then
                  i_27_ = (i_27_ + 1)
                  tbl_26_[i_27_] = val_28_
                else
                end
              end
              lines = tbl_26_
            end
            lines[1] = ("[" .. string.gsub((lines[1] or ""), "^%s+", ""))
            lines[#lines] = (lines[#lines] .. "]")
            return lines
          end
        end
        mt["__fennelview"] = _1007_
      elseif (case_1002_ == nil) then
        vec_2a(setmetatable(v, {}))
      else
      end
    end
    return v
  end
  local vec
  do
    local v_27_auto
    local function vec0(...)
      local coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "vec"))
        else
        end
      end
      if empty_3f(coll) then
        return vec_2a(itable({}), 0)
      elseif vector_3f(coll) then
        return vec_2a(itable(coll), length_2a(coll))
      elseif "else" then
        local packed = lazy.pack(core.seq(coll))
        local len = packed.n
        local _1012_
        do
          packed["n"] = nil
          _1012_ = packed
        end
        return vec_2a(itable(_1012_, {["fast-index?"] = true}), len)
      else
        return nil
      end
    end
    v_27_auto = vec0
    core["vec"] = v_27_auto
    vec = v_27_auto
  end
  local vector
  do
    local v_27_auto
    local function vector0(...)
      local _let_1014_ = require("io.gitlab.andreyorst.cljlib.core")
      local list_38_auto = _let_1014_.list
      local _let_1015_ = list_38_auto(...)
      local args = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1015_, 1)
      return vec(args)
    end
    v_27_auto = vector0
    core["vector"] = v_27_auto
    vector = v_27_auto
  end
  local nth
  do
    local v_27_auto
    local function nth0(...)
      local case_1017_ = select("#", ...)
      if (case_1017_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "nth"))
      elseif (case_1017_ == 1) then
        return error(("Wrong number of args (%s) passed to %s"):format(1, "nth"))
      elseif (case_1017_ == 2) then
        local coll, i = ...
        if vector_3f(coll) then
          if ((i < 1) or (length_2a(coll) < i)) then
            return error(string.format("index %d is out of bounds", i))
          else
            return coll[i]
          end
        elseif string_3f(coll) then
          return nth0(vec(coll), i)
        elseif seq_3f(coll) then
          return nth0(vec(coll), i)
        elseif "else" then
          return error("expected an indexed collection")
        else
          return nil
        end
      elseif (case_1017_ == 3) then
        local coll, i, not_found = ...
        assert(int_3f(i), "expected an integer key")
        if vector_3f(coll) then
          return (coll[i] or not_found)
        elseif string_3f(coll) then
          return nth0(vec(coll), i, not_found)
        elseif seq_3f(coll) then
          return nth0(vec(coll), i, not_found)
        elseif "else" then
          return error("expected an indexed collection")
        else
          return nil
        end
      else
        local _ = case_1017_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "nth"))
      end
    end
    v_27_auto = nth0
    core["nth"] = v_27_auto
    nth = v_27_auto
  end
  local seq_2a
  local function seq_2a0(...)
    local x = ...
    do
      local cnt_54_auto = select("#", ...)
      if (1 ~= cnt_54_auto) then
        error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "seq*"))
      else
      end
    end
    do
      local case_1023_ = getmetatable(x)
      if (nil ~= case_1023_) then
        local mt = case_1023_
        mt["cljlib/type"] = "seq"
        local function _1024_(s, v)
          return core.cons(v, s)
        end
        mt["cljlib/conj"] = _1024_
        local function _1025_()
          return core.list()
        end
        mt["cljlib/empty"] = _1025_
      else
      end
    end
    return x
  end
  seq_2a = seq_2a0
  local seq
  do
    local v_27_auto
    local function seq0(...)
      local coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "seq"))
        else
        end
      end
      local function _1029_(...)
        local case_1028_ = getmetatable(coll)
        if ((_G.type(case_1028_) == "table") and (nil ~= case_1028_["cljlib/seq"])) then
          local f = case_1028_["cljlib/seq"]
          return f(coll)
        else
          local _ = case_1028_
          if lazy["seq?"](coll) then
            return lazy.seq(coll)
          elseif map_3f(coll) then
            return lazy.map(vec, coll)
          elseif "else" then
            return lazy.seq(coll)
          else
            return nil
          end
        end
      end
      return seq_2a(_1029_(...))
    end
    v_27_auto = seq0
    core["seq"] = v_27_auto
    seq = v_27_auto
  end
  local rseq
  do
    local v_27_auto
    local function rseq0(...)
      local rev = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "rseq"))
        else
        end
      end
      return seq_2a(lazy.rseq(rev))
    end
    v_27_auto = rseq0
    core["rseq"] = v_27_auto
    rseq = v_27_auto
  end
  local lazy_seq_2a
  do
    local v_27_auto
    local function lazy_seq_2a0(...)
      local f = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "lazy-seq*"))
        else
        end
      end
      return seq_2a(lazy["lazy-seq*"](f))
    end
    v_27_auto = lazy_seq_2a0
    core["lazy-seq*"] = v_27_auto
    lazy_seq_2a = v_27_auto
  end
  local first
  do
    local v_27_auto
    local function first0(...)
      local coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "first"))
        else
        end
      end
      return lazy.first(seq(coll))
    end
    v_27_auto = first0
    core["first"] = v_27_auto
    first = v_27_auto
  end
  local rest
  do
    local v_27_auto
    local function rest0(...)
      local coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "rest"))
        else
        end
      end
      return seq_2a(lazy.rest(seq(coll)))
    end
    v_27_auto = rest0
    core["rest"] = v_27_auto
    rest = v_27_auto
  end
  local next_2a
  local function next_2a0(...)
    local s = ...
    do
      local cnt_54_auto = select("#", ...)
      if (1 ~= cnt_54_auto) then
        error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "next*"))
      else
      end
    end
    return seq_2a(lazy.next(s))
  end
  next_2a = next_2a0
  do
    core["next"] = next_2a
  end
  local count
  do
    local v_27_auto
    local function count0(...)
      local s = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "count"))
        else
        end
      end
      local case_1038_ = getmetatable(s)
      if ((_G.type(case_1038_) == "table") and (case_1038_["cljlib/type"] == "vector")) then
        return length_2a(s)
      else
        local _ = case_1038_
        return lazy.count(s)
      end
    end
    v_27_auto = count0
    core["count"] = v_27_auto
    count = v_27_auto
  end
  local cons
  do
    local v_27_auto
    local function cons0(...)
      local head, tail = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "cons"))
        else
        end
      end
      return seq_2a(lazy.cons(head, tail))
    end
    v_27_auto = cons0
    core["cons"] = v_27_auto
    cons = v_27_auto
  end
  local function list(...)
    return seq_2a(lazy.list(...))
  end
  core.list = list
  local list_2a
  do
    local v_27_auto
    local function list_2a0(...)
      local _let_1041_ = require("io.gitlab.andreyorst.cljlib.core")
      local list_38_auto = _let_1041_.list
      local _let_1042_ = list_38_auto(...)
      local args = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1042_, 1)
      return seq_2a(apply(lazy["list*"], args))
    end
    v_27_auto = list_2a0
    core["list*"] = v_27_auto
    list_2a = v_27_auto
  end
  local last
  do
    local v_27_auto
    local function last0(...)
      local coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "last"))
        else
        end
      end
      local case_1044_ = next_2a(coll)
      if (nil ~= case_1044_) then
        local coll_2a = case_1044_
        return last0(coll_2a)
      else
        local _ = case_1044_
        return first(coll)
      end
    end
    v_27_auto = last0
    core["last"] = v_27_auto
    last = v_27_auto
  end
  local butlast
  do
    local v_27_auto
    local function butlast0(...)
      local coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "butlast"))
        else
        end
      end
      return seq(lazy["drop-last"](coll))
    end
    v_27_auto = butlast0
    core["butlast"] = v_27_auto
    butlast = v_27_auto
  end
  local map
  do
    local v_27_auto
    local function map0(...)
      local case_1047_ = select("#", ...)
      if (case_1047_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "map"))
      elseif (case_1047_ == 1) then
        local f = ...
        local function fn_1048_(...)
          local rf = ...
          do
            local cnt_54_auto = select("#", ...)
            if (1 ~= cnt_54_auto) then
              error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "fn_1048_"))
            else
            end
          end
          local function fn_1050_(...)
            local case_1051_ = select("#", ...)
            if (case_1051_ == 0) then
              return rf()
            elseif (case_1051_ == 1) then
              local result = ...
              return rf(result)
            elseif (case_1051_ == 2) then
              local result, input = ...
              return rf(result, f(input))
            else
              local _ = case_1051_
              local _let_1052_ = require("io.gitlab.andreyorst.cljlib.core")
              local list_38_auto = _let_1052_.list
              local _let_1053_ = list_38_auto(...)
              local result = _let_1053_[1]
              local input = _let_1053_[2]
              local inputs = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1053_, 3)
              return rf(result, apply(f, input, inputs))
            end
          end
          return fn_1050_
        end
        return fn_1048_
      elseif (case_1047_ == 2) then
        local f, coll = ...
        return seq_2a(lazy.map(f, coll))
      else
        local _ = case_1047_
        local _let_1055_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_1055_.list
        local _let_1056_ = list_38_auto(...)
        local f = _let_1056_[1]
        local coll = _let_1056_[2]
        local colls = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1056_, 3)
        return seq_2a(apply(lazy.map, f, coll, colls))
      end
    end
    v_27_auto = map0
    core["map"] = v_27_auto
    map = v_27_auto
  end
  local mapv
  do
    local v_27_auto
    local function mapv0(...)
      local case_1059_ = select("#", ...)
      if (case_1059_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "mapv"))
      elseif (case_1059_ == 1) then
        return error(("Wrong number of args (%s) passed to %s"):format(1, "mapv"))
      elseif (case_1059_ == 2) then
        local f, coll = ...
        return core["persistent!"](core.transduce(map(f), core["conj!"], core.transient(vector()), coll))
      else
        local _ = case_1059_
        local _let_1060_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_1060_.list
        local _let_1061_ = list_38_auto(...)
        local f = _let_1061_[1]
        local coll = _let_1061_[2]
        local colls = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1061_, 3)
        return vec(apply(map, f, coll, colls))
      end
    end
    v_27_auto = mapv0
    core["mapv"] = v_27_auto
    mapv = v_27_auto
  end
  local map_indexed
  do
    local v_27_auto
    local function map_indexed0(...)
      local case_1063_ = select("#", ...)
      if (case_1063_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "map-indexed"))
      elseif (case_1063_ == 1) then
        local f = ...
        local function fn_1064_(...)
          local rf = ...
          do
            local cnt_54_auto = select("#", ...)
            if (1 ~= cnt_54_auto) then
              error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "fn_1064_"))
            else
            end
          end
          local i = -1
          local function fn_1066_(...)
            local case_1067_ = select("#", ...)
            if (case_1067_ == 0) then
              return rf()
            elseif (case_1067_ == 1) then
              local result = ...
              return rf(result)
            elseif (case_1067_ == 2) then
              local result, input = ...
              i = (i + 1)
              return rf(result, f(i, input))
            else
              local _ = case_1067_
              return error(("Wrong number of args (%s) passed to %s"):format(_, "fn_1066_"))
            end
          end
          return fn_1066_
        end
        return fn_1064_
      elseif (case_1063_ == 2) then
        local f, coll = ...
        return seq_2a(lazy["map-indexed"](f, coll))
      else
        local _ = case_1063_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "map-indexed"))
      end
    end
    v_27_auto = map_indexed0
    core["map-indexed"] = v_27_auto
    map_indexed = v_27_auto
  end
  local mapcat
  do
    local v_27_auto
    local function mapcat0(...)
      local case_1070_ = select("#", ...)
      if (case_1070_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "mapcat"))
      elseif (case_1070_ == 1) then
        local f = ...
        return comp(map(f), core.cat)
      else
        local _ = case_1070_
        local _let_1071_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_1071_.list
        local _let_1072_ = list_38_auto(...)
        local f = _let_1072_[1]
        local colls = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1072_, 2)
        return seq_2a(apply(lazy.mapcat, f, colls))
      end
    end
    v_27_auto = mapcat0
    core["mapcat"] = v_27_auto
    mapcat = v_27_auto
  end
  local filter
  do
    local v_27_auto
    local function filter0(...)
      local case_1074_ = select("#", ...)
      if (case_1074_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "filter"))
      elseif (case_1074_ == 1) then
        local pred = ...
        local function fn_1075_(...)
          local rf = ...
          do
            local cnt_54_auto = select("#", ...)
            if (1 ~= cnt_54_auto) then
              error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "fn_1075_"))
            else
            end
          end
          local function fn_1077_(...)
            local case_1078_ = select("#", ...)
            if (case_1078_ == 0) then
              return rf()
            elseif (case_1078_ == 1) then
              local result = ...
              return rf(result)
            elseif (case_1078_ == 2) then
              local result, input = ...
              if pred(input) then
                return rf(result, input)
              else
                return result
              end
            else
              local _ = case_1078_
              return error(("Wrong number of args (%s) passed to %s"):format(_, "fn_1077_"))
            end
          end
          return fn_1077_
        end
        return fn_1075_
      elseif (case_1074_ == 2) then
        local pred, coll = ...
        return seq_2a(lazy.filter(pred, coll))
      else
        local _ = case_1074_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "filter"))
      end
    end
    v_27_auto = filter0
    core["filter"] = v_27_auto
    filter = v_27_auto
  end
  local filterv
  do
    local v_27_auto
    local function filterv0(...)
      local pred, coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "filterv"))
        else
        end
      end
      return vec(filter(pred, coll))
    end
    v_27_auto = filterv0
    core["filterv"] = v_27_auto
    filterv = v_27_auto
  end
  local every_3f
  do
    local v_27_auto
    local function every_3f0(...)
      local pred, coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "every?"))
        else
        end
      end
      return lazy["every?"](pred, coll)
    end
    v_27_auto = every_3f0
    core["every?"] = v_27_auto
    every_3f = v_27_auto
  end
  local some
  do
    local v_27_auto
    local function some0(...)
      local pred, coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "some"))
        else
        end
      end
      return lazy["some?"](pred, coll)
    end
    v_27_auto = some0
    core["some"] = v_27_auto
    some = v_27_auto
  end
  local not_any_3f
  do
    local v_27_auto
    local function not_any_3f0(...)
      local pred, coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "not-any?"))
        else
        end
      end
      local function _1086_(_241)
        return not pred(_241)
      end
      return some(_1086_, coll)
    end
    v_27_auto = not_any_3f0
    core["not-any?"] = v_27_auto
    not_any_3f = v_27_auto
  end
  local range
  do
    local v_27_auto
    local function range0(...)
      local case_1087_ = select("#", ...)
      if (case_1087_ == 0) then
        return seq_2a(lazy.range())
      elseif (case_1087_ == 1) then
        local upper = ...
        return seq_2a(lazy.range(upper))
      elseif (case_1087_ == 2) then
        local lower, upper = ...
        return seq_2a(lazy.range(lower, upper))
      elseif (case_1087_ == 3) then
        local lower, upper, step = ...
        return seq_2a(lazy.range(lower, upper, step))
      else
        local _ = case_1087_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "range"))
      end
    end
    v_27_auto = range0
    core["range"] = v_27_auto
    range = v_27_auto
  end
  local concat
  do
    local v_27_auto
    local function concat0(...)
      local _let_1089_ = require("io.gitlab.andreyorst.cljlib.core")
      local list_38_auto = _let_1089_.list
      local _let_1090_ = list_38_auto(...)
      local colls = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1090_, 1)
      return seq_2a(apply(lazy.concat, colls))
    end
    v_27_auto = concat0
    core["concat"] = v_27_auto
    concat = v_27_auto
  end
  local reverse
  do
    local v_27_auto
    local function reverse0(...)
      local coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "reverse"))
        else
        end
      end
      return seq_2a(lazy.reverse(coll))
    end
    v_27_auto = reverse0
    core["reverse"] = v_27_auto
    reverse = v_27_auto
  end
  local take
  do
    local v_27_auto
    local function take0(...)
      local case_1092_ = select("#", ...)
      if (case_1092_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "take"))
      elseif (case_1092_ == 1) then
        local n = ...
        local function fn_1093_(...)
          local rf = ...
          do
            local cnt_54_auto = select("#", ...)
            if (1 ~= cnt_54_auto) then
              error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "fn_1093_"))
            else
            end
          end
          local n0 = n
          local function fn_1095_(...)
            local case_1096_ = select("#", ...)
            if (case_1096_ == 0) then
              return rf()
            elseif (case_1096_ == 1) then
              local result = ...
              return rf(result)
            elseif (case_1096_ == 2) then
              local result, input = ...
              local result0
              if (0 < n0) then
                result0 = rf(result, input)
              else
                result0 = result
              end
              n0 = (n0 - 1)
              if not (0 < n0) then
                return core["ensure-reduced"](result0)
              else
                return result0
              end
            else
              local _ = case_1096_
              return error(("Wrong number of args (%s) passed to %s"):format(_, "fn_1095_"))
            end
          end
          return fn_1095_
        end
        return fn_1093_
      elseif (case_1092_ == 2) then
        local n, coll = ...
        return seq_2a(lazy.take(n, coll))
      else
        local _ = case_1092_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "take"))
      end
    end
    v_27_auto = take0
    core["take"] = v_27_auto
    take = v_27_auto
  end
  local take_while
  do
    local v_27_auto
    local function take_while0(...)
      local case_1101_ = select("#", ...)
      if (case_1101_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "take-while"))
      elseif (case_1101_ == 1) then
        local pred = ...
        local function fn_1102_(...)
          local rf = ...
          do
            local cnt_54_auto = select("#", ...)
            if (1 ~= cnt_54_auto) then
              error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "fn_1102_"))
            else
            end
          end
          local function fn_1104_(...)
            local case_1105_ = select("#", ...)
            if (case_1105_ == 0) then
              return rf()
            elseif (case_1105_ == 1) then
              local result = ...
              return rf(result)
            elseif (case_1105_ == 2) then
              local result, input = ...
              if pred(input) then
                return rf(result, input)
              else
                return core.reduced(result)
              end
            else
              local _ = case_1105_
              return error(("Wrong number of args (%s) passed to %s"):format(_, "fn_1104_"))
            end
          end
          return fn_1104_
        end
        return fn_1102_
      elseif (case_1101_ == 2) then
        local pred, coll = ...
        return seq_2a(lazy["take-while"](pred, coll))
      else
        local _ = case_1101_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "take-while"))
      end
    end
    v_27_auto = take_while0
    core["take-while"] = v_27_auto
    take_while = v_27_auto
  end
  local drop
  do
    local v_27_auto
    local function drop0(...)
      local case_1109_ = select("#", ...)
      if (case_1109_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "drop"))
      elseif (case_1109_ == 1) then
        local n = ...
        local function fn_1110_(...)
          local rf = ...
          do
            local cnt_54_auto = select("#", ...)
            if (1 ~= cnt_54_auto) then
              error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "fn_1110_"))
            else
            end
          end
          local nv = n
          local function fn_1112_(...)
            local case_1113_ = select("#", ...)
            if (case_1113_ == 0) then
              return rf()
            elseif (case_1113_ == 1) then
              local result = ...
              return rf(result)
            elseif (case_1113_ == 2) then
              local result, input = ...
              local n0 = nv
              nv = (nv - 1)
              if pos_3f(n0) then
                return result
              else
                return rf(result, input)
              end
            else
              local _ = case_1113_
              return error(("Wrong number of args (%s) passed to %s"):format(_, "fn_1112_"))
            end
          end
          return fn_1112_
        end
        return fn_1110_
      elseif (case_1109_ == 2) then
        local n, coll = ...
        return seq_2a(lazy.drop(n, coll))
      else
        local _ = case_1109_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "drop"))
      end
    end
    v_27_auto = drop0
    core["drop"] = v_27_auto
    drop = v_27_auto
  end
  local drop_while
  do
    local v_27_auto
    local function drop_while0(...)
      local case_1117_ = select("#", ...)
      if (case_1117_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "drop-while"))
      elseif (case_1117_ == 1) then
        local pred = ...
        local function fn_1118_(...)
          local rf = ...
          do
            local cnt_54_auto = select("#", ...)
            if (1 ~= cnt_54_auto) then
              error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "fn_1118_"))
            else
            end
          end
          local dv = true
          local function fn_1120_(...)
            local case_1121_ = select("#", ...)
            if (case_1121_ == 0) then
              return rf()
            elseif (case_1121_ == 1) then
              local result = ...
              return rf(result)
            elseif (case_1121_ == 2) then
              local result, input = ...
              local drop_3f = dv
              if (drop_3f and pred(input)) then
                return result
              else
                dv = nil
                return rf(result, input)
              end
            else
              local _ = case_1121_
              return error(("Wrong number of args (%s) passed to %s"):format(_, "fn_1120_"))
            end
          end
          return fn_1120_
        end
        return fn_1118_
      elseif (case_1117_ == 2) then
        local pred, coll = ...
        return seq_2a(lazy["drop-while"](pred, coll))
      else
        local _ = case_1117_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "drop-while"))
      end
    end
    v_27_auto = drop_while0
    core["drop-while"] = v_27_auto
    drop_while = v_27_auto
  end
  local drop_last
  do
    local v_27_auto
    local function drop_last0(...)
      local case_1125_ = select("#", ...)
      if (case_1125_ == 0) then
        return seq_2a(lazy["drop-last"]())
      elseif (case_1125_ == 1) then
        local coll = ...
        return seq_2a(lazy["drop-last"](coll))
      elseif (case_1125_ == 2) then
        local n, coll = ...
        return seq_2a(lazy["drop-last"](n, coll))
      else
        local _ = case_1125_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "drop-last"))
      end
    end
    v_27_auto = drop_last0
    core["drop-last"] = v_27_auto
    drop_last = v_27_auto
  end
  local take_last
  do
    local v_27_auto
    local function take_last0(...)
      local n, coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "take-last"))
        else
        end
      end
      return seq_2a(lazy["take-last"](n, coll))
    end
    v_27_auto = take_last0
    core["take-last"] = v_27_auto
    take_last = v_27_auto
  end
  local take_nth
  do
    local v_27_auto
    local function take_nth0(...)
      local case_1128_ = select("#", ...)
      if (case_1128_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "take-nth"))
      elseif (case_1128_ == 1) then
        local n = ...
        local function fn_1129_(...)
          local rf = ...
          do
            local cnt_54_auto = select("#", ...)
            if (1 ~= cnt_54_auto) then
              error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "fn_1129_"))
            else
            end
          end
          local iv = -1
          local function fn_1131_(...)
            local case_1132_ = select("#", ...)
            if (case_1132_ == 0) then
              return rf()
            elseif (case_1132_ == 1) then
              local result = ...
              return rf(result)
            elseif (case_1132_ == 2) then
              local result, input = ...
              iv = (iv + 1)
              if (0 == (iv % n)) then
                return rf(result, input)
              else
                return result
              end
            else
              local _ = case_1132_
              return error(("Wrong number of args (%s) passed to %s"):format(_, "fn_1131_"))
            end
          end
          return fn_1131_
        end
        return fn_1129_
      elseif (case_1128_ == 2) then
        local n, coll = ...
        return seq_2a(lazy["take-nth"](n, coll))
      else
        local _ = case_1128_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "take-nth"))
      end
    end
    v_27_auto = take_nth0
    core["take-nth"] = v_27_auto
    take_nth = v_27_auto
  end
  local split_at
  do
    local v_27_auto
    local function split_at0(...)
      local n, coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "split-at"))
        else
        end
      end
      return vec(lazy["split-at"](n, coll))
    end
    v_27_auto = split_at0
    core["split-at"] = v_27_auto
    split_at = v_27_auto
  end
  local split_with
  do
    local v_27_auto
    local function split_with0(...)
      local pred, coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "split-with"))
        else
        end
      end
      return vec(lazy["split-with"](pred, coll))
    end
    v_27_auto = split_with0
    core["split-with"] = v_27_auto
    split_with = v_27_auto
  end
  local nthrest
  do
    local v_27_auto
    local function nthrest0(...)
      local coll, n = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "nthrest"))
        else
        end
      end
      return seq_2a(lazy.nthrest(coll, n))
    end
    v_27_auto = nthrest0
    core["nthrest"] = v_27_auto
    nthrest = v_27_auto
  end
  local nthnext
  do
    local v_27_auto
    local function nthnext0(...)
      local coll, n = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "nthnext"))
        else
        end
      end
      return lazy.nthnext(coll, n)
    end
    v_27_auto = nthnext0
    core["nthnext"] = v_27_auto
    nthnext = v_27_auto
  end
  local keep
  do
    local v_27_auto
    local function keep0(...)
      local case_1140_ = select("#", ...)
      if (case_1140_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "keep"))
      elseif (case_1140_ == 1) then
        local f = ...
        local function fn_1141_(...)
          local rf = ...
          do
            local cnt_54_auto = select("#", ...)
            if (1 ~= cnt_54_auto) then
              error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "fn_1141_"))
            else
            end
          end
          local function fn_1143_(...)
            local case_1144_ = select("#", ...)
            if (case_1144_ == 0) then
              return rf()
            elseif (case_1144_ == 1) then
              local result = ...
              return rf(result)
            elseif (case_1144_ == 2) then
              local result, input = ...
              local v = f(input)
              if nil_3f(v) then
                return result
              else
                return rf(result, v)
              end
            else
              local _ = case_1144_
              return error(("Wrong number of args (%s) passed to %s"):format(_, "fn_1143_"))
            end
          end
          return fn_1143_
        end
        return fn_1141_
      elseif (case_1140_ == 2) then
        local f, coll = ...
        return seq_2a(lazy.keep(f, coll))
      else
        local _ = case_1140_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "keep"))
      end
    end
    v_27_auto = keep0
    core["keep"] = v_27_auto
    keep = v_27_auto
  end
  local keep_indexed
  do
    local v_27_auto
    local function keep_indexed0(...)
      local case_1148_ = select("#", ...)
      if (case_1148_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "keep-indexed"))
      elseif (case_1148_ == 1) then
        local f = ...
        local function fn_1149_(...)
          local rf = ...
          do
            local cnt_54_auto = select("#", ...)
            if (1 ~= cnt_54_auto) then
              error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "fn_1149_"))
            else
            end
          end
          local iv = -1
          local function fn_1151_(...)
            local case_1152_ = select("#", ...)
            if (case_1152_ == 0) then
              return rf()
            elseif (case_1152_ == 1) then
              local result = ...
              return rf(result)
            elseif (case_1152_ == 2) then
              local result, input = ...
              iv = (iv + 1)
              local v = f(iv, input)
              if nil_3f(v) then
                return result
              else
                return rf(result, v)
              end
            else
              local _ = case_1152_
              return error(("Wrong number of args (%s) passed to %s"):format(_, "fn_1151_"))
            end
          end
          return fn_1151_
        end
        return fn_1149_
      elseif (case_1148_ == 2) then
        local f, coll = ...
        return seq_2a(lazy["keep-indexed"](f, coll))
      else
        local _ = case_1148_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "keep-indexed"))
      end
    end
    v_27_auto = keep_indexed0
    core["keep-indexed"] = v_27_auto
    keep_indexed = v_27_auto
  end
  local partition
  do
    local v_27_auto
    local function partition0(...)
      local case_1157_ = select("#", ...)
      if (case_1157_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "partition"))
      elseif (case_1157_ == 1) then
        return error(("Wrong number of args (%s) passed to %s"):format(1, "partition"))
      elseif (case_1157_ == 2) then
        local n, coll = ...
        return map(seq_2a, lazy.partition(n, coll))
      elseif (case_1157_ == 3) then
        local n, step, coll = ...
        return map(seq_2a, lazy.partition(n, step, coll))
      elseif (case_1157_ == 4) then
        local n, step, pad, coll = ...
        return map(seq_2a, lazy.partition(n, step, pad, coll))
      else
        local _ = case_1157_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "partition"))
      end
    end
    v_27_auto = partition0
    core["partition"] = v_27_auto
    partition = v_27_auto
  end
  local function array()
    local len = 0
    local function _1159_()
      return len
    end
    local function _1160_(self)
      while (0 ~= len) do
        self[len] = nil
        len = (len - 1)
      end
      return nil
    end
    local function _1161_(self, val)
      len = (len + 1)
      self[len] = val
      return self
    end
    return setmetatable({}, {__len = _1159_, __index = {clear = _1160_, add = _1161_}})
  end
  local partition_by
  do
    local v_27_auto
    local function partition_by0(...)
      local case_1162_ = select("#", ...)
      if (case_1162_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "partition-by"))
      elseif (case_1162_ == 1) then
        local f = ...
        local function fn_1163_(...)
          local rf = ...
          do
            local cnt_54_auto = select("#", ...)
            if (1 ~= cnt_54_auto) then
              error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "fn_1163_"))
            else
            end
          end
          local a0 = array()
          local none = {}
          local pv = none
          local function fn_1165_(...)
            local case_1166_ = select("#", ...)
            if (case_1166_ == 0) then
              return rf()
            elseif (case_1166_ == 1) then
              local result = ...
              local function _1167_(...)
                if empty_3f(a0) then
                  return result
                else
                  local v = vec(a0)
                  a0:clear()
                  return core.unreduced(rf(result, v))
                end
              end
              return rf(_1167_(...))
            elseif (case_1166_ == 2) then
              local result, input = ...
              local pval = pv
              local val = f(input)
              pv = val
              if ((pval == none) or (val == pval)) then
                a0:add(input)
                return result
              else
                local v = vec(a0)
                a0:clear()
                local ret = rf(result, v)
                if not core["reduced?"](ret) then
                  a0:add(input)
                else
                end
                return ret
              end
            else
              local _ = case_1166_
              return error(("Wrong number of args (%s) passed to %s"):format(_, "fn_1165_"))
            end
          end
          return fn_1165_
        end
        return fn_1163_
      elseif (case_1162_ == 2) then
        local f, coll = ...
        return map(seq_2a, lazy["partition-by"](f, coll))
      else
        local _ = case_1162_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "partition-by"))
      end
    end
    v_27_auto = partition_by0
    core["partition-by"] = v_27_auto
    partition_by = v_27_auto
  end
  local partition_all
  do
    local v_27_auto
    local function partition_all0(...)
      local case_1172_ = select("#", ...)
      if (case_1172_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "partition-all"))
      elseif (case_1172_ == 1) then
        local n = ...
        local function fn_1173_(...)
          local rf = ...
          do
            local cnt_54_auto = select("#", ...)
            if (1 ~= cnt_54_auto) then
              error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "fn_1173_"))
            else
            end
          end
          local a0 = array()
          local function fn_1175_(...)
            local case_1176_ = select("#", ...)
            if (case_1176_ == 0) then
              return rf()
            elseif (case_1176_ == 1) then
              local result = ...
              local function _1177_(...)
                if (0 == #a0) then
                  return result
                else
                  local v = vec(a0)
                  a0:clear()
                  return core.unreduced(rf(result, v))
                end
              end
              return rf(_1177_(...))
            elseif (case_1176_ == 2) then
              local result, input = ...
              a0:add(input)
              if (n == #a0) then
                local v = vec(a0)
                a0:clear()
                return rf(result, v)
              else
                return result
              end
            else
              local _ = case_1176_
              return error(("Wrong number of args (%s) passed to %s"):format(_, "fn_1175_"))
            end
          end
          return fn_1175_
        end
        return fn_1173_
      elseif (case_1172_ == 2) then
        local n, coll = ...
        return map(seq_2a, lazy["partition-all"](n, coll))
      elseif (case_1172_ == 3) then
        local n, step, coll = ...
        return map(seq_2a, lazy["partition-all"](n, step, coll))
      else
        local _ = case_1172_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "partition-all"))
      end
    end
    v_27_auto = partition_all0
    core["partition-all"] = v_27_auto
    partition_all = v_27_auto
  end
  local reductions
  do
    local v_27_auto
    local function reductions0(...)
      local case_1182_ = select("#", ...)
      if (case_1182_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "reductions"))
      elseif (case_1182_ == 1) then
        return error(("Wrong number of args (%s) passed to %s"):format(1, "reductions"))
      elseif (case_1182_ == 2) then
        local f, coll = ...
        return seq_2a(lazy.reductions(f, coll))
      elseif (case_1182_ == 3) then
        local f, init, coll = ...
        return seq_2a(lazy.reductions(f, init, coll))
      else
        local _ = case_1182_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "reductions"))
      end
    end
    v_27_auto = reductions0
    core["reductions"] = v_27_auto
    reductions = v_27_auto
  end
  local contains_3f
  do
    local v_27_auto
    local function contains_3f0(...)
      local coll, elt = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "contains?"))
        else
        end
      end
      return lazy["contains?"](coll, elt)
    end
    v_27_auto = contains_3f0
    core["contains?"] = v_27_auto
    contains_3f = v_27_auto
  end
  local distinct
  do
    local v_27_auto
    local function distinct0(...)
      local case_1185_ = select("#", ...)
      if (case_1185_ == 0) then
        local function fn_1186_(...)
          local rf = ...
          do
            local cnt_54_auto = select("#", ...)
            if (1 ~= cnt_54_auto) then
              error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "fn_1186_"))
            else
            end
          end
          local seen = setmetatable({}, {__index = deep_index})
          local function fn_1188_(...)
            local case_1189_ = select("#", ...)
            if (case_1189_ == 0) then
              return rf()
            elseif (case_1189_ == 1) then
              local result = ...
              return rf(result)
            elseif (case_1189_ == 2) then
              local result, input = ...
              if seen[input] then
                return result
              else
                seen[input] = true
                return rf(result, input)
              end
            else
              local _ = case_1189_
              return error(("Wrong number of args (%s) passed to %s"):format(_, "fn_1188_"))
            end
          end
          return fn_1188_
        end
        return fn_1186_
      elseif (case_1185_ == 1) then
        local coll = ...
        return seq_2a(lazy.distinct(coll))
      else
        local _ = case_1185_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "distinct"))
      end
    end
    v_27_auto = distinct0
    core["distinct"] = v_27_auto
    distinct = v_27_auto
  end
  local dedupe
  do
    local v_27_auto
    local function dedupe0(...)
      local case_1193_ = select("#", ...)
      if (case_1193_ == 0) then
        local function fn_1194_(...)
          local rf = ...
          do
            local cnt_54_auto = select("#", ...)
            if (1 ~= cnt_54_auto) then
              error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "fn_1194_"))
            else
            end
          end
          local none = {}
          local pv = none
          local function fn_1196_(...)
            local case_1197_ = select("#", ...)
            if (case_1197_ == 0) then
              return rf()
            elseif (case_1197_ == 1) then
              local result = ...
              return rf(result)
            elseif (case_1197_ == 2) then
              local result, input = ...
              local prior = pv
              pv = input
              if (prior == input) then
                return result
              else
                return rf(result, input)
              end
            else
              local _ = case_1197_
              return error(("Wrong number of args (%s) passed to %s"):format(_, "fn_1196_"))
            end
          end
          return fn_1196_
        end
        return fn_1194_
      elseif (case_1193_ == 1) then
        local coll = ...
        return core.sequence(dedupe0(), coll)
      else
        local _ = case_1193_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "dedupe"))
      end
    end
    v_27_auto = dedupe0
    core["dedupe"] = v_27_auto
    dedupe = v_27_auto
  end
  local random_sample
  do
    local v_27_auto
    local function random_sample0(...)
      local case_1201_ = select("#", ...)
      if (case_1201_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "random-sample"))
      elseif (case_1201_ == 1) then
        local prob = ...
        local function _1202_()
          return (math.random() < prob)
        end
        return filter(_1202_)
      elseif (case_1201_ == 2) then
        local prob, coll = ...
        local function _1203_()
          return (math.random() < prob)
        end
        return filter(_1203_, coll)
      else
        local _ = case_1201_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "random-sample"))
      end
    end
    v_27_auto = random_sample0
    core["random-sample"] = v_27_auto
    random_sample = v_27_auto
  end
  local doall
  do
    local v_27_auto
    local function doall0(...)
      local seq0 = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "doall"))
        else
        end
      end
      return seq_2a(lazy.doall(seq0))
    end
    v_27_auto = doall0
    core["doall"] = v_27_auto
    doall = v_27_auto
  end
  local dorun
  do
    local v_27_auto
    local function dorun0(...)
      local seq0 = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "dorun"))
        else
        end
      end
      return lazy.dorun(seq0)
    end
    v_27_auto = dorun0
    core["dorun"] = v_27_auto
    dorun = v_27_auto
  end
  local line_seq
  do
    local v_27_auto
    local function line_seq0(...)
      local file = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "line-seq"))
        else
        end
      end
      return seq_2a(lazy["line-seq"](file))
    end
    v_27_auto = line_seq0
    core["line-seq"] = v_27_auto
    line_seq = v_27_auto
  end
  local iterate
  do
    local v_27_auto
    local function iterate0(...)
      local f, x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "iterate"))
        else
        end
      end
      return seq_2a(lazy.iterate(f, x))
    end
    v_27_auto = iterate0
    core["iterate"] = v_27_auto
    iterate = v_27_auto
  end
  local remove
  do
    local v_27_auto
    local function remove0(...)
      local case_1209_ = select("#", ...)
      if (case_1209_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "remove"))
      elseif (case_1209_ == 1) then
        local pred = ...
        return filter(complement(pred))
      elseif (case_1209_ == 2) then
        local pred, coll = ...
        return seq_2a(lazy.remove(pred, coll))
      else
        local _ = case_1209_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "remove"))
      end
    end
    v_27_auto = remove0
    core["remove"] = v_27_auto
    remove = v_27_auto
  end
  local cycle
  do
    local v_27_auto
    local function cycle0(...)
      local coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "cycle"))
        else
        end
      end
      return seq_2a(lazy.cycle(coll))
    end
    v_27_auto = cycle0
    core["cycle"] = v_27_auto
    cycle = v_27_auto
  end
  local _repeat
  do
    local v_27_auto
    local function _repeat0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "repeat"))
        else
        end
      end
      return seq_2a(lazy["repeat"](x))
    end
    v_27_auto = _repeat0
    core["repeat"] = v_27_auto
    _repeat = v_27_auto
  end
  local repeatedly
  do
    local v_27_auto
    local function repeatedly0(...)
      local _let_1213_ = require("io.gitlab.andreyorst.cljlib.core")
      local list_38_auto = _let_1213_.list
      local _let_1214_ = list_38_auto(...)
      local f = _let_1214_[1]
      local args = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1214_, 2)
      return seq_2a(apply(lazy.repeatedly, f, args))
    end
    v_27_auto = repeatedly0
    core["repeatedly"] = v_27_auto
    repeatedly = v_27_auto
  end
  local tree_seq
  do
    local v_27_auto
    local function tree_seq0(...)
      local branch_3f, children, root = ...
      do
        local cnt_54_auto = select("#", ...)
        if (3 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "tree-seq"))
        else
        end
      end
      return seq_2a(lazy["tree-seq"](branch_3f, children, root))
    end
    v_27_auto = tree_seq0
    core["tree-seq"] = v_27_auto
    tree_seq = v_27_auto
  end
  local interleave
  do
    local v_27_auto
    local function interleave0(...)
      local case_1216_ = select("#", ...)
      if (case_1216_ == 0) then
        return seq_2a(lazy.interleave())
      elseif (case_1216_ == 1) then
        local s = ...
        return seq_2a(lazy.interleave(s))
      elseif (case_1216_ == 2) then
        local s1, s2 = ...
        return seq_2a(lazy.interleave(s1, s2))
      else
        local _ = case_1216_
        local _let_1217_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_1217_.list
        local _let_1218_ = list_38_auto(...)
        local s1 = _let_1218_[1]
        local s2 = _let_1218_[2]
        local ss = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1218_, 3)
        return seq_2a(apply(lazy.interleave, s1, s2, ss))
      end
    end
    v_27_auto = interleave0
    core["interleave"] = v_27_auto
    interleave = v_27_auto
  end
  local interpose
  do
    local v_27_auto
    local function interpose0(...)
      local case_1220_ = select("#", ...)
      if (case_1220_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "interpose"))
      elseif (case_1220_ == 1) then
        local sep = ...
        local function fn_1221_(...)
          local rf = ...
          do
            local cnt_54_auto = select("#", ...)
            if (1 ~= cnt_54_auto) then
              error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "fn_1221_"))
            else
            end
          end
          local started = false
          local function fn_1223_(...)
            local case_1224_ = select("#", ...)
            if (case_1224_ == 0) then
              return rf()
            elseif (case_1224_ == 1) then
              local result = ...
              return rf(result)
            elseif (case_1224_ == 2) then
              local result, input = ...
              if started then
                local sepr = rf(result, sep)
                if core["reduced?"](sepr) then
                  return sepr
                else
                  return rf(sepr, input)
                end
              else
                started = true
                return rf(result, input)
              end
            else
              local _ = case_1224_
              return error(("Wrong number of args (%s) passed to %s"):format(_, "fn_1223_"))
            end
          end
          return fn_1223_
        end
        return fn_1221_
      elseif (case_1220_ == 2) then
        local separator, coll = ...
        return seq_2a(lazy.interpose(separator, coll))
      else
        local _ = case_1220_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "interpose"))
      end
    end
    v_27_auto = interpose0
    core["interpose"] = v_27_auto
    interpose = v_27_auto
  end
  local halt_when
  do
    local v_27_auto
    local function halt_when0(...)
      local case_1229_ = select("#", ...)
      if (case_1229_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "halt-when"))
      elseif (case_1229_ == 1) then
        local pred = ...
        return halt_when0(pred, nil)
      elseif (case_1229_ == 2) then
        local pred, retf = ...
        local function fn_1230_(...)
          local rf = ...
          do
            local cnt_54_auto = select("#", ...)
            if (1 ~= cnt_54_auto) then
              error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "fn_1230_"))
            else
            end
          end
          local halt
          local function _1232_()
            return "#<halt>"
          end
          halt = setmetatable({}, {__fennelview = _1232_})
          local function fn_1233_(...)
            local case_1234_ = select("#", ...)
            if (case_1234_ == 0) then
              return rf()
            elseif (case_1234_ == 1) then
              local result = ...
              if (map_3f(result) and contains_3f(result, halt)) then
                return result.value
              else
                return rf(result)
              end
            elseif (case_1234_ == 2) then
              local result, input = ...
              if pred(input) then
                local _1236_
                if retf then
                  _1236_ = retf(rf(result), input)
                else
                  _1236_ = input
                end
                return core.reduced({[halt] = true, value = _1236_})
              else
                return rf(result, input)
              end
            else
              local _ = case_1234_
              return error(("Wrong number of args (%s) passed to %s"):format(_, "fn_1233_"))
            end
          end
          return fn_1233_
        end
        return fn_1230_
      else
        local _ = case_1229_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "halt-when"))
      end
    end
    v_27_auto = halt_when0
    core["halt-when"] = v_27_auto
    halt_when = v_27_auto
  end
  local realized_3f
  do
    local v_27_auto
    local function realized_3f0(...)
      local s = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "realized?"))
        else
        end
      end
      return lazy["realized?"](s)
    end
    v_27_auto = realized_3f0
    core["realized?"] = v_27_auto
    realized_3f = v_27_auto
  end
  local keys
  do
    local v_27_auto
    local function keys0(...)
      local coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "keys"))
        else
        end
      end
      assert((map_3f(coll) or empty_3f(coll)), "expected a map")
      if empty_3f(coll) then
        return lazy.list()
      else
        return lazy.keys(coll)
      end
    end
    v_27_auto = keys0
    core["keys"] = v_27_auto
    keys = v_27_auto
  end
  local vals
  do
    local v_27_auto
    local function vals0(...)
      local coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "vals"))
        else
        end
      end
      assert((map_3f(coll) or empty_3f(coll)), "expected a map")
      if empty_3f(coll) then
        return lazy.list()
      else
        return lazy.vals(coll)
      end
    end
    v_27_auto = vals0
    core["vals"] = v_27_auto
    vals = v_27_auto
  end
  local find
  do
    local v_27_auto
    local function find0(...)
      local coll, key = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "find"))
        else
        end
      end
      assert((map_3f(coll) or empty_3f(coll)), "expected a map")
      local case_1247_ = coll[key]
      if (nil ~= case_1247_) then
        local v = case_1247_
        return {key, v}
      else
        return nil
      end
    end
    v_27_auto = find0
    core["find"] = v_27_auto
    find = v_27_auto
  end
  local sort
  do
    local v_27_auto
    local function sort0(...)
      local case_1249_ = select("#", ...)
      if (case_1249_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "sort"))
      elseif (case_1249_ == 1) then
        local coll = ...
        local case_1250_ = seq(coll)
        if (nil ~= case_1250_) then
          local s = case_1250_
          return seq(itable.sort(vec(s)))
        else
          local _ = case_1250_
          return list()
        end
      elseif (case_1249_ == 2) then
        local comparator, coll = ...
        local case_1252_ = seq(coll)
        if (nil ~= case_1252_) then
          local s = case_1252_
          return seq(itable.sort(vec(s), comparator))
        else
          local _ = case_1252_
          return list()
        end
      else
        local _ = case_1249_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "sort"))
      end
    end
    v_27_auto = sort0
    core["sort"] = v_27_auto
    sort = v_27_auto
  end
  local reduce
  do
    local v_27_auto
    local function reduce0(...)
      local case_1256_ = select("#", ...)
      if (case_1256_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "reduce"))
      elseif (case_1256_ == 1) then
        return error(("Wrong number of args (%s) passed to %s"):format(1, "reduce"))
      elseif (case_1256_ == 2) then
        local f, coll = ...
        return lazy.reduce(f, seq(coll))
      elseif (case_1256_ == 3) then
        local f, val, coll = ...
        return lazy.reduce(f, val, seq(coll))
      else
        local _ = case_1256_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "reduce"))
      end
    end
    v_27_auto = reduce0
    core["reduce"] = v_27_auto
    reduce = v_27_auto
  end
  local reduced
  do
    local v_27_auto
    local function reduced0(...)
      local value = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "reduced"))
        else
        end
      end
      local tmp_9_ = rdc.reduced(value)
      local function _1259_(_241)
        return _241:unbox()
      end
      getmetatable(tmp_9_)["cljlib/deref"] = _1259_
      return tmp_9_
    end
    v_27_auto = reduced0
    core["reduced"] = v_27_auto
    reduced = v_27_auto
  end
  local reduced_3f
  do
    local v_27_auto
    local function reduced_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "reduced?"))
        else
        end
      end
      return rdc["reduced?"](x)
    end
    v_27_auto = reduced_3f0
    core["reduced?"] = v_27_auto
    reduced_3f = v_27_auto
  end
  local unreduced
  do
    local v_27_auto
    local function unreduced0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "unreduced"))
        else
        end
      end
      if reduced_3f(x) then
        return deref(x)
      else
        return x
      end
    end
    v_27_auto = unreduced0
    core["unreduced"] = v_27_auto
    unreduced = v_27_auto
  end
  local ensure_reduced
  do
    local v_27_auto
    local function ensure_reduced0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "ensure-reduced"))
        else
        end
      end
      if reduced_3f(x) then
        return x
      else
        return reduced(x)
      end
    end
    v_27_auto = ensure_reduced0
    core["ensure-reduced"] = v_27_auto
    ensure_reduced = v_27_auto
  end
  local preserving_reduced
  local function preserving_reduced0(...)
    local rf = ...
    do
      local cnt_54_auto = select("#", ...)
      if (1 ~= cnt_54_auto) then
        error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "preserving-reduced"))
      else
      end
    end
    local function fn_1266_(...)
      local a0, b = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "fn_1266_"))
        else
        end
      end
      local ret = rf(a0, b)
      if reduced_3f(ret) then
        return reduced(ret)
      else
        return ret
      end
    end
    return fn_1266_
  end
  preserving_reduced = preserving_reduced0
  local cat
  do
    local v_27_auto
    local function cat0(...)
      local rf = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "cat"))
        else
        end
      end
      local rrf = preserving_reduced(rf)
      local function fn_1270_(...)
        local case_1271_ = select("#", ...)
        if (case_1271_ == 0) then
          return rf()
        elseif (case_1271_ == 1) then
          local result = ...
          return rf(result)
        elseif (case_1271_ == 2) then
          local result, input = ...
          return reduce(rrf, result, input)
        else
          local _ = case_1271_
          return error(("Wrong number of args (%s) passed to %s"):format(_, "fn_1270_"))
        end
      end
      return fn_1270_
    end
    v_27_auto = cat0
    core["cat"] = v_27_auto
    cat = v_27_auto
  end
  local reduce_kv
  do
    local v_27_auto
    local function reduce_kv0(...)
      local f, val, s = ...
      do
        local cnt_54_auto = select("#", ...)
        if (3 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "reduce-kv"))
        else
        end
      end
      if map_3f(s) then
        local function _1275_(res, _1274_)
          local k = _1274_[1]
          local v = _1274_[2]
          return f(res, k, v)
        end
        return reduce(_1275_, val, seq(s))
      else
        local function _1277_(res, _1276_)
          local k = _1276_[1]
          local v = _1276_[2]
          return f(res, k, v)
        end
        return reduce(_1277_, val, map(vector, drop(1, range()), seq(s)))
      end
    end
    v_27_auto = reduce_kv0
    core["reduce-kv"] = v_27_auto
    reduce_kv = v_27_auto
  end
  local completing
  do
    local v_27_auto
    local function completing0(...)
      local case_1279_ = select("#", ...)
      if (case_1279_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "completing"))
      elseif (case_1279_ == 1) then
        local f = ...
        return completing0(f, identity)
      elseif (case_1279_ == 2) then
        local f, cf = ...
        local function fn_1280_(...)
          local case_1281_ = select("#", ...)
          if (case_1281_ == 0) then
            return f()
          elseif (case_1281_ == 1) then
            local x = ...
            return cf(x)
          elseif (case_1281_ == 2) then
            local x, y = ...
            return f(x, y)
          else
            local _ = case_1281_
            return error(("Wrong number of args (%s) passed to %s"):format(_, "fn_1280_"))
          end
        end
        return fn_1280_
      else
        local _ = case_1279_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "completing"))
      end
    end
    v_27_auto = completing0
    core["completing"] = v_27_auto
    completing = v_27_auto
  end
  local transduce
  do
    local v_27_auto
    local function transduce0(...)
      local case_1287_ = select("#", ...)
      if (case_1287_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "transduce"))
      elseif (case_1287_ == 1) then
        return error(("Wrong number of args (%s) passed to %s"):format(1, "transduce"))
      elseif (case_1287_ == 2) then
        return error(("Wrong number of args (%s) passed to %s"):format(2, "transduce"))
      elseif (case_1287_ == 3) then
        local xform, f, coll = ...
        return transduce0(xform, f, f(), coll)
      elseif (case_1287_ == 4) then
        local xform, f, init, coll = ...
        local f0 = xform(f)
        return f0(reduce(f0, init, seq(coll)))
      else
        local _ = case_1287_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "transduce"))
      end
    end
    v_27_auto = transduce0
    core["transduce"] = v_27_auto
    transduce = v_27_auto
  end
  local sequence
  do
    local v_27_auto
    local function sequence0(...)
      local case_1289_ = select("#", ...)
      if (case_1289_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "sequence"))
      elseif (case_1289_ == 1) then
        local coll = ...
        if seq_3f(coll) then
          return coll
        else
          return (seq(coll) or list())
        end
      elseif (case_1289_ == 2) then
        local xform, coll = ...
        local f
        local function _1291_(_241, _242)
          return cons(_242, _241)
        end
        f = xform(completing(_1291_))
        local function step(coll0)
          local val_101_auto = seq(coll0)
          if (nil ~= val_101_auto) then
            local s = val_101_auto
            local res = f(nil, first(s))
            if reduced_3f(res) then
              return f(deref(res))
            elseif seq_3f(res) then
              local function _1292_()
                return step(rest(s))
              end
              return concat(res, lazy_seq_2a(_1292_))
            elseif "else" then
              return step(rest(s))
            else
              return nil
            end
          else
            return f(nil)
          end
        end
        return (step(coll) or list())
      else
        local _ = case_1289_
        local _let_1295_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_1295_.list
        local _let_1296_ = list_38_auto(...)
        local xform = _let_1296_[1]
        local coll = _let_1296_[2]
        local colls = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1296_, 3)
        local f
        local function _1297_(_241, _242)
          return cons(_242, _241)
        end
        f = xform(completing(_1297_))
        local function step(colls0)
          if every_3f(seq, colls0) then
            local res = apply(f, nil, map(first, colls0))
            if reduced_3f(res) then
              return f(deref(res))
            elseif seq_3f(res) then
              local function _1298_()
                return step(map(rest, colls0))
              end
              return concat(res, lazy_seq_2a(_1298_))
            elseif "else" then
              return step(map(rest, colls0))
            else
              return nil
            end
          else
            return f(nil)
          end
        end
        return (step(cons(coll, colls)) or list())
      end
    end
    v_27_auto = sequence0
    core["sequence"] = v_27_auto
    sequence = v_27_auto
  end
  local function map__3etransient(immutable)
    local function _1302_(map0)
      local removed = setmetatable({}, {__index = deep_index})
      local function _1303_(_, k)
        if not removed[k] then
          return map0[k]
        else
          return nil
        end
      end
      local function _1305_()
        return error("can't `conj` onto transient map, use `conj!`")
      end
      local function _1306_()
        return error("can't `assoc` onto transient map, use `assoc!`")
      end
      local function _1307_()
        return error("can't `dissoc` onto transient map, use `dissoc!`")
      end
      local function _1309_(tmap, _1308_)
        local k = _1308_[1]
        local v = _1308_[2]
        if (nil == v) then
          removed[k] = true
        else
          removed[k] = nil
        end
        tmap[k] = v
        return tmap
      end
      local function _1311_(tmap, ...)
        for i = 1, select("#", ...), 2 do
          local k, v = select(i, ...)
          tmap[k] = v
          if (nil == v) then
            removed[k] = true
          else
            removed[k] = nil
          end
        end
        return tmap
      end
      local function _1313_(tmap, ...)
        for i = 1, select("#", ...) do
          local k = select(i, ...)
          tmap[k] = nil
          removed[k] = true
        end
        return tmap
      end
      local function _1314_(tmap)
        local t
        do
          local tbl_21_
          do
            local tbl_21_0 = {}
            for k, v in pairs(map0) do
              local k_22_, v_23_ = k, v
              if ((k_22_ ~= nil) and (v_23_ ~= nil)) then
                tbl_21_0[k_22_] = v_23_
              else
              end
            end
            tbl_21_ = tbl_21_0
          end
          for k, v in pairs(tmap) do
            local k_22_, v_23_ = k, v
            if ((k_22_ ~= nil) and (v_23_ ~= nil)) then
              tbl_21_[k_22_] = v_23_
            else
            end
          end
          t = tbl_21_
        end
        for k in pairs(removed) do
          t[k] = nil
        end
        local function _1317_()
          local tbl_26_ = {}
          local i_27_ = 0
          for k in pairs_2a(tmap) do
            local val_28_ = k
            if (nil ~= val_28_) then
              i_27_ = (i_27_ + 1)
              tbl_26_[i_27_] = val_28_
            else
            end
          end
          return tbl_26_
        end
        for _, k in ipairs(_1317_()) do
          tmap[k] = nil
        end
        local function _1319_()
          return error("attempt to use transient after it was persistet")
        end
        local function _1320_()
          return error("attempt to use transient after it was persistet")
        end
        setmetatable(tmap, {__index = _1319_, __newindex = _1320_})
        return immutable(itable(t))
      end
      return setmetatable({}, {__index = _1303_, ["cljlib/type"] = "transient", ["cljlib/conj"] = _1305_, ["cljlib/assoc"] = _1306_, ["cljlib/dissoc"] = _1307_, ["cljlib/conj!"] = _1309_, ["cljlib/assoc!"] = _1311_, ["cljlib/dissoc!"] = _1313_, ["cljlib/persistent!"] = _1314_})
    end
    return _1302_
  end
  local function hash_map_2a(x)
    do
      local case_1321_ = getmetatable(x)
      if (nil ~= case_1321_) then
        local mt = case_1321_
        mt["cljlib/type"] = "hash-map"
        mt["cljlib/editable"] = true
        local function _1323_(t, _1322_, ...)
          local k = _1322_[1]
          local v = _1322_[2]
          local function _1324_(...)
            local kvs = {}
            for _, _1325_ in ipairs_2a({...}) do
              local k0 = _1325_[1]
              local v0 = _1325_[2]
              table.insert(kvs, k0)
              table.insert(kvs, v0)
              kvs = kvs
            end
            return kvs
          end
          return apply(core.assoc, t, k, v, _1324_(...))
        end
        mt["cljlib/conj"] = _1323_
        mt["cljlib/transient"] = map__3etransient(hash_map_2a)
        local function _1326_()
          return hash_map_2a(itable({}))
        end
        mt["cljlib/empty"] = _1326_
      else
        local _ = case_1321_
        hash_map_2a(setmetatable(x, {}))
      end
    end
    return x
  end
  local assoc
  do
    local v_27_auto
    local function assoc0(...)
      local case_1330_ = select("#", ...)
      if (case_1330_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "assoc"))
      elseif (case_1330_ == 1) then
        local tbl = ...
        return hash_map_2a(itable({}))
      elseif (case_1330_ == 2) then
        return error(("Wrong number of args (%s) passed to %s"):format(2, "assoc"))
      elseif (case_1330_ == 3) then
        local tbl, k, v = ...
        assert((nil_3f(tbl) or map_3f(tbl) or empty_3f(tbl)), "expected a map")
        assert(not nil_3f(k), "attempt to use nil as key")
        return hash_map_2a(itable.assoc((tbl or {}), k, v))
      else
        local _ = case_1330_
        local _let_1331_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_1331_.list
        local _let_1332_ = list_38_auto(...)
        local tbl = _let_1332_[1]
        local k = _let_1332_[2]
        local v = _let_1332_[3]
        local kvs = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1332_, 4)
        assert((nil_3f(tbl) or map_3f(tbl) or empty_3f(tbl)), "expected a map")
        assert(not nil_3f(k), "attempt to use nil as key")
        return hash_map_2a(apply(itable.assoc, (tbl or {}), k, v, kvs))
      end
    end
    v_27_auto = assoc0
    core["assoc"] = v_27_auto
    assoc = v_27_auto
  end
  local assoc_in
  do
    local v_27_auto
    local function assoc_in0(...)
      local tbl, key_seq, val = ...
      do
        local cnt_54_auto = select("#", ...)
        if (3 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "assoc-in"))
        else
        end
      end
      assert((nil_3f(tbl) or map_3f(tbl) or empty_3f(tbl)), "expected a map or nil")
      return hash_map_2a(itable["assoc-in"](tbl, key_seq, val))
    end
    v_27_auto = assoc_in0
    core["assoc-in"] = v_27_auto
    assoc_in = v_27_auto
  end
  local update
  do
    local v_27_auto
    local function update0(...)
      local tbl, key, f = ...
      do
        local cnt_54_auto = select("#", ...)
        if (3 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "update"))
        else
        end
      end
      assert((nil_3f(tbl) or map_3f(tbl) or empty_3f(tbl)), "expected a map")
      return hash_map_2a(itable.update(tbl, key, f))
    end
    v_27_auto = update0
    core["update"] = v_27_auto
    update = v_27_auto
  end
  local update_in
  do
    local v_27_auto
    local function update_in0(...)
      local tbl, key_seq, f = ...
      do
        local cnt_54_auto = select("#", ...)
        if (3 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "update-in"))
        else
        end
      end
      assert((nil_3f(tbl) or map_3f(tbl) or empty_3f(tbl)), "expected a map or nil")
      return hash_map_2a(itable["update-in"](tbl, key_seq, f))
    end
    v_27_auto = update_in0
    core["update-in"] = v_27_auto
    update_in = v_27_auto
  end
  local hash_map
  do
    local v_27_auto
    local function hash_map0(...)
      local _let_1337_ = require("io.gitlab.andreyorst.cljlib.core")
      local list_38_auto = _let_1337_.list
      local _let_1338_ = list_38_auto(...)
      local kvs = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1338_, 1)
      return apply(assoc, {}, kvs)
    end
    v_27_auto = hash_map0
    core["hash-map"] = v_27_auto
    hash_map = v_27_auto
  end
  local get
  do
    local v_27_auto
    local function get0(...)
      local case_1340_ = select("#", ...)
      if (case_1340_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "get"))
      elseif (case_1340_ == 1) then
        return error(("Wrong number of args (%s) passed to %s"):format(1, "get"))
      elseif (case_1340_ == 2) then
        local tbl, key = ...
        return get0(tbl, key, nil)
      elseif (case_1340_ == 3) then
        local tbl, key, not_found = ...
        assert((map_3f(tbl) or empty_3f(tbl)), "expected a map")
        return (tbl[key] or not_found)
      else
        local _ = case_1340_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "get"))
      end
    end
    v_27_auto = get0
    core["get"] = v_27_auto
    get = v_27_auto
  end
  local get_in
  do
    local v_27_auto
    local function get_in0(...)
      local case_1343_ = select("#", ...)
      if (case_1343_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "get-in"))
      elseif (case_1343_ == 1) then
        return error(("Wrong number of args (%s) passed to %s"):format(1, "get-in"))
      elseif (case_1343_ == 2) then
        local tbl, keys0 = ...
        return get_in0(tbl, keys0, nil)
      elseif (case_1343_ == 3) then
        local tbl, keys0, not_found = ...
        assert((map_3f(tbl) or empty_3f(tbl)), "expected a map")
        local res, t, done = tbl, tbl, nil
        for _, k in ipairs_2a(keys0) do
          if done then break end
          local case_1344_ = t[k]
          if (nil ~= case_1344_) then
            local v = case_1344_
            res, t = v, v
          else
            local _0 = case_1344_
            res, done = not_found, true
          end
        end
        return res
      else
        local _ = case_1343_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "get-in"))
      end
    end
    v_27_auto = get_in0
    core["get-in"] = v_27_auto
    get_in = v_27_auto
  end
  local dissoc
  do
    local v_27_auto
    local function dissoc0(...)
      local case_1347_ = select("#", ...)
      if (case_1347_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "dissoc"))
      elseif (case_1347_ == 1) then
        local tbl = ...
        return tbl
      elseif (case_1347_ == 2) then
        local tbl, key = ...
        assert((map_3f(tbl) or empty_3f(tbl)), "expected a map")
        local function _1348_(...)
          tbl[key] = nil
          return tbl
        end
        return hash_map_2a(_1348_(...))
      else
        local _ = case_1347_
        local _let_1349_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_1349_.list
        local _let_1350_ = list_38_auto(...)
        local tbl = _let_1350_[1]
        local key = _let_1350_[2]
        local keys0 = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1350_, 3)
        return apply(dissoc0, dissoc0(tbl, key), keys0)
      end
    end
    v_27_auto = dissoc0
    core["dissoc"] = v_27_auto
    dissoc = v_27_auto
  end
  local merge
  do
    local v_27_auto
    local function merge0(...)
      local _let_1352_ = require("io.gitlab.andreyorst.cljlib.core")
      local list_38_auto = _let_1352_.list
      local _let_1353_ = list_38_auto(...)
      local maps = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1353_, 1)
      if some(identity, maps) then
        local function _1354_(a0, b)
          local tbl_21_ = a0
          for k, v in pairs_2a(b) do
            local k_22_, v_23_ = k, v
            if ((k_22_ ~= nil) and (v_23_ ~= nil)) then
              tbl_21_[k_22_] = v_23_
            else
            end
          end
          return tbl_21_
        end
        return hash_map_2a(itable(reduce(_1354_, {}, maps)))
      else
        return nil
      end
    end
    v_27_auto = merge0
    core["merge"] = v_27_auto
    merge = v_27_auto
  end
  local frequencies
  do
    local v_27_auto
    local function frequencies0(...)
      local t = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "frequencies"))
        else
        end
      end
      return hash_map_2a(itable.frequencies(t))
    end
    v_27_auto = frequencies0
    core["frequencies"] = v_27_auto
    frequencies = v_27_auto
  end
  local group_by
  do
    local v_27_auto
    local function group_by0(...)
      local f, t = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "group-by"))
        else
        end
      end
      return hash_map_2a((itable["group-by"](f, t)))
    end
    v_27_auto = group_by0
    core["group-by"] = v_27_auto
    group_by = v_27_auto
  end
  local zipmap
  do
    local v_27_auto
    local function zipmap0(...)
      local keys0, vals0 = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "zipmap"))
        else
        end
      end
      return hash_map_2a(itable(lazy.zipmap(keys0, vals0)))
    end
    v_27_auto = zipmap0
    core["zipmap"] = v_27_auto
    zipmap = v_27_auto
  end
  local replace
  do
    local v_27_auto
    local function replace0(...)
      local case_1360_ = select("#", ...)
      if (case_1360_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "replace"))
      elseif (case_1360_ == 1) then
        local smap = ...
        local function _1361_(_241)
          local val_97_auto = find(smap, _241)
          if val_97_auto then
            local e = val_97_auto
            return e[2]
          else
            return _241
          end
        end
        return map(_1361_)
      elseif (case_1360_ == 2) then
        local smap, coll = ...
        if vector_3f(coll) then
          local function _1363_(res, v)
            local val_97_auto = find(smap, v)
            if val_97_auto then
              local e = val_97_auto
              table.insert(res, e[2])
              return res
            else
              table.insert(res, v)
              return res
            end
          end
          return vec_2a(itable(reduce(_1363_, {}, coll)))
        else
          local function _1365_(_241)
            local val_97_auto = find(smap, _241)
            if val_97_auto then
              local e = val_97_auto
              return e[2]
            else
              return _241
            end
          end
          return map(_1365_, coll)
        end
      else
        local _ = case_1360_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "replace"))
      end
    end
    v_27_auto = replace0
    core["replace"] = v_27_auto
    replace = v_27_auto
  end
  local conj
  do
    local v_27_auto
    local function conj0(...)
      local case_1369_ = select("#", ...)
      if (case_1369_ == 0) then
        return vector()
      elseif (case_1369_ == 1) then
        local s = ...
        return s
      elseif (case_1369_ == 2) then
        local s, x = ...
        local case_1370_ = getmetatable(s)
        if ((_G.type(case_1370_) == "table") and (nil ~= case_1370_["cljlib/conj"])) then
          local f = case_1370_["cljlib/conj"]
          return f(s, x)
        else
          local _ = case_1370_
          if vector_3f(s) then
            return vec_2a(itable.insert(s, x))
          elseif map_3f(s) then
            return apply(assoc, s, x)
          elseif nil_3f(s) then
            return cons(x, s)
          elseif empty_3f(s) then
            return vector(x)
          else
            return error("expected collection, got", type(s))
          end
        end
      else
        local _ = case_1369_
        local _let_1373_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_1373_.list
        local _let_1374_ = list_38_auto(...)
        local s = _let_1374_[1]
        local x = _let_1374_[2]
        local xs = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1374_, 3)
        return apply(conj0, conj0(s, x), xs)
      end
    end
    v_27_auto = conj0
    core["conj"] = v_27_auto
    conj = v_27_auto
  end
  local disj
  do
    local v_27_auto
    local function disj0(...)
      local case_1376_ = select("#", ...)
      if (case_1376_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "disj"))
      elseif (case_1376_ == 1) then
        local Set = ...
        return Set
      elseif (case_1376_ == 2) then
        local Set, key = ...
        local case_1377_ = getmetatable(Set)
        if ((_G.type(case_1377_) == "table") and (case_1377_["cljlib/type"] == "hash-set") and (nil ~= case_1377_["cljlib/disj"])) then
          local f = case_1377_["cljlib/disj"]
          return f(Set, key)
        else
          local _ = case_1377_
          return error(("disj is not supported on " .. class(Set)), 2)
        end
      else
        local _ = case_1376_
        local _let_1379_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_1379_.list
        local _let_1380_ = list_38_auto(...)
        local Set = _let_1380_[1]
        local key = _let_1380_[2]
        local keys0 = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1380_, 3)
        local case_1381_ = getmetatable(Set)
        if ((_G.type(case_1381_) == "table") and (case_1381_["cljlib/type"] == "hash-set") and (nil ~= case_1381_["cljlib/disj"])) then
          local f = case_1381_["cljlib/disj"]
          return apply(f, Set, key, keys0)
        else
          local _0 = case_1381_
          return error(("disj is not supported on " .. class(Set)), 2)
        end
      end
    end
    v_27_auto = disj0
    core["disj"] = v_27_auto
    disj = v_27_auto
  end
  local pop
  do
    local v_27_auto
    local function pop0(...)
      local coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "pop"))
        else
        end
      end
      local case_1385_ = getmetatable(coll)
      if ((_G.type(case_1385_) == "table") and (case_1385_["cljlib/type"] == "seq")) then
        local case_1386_ = seq(coll)
        if (nil ~= case_1386_) then
          local s = case_1386_
          return drop(1, s)
        else
          local _ = case_1386_
          return error("can't pop empty list", 2)
        end
      elseif ((_G.type(case_1385_) == "table") and (nil ~= case_1385_["cljlib/pop"])) then
        local f = case_1385_["cljlib/pop"]
        return f(coll)
      else
        local _ = case_1385_
        return error(("pop is not supported on " .. class(coll)), 2)
      end
    end
    v_27_auto = pop0
    core["pop"] = v_27_auto
    pop = v_27_auto
  end
  local transient
  do
    local v_27_auto
    local function transient0(...)
      local coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "transient"))
        else
        end
      end
      local case_1390_ = getmetatable(coll)
      if ((_G.type(case_1390_) == "table") and (case_1390_["cljlib/editable"] == true) and (nil ~= case_1390_["cljlib/transient"])) then
        local f = case_1390_["cljlib/transient"]
        return f(coll)
      else
        local _ = case_1390_
        return error("expected editable collection", 2)
      end
    end
    v_27_auto = transient0
    core["transient"] = v_27_auto
    transient = v_27_auto
  end
  local conj_21
  do
    local v_27_auto
    local function conj_210(...)
      local case_1392_ = select("#", ...)
      if (case_1392_ == 0) then
        return transient(vec_2a({}))
      elseif (case_1392_ == 1) then
        local coll = ...
        return coll
      elseif (case_1392_ == 2) then
        local coll, x = ...
        do
          local case_1393_ = getmetatable(coll)
          if ((_G.type(case_1393_) == "table") and (case_1393_["cljlib/type"] == "transient") and (nil ~= case_1393_["cljlib/conj!"])) then
            local f = case_1393_["cljlib/conj!"]
            f(coll, x)
          elseif ((_G.type(case_1393_) == "table") and (case_1393_["cljlib/type"] == "transient")) then
            error("unsupported transient operation", 2)
          else
            local _ = case_1393_
            error("expected transient collection", 2)
          end
        end
        return coll
      else
        local _ = case_1392_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "conj!"))
      end
    end
    v_27_auto = conj_210
    core["conj!"] = v_27_auto
    conj_21 = v_27_auto
  end
  local assoc_21
  do
    local v_27_auto
    local function assoc_210(...)
      local _let_1396_ = require("io.gitlab.andreyorst.cljlib.core")
      local list_38_auto = _let_1396_.list
      local _let_1397_ = list_38_auto(...)
      local map0 = _let_1397_[1]
      local k = _let_1397_[2]
      local ks = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1397_, 3)
      do
        local case_1398_ = getmetatable(map0)
        if ((_G.type(case_1398_) == "table") and (case_1398_["cljlib/type"] == "transient") and (nil ~= case_1398_["cljlib/dissoc!"])) then
          local f = case_1398_["cljlib/dissoc!"]
          apply(f, map0, k, ks)
        elseif ((_G.type(case_1398_) == "table") and (case_1398_["cljlib/type"] == "transient")) then
          error("unsupported transient operation", 2)
        else
          local _ = case_1398_
          error("expected transient collection", 2)
        end
      end
      return map0
    end
    v_27_auto = assoc_210
    core["assoc!"] = v_27_auto
    assoc_21 = v_27_auto
  end
  local dissoc_21
  do
    local v_27_auto
    local function dissoc_210(...)
      local _let_1400_ = require("io.gitlab.andreyorst.cljlib.core")
      local list_38_auto = _let_1400_.list
      local _let_1401_ = list_38_auto(...)
      local map0 = _let_1401_[1]
      local k = _let_1401_[2]
      local ks = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1401_, 3)
      do
        local case_1402_ = getmetatable(map0)
        if ((_G.type(case_1402_) == "table") and (case_1402_["cljlib/type"] == "transient") and (nil ~= case_1402_["cljlib/dissoc!"])) then
          local f = case_1402_["cljlib/dissoc!"]
          apply(f, map0, k, ks)
        elseif ((_G.type(case_1402_) == "table") and (case_1402_["cljlib/type"] == "transient")) then
          error("unsupported transient operation", 2)
        else
          local _ = case_1402_
          error("expected transient collection", 2)
        end
      end
      return map0
    end
    v_27_auto = dissoc_210
    core["dissoc!"] = v_27_auto
    dissoc_21 = v_27_auto
  end
  local disj_21
  do
    local v_27_auto
    local function disj_210(...)
      local case_1404_ = select("#", ...)
      if (case_1404_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "disj!"))
      elseif (case_1404_ == 1) then
        local Set = ...
        return Set
      else
        local _ = case_1404_
        local _let_1405_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_1405_.list
        local _let_1406_ = list_38_auto(...)
        local Set = _let_1406_[1]
        local key = _let_1406_[2]
        local ks = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1406_, 3)
        local case_1407_ = getmetatable(Set)
        if ((_G.type(case_1407_) == "table") and (case_1407_["cljlib/type"] == "transient") and (nil ~= case_1407_["cljlib/disj!"])) then
          local f = case_1407_["cljlib/disj!"]
          return apply(f, Set, key, ks)
        elseif ((_G.type(case_1407_) == "table") and (case_1407_["cljlib/type"] == "transient")) then
          return error("unsupported transient operation", 2)
        else
          local _0 = case_1407_
          return error("expected transient collection", 2)
        end
      end
    end
    v_27_auto = disj_210
    core["disj!"] = v_27_auto
    disj_21 = v_27_auto
  end
  local pop_21
  do
    local v_27_auto
    local function pop_210(...)
      local coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "pop!"))
        else
        end
      end
      local case_1411_ = getmetatable(coll)
      if ((_G.type(case_1411_) == "table") and (case_1411_["cljlib/type"] == "transient") and (nil ~= case_1411_["cljlib/pop!"])) then
        local f = case_1411_["cljlib/pop!"]
        return f(coll)
      elseif ((_G.type(case_1411_) == "table") and (case_1411_["cljlib/type"] == "transient")) then
        return error("unsupported transient operation", 2)
      else
        local _ = case_1411_
        return error("expected transient collection", 2)
      end
    end
    v_27_auto = pop_210
    core["pop!"] = v_27_auto
    pop_21 = v_27_auto
  end
  local persistent_21
  do
    local v_27_auto
    local function persistent_210(...)
      local coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "persistent!"))
        else
        end
      end
      local case_1414_ = getmetatable(coll)
      if ((_G.type(case_1414_) == "table") and (case_1414_["cljlib/type"] == "transient") and (nil ~= case_1414_["cljlib/persistent!"])) then
        local f = case_1414_["cljlib/persistent!"]
        return f(coll)
      else
        local _ = case_1414_
        return error("expected transient collection", 2)
      end
    end
    v_27_auto = persistent_210
    core["persistent!"] = v_27_auto
    persistent_21 = v_27_auto
  end
  local into
  do
    local v_27_auto
    local function into0(...)
      local case_1416_ = select("#", ...)
      if (case_1416_ == 0) then
        return vector()
      elseif (case_1416_ == 1) then
        local to = ...
        return to
      elseif (case_1416_ == 2) then
        local to, from = ...
        local case_1417_ = getmetatable(to)
        if ((_G.type(case_1417_) == "table") and (case_1417_["cljlib/editable"] == true)) then
          return persistent_21(reduce(conj_21, transient(to), from))
        else
          local _ = case_1417_
          return reduce(conj, to, from)
        end
      elseif (case_1416_ == 3) then
        local to, xform, from = ...
        local case_1419_ = getmetatable(to)
        if ((_G.type(case_1419_) == "table") and (case_1419_["cljlib/editable"] == true)) then
          return persistent_21(transduce(xform, conj_21, transient(to), from))
        else
          local _ = case_1419_
          return transduce(xform, conj, to, from)
        end
      else
        local _ = case_1416_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "into"))
      end
    end
    v_27_auto = into0
    core["into"] = v_27_auto
    into = v_27_auto
  end
  local function viewset(Set, view, inspector, indent)
    if inspector.seen[Set] then
      return ("@set" .. inspector.seen[Set] .. "{...}")
    else
      local prefix
      local _1422_
      if inspector["visible-cycle?"](Set) then
        _1422_ = inspector.seen[Set]
      else
        _1422_ = ""
      end
      prefix = ("@set" .. _1422_ .. "{")
      local set_indent = #prefix
      local indent_str = string.rep(" ", set_indent)
      local lines
      do
        local tbl_26_ = {}
        local i_27_ = 0
        for v in pairs_2a(Set) do
          local val_28_ = (indent_str .. view(v, inspector, (indent + set_indent), true))
          if (nil ~= val_28_) then
            i_27_ = (i_27_ + 1)
            tbl_26_[i_27_] = val_28_
          else
          end
        end
        lines = tbl_26_
      end
      lines[1] = (prefix .. string.gsub((lines[1] or ""), "^%s+", ""))
      lines[#lines] = (lines[#lines] .. "}")
      return lines
    end
  end
  local function hash_set__3etransient(immutable)
    local function _1426_(hset)
      local removed = setmetatable({}, {__index = deep_index})
      local function _1427_(_, k)
        if not removed[k] then
          return hset[k]
        else
          return nil
        end
      end
      local function _1429_()
        return error("can't `conj` onto transient set, use `conj!`")
      end
      local function _1430_()
        return error("can't `disj` a transient set, use `disj!`")
      end
      local function _1431_()
        return error("can't `assoc` onto transient set, use `assoc!`")
      end
      local function _1432_()
        return error("can't `dissoc` onto transient set, use `dissoc!`")
      end
      local function _1433_(thset, v)
        if (nil == v) then
          removed[v] = true
        else
          removed[v] = nil
        end
        thset[v] = v
        return thset
      end
      local function _1435_()
        return error("can't `dissoc!` a transient set")
      end
      local function _1436_(thset, ...)
        for i = 1, select("#", ...) do
          local k = select(i, ...)
          thset[k] = nil
          removed[k] = true
        end
        return thset
      end
      local function _1437_(thset)
        local t
        do
          local tbl_21_
          do
            local tbl_21_0 = {}
            for k, v in pairs(hset) do
              local k_22_, v_23_ = k, v
              if ((k_22_ ~= nil) and (v_23_ ~= nil)) then
                tbl_21_0[k_22_] = v_23_
              else
              end
            end
            tbl_21_ = tbl_21_0
          end
          for k, v in pairs(thset) do
            local k_22_, v_23_ = k, v
            if ((k_22_ ~= nil) and (v_23_ ~= nil)) then
              tbl_21_[k_22_] = v_23_
            else
            end
          end
          t = tbl_21_
        end
        for k in pairs(removed) do
          t[k] = nil
        end
        local function _1440_()
          local tbl_26_ = {}
          local i_27_ = 0
          for k in pairs_2a(thset) do
            local val_28_ = k
            if (nil ~= val_28_) then
              i_27_ = (i_27_ + 1)
              tbl_26_[i_27_] = val_28_
            else
            end
          end
          return tbl_26_
        end
        for _, k in ipairs(_1440_()) do
          thset[k] = nil
        end
        local function _1442_()
          return error("attempt to use transient after it was persistet")
        end
        local function _1443_()
          return error("attempt to use transient after it was persistet")
        end
        setmetatable(thset, {__index = _1442_, __newindex = _1443_})
        return immutable(itable(t))
      end
      return setmetatable({}, {__index = _1427_, ["cljlib/type"] = "transient", ["cljlib/conj"] = _1429_, ["cljlib/disj"] = _1430_, ["cljlib/assoc"] = _1431_, ["cljlib/dissoc"] = _1432_, ["cljlib/conj!"] = _1433_, ["cljlib/assoc!"] = _1435_, ["cljlib/disj!"] = _1436_, ["cljlib/persistent!"] = _1437_})
    end
    return _1426_
  end
  local function hash_set_2a(x)
    do
      local case_1444_ = getmetatable(x)
      if (nil ~= case_1444_) then
        local mt = case_1444_
        mt["cljlib/type"] = "hash-set"
        local function _1445_(s, v, ...)
          local function _1446_(...)
            local res = {}
            for _, v0 in ipairs({...}) do
              table.insert(res, v0)
              table.insert(res, v0)
            end
            return res
          end
          return hash_set_2a(itable.assoc(s, v, v, unpack_2a(_1446_(...))))
        end
        mt["cljlib/conj"] = _1445_
        local function _1447_(s, k, ...)
          local to_remove
          do
            local tbl_21_ = setmetatable({[k] = true}, {__index = deep_index})
            for _, k0 in ipairs({...}) do
              local k_22_, v_23_ = k0, true
              if ((k_22_ ~= nil) and (v_23_ ~= nil)) then
                tbl_21_[k_22_] = v_23_
              else
              end
            end
            to_remove = tbl_21_
          end
          local function _1449_(...)
            local res = {}
            for _, v in pairs(s) do
              if not to_remove[v] then
                table.insert(res, v)
                table.insert(res, v)
              else
              end
            end
            return res
          end
          return hash_set_2a(itable.assoc({}, unpack_2a(_1449_(...))))
        end
        mt["cljlib/disj"] = _1447_
        local function _1451_()
          return hash_set_2a(itable({}))
        end
        mt["cljlib/empty"] = _1451_
        mt["cljlib/editable"] = true
        mt["cljlib/transient"] = hash_set__3etransient(hash_set_2a)
        local function _1452_(s)
          local function _1453_(_241)
            if vector_3f(_241) then
              return _241[1]
            else
              return _241
            end
          end
          return map(_1453_, s)
        end
        mt["cljlib/seq"] = _1452_
        mt["__fennelview"] = viewset
        local function _1455_(s, i)
          local j = 1
          local vals0 = {}
          for v in pairs_2a(s) do
            if (j >= i) then
              table.insert(vals0, v)
            else
              j = (j + 1)
            end
          end
          return core["hash-set"](unpack_2a(vals0))
        end
        mt["__fennelrest"] = _1455_
      else
        local _ = case_1444_
        hash_set_2a(setmetatable(x, {}))
      end
    end
    return x
  end
  local hash_set
  do
    local v_27_auto
    local function hash_set0(...)
      local _let_1458_ = require("io.gitlab.andreyorst.cljlib.core")
      local list_38_auto = _let_1458_.list
      local _let_1459_ = list_38_auto(...)
      local xs = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1459_, 1)
      local Set
      do
        local tbl_21_ = setmetatable({}, {__newindex = deep_newindex})
        for _, val in pairs_2a(xs) do
          local k_22_, v_23_ = val, val
          if ((k_22_ ~= nil) and (v_23_ ~= nil)) then
            tbl_21_[k_22_] = v_23_
          else
          end
        end
        Set = tbl_21_
      end
      return hash_set_2a(itable(Set))
    end
    v_27_auto = hash_set0
    core["hash-set"] = v_27_auto
    hash_set = v_27_auto
  end
  local multifn_3f
  do
    local v_27_auto
    local function multifn_3f0(...)
      local mf = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "multifn?"))
        else
        end
      end
      local case_1462_ = getmetatable(mf)
      if ((_G.type(case_1462_) == "table") and (case_1462_["cljlib/type"] == "multifn")) then
        return true
      else
        local _ = case_1462_
        return false
      end
    end
    v_27_auto = multifn_3f0
    core["multifn?"] = v_27_auto
    multifn_3f = v_27_auto
  end
  local remove_method
  do
    local v_27_auto
    local function remove_method0(...)
      local multimethod, dispatch_value = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "remove-method"))
        else
        end
      end
      if multifn_3f(multimethod) then
        multimethod[dispatch_value] = nil
      else
        error((tostring(multimethod) .. " is not a multifn"), 2)
      end
      return multimethod
    end
    v_27_auto = remove_method0
    core["remove-method"] = v_27_auto
    remove_method = v_27_auto
  end
  local remove_all_methods
  do
    local v_27_auto
    local function remove_all_methods0(...)
      local multimethod = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "remove-all-methods"))
        else
        end
      end
      if multifn_3f(multimethod) then
        for k, _ in pairs(multimethod) do
          multimethod[k] = nil
        end
      else
        error((tostring(multimethod) .. " is not a multifn"), 2)
      end
      return multimethod
    end
    v_27_auto = remove_all_methods0
    core["remove-all-methods"] = v_27_auto
    remove_all_methods = v_27_auto
  end
  local methods
  do
    local v_27_auto
    local function methods0(...)
      local multimethod = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "methods"))
        else
        end
      end
      if multifn_3f(multimethod) then
        local m = {}
        for k, v in pairs(multimethod) do
          m[k] = v
        end
        return m
      else
        return error((tostring(multimethod) .. " is not a multifn"), 2)
      end
    end
    v_27_auto = methods0
    core["methods"] = v_27_auto
    methods = v_27_auto
  end
  local get_method
  do
    local v_27_auto
    local function get_method0(...)
      local multimethod, dispatch_value = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "get-method"))
        else
        end
      end
      if multifn_3f(multimethod) then
        return (multimethod[dispatch_value] or multimethod.default)
      else
        return error((tostring(multimethod) .. " is not a multifn"), 2)
      end
    end
    v_27_auto = get_method0
    core["get-method"] = v_27_auto
    get_method = v_27_auto
  end
  local inst
  do
    local v_27_auto
    local function inst0(...)
      local s = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "inst"))
        else
        end
      end
      local date = lua_inst(s)
      local function _1473_(_241)
        return ("#<inst: %04d-%s.%03d-00:00>"):format(_241.year, os.date("%m-%dT%H:%M:%S", os.time(_241)), _241.msec)
      end
      getmetatable(date)["__fennelview"] = _1473_
      return date
    end
    v_27_auto = inst0
    core["inst"] = v_27_auto
    inst = v_27_auto
  end
  local function start_task_runner(agent)
    local function _1474_()
      while (agent.status == "ready") do
        local _let_1475_ = a["<!"](agent.tasks)
        local f = _let_1475_[1]
        local args = _let_1475_[2]
        local task_ok_3f, state_or_msg = pcall(apply, f, agent.state, args)
        local task_ok_3f0, state_or_msg0
        if task_ok_3f then
          local validator_ok, err = pcall(agent.validator, state_or_msg)
          if validator_ok then
            task_ok_3f0, state_or_msg0 = true, state_or_msg
          else
            task_ok_3f0, state_or_msg0 = false, err
          end
        else
          task_ok_3f0, state_or_msg0 = false, state_or_msg
        end
        local case_1478_, case_1479_ = task_ok_3f0, state_or_msg0
        if ((case_1478_ == true) and true) then
          local _3fstate = case_1479_
          agent.state = _3fstate
        elseif ((case_1478_ == false) and (nil ~= case_1479_)) then
          local err = case_1479_
          if (agent["error-mode"] ~= "continue") then
            agent.status = "failed"
            agent.error = err
          else
          end
          if agent["error-handler"] then
            agent["error-handler"](agent, err)
          else
          end
        else
        end
      end
      return nil
    end
    a["go*"](_1474_)
    return nil
  end
  local agents = {}
  local agent
  do
    local v_27_auto
    local function agent0(...)
      local _let_1483_ = require("io.gitlab.andreyorst.cljlib.core")
      local list_38_auto = _let_1483_.list
      local _let_1484_ = list_38_auto(...)
      local state = _let_1484_[1]
      local options = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1484_, 2)
      local opts = apply(hash_map, options)
      local agent1
      local _1485_
      if opts.validator then
        local function _1486_(newstate)
          if not opts.validator(newstate) then
            return error("Invalid reference state", 2)
          else
            return nil
          end
        end
        _1485_ = _1486_
      else
        local function _1488_()
          return true
        end
        _1485_ = _1488_
      end
      local or_1490_ = opts["error-handler"]
      if not or_1490_ then
        local function _1491_()
          return true
        end
        or_1490_ = _1491_
      end
      local function _1492_(self)
        return self.state
      end
      local function _1493_(agent2, task)
        if (agent2.status ~= "ready") then
          error(agent2.error, 3)
        else
        end
        local function _1495_()
          return a[">!"](agent2.tasks, task)
        end
        a["go*"](_1495_)
        return agent2
      end
      local function _1496_(agent2, view, inspector, indent)
        local prefix = ("#<" .. string.gsub(tostring(agent2), "table", "agent") .. " ")
        local _1497_
        do
          inspector["one-line?"] = true
          _1497_ = inspector
        end
        return {(prefix .. view({val = agent2.state, status = agent2.status}, _1497_, (indent + #prefix)) .. ">")}
      end
      agent1 = setmetatable({state = state, ["error-mode"] = (opts["error-mode"] or (opts["error-handler"] and "continue") or "fail"), validator = _1485_, ["error-handler"] = or_1490_, status = "ready", tasks = a.chan()}, {["cljlib/type"] = "agent", ["cljlib/deref"] = _1492_, ["cljlib/send"] = _1493_, __fennelview = _1496_})
      start_task_runner(agent1)
      agents[agent1] = true
      return agent1
    end
    v_27_auto = agent0
    core["agent"] = v_27_auto
    agent = v_27_auto
  end
  local set_error_handler_21
  do
    local v_27_auto
    local function set_error_handler_210(...)
      local agent0, handler_fn = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "set-error-handler!"))
        else
        end
      end
      agent0["error-handler"] = handler_fn
      return nil
    end
    v_27_auto = set_error_handler_210
    core["set-error-handler!"] = v_27_auto
    set_error_handler_21 = v_27_auto
  end
  local set_error_mode_21
  do
    local v_27_auto
    local function set_error_mode_210(...)
      local agent0, mode_keyword = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "set-error-mode!"))
        else
        end
      end
      agent0["error-mode"] = mode_keyword
      return nil
    end
    v_27_auto = set_error_mode_210
    core["set-error-mode!"] = v_27_auto
    set_error_mode_21 = v_27_auto
  end
  local agent_error
  do
    local v_27_auto
    local function agent_error0(...)
      local agent0 = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "agent-error"))
        else
        end
      end
      return agent0.error
    end
    v_27_auto = agent_error0
    core["agent-error"] = v_27_auto
    agent_error = v_27_auto
  end
  local restart_agent
  do
    local v_27_auto
    local function restart_agent0(...)
      local _let_1501_ = require("io.gitlab.andreyorst.cljlib.core")
      local list_38_auto = _let_1501_.list
      local _let_1502_ = list_38_auto(...)
      local agent0 = _let_1502_[1]
      local new_state = _let_1502_[2]
      local options = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1502_, 3)
      if (agent0.status ~= "failed") then
        error("Agent does not need a restart", 2)
      else
      end
      local opts = apply(hash_map, options)
      do
        agent0["state"] = new_state
        agent0["status"] = "ready"
        agent0["error"] = nil
      end
      if opts["clear-actions"] then
        agent0.tasks = a.chan()
      else
      end
      return start_task_runner(agent0)
    end
    v_27_auto = restart_agent0
    core["restart-agent"] = v_27_auto
    restart_agent = v_27_auto
  end
  local send
  do
    local v_27_auto
    local function send0(...)
      local _let_1505_ = require("io.gitlab.andreyorst.cljlib.core")
      local list_38_auto = _let_1505_.list
      local _let_1506_ = list_38_auto(...)
      local a0 = _let_1506_[1]
      local f = _let_1506_[2]
      local args = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1506_, 3)
      do
        local case_1507_ = getmetatable(a0)
        if ((_G.type(case_1507_) == "table") and (nil ~= case_1507_["cljlib/send"])) then
          local send1 = case_1507_["cljlib/send"]
          send1(a0, {f, args})
        else
          local _ = case_1507_
          error("object doesn't implement cljlib/send metamethod", 2)
        end
      end
      return a0
    end
    v_27_auto = send0
    core["send"] = v_27_auto
    send = v_27_auto
  end
  local shutdown_agents
  do
    local v_27_auto
    local function shutdown_agents0(...)
      do
        local cnt_54_auto = select("#", ...)
        if (0 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "shutdown-agents"))
        else
        end
      end
      for agent0 in pairs(agents) do
        agent0.status = nil
        local function _1510_(x)
          return x
        end
        send(a, _1510_)
      end
      agents = {}
      return nil
    end
    v_27_auto = shutdown_agents0
    core["shutdown-agents"] = v_27_auto
    shutdown_agents = v_27_auto
  end
  local atom
  do
    local v_27_auto
    local function atom0(...)
      local _let_1511_ = require("io.gitlab.andreyorst.cljlib.core")
      local list_38_auto = _let_1511_.list
      local _let_1512_ = list_38_auto(...)
      local x = _let_1512_[1]
      local options = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1512_, 2)
      local opts = apply(hash_map, options)
      if (opts.validator and not opts.validator(x)) then
        error("Invalid reference state", 2)
      else
      end
      local _1514_
      if opts.validator then
        local function _1515_(newstate)
          if not opts.validator(newstate) then
            return error("Invalid reference state", 2)
          else
            return nil
          end
        end
        _1514_ = _1515_
      else
        local function _1517_(_newstate)
          return true
        end
        _1514_ = _1517_
      end
      local function _1519_(self)
        return self.val
      end
      local function _1520_(atom1, view, inspector, indent)
        local prefix = ("#<" .. string.gsub(tostring(agent), "table", "atom") .. " ")
        local _1521_
        do
          inspector["one-line?"] = true
          _1521_ = inspector
        end
        return {(prefix .. view({val = atom1.val, status = "ready"}, _1521_, (indent + #prefix)) .. ">")}
      end
      return setmetatable({val = x, validator = _1514_}, {["cljlib/type"] = "atom", ["cljlib/deref"] = _1519_, __fennelview = _1520_})
    end
    v_27_auto = atom0
    core["atom"] = v_27_auto
    atom = v_27_auto
  end
  core["swap!"] = function(atom0, f, ...)
    local newval = f(atom0.val, ...)
    atom0.validator(newval)
    atom0.val = newval
    return newval
  end
  local reset_21
  do
    local v_27_auto
    local function reset_210(...)
      local atom0, newval = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "reset!"))
        else
        end
      end
      local function _1523_()
        return newval
      end
      return core["swap!"](atom0, _1523_)
    end
    v_27_auto = reset_210
    core["reset!"] = v_27_auto
    reset_21 = v_27_auto
  end
  local volatile_21
  do
    local v_27_auto
    local function volatile_210(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "volatile!"))
        else
        end
      end
      local function _1525_(self)
        return self.val
      end
      local function _1526_(volatile, view, inspector, indent)
        local prefix = ("#<" .. string.gsub(tostring(agent), "table", "volatile") .. " ")
        local _1527_
        do
          inspector["one-line?"] = true
          _1527_ = inspector
        end
        return {(prefix .. view({val = volatile.val, status = "ready"}, _1527_, (indent + #prefix)) .. ">")}
      end
      return setmetatable({val = x}, {["cljlib/type"] = "volatile", ["cljlib/deref"] = _1525_, __fennelview = _1526_})
    end
    v_27_auto = volatile_210
    core["volatile!"] = v_27_auto
    volatile_21 = v_27_auto
  end
  core["vswap!"] = function(volatile, f, ...)
    local newval = f(volatile.val, ...)
    volatile.val = newval
    return newval
  end
  local vreset_21
  do
    local v_27_auto
    local function vreset_210(...)
      local volatile, newval = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "vreset!"))
        else
        end
      end
      local function _1529_()
        return newval
      end
      return core["vswap!"](volatile, _1529_)
    end
    v_27_auto = vreset_210
    core["vreset!"] = v_27_auto
    vreset_21 = v_27_auto
  end
  local set_validator_21
  do
    local v_27_auto
    local function set_validator_210(...)
      local agent_2fatom, validator_fn = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "set-validator!"))
        else
        end
      end
      if ((nil ~= validator_fn) and not validator_fn(deref(agent_2fatom))) then
        error("Invalid reference state", 2)
      else
      end
      local function _1532_(newstate)
        if not validator_fn(newstate) then
          return error("Invalid reference state", 2)
        else
          return nil
        end
      end
      agent_2fatom.validator = _1532_
      return nil
    end
    v_27_auto = set_validator_210
    core["set-validator!"] = v_27_auto
    set_validator_21 = v_27_auto
  end
  local tap_ch = a.chan()
  local mult_ch = a.mult(tap_ch)
  local taps = {}
  local remove_tap
  do
    local v_27_auto
    local function remove_tap0(...)
      local f = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "remove-tap"))
        else
        end
      end
      do
        local case_1535_ = taps[f]
        if (nil ~= case_1535_) then
          local c = case_1535_
          a.untap(mult_ch, c)
          a["close!"](c)
        else
        end
      end
      taps[f] = nil
      return nil
    end
    v_27_auto = remove_tap0
    core["remove-tap"] = v_27_auto
    remove_tap = v_27_auto
  end
  local add_tap
  do
    local v_27_auto
    local function add_tap0(...)
      local f = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "add-tap"))
        else
        end
      end
      remove_tap(f)
      local c = a.chan()
      a.tap(mult_ch, c)
      local function _1538_()
        local function recur()
          local data = a["<!"](c)
          if data then
            f(data)
            return recur()
          else
            return nil
          end
        end
        return recur()
      end
      a["go*"](_1538_)
      taps[f] = c
      return nil
    end
    v_27_auto = add_tap0
    core["add-tap"] = v_27_auto
    add_tap = v_27_auto
  end
  local tap_3e
  do
    local v_27_auto
    local function tap_3e0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "tap>"))
        else
        end
      end
      return a["offer!"](tap_ch, x)
    end
    v_27_auto = tap_3e0
    core["tap>"] = v_27_auto
    tap_3e = v_27_auto
  end
  return core
end
package.preload["io.gitlab.andreyorst.lazy-seq"] = package.preload["io.gitlab.andreyorst.lazy-seq"] or function(...)
  --[[ "MIT License
  
    Copyright (c) 2021 Andrey Listopadov
  
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the “Software”), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
  
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
  
    THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE." ]]
  utf8 = _G.utf8
  local function pairs_2a(t)
    local mt = getmetatable(t)
    if (("table" == mt) and mt.__pairs) then
      return mt.__pairs(t)
    else
      return pairs(t)
    end
  end
  local function ipairs_2a(t)
    local mt = getmetatable(t)
    if (("table" == mt) and mt.__ipairs) then
      return mt.__ipairs(t)
    else
      return ipairs(t)
    end
  end
  local function rev_ipairs(t)
    local function _4_(t0, i)
      local i0 = (i - 1)
      if (i0 == 0) then
        return nil
      else
        local _ = i0
        return i0, t0[i0]
      end
    end
    return _4_, t, (1 + #t)
  end
  local function length_2a(t)
    local mt = getmetatable(t)
    if (("table" == mt) and mt.__len) then
      return mt.__len(t)
    else
      return #t
    end
  end
  local function table_pack(...)
    local tmp_9_ = {...}
    tmp_9_["n"] = select("#", ...)
    return tmp_9_
  end
  local table_unpack = (table.unpack or _G.unpack)
  local seq = nil
  local cons_iter = nil
  local function first(s)
    local case_7_ = seq(s)
    if (nil ~= case_7_) then
      local s_2a = case_7_
      return s_2a(true)
    else
      local _ = case_7_
      return nil
    end
  end
  local function empty_cons_view()
    return "@seq()"
  end
  local function empty_cons_len()
    return 0
  end
  local function empty_cons_index()
    return nil
  end
  local function cons_newindex()
    return error("cons cell is immutable")
  end
  local function empty_cons_next(_)
    return nil
  end
  local function empty_cons_pairs(s)
    return empty_cons_next, nil, s
  end
  local function gettype(x)
    local case_9_
    do
      local t_10_ = getmetatable(x)
      if (nil ~= t_10_) then
        t_10_ = t_10_["__lazy-seq/type"]
      else
      end
      case_9_ = t_10_
    end
    if (nil ~= case_9_) then
      local t = case_9_
      return t
    else
      local _ = case_9_
      return type(x)
    end
  end
  local function realize(c)
    if ("lazy-cons" == gettype(c)) then
      c()
    else
    end
    return c
  end
  local empty_cons = {}
  local function empty_cons_call(tf)
    if tf then
      return nil
    else
      return empty_cons
    end
  end
  local function empty_cons_fennelrest()
    return empty_cons
  end
  local function empty_cons_eq(_, s)
    return rawequal(getmetatable(empty_cons), getmetatable(realize(s)))
  end
  setmetatable(empty_cons, {__call = empty_cons_call, __len = empty_cons_len, __fennelview = empty_cons_view, __fennelrest = empty_cons_fennelrest, ["__lazy-seq/type"] = "empty-cons", __newindex = cons_newindex, __index = empty_cons_index, __name = "cons", __eq = empty_cons_eq, __pairs = empty_cons_pairs})
  local function rest(s)
    local case_15_ = seq(s)
    if (nil ~= case_15_) then
      local s_2a = case_15_
      return s_2a(false)
    else
      local _ = case_15_
      return empty_cons
    end
  end
  local function seq_3f(x)
    local tp = gettype(x)
    return ((tp == "cons") or (tp == "lazy-cons") or (tp == "empty-cons"))
  end
  local function empty_3f(x)
    return not seq(x)
  end
  local function next(s)
    return seq(realize(rest(seq(s))))
  end
  local function view_seq(list, options, view, indent, elements)
    table.insert(elements, view(first(list), options, indent))
    do
      local tail = next(list)
      if ("cons" == gettype(tail)) then
        view_seq(tail, options, view, indent, elements)
      else
      end
    end
    return elements
  end
  local function pp_seq(list, view, options, indent)
    local items = view_seq(list, options, view, (indent + 5), {})
    local lines
    do
      local tbl_26_ = {}
      local i_27_ = 0
      for i, line in ipairs(items) do
        local val_28_
        if (i == 1) then
          val_28_ = line
        else
          val_28_ = ("     " .. line)
        end
        if (nil ~= val_28_) then
          i_27_ = (i_27_ + 1)
          tbl_26_[i_27_] = val_28_
        else
        end
      end
      lines = tbl_26_
    end
    lines[1] = ("@seq(" .. (lines[1] or ""))
    lines[#lines] = (lines[#lines] .. ")")
    return lines
  end
  local drop = nil
  local function cons_fennelrest(c, i)
    return drop((i - 1), c)
  end
  local allowed_types = {cons = true, ["empty-cons"] = true, ["lazy-cons"] = true, ["nil"] = true, string = true, table = true}
  local function cons_next(_, s)
    if (empty_cons ~= s) then
      local tail = next(s)
      local case_20_ = gettype(tail)
      if (case_20_ == "cons") then
        return tail, first(s)
      else
        local _0 = case_20_
        return empty_cons, first(s)
      end
    else
      return nil
    end
  end
  local function cons_pairs(s)
    return cons_next, nil, s
  end
  local function cons_eq(s1, s2)
    if rawequal(s1, s2) then
      return true
    else
      if (not rawequal(s2, empty_cons) and not rawequal(s1, empty_cons)) then
        local s10, s20, res = s1, s2, true
        while (res and s10 and s20) do
          res = (first(s10) == first(s20))
          s10 = next(s10)
          s20 = next(s20)
        end
        return res
      else
        return false
      end
    end
  end
  local function cons_len(s)
    local s0, len = s, 0
    while s0 do
      s0, len = next(s0), (len + 1)
    end
    return len
  end
  local function cons_index(s, i)
    if (i > 0) then
      local s0, i_2a = s, 1
      while ((i_2a ~= i) and s0) do
        s0, i_2a = next(s0), (i_2a + 1)
      end
      return first(s0)
    else
      return nil
    end
  end
  local function cons(head, tail)
    do local _ = {head, tail} end
    local tp = gettype(tail)
    assert(allowed_types[tp], ("expected nil, cons, table, or string as a tail, got: %s"):format(tp))
    local function _26_(_241, _242)
      if _242 then
        return head
      else
        if (nil ~= tail) then
          local s = tail
          return s
        elseif (tail == nil) then
          return empty_cons
        else
          return nil
        end
      end
    end
    return setmetatable({}, {__call = _26_, ["__lazy-seq/type"] = "cons", __index = cons_index, __newindex = cons_newindex, __len = cons_len, __pairs = cons_pairs, __name = "cons", __eq = cons_eq, __fennelview = pp_seq, __fennelrest = cons_fennelrest})
  end
  local function _29_(s)
    local case_30_ = gettype(s)
    if (case_30_ == "cons") then
      return s
    elseif (case_30_ == "lazy-cons") then
      return seq(realize(s))
    elseif (case_30_ == "empty-cons") then
      return nil
    elseif (case_30_ == "nil") then
      return nil
    elseif (case_30_ == "table") then
      return cons_iter(s)
    elseif (case_30_ == "string") then
      return cons_iter(s)
    else
      local _ = case_30_
      return error(("expected table, string or sequence, got %s"):format(_), 2)
    end
  end
  seq = _29_
  local function lazy_seq_2a(f)
    local lazy_cons = cons(nil, nil)
    local realize0
    local function _32_()
      local s = seq(f())
      if (nil ~= s) then
        return setmetatable(lazy_cons, getmetatable(s))
      else
        return setmetatable(lazy_cons, getmetatable(empty_cons))
      end
    end
    realize0 = _32_
    local function _34_(_241, _242)
      return realize0()(_242)
    end
    local function _35_(_241, _242)
      return realize0()[_242]
    end
    local function _36_(...)
      realize0()
      return pp_seq(...)
    end
    local function _37_()
      return length_2a(realize0())
    end
    local function _38_()
      return pairs_2a(realize0())
    end
    local function _39_(_241, _242)
      return (realize0() == _242)
    end
    return setmetatable(lazy_cons, {__call = _34_, __index = _35_, __newindex = cons_newindex, __fennelview = _36_, __fennelrest = cons_fennelrest, __len = _37_, __pairs = _38_, __name = "lazy cons", __eq = _39_, ["__lazy-seq/type"] = "lazy-cons"})
  end
  local function list(...)
    local args = table_pack(...)
    local l = empty_cons
    for i = args.n, 1, -1 do
      l = cons(args[i], l)
    end
    return l
  end
  local function spread(arglist)
    local arglist0 = seq(arglist)
    if (nil == arglist0) then
      return nil
    elseif (nil == next(arglist0)) then
      return seq(first(arglist0))
    elseif "else" then
      return cons(first(arglist0), spread(next(arglist0)))
    else
      return nil
    end
  end
  local function list_2a(...)
    local case_41_, case_42_, case_43_, case_44_, case_45_ = select("#", ...), ...
    if ((case_41_ == 1) and true) then
      local _3fargs = case_42_
      return seq(_3fargs)
    elseif ((case_41_ == 2) and true and true) then
      local _3fa = case_42_
      local _3fargs = case_43_
      return cons(_3fa, seq(_3fargs))
    elseif ((case_41_ == 3) and true and true and true) then
      local _3fa = case_42_
      local _3fb = case_43_
      local _3fargs = case_44_
      return cons(_3fa, cons(_3fb, seq(_3fargs)))
    elseif ((case_41_ == 4) and true and true and true and true) then
      local _3fa = case_42_
      local _3fb = case_43_
      local _3fc = case_44_
      local _3fargs = case_45_
      return cons(_3fa, cons(_3fb, cons(_3fc, seq(_3fargs))))
    else
      local _ = case_41_
      return spread(list(...))
    end
  end
  local function kind(t)
    local case_47_ = type(t)
    if (case_47_ == "table") then
      local len = length_2a(t)
      local nxt, t_2a, k = pairs_2a(t)
      local function _48_()
        if (len == 0) then
          return k
        else
          return len
        end
      end
      if (nil ~= nxt(t_2a, _48_())) then
        return "assoc"
      elseif (len > 0) then
        return "seq"
      else
        return "empty"
      end
    elseif (case_47_ == "string") then
      local len
      if utf8 then
        len = utf8.len(t)
      else
        len = #t
      end
      if (len > 0) then
        return "string"
      else
        return "empty"
      end
    else
      local _ = case_47_
      return "else"
    end
  end
  local function rseq(rev)
    local case_53_ = gettype(rev)
    if (case_53_ == "table") then
      local case_54_ = kind(rev)
      if (case_54_ == "seq") then
        local function wrap(nxt, t, i)
          local i0, v = nxt(t, i)
          if (nil ~= i0) then
            local function _55_()
              return wrap(nxt, t, i0)
            end
            return cons(v, lazy_seq_2a(_55_))
          else
            return empty_cons
          end
        end
        return wrap(rev_ipairs(rev))
      elseif (case_54_ == "empty") then
        return nil
      else
        local _ = case_54_
        return error("can't create an rseq from a non-sequential table")
      end
    else
      local _ = case_53_
      return error(("can't create an rseq from a " .. _))
    end
  end
  local function _59_(t)
    local case_60_ = kind(t)
    if (case_60_ == "assoc") then
      local function wrap(nxt, t0, k)
        local k0, v = nxt(t0, k)
        if (nil ~= k0) then
          local function _61_()
            return wrap(nxt, t0, k0)
          end
          return cons({k0, v}, lazy_seq_2a(_61_))
        else
          return empty_cons
        end
      end
      return wrap(pairs_2a(t))
    elseif (case_60_ == "seq") then
      local function wrap(nxt, t0, i)
        local i0, v = nxt(t0, i)
        if (nil ~= i0) then
          local function _63_()
            return wrap(nxt, t0, i0)
          end
          return cons(v, lazy_seq_2a(_63_))
        else
          return empty_cons
        end
      end
      return wrap(ipairs_2a(t))
    elseif (case_60_ == "string") then
      local char
      if utf8 then
        char = utf8.char
      else
        char = string.char
      end
      local function wrap(nxt, t0, i)
        local i0, v = nxt(t0, i)
        if (nil ~= i0) then
          local function _66_()
            return wrap(nxt, t0, i0)
          end
          return cons(char(v), lazy_seq_2a(_66_))
        else
          return empty_cons
        end
      end
      local function _68_()
        if utf8 then
          return utf8.codes(t)
        else
          return ipairs_2a({string.byte(t, 1, #t)})
        end
      end
      return wrap(_68_())
    elseif (case_60_ == "empty") then
      return nil
    else
      return nil
    end
  end
  cons_iter = _59_
  local function every_3f(pred, coll)
    local case_70_ = seq(coll)
    if (nil ~= case_70_) then
      local s = case_70_
      if pred(first(s)) then
        local case_71_ = next(s)
        if (nil ~= case_71_) then
          local r = case_71_
          return every_3f(pred, r)
        else
          local _ = case_71_
          return true
        end
      else
        return false
      end
    else
      local _ = case_70_
      return false
    end
  end
  local function some_3f(pred, coll)
    local case_75_ = seq(coll)
    if (nil ~= case_75_) then
      local s = case_75_
      local or_76_ = pred(first(s))
      if not or_76_ then
        local case_77_ = next(s)
        if (nil ~= case_77_) then
          local r = case_77_
          or_76_ = some_3f(pred, r)
        else
          local _ = case_77_
          or_76_ = nil
        end
      end
      return or_76_
    else
      local _ = case_75_
      return nil
    end
  end
  local function pack(s)
    local res = {}
    local n = 0
    do
      local case_83_ = seq(s)
      if (nil ~= case_83_) then
        local s_2a = case_83_
        for _, v in pairs_2a(s_2a) do
          n = (n + 1)
          res[n] = v
        end
      else
      end
    end
    res["n"] = n
    return res
  end
  local function count(s)
    local case_85_ = seq(s)
    if (nil ~= case_85_) then
      local s_2a = case_85_
      return length_2a(s_2a)
    else
      local _ = case_85_
      return 0
    end
  end
  local function unpack(s)
    local t = pack(s)
    return table_unpack(t, 1, t.n)
  end
  local function concat(...)
    local case_87_ = select("#", ...)
    if (case_87_ == 0) then
      return empty_cons
    elseif (case_87_ == 1) then
      local x = ...
      local function _88_()
        return x
      end
      return lazy_seq_2a(_88_)
    elseif (case_87_ == 2) then
      local x, y = ...
      local function _89_()
        local case_90_ = seq(x)
        if (nil ~= case_90_) then
          local s = case_90_
          return cons(first(s), concat(rest(s), y))
        elseif (case_90_ == nil) then
          return y
        else
          return nil
        end
      end
      return lazy_seq_2a(_89_)
    else
      local _ = case_87_
      local pv_92_, pv_93_ = ...
      return concat(concat(pv_92_, pv_93_), select(3, ...))
    end
  end
  local function reverse(s)
    local function helper(s0, res)
      local case_95_ = seq(s0)
      if (nil ~= case_95_) then
        local s_2a = case_95_
        return helper(rest(s_2a), cons(first(s_2a), res))
      else
        local _ = case_95_
        return res
      end
    end
    return helper(s, empty_cons)
  end
  local function map(f, ...)
    local case_97_ = select("#", ...)
    if (case_97_ == 0) then
      return nil
    elseif (case_97_ == 1) then
      local col = ...
      local function _98_()
        local case_99_ = seq(col)
        if (nil ~= case_99_) then
          local x = case_99_
          return cons(f(first(x)), map(f, seq(rest(x))))
        else
          local _ = case_99_
          return nil
        end
      end
      return lazy_seq_2a(_98_)
    elseif (case_97_ == 2) then
      local s1, s2 = ...
      local function _101_()
        local s10 = seq(s1)
        local s20 = seq(s2)
        if (s10 and s20) then
          return cons(f(first(s10), first(s20)), map(f, rest(s10), rest(s20)))
        else
          return nil
        end
      end
      return lazy_seq_2a(_101_)
    elseif (case_97_ == 3) then
      local s1, s2, s3 = ...
      local function _103_()
        local s10 = seq(s1)
        local s20 = seq(s2)
        local s30 = seq(s3)
        if (s10 and s20 and s30) then
          return cons(f(first(s10), first(s20), first(s30)), map(f, rest(s10), rest(s20), rest(s30)))
        else
          return nil
        end
      end
      return lazy_seq_2a(_103_)
    else
      local _ = case_97_
      local s = list(...)
      local function _105_()
        local function _106_(_2410)
          return (nil ~= seq(_2410))
        end
        if every_3f(_106_, s) then
          return cons(f(unpack(map(first, s))), map(f, unpack(map(rest, s))))
        else
          return nil
        end
      end
      return lazy_seq_2a(_105_)
    end
  end
  local function map_indexed(f, coll)
    local mapi
    local function mapi0(idx, coll0)
      local function _109_()
        local case_110_ = seq(coll0)
        if (nil ~= case_110_) then
          local s = case_110_
          return cons(f(idx, first(s)), mapi0((idx + 1), rest(s)))
        else
          local _ = case_110_
          return nil
        end
      end
      return lazy_seq_2a(_109_)
    end
    mapi = mapi0
    return mapi(1, coll)
  end
  local function mapcat(f, ...)
    local step
    local function step0(colls)
      local function _112_()
        local case_113_ = seq(colls)
        if (nil ~= case_113_) then
          local s = case_113_
          local c = first(s)
          return concat(c, step0(rest(colls)))
        else
          local _ = case_113_
          return nil
        end
      end
      return lazy_seq_2a(_112_)
    end
    step = step0
    return step(map(f, ...))
  end
  local function take(n, coll)
    local function _115_()
      if (n > 0) then
        local case_116_ = seq(coll)
        if (nil ~= case_116_) then
          local s = case_116_
          return cons(first(s), take((n - 1), rest(s)))
        else
          local _ = case_116_
          return nil
        end
      else
        return nil
      end
    end
    return lazy_seq_2a(_115_)
  end
  local function take_while(pred, coll)
    local function _119_()
      local case_120_ = seq(coll)
      if (nil ~= case_120_) then
        local s = case_120_
        local v = first(s)
        if pred(v) then
          return cons(v, take_while(pred, rest(s)))
        else
          return nil
        end
      else
        local _ = case_120_
        return nil
      end
    end
    return lazy_seq_2a(_119_)
  end
  local function _123_(n, coll)
    local step
    local function step0(n0, coll0)
      local s = seq(coll0)
      if ((n0 > 0) and s) then
        return step0((n0 - 1), rest(s))
      else
        return s
      end
    end
    step = step0
    local function _125_()
      return step(n, coll)
    end
    return lazy_seq_2a(_125_)
  end
  drop = _123_
  local function drop_while(pred, coll)
    local step
    local function step0(pred0, coll0)
      local s = seq(coll0)
      if (s and pred0(first(s))) then
        return step0(pred0, rest(s))
      else
        return s
      end
    end
    step = step0
    local function _127_()
      return step(pred, coll)
    end
    return lazy_seq_2a(_127_)
  end
  local function drop_last(...)
    local case_128_ = select("#", ...)
    if (case_128_ == 0) then
      return empty_cons
    elseif (case_128_ == 1) then
      return drop_last(1, ...)
    else
      local _ = case_128_
      local n, coll = ...
      local function _129_(x)
        return x
      end
      return map(_129_, coll, drop(n, coll))
    end
  end
  local function take_last(n, coll)
    local function loop(s, lead)
      if lead then
        return loop(next(s), next(lead))
      else
        return s
      end
    end
    return loop(seq(coll), seq(drop(n, coll)))
  end
  local function take_nth(n, coll)
    local function _132_()
      local case_133_ = seq(coll)
      if (nil ~= case_133_) then
        local s = case_133_
        return cons(first(s), take_nth(n, drop(n, s)))
      else
        return nil
      end
    end
    return lazy_seq_2a(_132_)
  end
  local function split_at(n, coll)
    return {take(n, coll), drop(n, coll)}
  end
  local function split_with(pred, coll)
    return {take_while(pred, coll), drop_while(pred, coll)}
  end
  local function filter(pred, coll)
    local function _135_()
      local case_136_ = seq(coll)
      if (nil ~= case_136_) then
        local s = case_136_
        local x = first(s)
        local r = rest(s)
        if pred(x) then
          return cons(x, filter(pred, r))
        else
          return filter(pred, r)
        end
      else
        local _ = case_136_
        return nil
      end
    end
    return lazy_seq_2a(_135_)
  end
  local function keep(f, coll)
    local function _139_()
      local case_140_ = seq(coll)
      if (nil ~= case_140_) then
        local s = case_140_
        local case_141_ = f(first(s))
        if (nil ~= case_141_) then
          local x = case_141_
          return cons(x, keep(f, rest(s)))
        elseif (case_141_ == nil) then
          return keep(f, rest(s))
        else
          return nil
        end
      else
        local _ = case_140_
        return nil
      end
    end
    return lazy_seq_2a(_139_)
  end
  local function keep_indexed(f, coll)
    local keepi
    local function keepi0(idx, coll0)
      local function _144_()
        local case_145_ = seq(coll0)
        if (nil ~= case_145_) then
          local s = case_145_
          local x = f(idx, first(s))
          if (nil == x) then
            return keepi0((1 + idx), rest(s))
          else
            return cons(x, keepi0((1 + idx), rest(s)))
          end
        else
          return nil
        end
      end
      return lazy_seq_2a(_144_)
    end
    keepi = keepi0
    return keepi(1, coll)
  end
  local function remove(pred, coll)
    local function _148_(_241)
      return not pred(_241)
    end
    return filter(_148_, coll)
  end
  local function cycle(coll)
    local function _149_()
      return concat(seq(coll), cycle(coll))
    end
    return lazy_seq_2a(_149_)
  end
  local function _repeat(x)
    local function step(x0)
      local function _150_()
        return cons(x0, step(x0))
      end
      return lazy_seq_2a(_150_)
    end
    return step(x)
  end
  local function repeatedly(f, ...)
    local args = table_pack(...)
    local f0
    local function _151_()
      return f(table_unpack(args, 1, args.n))
    end
    f0 = _151_
    local function step(f1)
      local function _152_()
        return cons(f1(), step(f1))
      end
      return lazy_seq_2a(_152_)
    end
    return step(f0)
  end
  local function iterate(f, x)
    local x_2a = f(x)
    local function _153_()
      return iterate(f, x_2a)
    end
    return cons(x, lazy_seq_2a(_153_))
  end
  local function nthnext(coll, n)
    local function loop(n0, xs)
      local and_154_ = (nil ~= xs)
      if and_154_ then
        local xs_2a = xs
        and_154_ = (n0 > 0)
      end
      if and_154_ then
        local xs_2a = xs
        return loop((n0 - 1), next(xs_2a))
      else
        local _ = xs
        return xs
      end
    end
    return loop(n, seq(coll))
  end
  local function nthrest(coll, n)
    local function loop(n0, xs)
      local case_157_ = seq(xs)
      local and_158_ = (nil ~= case_157_)
      if and_158_ then
        local xs_2a = case_157_
        and_158_ = (n0 > 0)
      end
      if and_158_ then
        local xs_2a = case_157_
        return loop((n0 - 1), rest(xs_2a))
      else
        local _ = case_157_
        return xs
      end
    end
    return loop(n, coll)
  end
  local function dorun(s)
    local case_161_ = seq(s)
    if (nil ~= case_161_) then
      local s_2a = case_161_
      return dorun(next(s_2a))
    else
      local _ = case_161_
      return nil
    end
  end
  local function doall(s)
    dorun(s)
    return s
  end
  local function partition(...)
    local case_163_ = select("#", ...)
    if (case_163_ == 2) then
      local n, coll = ...
      return partition(n, n, coll)
    elseif (case_163_ == 3) then
      local n, step, coll = ...
      local function _164_()
        local case_165_ = seq(coll)
        if (nil ~= case_165_) then
          local s = case_165_
          local p = take(n, s)
          if (n == length_2a(p)) then
            return cons(p, partition(n, step, nthrest(s, step)))
          else
            return nil
          end
        else
          local _ = case_165_
          return nil
        end
      end
      return lazy_seq_2a(_164_)
    elseif (case_163_ == 4) then
      local n, step, pad, coll = ...
      local function _168_()
        local case_169_ = seq(coll)
        if (nil ~= case_169_) then
          local s = case_169_
          local p = take(n, s)
          if (n == length_2a(p)) then
            return cons(p, partition(n, step, pad, nthrest(s, step)))
          else
            return list(take(n, concat(p, pad)))
          end
        else
          local _ = case_169_
          return nil
        end
      end
      return lazy_seq_2a(_168_)
    else
      local _ = case_163_
      return error("wrong amount arguments to 'partition'")
    end
  end
  local function partition_by(f, coll)
    local function _173_()
      local case_174_ = seq(coll)
      if (nil ~= case_174_) then
        local s = case_174_
        local v = first(s)
        local fv = f(v)
        local run
        local function _175_(_2410)
          return (fv == f(_2410))
        end
        run = cons(v, take_while(_175_, next(s)))
        local function _176_()
          return drop(length_2a(run), s)
        end
        return cons(run, partition_by(f, lazy_seq_2a(_176_)))
      else
        return nil
      end
    end
    return lazy_seq_2a(_173_)
  end
  local function partition_all(...)
    local case_178_ = select("#", ...)
    if (case_178_ == 2) then
      local n, coll = ...
      return partition_all(n, n, coll)
    elseif (case_178_ == 3) then
      local n, step, coll = ...
      local function _179_()
        local case_180_ = seq(coll)
        if (nil ~= case_180_) then
          local s = case_180_
          local p = take(n, s)
          return cons(p, partition_all(n, step, nthrest(s, step)))
        else
          local _ = case_180_
          return nil
        end
      end
      return lazy_seq_2a(_179_)
    else
      local _ = case_178_
      return error("wrong amount arguments to 'partition-all'")
    end
  end
  local function reductions(...)
    local case_183_ = select("#", ...)
    if (case_183_ == 2) then
      local f, coll = ...
      local function _184_()
        local case_185_ = seq(coll)
        if (nil ~= case_185_) then
          local s = case_185_
          return reductions(f, first(s), rest(s))
        else
          local _ = case_185_
          return list(f())
        end
      end
      return lazy_seq_2a(_184_)
    elseif (case_183_ == 3) then
      local f, init, coll = ...
      local function _187_()
        local case_188_ = seq(coll)
        if (nil ~= case_188_) then
          local s = case_188_
          return reductions(f, f(init, first(s)), rest(s))
        else
          return nil
        end
      end
      return cons(init, lazy_seq_2a(_187_))
    else
      local _ = case_183_
      return error("wrong amount arguments to 'reductions'")
    end
  end
  local function contains_3f(coll, elt)
    local case_191_ = gettype(coll)
    if (case_191_ == "table") then
      local case_192_ = kind(coll)
      if (case_192_ == "seq") then
        local res = false
        for _, v in ipairs_2a(coll) do
          if res then break end
          if (elt == v) then
            res = true
          else
            res = false
          end
        end
        return res
      elseif (case_192_ == "assoc") then
        if coll[elt] then
          return true
        else
          return false
        end
      else
        return nil
      end
    else
      local _ = case_191_
      local function loop(coll0)
        local case_196_ = seq(coll0)
        if (nil ~= case_196_) then
          local s = case_196_
          if (elt == first(s)) then
            return true
          else
            return loop(rest(s))
          end
        elseif (case_196_ == nil) then
          return false
        else
          return nil
        end
      end
      return loop(coll)
    end
  end
  local function distinct(coll)
    local function step(xs, seen)
      local loop
      local function loop0(_200_, seen0)
        local f = _200_[1]
        local xs0 = _200_
        local case_201_ = seq(xs0)
        if (nil ~= case_201_) then
          local s = case_201_
          if seen0[f] then
            return loop0(rest(s), seen0)
          else
            local function _202_()
              seen0[f] = true
              return seen0
            end
            return cons(f, step(rest(s), _202_()))
          end
        else
          local _ = case_201_
          return nil
        end
      end
      loop = loop0
      local function _205_()
        return loop(xs, seen)
      end
      return lazy_seq_2a(_205_)
    end
    return step(coll, {})
  end
  local function inf_range(x, step)
    local function _206_()
      return cons(x, inf_range((x + step), step))
    end
    return lazy_seq_2a(_206_)
  end
  local function fix_range(x, _end, step)
    local function _207_()
      if (((step >= 0) and (x < _end)) or ((step < 0) and (x > _end))) then
        return cons(x, fix_range((x + step), _end, step))
      elseif ((step == 0) and (x ~= _end)) then
        return cons(x, fix_range(x, _end, step))
      else
        return nil
      end
    end
    return lazy_seq_2a(_207_)
  end
  local function range(...)
    local case_209_ = select("#", ...)
    if (case_209_ == 0) then
      return inf_range(0, 1)
    elseif (case_209_ == 1) then
      local _end = ...
      return fix_range(0, _end, 1)
    elseif (case_209_ == 2) then
      local x, _end = ...
      return fix_range(x, _end, 1)
    else
      local _ = case_209_
      return fix_range(...)
    end
  end
  local function realized_3f(s)
    local case_211_ = gettype(s)
    if (case_211_ == "lazy-cons") then
      return false
    elseif (case_211_ == "empty-cons") then
      return true
    elseif (case_211_ == "cons") then
      return true
    else
      local _ = case_211_
      return error(("expected a sequence, got: %s"):format(_))
    end
  end
  local function line_seq(file)
    local next_line = file:lines()
    local function step(f)
      local line = f()
      if ("string" == type(line)) then
        local function _213_()
          return step(f)
        end
        return cons(line, lazy_seq_2a(_213_))
      else
        return nil
      end
    end
    return step(next_line)
  end
  local function tree_seq(branch_3f, children, root)
    local function walk(node)
      local function _215_()
        local function _216_()
          if branch_3f(node) then
            return mapcat(walk, children(node))
          else
            return nil
          end
        end
        return cons(node, _216_())
      end
      return lazy_seq_2a(_215_)
    end
    return walk(root)
  end
  local function interleave(...)
    local case_217_, case_218_, case_219_ = select("#", ...), ...
    if (case_217_ == 0) then
      return empty_cons
    elseif ((case_217_ == 1) and true) then
      local _3fs = case_218_
      local function _220_()
        return _3fs
      end
      return lazy_seq_2a(_220_)
    elseif ((case_217_ == 2) and true and true) then
      local _3fs1 = case_218_
      local _3fs2 = case_219_
      local function _221_()
        local s1 = seq(_3fs1)
        local s2 = seq(_3fs2)
        if (s1 and s2) then
          return cons(first(s1), cons(first(s2), interleave(rest(s1), rest(s2))))
        else
          return nil
        end
      end
      return lazy_seq_2a(_221_)
    elseif true then
      local _ = case_217_
      local cols = list(...)
      local function _223_()
        local seqs = map(seq, cols)
        local function _224_(_2410)
          return (nil ~= seq(_2410))
        end
        if every_3f(_224_, seqs) then
          return concat(map(first, seqs), interleave(unpack(map(rest, seqs))))
        else
          return nil
        end
      end
      return lazy_seq_2a(_223_)
    else
      return nil
    end
  end
  local function interpose(separator, coll)
    return drop(1, interleave(_repeat(separator), coll))
  end
  local function keys(t)
    assert(("assoc" == kind(t)), "expected an associative table")
    local function _227_(_241)
      return _241[1]
    end
    return map(_227_, t)
  end
  local function vals(t)
    assert(("assoc" == kind(t)), "expected an associative table")
    local function _228_(_241)
      return _241[2]
    end
    return map(_228_, t)
  end
  local function zipmap(keys0, vals0)
    local t = {}
    local function loop(s1, s2)
      if (s1 and s2) then
        t[first(s1)] = first(s2)
        return loop(next(s1), next(s2))
      else
        return nil
      end
    end
    loop(seq(keys0), seq(vals0))
    return t
  end
  local _local_230_ = require("io.gitlab.andreyorst.reduced")
  local reduced = _local_230_.reduced
  local reduced_3f = _local_230_["reduced?"]
  local function reduce(f, ...)
    local case_231_, case_232_, case_233_ = select("#", ...), ...
    if (case_231_ == 0) then
      return error("expected a collection")
    elseif ((case_231_ == 1) and true) then
      local _3fcoll = case_232_
      local case_234_ = count(_3fcoll)
      if (case_234_ == 0) then
        return f()
      elseif (case_234_ == 1) then
        return first(_3fcoll)
      else
        local _ = case_234_
        return reduce(f, first(_3fcoll), rest(_3fcoll))
      end
    elseif ((case_231_ == 2) and true and true) then
      local _3fval = case_232_
      local _3fcoll = case_233_
      local case_236_ = seq(_3fcoll)
      if (nil ~= case_236_) then
        local coll = case_236_
        local done_3f = false
        local res = _3fval
        for _, v in pairs_2a(coll) do
          if done_3f then break end
          local res0 = f(res, v)
          if reduced_3f(res0) then
            done_3f = true
            res = res0:unbox()
          else
            res = res0
          end
        end
        return res
      else
        local _ = case_236_
        return _3fval
      end
    else
      return nil
    end
  end
  return {first = first, rest = rest, nthrest = nthrest, next = next, nthnext = nthnext, cons = cons, seq = seq, rseq = rseq, ["seq?"] = seq_3f, ["empty?"] = empty_3f, ["lazy-seq*"] = lazy_seq_2a, list = list, ["list*"] = list_2a, ["every?"] = every_3f, ["some?"] = some_3f, pack = pack, unpack = unpack, count = count, concat = concat, map = map, ["map-indexed"] = map_indexed, mapcat = mapcat, take = take, ["take-while"] = take_while, ["take-last"] = take_last, ["take-nth"] = take_nth, drop = drop, ["drop-while"] = drop_while, ["drop-last"] = drop_last, remove = remove, ["split-at"] = split_at, ["split-with"] = split_with, partition = partition, ["partition-by"] = partition_by, ["partition-all"] = partition_all, filter = filter, keep = keep, ["keep-indexed"] = keep_indexed, ["contains?"] = contains_3f, distinct = distinct, cycle = cycle, ["repeat"] = _repeat, repeatedly = repeatedly, reductions = reductions, iterate = iterate, range = range, ["realized?"] = realized_3f, dorun = dorun, doall = doall, ["line-seq"] = line_seq, ["tree-seq"] = tree_seq, reverse = reverse, interleave = interleave, interpose = interpose, keys = keys, vals = vals, zipmap = zipmap, reduce = reduce, reduced = reduced, ["reduced?"] = reduced_3f, __VERSION = "0.1.127"}
end
package.preload["io.gitlab.andreyorst.reduced"] = package.preload["io.gitlab.andreyorst.reduced"] or function(...)
  --[[ MIT License
  
    Copyright (c) 2023 Andrey Listopadov
  
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the “Software”), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
  
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
  
    THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE. ]]
  
  local lib_include_path = ...
  
  if lib_include_path ~= "io.gitlab.andreyorst.reduced" then
    local msg = [[Invalid usage of the Reduced library: required as "%s" not as "io.gitlab.andreyorst.reduced".
  
  The Reduced library must be required by callind require with the string "io.gitlab.andreyorst.reduced" as the argument.
  This ensures that all of the code across all libraries uses the same entry from package.loaded.]]
    error(msg:format(lib_include_path))
  end
  
  local Reduced = {
    __index = {unbox = function (x) return x[1] end},
    __fennelview = function (x, view, options, indent)
      return "#<reduced: " .. view(x[1], options, (11 + indent)) .. ">"
    end,
    __name = "reduced",
    __tostring = function (x) return ("reduced: " .. tostring(x[1])) end
  }
  
  local function reduced(value) return setmetatable({value}, Reduced) end
  local function is_reduced(value) return rawequal(getmetatable(value), Reduced) end
  
  return {reduced = reduced, ["reduced?"] = is_reduced, is_reduced = is_reduced}
end
package.preload["io.gitlab.andreyorst.itable"] = package.preload["io.gitlab.andreyorst.itable"] or function(...)
  local t_2fsort = table.sort
  local t_2fconcat = table.concat
  local t_2fremove = table.remove
  local t_2fmove = table.move
  local t_2finsert = table.insert
  local itable = {__VERSION = "0.1.31"}
  local t_2funpack = (table.unpack or _G.unpack)
  local pairs_2a
  itable.pairs = function(t)
    local _241_
    do
      local case_240_ = getmetatable(t)
      if ((_G.type(case_240_) == "table") and (nil ~= case_240_.__pairs)) then
        local p = case_240_.__pairs
        _241_ = p
      else
        local _ = case_240_
        _241_ = pairs
      end
    end
    return _241_(t)
  end
  pairs_2a = itable.pairs
  local ipairs_2a
  itable.ipairs = function(t)
    local _246_
    do
      local case_245_ = getmetatable(t)
      if ((_G.type(case_245_) == "table") and (nil ~= case_245_.__ipairs)) then
        local i = case_245_.__ipairs
        _246_ = i
      else
        local _ = case_245_
        _246_ = ipairs
      end
    end
    return _246_(t)
  end
  ipairs_2a = itable.ipairs
  local length_2a
  itable.length = function(t)
    local _251_
    do
      local case_250_ = getmetatable(t)
      if ((_G.type(case_250_) == "table") and (nil ~= case_250_.__len)) then
        local l = case_250_.__len
        _251_ = l
      else
        local _ = case_250_
        local function _254_(...)
          return #...
        end
        _251_ = _254_
      end
    end
    return _251_(t)
  end
  length_2a = itable.length
  local function copy(t)
    if t then
      local tbl_21_ = {}
      for k, v in pairs_2a(t) do
        local k_22_, v_23_ = k, v
        if ((k_22_ ~= nil) and (v_23_ ~= nil)) then
          tbl_21_[k_22_] = v_23_
        else
        end
      end
      return tbl_21_
    else
      return nil
    end
  end
  local function eq(...)
    local case_258_, case_259_, case_260_ = select("#", ...), ...
    if ((case_258_ == 0) or (case_258_ == 1)) then
      return true
    elseif ((case_258_ == 2) and true and true) then
      local _3fa = case_259_
      local _3fb = case_260_
      if (_3fa == _3fb) then
        return true
      else
        local _261_ = type(_3fb)
        if ((type(_3fa) == _261_) and (_261_ == "table")) then
          local res, count_a, count_b = true, 0, 0
          for k, v in pairs_2a(_3fa) do
            if not res then break end
            local function _262_(...)
              local res0 = nil
              for k_2a, v0 in pairs_2a(_3fb) do
                if res0 then break end
                if eq(k_2a, k) then
                  res0 = v0
                else
                end
              end
              return res0
            end
            res = eq(v, _262_(...))
            count_a = (count_a + 1)
          end
          if res then
            for _, _0 in pairs_2a(_3fb) do
              count_b = (count_b + 1)
            end
            res = (count_a == count_b)
          else
          end
          return res
        else
          return false
        end
      end
    elseif (true and true and true) then
      local _ = case_258_
      local _3fa = case_259_
      local _3fb = case_260_
      return (eq(_3fa, _3fb) and eq(select(2, ...)))
    else
      return nil
    end
  end
  itable.eq = eq
  local function deep_index(tbl, key)
    local res = nil
    for k, v in pairs_2a(tbl) do
      if res then break end
      if eq(k, key) then
        res = v
      else
        res = nil
      end
    end
    return res
  end
  local function deep_newindex(tbl, key, val)
    local done = false
    if ("table" == type(key)) then
      for k, _ in pairs_2a(tbl) do
        if done then break end
        if eq(k, key) then
          rawset(tbl, k, val)
          done = true
        else
        end
      end
    else
    end
    if not done then
      return rawset(tbl, key, val)
    else
      return nil
    end
  end
  local function immutable(t, opts)
    local t0
    if (opts and opts["fast-index?"]) then
      t0 = t
    else
      t0 = setmetatable(t, {__index = deep_index, __newindex = deep_newindex})
    end
    local len = length_2a(t0)
    local proxy = {}
    local __len
    local function _272_()
      return len
    end
    __len = _272_
    local __index
    local function _273_(_241, _242)
      return t0[_242]
    end
    __index = _273_
    local __newindex
    local function _274_()
      return error((tostring(proxy) .. " is immutable"), 2)
    end
    __newindex = _274_
    local __pairs
    local function _275_()
      local function _276_(_, k)
        return next(t0, k)
      end
      return _276_, nil, nil
    end
    __pairs = _275_
    local __ipairs
    local function _277_()
      local function _278_(_, k)
        return next(t0, k)
      end
      return _278_
    end
    __ipairs = _277_
    local __call
    local function _279_(_241, _242)
      return t0[_242]
    end
    __call = _279_
    local __fennelview
    local function _280_(_241, _242, _243, _244)
      return _242(t0, _243, _244)
    end
    __fennelview = _280_
    local __fennelrest
    local function _281_(_241, _242)
      return immutable({t_2funpack(t0, _242)})
    end
    __fennelrest = _281_
    return setmetatable(proxy, {__index = __index, __newindex = __newindex, __len = __len, __pairs = __pairs, __ipairs = __ipairs, __call = __call, __metatable = {__len = __len, __pairs = __pairs, __ipairs = __ipairs, __call = __call, __fennelrest = __fennelrest, __fennelview = __fennelview, __index = itable}})
  end
  itable.immutable = immutable
  itable.insert = function(t, ...)
    local t0 = copy(t)
    do
      local case_282_, case_283_, case_284_ = select("#", ...), ...
      if (case_282_ == 0) then
        error("wrong number of arguments to 'insert'")
      elseif ((case_282_ == 1) and true) then
        local _3fv = case_283_
        t_2finsert(t0, _3fv)
      elseif (true and true and true) then
        local _ = case_282_
        local _3fk = case_283_
        local _3fv = case_284_
        t_2finsert(t0, _3fk, _3fv)
      else
      end
    end
    return immutable(t0)
  end
  if t_2fmove then
    local function _286_(src, start, _end, tgt, dest)
      local src0 = copy(src)
      local dest0 = copy(dest)
      return immutable(t_2fmove(src0, start, _end, tgt, dest0))
    end
    itable.move = _286_
  else
    itable.move = nil
  end
  itable.pack = function(...)
    local function _288_(...)
      local tmp_9_ = {...}
      tmp_9_["n"] = select("#", ...)
      return tmp_9_
    end
    return immutable(_288_(...))
  end
  local function remove(t, key)
    local t0 = copy(t)
    local v = t_2fremove(t0, key)
    return immutable(t0), v
  end
  itable.remove = remove
  itable.concat = function(t, sep, start, _end, serializer, opts)
    local serializer0 = (serializer or tostring)
    local _289_
    do
      local tbl_26_ = {}
      local i_27_ = 0
      for _, v in ipairs_2a(t) do
        local val_28_ = serializer0(v, opts)
        if (nil ~= val_28_) then
          i_27_ = (i_27_ + 1)
          tbl_26_[i_27_] = val_28_
        else
        end
      end
      _289_ = tbl_26_
    end
    return t_2fconcat(_289_, sep, start, _end)
  end
  itable.unpack = function(t, ...)
    return t_2funpack(copy(t), ...)
  end
  local function assoc(t, key, val, ...)
    local len = select("#", ...)
    if (0 ~= (len % 2)) then
      error(("no value supplied for key " .. tostring(select(len, ...))), 2)
    else
    end
    local t0
    do
      local tmp_9_ = copy(t)
      tmp_9_[key] = val
      t0 = tmp_9_
    end
    for i = 1, len, 2 do
      local k, v = select(i, ...)
      t0[k] = v
    end
    return immutable(t0)
  end
  itable.assoc = assoc
  local function assoc_in(t, _292_, val)
    local k = _292_[1]
    local ks = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_292_, 2)
    local t0 = (t or {})
    print(ks)
    if next(ks) then
      return assoc(t0, k, assoc_in((t0[k] or {}), ks, val))
    else
      return assoc(t0, k, val)
    end
  end
  itable["assoc-in"] = assoc_in
  local function update(t, key, f)
    local function _294_()
      local tmp_9_ = copy(t)
      tmp_9_[key] = f(t[key])
      return tmp_9_
    end
    return immutable(_294_())
  end
  itable.update = update
  local function update_in(t, _295_, f)
    local k = _295_[1]
    local ks = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_295_, 2)
    local t0 = (t or {})
    if next(ks) then
      return assoc(t0, k, update_in(t0[k], ks, f))
    else
      return update(t0, k, f)
    end
  end
  itable["update-in"] = update_in
  itable.deepcopy = function(x)
    local function deepcopy_2a(x0, seen)
      local case_297_ = type(x0)
      if (case_297_ == "table") then
        local case_298_ = seen[x0]
        if (case_298_ == true) then
          return error("immutable tables can't contain self reference", 2)
        else
          local _ = case_298_
          seen[x0] = true
          local function _299_()
            local tbl_21_ = {}
            for k, v in pairs_2a(x0) do
              local k_22_, v_23_ = deepcopy_2a(k, seen), deepcopy_2a(v, seen)
              if ((k_22_ ~= nil) and (v_23_ ~= nil)) then
                tbl_21_[k_22_] = v_23_
              else
              end
            end
            return tbl_21_
          end
          return immutable(_299_())
        end
      else
        local _ = case_297_
        return x0
      end
    end
    return deepcopy_2a(x, {})
  end
  itable.first = function(_303_)
    local x = _303_[1]
    return x
  end
  itable.rest = function(t)
    return (remove(t, 1))
  end
  local function nthrest(t, n)
    local t_2a = {}
    for i = (n + 1), length_2a(t) do
      t_2finsert(t_2a, t[i])
    end
    return immutable(t_2a)
  end
  itable.nthrest = nthrest
  itable.last = function(t)
    return t[length_2a(t)]
  end
  itable.butlast = function(t)
    return (remove(t, length_2a(t)))
  end
  local function join(...)
    local case_304_, case_305_, case_306_ = select("#", ...), ...
    if (case_304_ == 0) then
      return nil
    elseif ((case_304_ == 1) and true) then
      local _3ft = case_305_
      return immutable(copy(_3ft))
    elseif ((case_304_ == 2) and true and true) then
      local _3ft1 = case_305_
      local _3ft2 = case_306_
      local to = copy(_3ft1)
      local from = (_3ft2 or {})
      for _, v in ipairs_2a(from) do
        t_2finsert(to, v)
      end
      return immutable(to)
    elseif (true and true and true) then
      local _ = case_304_
      local _3ft1 = case_305_
      local _3ft2 = case_306_
      return join(join(_3ft1, _3ft2), select(3, ...))
    else
      return nil
    end
  end
  itable.join = join
  local function take(n, t)
    local t_2a = {}
    for i = 1, n do
      t_2finsert(t_2a, t[i])
    end
    return immutable(t_2a)
  end
  itable.take = take
  itable.drop = function(n, t)
    return nthrest(t, n)
  end
  itable.partition = function(...)
    local res = {}
    local function partition_2a(...)
      local case_308_, case_309_, case_310_, case_311_, case_312_ = select("#", ...), ...
      if ((case_308_ == 0) or (case_308_ == 1)) then
        return error("wrong amount arguments to 'partition'")
      elseif ((case_308_ == 2) and true and true) then
        local _3fn = case_309_
        local _3ft = case_310_
        return partition_2a(_3fn, _3fn, _3ft)
      elseif ((case_308_ == 3) and true and true and true) then
        local _3fn = case_309_
        local _3fstep = case_310_
        local _3ft = case_311_
        local p = take(_3fn, _3ft)
        if (_3fn == length_2a(p)) then
          t_2finsert(res, p)
          return partition_2a(_3fn, _3fstep, {t_2funpack(_3ft, (_3fstep + 1))})
        else
          return nil
        end
      elseif (true and true and true and true and true) then
        local _ = case_308_
        local _3fn = case_309_
        local _3fstep = case_310_
        local _3fpad = case_311_
        local _3ft = case_312_
        local p = take(_3fn, _3ft)
        if (_3fn == length_2a(p)) then
          t_2finsert(res, p)
          return partition_2a(_3fn, _3fstep, _3fpad, {t_2funpack(_3ft, (_3fstep + 1))})
        else
          return t_2finsert(res, take(_3fn, join(p, _3fpad)))
        end
      else
        return nil
      end
    end
    partition_2a(...)
    return immutable(res)
  end
  itable.keys = function(t)
    local function _316_()
      local tbl_26_ = {}
      local i_27_ = 0
      for k, _ in pairs_2a(t) do
        local val_28_ = k
        if (nil ~= val_28_) then
          i_27_ = (i_27_ + 1)
          tbl_26_[i_27_] = val_28_
        else
        end
      end
      return tbl_26_
    end
    return immutable(_316_())
  end
  itable.vals = function(t)
    local function _318_()
      local tbl_26_ = {}
      local i_27_ = 0
      for _, v in pairs_2a(t) do
        local val_28_ = v
        if (nil ~= val_28_) then
          i_27_ = (i_27_ + 1)
          tbl_26_[i_27_] = val_28_
        else
        end
      end
      return tbl_26_
    end
    return immutable(_318_())
  end
  itable["group-by"] = function(f, t)
    local res = {}
    local ungroupped = {}
    for _, v in pairs_2a(t) do
      local k = f(v)
      if (nil ~= k) then
        local case_320_ = res[k]
        if (nil ~= case_320_) then
          local t_2a = case_320_
          t_2finsert(t_2a, v)
        else
          local _0 = case_320_
          res[k] = {v}
        end
      else
        t_2finsert(ungroupped, v)
      end
    end
    local function _323_()
      local tbl_21_ = {}
      for k, t0 in pairs_2a(res) do
        local k_22_, v_23_ = k, immutable(t0)
        if ((k_22_ ~= nil) and (v_23_ ~= nil)) then
          tbl_21_[k_22_] = v_23_
        else
        end
      end
      return tbl_21_
    end
    return immutable(_323_()), immutable(ungroupped)
  end
  itable.frequencies = function(t)
    local res = setmetatable({}, {__index = deep_index, __newindex = deep_newindex})
    for _, v in pairs_2a(t) do
      local case_325_ = res[v]
      if (nil ~= case_325_) then
        local a = case_325_
        res[v] = (a + 1)
      else
        local _0 = case_325_
        res[v] = 1
      end
    end
    return immutable(res)
  end
  itable.sort = function(t, f)
    local function _327_()
      local tmp_9_ = copy(t)
      t_2fsort(tmp_9_, f)
      return tmp_9_
    end
    return immutable(_327_())
  end
  itable["immutable?"] = function(t)
    local case_328_ = getmetatable(t)
    if ((_G.type(case_328_) == "table") and (case_328_.__index == itable)) then
      return true
    else
      local _ = case_328_
      return false
    end
  end
  local function _330_(_, t, opts)
    local case_331_ = getmetatable(t)
    if ((_G.type(case_331_) == "table") and (case_331_.__index == itable)) then
      return t
    else
      local _0 = case_331_
      return immutable(copy(t), opts)
    end
  end
  return setmetatable(itable, {__call = _330_})
end
package.preload["io.gitlab.andreyorst.inst"] = package.preload["io.gitlab.andreyorst.inst"] or function(...)
  --[[ MIT License
  
  Copyright (c) 2021 Andrey Listopadov
  
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:
  
  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.
  
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE. ]]
  
  local date, time = os.date, os.time
  
  local full_date_formats = {
      "(%-?%d%d%d%d)%-(1[012])%-([012]%d)",
      "(%-?%d%d%d%d)%-(1[012])%-(3[01])",
      "(%-?%d%d%d%d)%-(0%d)%-([012]%d)",
      "(%-?%d%d%d%d)%-(0%d)%-(3[01])",
      "(%-?%d%d%d%d)(1[012])([012]%d)",
      "(%-?%d%d%d%d)(1[012])(3[01])",
      "(%-?%d%d%d%d)(0%d)([012]%d)",
      "(%-?%d%d%d%d)(0%d)(3[01])",
  }
  
  local partial_date_formats = {
      "(%-?%d%d%d%d)%-(1[012])",
      "(%-?%d%d%d%d)%-(0%d)",
      "(%-?%d%d%d%d)(1[012])",
      "(%-?%d%d%d%d)(0%d)",
      "(%-?%d%d%d%d)",
  }
  
  local time_formats = {
      "([01]%d):([0-5]%d):([0-5]%d)%.(%d+)",
      "([2][0-4]):([0-5]%d):([0-5]%d)%.(%d+)",
      "([01]%d):([0-5]%d):(60)%.(%d+)",
      "([2][0-4]):([0-5]%d):(60)%.(%d+)",
      "([01]%d):([0-5]%d):([0-5]%d)",
      "([2][0-4]):([0-5]%d):([0-5]%d)",
      "([01]%d):([0-5]%d):(60)",
      "([2][0-4]):([0-5]%d):(60)",
  }
  
  local offset_formats = {
      "([+-])([01]%d):([0-5]%d)",
      "([+-])([2][0-4]):([0-5]%d)",
      "([+-])([01]%d)([0-5]%d)",
      "([+-])([2][0-4])([0-5]%d)",
      "([+-])([01]%d)",
      "([+-])([2][0-4])",
      "Z"
  }
  
  local months_w_thirty_one_days = {
      [1] = true,
      [3] = true,
      [5] = true,
      [7] = true,
      [8] = true,
      [10] = true,
      [12] = true
  }
  
  -- compiling all possible ISO8601 patterns
  local iso8601_formats = {}
  for _,date_fmt in ipairs(full_date_formats) do
      for _,time_fmt in ipairs(time_formats) do
          for _,offset_fmt in ipairs(offset_formats) do
              iso8601_formats[#iso8601_formats+1] = "^"..date_fmt.."T"..time_fmt..offset_fmt.."$"
  end end end
  
  local function is_leap_year(year)
      return 0 == year % 4 and (0 ~= year % 100 or 0 == year % 400)
  end
  
  local function parse_date_time (date_time_str)
      local year, mon, day, hh, mm, ss, ms, sign, off_h, off_m
  
      -- trying to parse a complete ISO8601 date
      for _,fmt in pairs(iso8601_formats) do
          year, mon, day, hh, mm, ss, ms, sign, off_h, off_m = date_time_str:match(fmt)
          if year then break end
      end
  
      -- milliseconds are optional, so offset may be stored in ms
      if not off_m and ms and ms:match("^[+-]") then
          off_m, off_h, sign, ms = off_h, sign, ms, 0
      end
  
      sign, off_h, off_m = sign or "+", off_h or 0, off_m or 0
  
      return year, mon, day, hh, mm, ss, ms, sign, off_h, off_m
  end
  
  local function parse_date (date_str)
      local year, mon, day
      for _,fmt in pairs(full_date_formats) do
          year, mon, day = date_str:match("^"..fmt.."$")
          if year ~= nil then break end
      end
      if not year then
          for _,fmt in pairs(partial_date_formats) do
              year, mon, day = date_str:match("^"..fmt.."$")
              if year ~= nil then break end
      end end
      return year, mon, day
  end
  
  local function parse_iso8601 (date_str)
      local year, mon, day, hh, mm, ss, ms, sign, off_h, off_m = parse_date_time(date_str)
  
      if not year then
          -- trying to parse only a year with optional month and day
          year, mon, day = parse_date(date_str)
      end
  
      if not year then
          error(("invalid date '%s': date string doesn't match ISO8601 pattern"):format(date_str), 2)
      end
  
      if is_leap_year(tonumber(year)) and mon and tonumber(mon) == 2 and day and tonumber(day) > 29 then
          error(("invalid date '%s': February has 29 days in leap years"):format(date_str), 2)
      elseif not is_leap_year(tonumber(year)) and mon and tonumber(mon) == 2 and day and tonumber(day) > 28 then
          error(("invalid date '%s': February has 28 days in non leap years"):format(date_str), 2)
      end
  
      if mon and day and tonumber(day) == 31 and not months_w_thirty_one_days[tonumber(mon)] then
          error(("invalid date '%s': month %d has 30 days"):format(date_str, mon), 2)
      end
  
      return { year = year,
               month = tonumber(mon) or 1,
               day = tonumber(day) or 1,
               hour = (tonumber(hh) or 0) - (tonumber(sign..off_h) or 0),
               min = (tonumber(mm) or 0) - (tonumber(sign..off_m) or 0),
               sec = tonumber(ss or 0),
               msec = tonumber(ms or 0) }
  end
  
  local function inst (date_str)
      local inst = parse_iso8601(date_str)
      return setmetatable(inst, {
          __tostring = function ()
              return ("#inst \"%04d-%s.%03d-00:00\""):format(inst.year, date("%m-%dT%H:%M:%S", time(inst)), inst.msec)
          end,
          __len = function (inst) return inst end
      })
  end
  
  return inst
end
package.preload["io.gitlab.andreyorst.async"] = package.preload["io.gitlab.andreyorst.async"] or function(...)
  --[[ "Copyright (c) 2023 Andrey Listopadov and contributors.  All rights reserved.
  The use and distribution terms for this software are covered by the Eclipse
  Public License 1.0 (http://opensource.org/licenses/eclipse-1.0.php) which
  can be found in the file LICENSE at the root of this distribution.  By using
  this software in any fashion, you are agreeing to be bound by the terms of
  this license.
  You must not remove this notice, or any other, from this software." ]]
  local lib_name = (... or "io.gitlab.andreyorst.async")
  local main_thread = (coroutine.running() or error((lib_name .. " requires Lua 5.2 or higher")))
  local or_333_ = package.preload["io.gitlab.andreyorst.reduced"]
  if not or_333_ then
    local function _334_()
      local Reduced
      local function _336_(_335_, view, options, indent)
        local x = _335_[1]
        return ("#<reduced: " .. view(x, options, (11 + indent)) .. ">")
      end
      local function _338_(_337_)
        local x = _337_[1]
        return x
      end
      local function _340_(_339_)
        local x = _339_[1]
        return ("reduced: " .. tostring(x))
      end
      Reduced = {__fennelview = _336_, __index = {unbox = _338_}, __name = "reduced", __tostring = _340_}
      local function reduced(value)
        return setmetatable({value}, Reduced)
      end
      local function reduced_3f(value)
        return rawequal(getmetatable(value), Reduced)
      end
      return {is_reduced = reduced_3f, reduced = reduced, ["reduced?"] = reduced_3f}
    end
    or_333_ = _334_
  end
  package.preload["io.gitlab.andreyorst.reduced"] = or_333_
  local _local_341_ = require("io.gitlab.andreyorst.reduced")
  local reduced = _local_341_.reduced
  local reduced_3f = _local_341_["reduced?"]
  local gethook, sethook
  do
    local case_342_ = _G.debug
    if ((_G.type(case_342_) == "table") and (nil ~= case_342_.gethook) and (nil ~= case_342_.sethook)) then
      local gethook0 = case_342_.gethook
      local sethook0 = case_342_.sethook
      gethook, sethook = gethook0, sethook0
    else
      local _ = case_342_
      io.stderr:write("WARNING: debug library is unawailable.  ", lib_name, " uses debug.sethook to advance timers.  ", "Time-related features are disabled.\n")
      gethook, sethook = nil
    end
  end
  local t_2fremove = table.remove
  local t_2fconcat = table.concat
  local t_2finsert = table.insert
  local t_2fsort = table.sort
  local t_2funpack = (_G.unpack or table.unpack)
  local c_2frunning = coroutine.running
  local c_2fresume = coroutine.resume
  local c_2fyield = coroutine.yield
  local c_2fcreate = coroutine.create
  local m_2fmin = math.min
  local m_2frandom = math.random
  local m_2fceil = math.ceil
  local m_2ffloor = math.floor
  local m_2fmodf = math.modf
  local function main_thread_3f()
    local case_344_, case_345_ = c_2frunning()
    if (case_344_ == nil) then
      return true
    elseif (true and (case_345_ == true)) then
      local _ = case_344_
      return true
    else
      local _ = case_344_
      return false
    end
  end
  local function merge_2a(t1, t2)
    local res = {}
    do
      local tbl_21_ = res
      for k, v in pairs(t1) do
        local k_22_, v_23_ = k, v
        if ((k_22_ ~= nil) and (v_23_ ~= nil)) then
          tbl_21_[k_22_] = v_23_
        else
        end
      end
    end
    local tbl_21_ = res
    for k, v in pairs(t2) do
      local k_22_, v_23_ = k, v
      if ((k_22_ ~= nil) and (v_23_ ~= nil)) then
        tbl_21_[k_22_] = v_23_
      else
      end
    end
    return tbl_21_
  end
  local function merge_with(f, t1, t2)
    local res
    do
      local tbl_21_ = {}
      for k, v in pairs(t1) do
        local k_22_, v_23_ = k, v
        if ((k_22_ ~= nil) and (v_23_ ~= nil)) then
          tbl_21_[k_22_] = v_23_
        else
        end
      end
      res = tbl_21_
    end
    local tbl_21_ = res
    for k, v in pairs(t2) do
      local k_22_, v_23_
      do
        local case_350_ = res[k]
        if (nil ~= case_350_) then
          local e = case_350_
          k_22_, v_23_ = k, f(e, v)
        elseif (case_350_ == nil) then
          k_22_, v_23_ = k, v
        else
          k_22_, v_23_ = nil
        end
      end
      if ((k_22_ ~= nil) and (v_23_ ~= nil)) then
        tbl_21_[k_22_] = v_23_
      else
      end
    end
    return tbl_21_
  end
  local function active_3f(h)
    if (nil == h) then
      _G.error("Missing argument h on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:203", 2)
    else
    end
    return h["active?"](h)
  end
  local function blockable_3f(h)
    if (nil == h) then
      _G.error("Missing argument h on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:204", 2)
    else
    end
    return h["blockable?"](h)
  end
  local function commit(h)
    if (nil == h) then
      _G.error("Missing argument h on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:205", 2)
    else
    end
    return h:commit()
  end
  local _local_356_ = {["active?"] = active_3f, ["blockable?"] = blockable_3f, commit = commit}
  local active_3f0 = _local_356_["active?"]
  local blockable_3f0 = _local_356_["blockable?"]
  local commit0 = _local_356_.commit
  local Handler = _local_356_
  local function fn_handler(f, ...)
    local blockable
    if (0 == select("#", ...)) then
      blockable = true
    else
      blockable = ...
    end
    local _358_ = {}
    do
      do
        local case_359_ = Handler["active?"]
        if (nil ~= case_359_) then
          local f_3_auto = case_359_
          local function _360_(_)
            return true
          end
          _358_["active?"] = _360_
        else
          local _ = case_359_
          error("Protocol Handler doesn't define method active?")
        end
      end
      do
        local case_362_ = Handler["blockable?"]
        if (nil ~= case_362_) then
          local f_3_auto = case_362_
          local function _363_(_)
            return blockable
          end
          _358_["blockable?"] = _363_
        else
          local _ = case_362_
          error("Protocol Handler doesn't define method blockable?")
        end
      end
      local case_365_ = Handler.commit
      if (nil ~= case_365_) then
        local f_3_auto = case_365_
        local function _366_(_)
          return f
        end
        _358_["commit"] = _366_
      else
        local _ = case_365_
        error("Protocol Handler doesn't define method commit")
      end
    end
    local function _368_(_241)
      return ("#<" .. tostring(_241):gsub("table:", "reify:") .. ": " .. "Handler" .. ">")
    end
    return setmetatable({}, {__fennelview = _368_, __index = _358_, __name = "reify"})
  end
  local fhnop
  local function _369_()
    return nil
  end
  fhnop = fn_handler(_369_)
  local socket
  do
    local case_370_, case_371_ = pcall(require, "socket")
    if ((case_370_ == true) and (nil ~= case_371_)) then
      local s = case_371_
      socket = s
    else
      local _ = case_370_
      socket = nil
    end
  end
  local posix
  do
    local case_373_, case_374_ = pcall(require, "posix")
    if ((case_373_ == true) and (nil ~= case_374_)) then
      local p = case_374_
      posix = p
    else
      local _ = case_373_
      posix = nil
    end
  end
  local time, sleep, time_type
  local _377_
  do
    local t_376_ = socket
    if (nil ~= t_376_) then
      t_376_ = t_376_.gettime
    else
    end
    _377_ = t_376_
  end
  if _377_ then
    local sleep0 = socket.sleep
    local function _379_(_241)
      return sleep0((_241 / 1000))
    end
    time, sleep, time_type = socket.gettime, _379_, "socket"
  else
    local _381_
    do
      local t_380_ = posix
      if (nil ~= t_380_) then
        t_380_ = t_380_.clock_gettime
      else
      end
      _381_ = t_380_
    end
    if _381_ then
      local gettime = posix.clock_gettime
      local nanosleep = posix.nanosleep
      local function _383_()
        local s, ns = gettime()
        return (s + (ns / 1000000000))
      end
      local function _384_(_241)
        local s, ms = m_2fmodf((_241 / 1000))
        return nanosleep(s, (1000000 * 1000 * ms))
      end
      time, sleep, time_type = _383_, _384_, "posix"
    else
      time, sleep, time_type = os.time, nil, "lua"
    end
  end
  local difftime
  local function _386_(_241, _242)
    return (_241 - _242)
  end
  difftime = _386_
  local function add_21(buffer, item)
    if (nil == item) then
      _G.error("Missing argument item on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:244", 2)
    else
    end
    if (nil == buffer) then
      _G.error("Missing argument buffer on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:244", 2)
    else
    end
    return buffer["add!"](buffer, item)
  end
  local function close_buf_21(buffer)
    if (nil == buffer) then
      _G.error("Missing argument buffer on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:245", 2)
    else
    end
    return buffer["close-buf!"](buffer)
  end
  local function full_3f(buffer)
    if (nil == buffer) then
      _G.error("Missing argument buffer on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:242", 2)
    else
    end
    return buffer["full?"](buffer)
  end
  local function remove_21(buffer)
    if (nil == buffer) then
      _G.error("Missing argument buffer on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:243", 2)
    else
    end
    return buffer["remove!"](buffer)
  end
  local _local_392_ = {["add!"] = add_21, ["close-buf!"] = close_buf_21, ["full?"] = full_3f, ["remove!"] = remove_21}
  local add_210 = _local_392_["add!"]
  local close_buf_210 = _local_392_["close-buf!"]
  local full_3f0 = _local_392_["full?"]
  local remove_210 = _local_392_["remove!"]
  local Buffer = _local_392_
  local FixedBuffer
  local function _394_(_393_)
    local buffer = _393_.buf
    local size = _393_.size
    return (#buffer >= size)
  end
  local function _396_(_395_)
    local buffer = _395_.buf
    return #buffer
  end
  local function _398_(_397_, val)
    local buffer = _397_.buf
    local this = _397_
    assert((val ~= nil), "value must not be nil")
    buffer[(1 + #buffer)] = val
    return this
  end
  local function _400_(_399_)
    local buffer = _399_.buf
    if (#buffer > 0) then
      return t_2fremove(buffer, 1)
    else
      return nil
    end
  end
  local function _402_(_)
    return nil
  end
  FixedBuffer = {type = Buffer, ["full?"] = _394_, length = _396_, ["add!"] = _398_, ["remove!"] = _400_, ["close-buf!"] = _402_}
  local DroppingBuffer
  local function _403_()
    return false
  end
  local function _405_(_404_)
    local buffer = _404_.buf
    return #buffer
  end
  local function _407_(_406_, val)
    local buffer = _406_.buf
    local size = _406_.size
    local this = _406_
    assert((val ~= nil), "value must not be nil")
    if (#buffer < size) then
      buffer[(1 + #buffer)] = val
    else
    end
    return this
  end
  local function _410_(_409_)
    local buffer = _409_.buf
    if (#buffer > 0) then
      return t_2fremove(buffer, 1)
    else
      return nil
    end
  end
  local function _412_(_)
    return nil
  end
  DroppingBuffer = {type = Buffer, ["full?"] = _403_, length = _405_, ["add!"] = _407_, ["remove!"] = _410_, ["close-buf!"] = _412_}
  local SlidingBuffer
  local function _413_()
    return false
  end
  local function _415_(_414_)
    local buffer = _414_.buf
    return #buffer
  end
  local function _417_(_416_, val)
    local buffer = _416_.buf
    local size = _416_.size
    local this = _416_
    assert((val ~= nil), "value must not be nil")
    buffer[(1 + #buffer)] = val
    if (size < #buffer) then
      t_2fremove(buffer, 1)
    else
    end
    return this
  end
  local function _420_(_419_)
    local buffer = _419_.buf
    if (#buffer > 0) then
      return t_2fremove(buffer, 1)
    else
      return nil
    end
  end
  local function _422_(_)
    return nil
  end
  SlidingBuffer = {type = Buffer, ["full?"] = _413_, length = _415_, ["add!"] = _417_, ["remove!"] = _420_, ["close-buf!"] = _422_}
  local no_val = {}
  local PromiseBuffer
  local function _423_()
    return false
  end
  local function _424_(this)
    if rawequal(no_val, this.val) then
      return 0
    else
      return 1
    end
  end
  local function _426_(this, val)
    assert((val ~= nil), "value must not be nil")
    if rawequal(no_val, this.val) then
      this["val"] = val
    else
    end
    return this
  end
  local function _429_(_428_)
    local value = _428_.val
    return value
  end
  local function _431_(_430_)
    local value = _430_.val
    local this = _430_
    if rawequal(no_val, value) then
      this["val"] = nil
      return nil
    else
      return nil
    end
  end
  PromiseBuffer = {type = Buffer, val = no_val, ["full?"] = _423_, length = _424_, ["add!"] = _426_, ["remove!"] = _429_, ["close-buf!"] = _431_}
  local function buffer_2a(size, buffer_type)
    do local _ = (size and assert(("number" == type(size)), ("size must be a number: " .. tostring(size)))) end
    assert(not tostring(size):match("%."), "size must be integer")
    local function _433_(self)
      return self:length()
    end
    local function _434_(_241)
      return ("#<" .. tostring(_241):gsub("table:", "buffer:") .. ">")
    end
    return setmetatable({size = size, buf = {}}, {__index = buffer_type, __name = "buffer", __len = _433_, __fennelview = _434_})
  end
  local function buffer(n)
    return buffer_2a(n, FixedBuffer)
  end
  local function dropping_buffer(n)
    return buffer_2a(n, DroppingBuffer)
  end
  local function sliding_buffer(n)
    return buffer_2a(n, SlidingBuffer)
  end
  local function promise_buffer()
    return buffer_2a(1, PromiseBuffer)
  end
  local function buffer_3f(obj)
    if ((_G.type(obj) == "table") and (obj.type == Buffer)) then
      return true
    else
      local _ = obj
      return false
    end
  end
  local function unblocking_buffer_3f(buff)
    local case_436_ = (buffer_3f(buff) and getmetatable(buff).__index)
    if (case_436_ == SlidingBuffer) then
      return true
    elseif (case_436_ == DroppingBuffer) then
      return true
    elseif (case_436_ == PromiseBuffer) then
      return true
    else
      local _ = case_436_
      return false
    end
  end
  local timeouts = {}
  local dispatched_tasks = {}
  local os_2fclock = os.clock
  local n_instr, register_time, orig_hook, orig_mask, orig_n = 1000000
  local function schedule_hook(hook, n)
    if (gethook and sethook) then
      local hook_2a, mask, n_2a = gethook()
      if (hook ~= hook_2a) then
        register_time, orig_hook, orig_mask, orig_n = os_2fclock(), hook_2a, mask, n_2a
        return sethook(main_thread, hook, "", n)
      else
        return nil
      end
    else
      return nil
    end
  end
  local function cancel_hook(hook)
    if (gethook and sethook) then
      local case_440_, case_441_, case_442_ = gethook(main_thread)
      if ((case_440_ == hook) and true and true) then
        local _3fmask = case_441_
        local _3fn = case_442_
        sethook(main_thread, orig_hook, orig_mask, orig_n)
        return _3fmask, _3fn
      else
        return nil
      end
    else
      return nil
    end
  end
  local function process_messages(event)
    local took = (os_2fclock() - register_time)
    local _, n = cancel_hook(process_messages)
    if (event ~= "count") then
      n_instr = n
    else
      n_instr = m_2ffloor((0.01 / (took / n)))
    end
    do
      local done = nil
      for _0 = 1, 1024 do
        if done then break end
        local case_446_ = next(dispatched_tasks)
        if (nil ~= case_446_) then
          local f = case_446_
          local _447_
          do
            pcall(f)
            _447_ = f
          end
          dispatched_tasks[_447_] = nil
          done = nil
        elseif (case_446_ == nil) then
          done = true
        else
          done = nil
        end
      end
    end
    for t, ch in pairs(timeouts) do
      if (0 >= difftime(t, time())) then
        timeouts[t] = ch["close!"](ch)
      else
      end
    end
    if (next(dispatched_tasks) or next(timeouts)) then
      return schedule_hook(process_messages, n_instr)
    else
      return nil
    end
  end
  local function dispatch(f)
    if (gethook and sethook) then
      dispatched_tasks[f] = true
      schedule_hook(process_messages, n_instr)
    else
      f()
    end
    return nil
  end
  local function put_active_3f(_452_)
    local handler = _452_[1]
    return handler["active?"](handler)
  end
  local function cleanup_21(t, pred)
    local to_keep
    do
      local tbl_26_ = {}
      local i_27_ = 0
      for i, v in ipairs(t) do
        local val_28_
        if pred(v) then
          val_28_ = v
        else
          val_28_ = nil
        end
        if (nil ~= val_28_) then
          i_27_ = (i_27_ + 1)
          tbl_26_[i_27_] = val_28_
        else
        end
      end
      to_keep = tbl_26_
    end
    while t_2fremove(t) do
    end
    for _, v in ipairs(to_keep) do
      t_2finsert(t, v)
    end
    return t
  end
  local MAX_QUEUE_SIZE = 1024
  local MAX_DIRTY = 64
  local Channel = {["dirty-puts"] = 0, ["dirty-takes"] = 0}
  Channel.abort = function(_455_)
    local puts = _455_.puts
    local function recur()
      local putter = t_2fremove(puts, 1)
      if (nil ~= putter) then
        local put_handler = putter[1]
        local val = putter[2]
        if put_handler["active?"](put_handler) then
          local put_cb = put_handler:commit()
          local function _456_()
            return put_cb(true)
          end
          return dispatch(_456_)
        else
          return recur()
        end
      else
        return nil
      end
    end
    return recur
  end
  Channel["put!"] = function(_459_, val, handler, enqueue_3f)
    local buf = _459_.buf
    local closed = _459_.closed
    local this = _459_
    assert((val ~= nil), "Can't put nil on a channel")
    if not handler["active?"]() then
      return {not closed}
    elseif closed then
      handler:commit()
      return {false}
    elseif (buf and not buf["full?"](buf)) then
      local takes = this.takes
      local add_211 = this["add!"]
      handler:commit()
      local done_3f = reduced_3f(add_211(buf, val))
      local take_cbs
      local function recur(takers)
        if (next(takes) and (#buf > 0)) then
          local taker = t_2fremove(takes, 1)
          if taker["active?"](taker) then
            local ret = taker:commit()
            local val0 = buf["remove!"](buf)
            local function _460_()
              local function _461_()
                return ret(val0)
              end
              t_2finsert(takers, _461_)
              return takers
            end
            return recur(_460_())
          else
            return recur(takers)
          end
        else
          return takers
        end
      end
      take_cbs = recur({})
      if done_3f then
        this:abort()
      else
      end
      if next(take_cbs) then
        for _, f in ipairs(take_cbs) do
          dispatch(f)
        end
      else
      end
      return {true}
    else
      local takes = this.takes
      local taker
      local function recur()
        local taker0 = t_2fremove(takes, 1)
        if taker0 then
          if taker0["active?"](taker0) then
            return taker0
          else
            return recur()
          end
        else
          return nil
        end
      end
      taker = recur()
      if taker then
        local take_cb = taker:commit()
        handler:commit()
        local function _468_()
          return take_cb(val)
        end
        dispatch(_468_)
        return {true}
      else
        local puts = this.puts
        local dirty_puts = this["dirty-puts"]
        if (dirty_puts > MAX_DIRTY) then
          this["dirty-puts"] = 0
          cleanup_21(puts, put_active_3f)
        else
          this["dirty-puts"] = (1 + dirty_puts)
        end
        if handler["blockable?"](handler) then
          assert((#puts < MAX_QUEUE_SIZE), ("No more than " .. MAX_QUEUE_SIZE .. " pending puts are allowed on a single channel." .. " Consider using a windowed buffer."))
          local handler_2a
          if (main_thread_3f() or enqueue_3f) then
            handler_2a = handler
          else
            local thunk = c_2frunning()
            local _470_ = {}
            do
              do
                local case_471_ = Handler["active?"]
                if (nil ~= case_471_) then
                  local f_3_auto = case_471_
                  local function _472_(_)
                    return handler["active?"](handler)
                  end
                  _470_["active?"] = _472_
                else
                  local _ = case_471_
                  error("Protocol Handler doesn't define method active?")
                end
              end
              do
                local case_474_ = Handler["blockable?"]
                if (nil ~= case_474_) then
                  local f_3_auto = case_474_
                  local function _475_(_)
                    return handler["blockable?"](handler)
                  end
                  _470_["blockable?"] = _475_
                else
                  local _ = case_474_
                  error("Protocol Handler doesn't define method blockable?")
                end
              end
              local case_477_ = Handler.commit
              if (nil ~= case_477_) then
                local f_3_auto = case_477_
                local function _478_(_)
                  local function _479_(...)
                    return c_2fresume(thunk, ...)
                  end
                  return _479_
                end
                _470_["commit"] = _478_
              else
                local _ = case_477_
                error("Protocol Handler doesn't define method commit")
              end
            end
            local function _481_(_241)
              return ("#<" .. tostring(_241):gsub("table:", "reify:") .. ": " .. "Handler" .. ">")
            end
            handler_2a = setmetatable({}, {__fennelview = _481_, __index = _470_, __name = "reify"})
          end
          t_2finsert(puts, {handler_2a, val})
          if (handler ~= handler_2a) then
            local val0 = c_2fyield()
            handler:commit()(val0)
            return {val0}
          else
            return nil
          end
        else
          return nil
        end
      end
    end
  end
  Channel["take!"] = function(_487_, handler, enqueue_3f)
    local buf = _487_.buf
    local this = _487_
    if not handler["active?"](handler) then
      return nil
    elseif (not (nil == buf) and (#buf > 0)) then
      local case_488_ = handler:commit()
      if (nil ~= case_488_) then
        local take_cb = case_488_
        local puts = this.puts
        local val = buf["remove!"](buf)
        if (not buf["full?"](buf) and next(puts)) then
          local add_211 = this["add!"]
          local function recur(cbs)
            local putter = t_2fremove(puts, 1)
            local put_handler = putter[1]
            local val0 = putter[2]
            local cb = (put_handler["active?"](put_handler) and put_handler:commit())
            local cbs0
            if cb then
              t_2finsert(cbs, cb)
              cbs0 = cbs
            else
              cbs0 = cbs
            end
            local done_3f
            if cb then
              done_3f = reduced_3f(add_211(buf, val0))
            else
              done_3f = nil
            end
            if (not done_3f and not buf["full?"](buf) and next(puts)) then
              return recur(cbs0)
            else
              return {done_3f, cbs0}
            end
          end
          local _let_492_ = recur({})
          local done_3f = _let_492_[1]
          local cbs = _let_492_[2]
          if done_3f then
            this:abort()
          else
          end
          for _, cb in ipairs(cbs) do
            local function _494_()
              return cb(true)
            end
            dispatch(_494_)
          end
        else
        end
        return {val}
      else
        return nil
      end
    else
      local puts = this.puts
      local putter
      local function recur()
        local putter0 = t_2fremove(puts, 1)
        if putter0 then
          local tgt_497_ = putter0[1]
          if (tgt_497_)["active?"](tgt_497_) then
            return putter0
          else
            return recur()
          end
        else
          return nil
        end
      end
      putter = recur()
      if putter then
        local put_cb = putter[1]:commit()
        handler:commit()
        local function _500_()
          return put_cb(true)
        end
        dispatch(_500_)
        return {putter[2]}
      elseif this.closed then
        if buf then
          this["add!"](buf)
        else
        end
        if (handler["active?"](handler) and handler:commit()) then
          local has_val = (buf and next(buf.buf))
          local val
          if has_val then
            val = buf["remove!"](buf)
          else
            val = nil
          end
          return {val}
        else
          return nil
        end
      else
        local takes = this.takes
        local dirty_takes = this["dirty-takes"]
        if (dirty_takes > MAX_DIRTY) then
          this["dirty-takes"] = 0
          local function _504_(_241)
            return _241["active?"](_241)
          end
          cleanup_21(takes, _504_)
        else
          this["dirty-takes"] = (1 + dirty_takes)
        end
        if handler["blockable?"](handler) then
          assert((#takes < MAX_QUEUE_SIZE), ("No more than " .. MAX_QUEUE_SIZE .. " pending takes are allowed on a single channel."))
          local handler_2a
          if (main_thread_3f() or enqueue_3f) then
            handler_2a = handler
          else
            local thunk = c_2frunning()
            local _506_ = {}
            do
              do
                local case_507_ = Handler["active?"]
                if (nil ~= case_507_) then
                  local f_3_auto = case_507_
                  local function _508_(_)
                    return handler["active?"](handler)
                  end
                  _506_["active?"] = _508_
                else
                  local _ = case_507_
                  error("Protocol Handler doesn't define method active?")
                end
              end
              do
                local case_510_ = Handler["blockable?"]
                if (nil ~= case_510_) then
                  local f_3_auto = case_510_
                  local function _511_(_)
                    return handler["blockable?"](handler)
                  end
                  _506_["blockable?"] = _511_
                else
                  local _ = case_510_
                  error("Protocol Handler doesn't define method blockable?")
                end
              end
              local case_513_ = Handler.commit
              if (nil ~= case_513_) then
                local f_3_auto = case_513_
                local function _514_(_)
                  local function _515_(...)
                    return c_2fresume(thunk, ...)
                  end
                  return _515_
                end
                _506_["commit"] = _514_
              else
                local _ = case_513_
                error("Protocol Handler doesn't define method commit")
              end
            end
            local function _517_(_241)
              return ("#<" .. tostring(_241):gsub("table:", "reify:") .. ": " .. "Handler" .. ">")
            end
            handler_2a = setmetatable({}, {__fennelview = _517_, __index = _506_, __name = "reify"})
          end
          t_2finsert(takes, handler_2a)
          if (handler ~= handler_2a) then
            local val = c_2fyield()
            handler:commit()(val)
            return {val}
          else
            return nil
          end
        else
          return nil
        end
      end
    end
  end
  Channel["close!"] = function(this)
    if this.closed then
      return nil
    else
      local buf = this.buf
      local takes = this.takes
      this.closed = true
      if (buf and (0 == #this.puts)) then
        this["add!"](buf)
      else
      end
      local function recur()
        local taker = t_2fremove(takes, 1)
        if (nil ~= taker) then
          if taker["active?"](taker) then
            local take_cb = taker:commit()
            local val
            if (buf and next(buf.buf)) then
              val = buf["remove!"](buf)
            else
              val = nil
            end
            local function _525_()
              return take_cb(val)
            end
            dispatch(_525_)
          else
          end
          return recur()
        else
          return nil
        end
      end
      recur()
      if buf then
        buf["close-buf!"](buf)
      else
      end
      return nil
    end
  end
  do
    Channel["type"] = Channel
    Channel["close"] = Channel["close!"]
  end
  local function err_handler_2a(e)
    io.stderr:write(tostring(e), "\n")
    return nil
  end
  local function add_21_2a(buf, ...)
    local case_530_, case_531_ = select("#", ...), ...
    if ((case_530_ == 1) and true) then
      local _3fval = case_531_
      return buf["add!"](buf, _3fval)
    elseif (case_530_ == 0) then
      return buf
    else
      return nil
    end
  end
  local function chan(buf_or_n, xform, err_handler)
    local buffer0
    if ((_G.type(buf_or_n) == "table") and (buf_or_n.type == Buffer)) then
      buffer0 = buf_or_n
    elseif (buf_or_n == 0) then
      buffer0 = nil
    elseif (nil ~= buf_or_n) then
      local size = buf_or_n
      buffer0 = buffer(size)
    else
      buffer0 = nil
    end
    local add_211
    if xform then
      assert((nil ~= buffer0), "buffer must be supplied when transducer is")
      add_211 = xform(add_21_2a)
    else
      add_211 = add_21_2a
    end
    local err_handler0 = (err_handler or err_handler_2a)
    local handler
    local function _535_(ch, err)
      local case_536_ = err_handler0(err)
      if (nil ~= case_536_) then
        local res = case_536_
        return ch["put!"](ch, res, fhnop)
      else
        return nil
      end
    end
    handler = _535_
    local c = {puts = {}, takes = {}, buf = buffer0, ["err-handler"] = handler}
    c["add!"] = function(...)
      local case_538_, case_539_ = pcall(add_211, ...)
      if ((case_538_ == true) and true) then
        local _ = case_539_
        return _
      elseif ((case_538_ == false) and (nil ~= case_539_)) then
        local e = case_539_
        return handler(c, e)
      else
        return nil
      end
    end
    local function _541_(_241)
      return ("#<" .. tostring(_241):gsub("table:", "ManyToManyChannel:") .. ">")
    end
    return setmetatable(c, {__index = Channel, __name = "ManyToManyChannel", __fennelview = _541_})
  end
  local function promise_chan(xform, err_handler)
    return chan(promise_buffer(), xform, err_handler)
  end
  local function chan_3f(obj)
    if ((_G.type(obj) == "table") and (obj.type == Channel)) then
      return true
    else
      local _ = obj
      return false
    end
  end
  local function closed_3f(port)
    assert(chan_3f(port), "expected a channel")
    return port.closed
  end
  local warned = false
  local function timeout(msecs)
    assert((gethook and sethook), "Can't advance timers - debug.sethook unavailable")
    local dt
    if (time_type == "lua") then
      local s = (msecs / 1000)
      if (not warned and not (m_2fceil(s) == s)) then
        warned = true
        local function _543_()
          warned = false
          return nil
        end
        local tgt_544_ = timeout(10000)
        do end (tgt_544_)["take!"](tgt_544_, fn_handler(_543_))
        io.stderr:write(("WARNING Lua doesn't support sub-second time precision.  " .. "Timeout rounded to the next nearest whole second.  " .. "Install luasocket or luaposix to get sub-second precision.\n"))
      else
      end
      dt = s
    else
      local _ = time_type
      dt = (msecs / 1000)
    end
    local t = ((m_2fceil((time() * 100)) / 100) + dt)
    local c
    local or_547_ = timeouts[t]
    if not or_547_ then
      local c0 = chan()
      timeouts[t] = c0
      or_547_ = c0
    end
    c = or_547_
    schedule_hook(process_messages, n_instr)
    return c
  end
  local function take_21(port, fn1, ...)
    assert(chan_3f(port), "expected a channel as first argument")
    assert((nil ~= fn1), "expected a callback")
    local on_caller_3f
    if (select("#", ...) == 0) then
      on_caller_3f = true
    else
      on_caller_3f = ...
    end
    do
      local case_550_ = port["take!"](port, fn_handler(fn1))
      if (nil ~= case_550_) then
        local retb = case_550_
        local val = retb[1]
        if on_caller_3f then
          fn1(val)
        else
          local function _551_()
            return fn1(val)
          end
          dispatch(_551_)
        end
      else
      end
    end
    return nil
  end
  local function try_sleep()
    local timers
    do
      local tmp_9_
      do
        local tbl_26_ = {}
        local i_27_ = 0
        for timer in pairs(timeouts) do
          local val_28_ = timer
          if (nil ~= val_28_) then
            i_27_ = (i_27_ + 1)
            tbl_26_[i_27_] = val_28_
          else
          end
        end
        tmp_9_ = tbl_26_
      end
      t_2fsort(tmp_9_)
      timers = tmp_9_
    end
    local case_555_ = timers[1]
    local and_556_ = (nil ~= case_555_)
    if and_556_ then
      local t = case_555_
      and_556_ = (sleep and not next(dispatched_tasks))
    end
    if and_556_ then
      local t = case_555_
      local t0 = (t - time())
      if (t0 > 0) then
        sleep(t0)
        process_messages("manual")
      else
      end
      return true
    else
      local _ = case_555_
      if next(dispatched_tasks) then
        process_messages("manual")
        return true
      else
        return nil
      end
    end
  end
  local function _3c_21_21(port)
    assert(main_thread_3f(), "<!! used not on the main thread")
    local val = nil
    local function _561_(_241)
      val = _241
      return nil
    end
    take_21(port, _561_)
    while ((val == nil) and not port.closed and try_sleep()) do
    end
    if ((nil == val) and not port.closed) then
      error(("The " .. tostring(port) .. " is not ready and there are no scheduled tasks." .. " Value will never arrive."), 2)
    else
    end
    return val
  end
  local function _3c_21(port)
    assert(not main_thread_3f(), "<! used not in (go ...) block")
    assert(chan_3f(port), "expected a channel as first argument")
    local case_563_ = port["take!"](port, fhnop)
    if (nil ~= case_563_) then
      local retb = case_563_
      return retb[1]
    else
      return nil
    end
  end
  local function put_21(port, val, ...)
    assert(chan_3f(port), "expected a channel as first argument")
    local case_565_ = select("#", ...)
    if (case_565_ == 0) then
      local case_566_ = port["put!"](port, val, fhnop)
      if (nil ~= case_566_) then
        local retb = case_566_
        return retb[1]
      else
        local _ = case_566_
        return true
      end
    elseif (case_565_ == 1) then
      return put_21(port, val, ..., true)
    elseif (case_565_ == 2) then
      local fn1, on_caller_3f = ...
      local case_568_ = port["put!"](port, val, fn_handler(fn1))
      if (nil ~= case_568_) then
        local retb = case_568_
        local ret = retb[1]
        if on_caller_3f then
          fn1(ret)
        else
          local function _569_()
            return fn1(ret)
          end
          dispatch(_569_)
        end
        return ret
      else
        local _ = case_568_
        return true
      end
    else
      return nil
    end
  end
  local function _3e_21_21(port, val)
    assert(main_thread_3f(), ">!! used not on the main thread")
    local not_done, res = true
    local function _573_(_241)
      not_done, res = false, _241
      return nil
    end
    put_21(port, val, _573_)
    while (not_done and try_sleep(port)) do
    end
    if (not_done and not port.closed) then
      error(("The " .. tostring(port) .. " is not ready and there are no scheduled tasks." .. " Value was sent but there's no one to receive it"), 2)
    else
    end
    return res
  end
  local function _3e_21(port, val)
    assert(not main_thread_3f(), ">! used not in (go ...) block")
    local case_575_ = port["put!"](port, val, fhnop)
    if (nil ~= case_575_) then
      local retb = case_575_
      return retb[1]
    else
      return nil
    end
  end
  local function close_21(port)
    assert(chan_3f(port), "expected a channel")
    return port:close()
  end
  local function go_2a(fn1)
    local c = chan(1)
    do
      local case_577_, case_578_
      local function _579_()
        do
          local case_580_ = fn1()
          if (nil ~= case_580_) then
            local val = case_580_
            _3e_21(c, val)
          else
          end
        end
        return close_21(c)
      end
      case_577_, case_578_ = c_2fresume(c_2fcreate(_579_))
      if ((case_577_ == false) and (nil ~= case_578_)) then
        local msg = case_578_
        c["err-handler"](c, msg)
        close_21(c)
      else
      end
    end
    return c
  end
  local function random_array(n)
    local ids
    do
      local tbl_26_ = {}
      local i_27_ = 0
      for i = 1, n do
        local val_28_ = i
        if (nil ~= val_28_) then
          i_27_ = (i_27_ + 1)
          tbl_26_[i_27_] = val_28_
        else
        end
      end
      ids = tbl_26_
    end
    for i = n, 2, -1 do
      local j = m_2frandom(i)
      local ti = ids[i]
      ids[i] = ids[j]
      ids[j] = ti
    end
    return ids
  end
  local function alt_flag()
    local atom = {flag = true}
    local _584_ = {}
    do
      do
        local case_585_ = Handler["active?"]
        if (nil ~= case_585_) then
          local f_3_auto = case_585_
          local function _586_(_)
            return atom.flag
          end
          _584_["active?"] = _586_
        else
          local _ = case_585_
          error("Protocol Handler doesn't define method active?")
        end
      end
      do
        local case_588_ = Handler["blockable?"]
        if (nil ~= case_588_) then
          local f_3_auto = case_588_
          local function _589_(_)
            return true
          end
          _584_["blockable?"] = _589_
        else
          local _ = case_588_
          error("Protocol Handler doesn't define method blockable?")
        end
      end
      local case_591_ = Handler.commit
      if (nil ~= case_591_) then
        local f_3_auto = case_591_
        local function _592_(_)
          atom.flag = false
          return true
        end
        _584_["commit"] = _592_
      else
        local _ = case_591_
        error("Protocol Handler doesn't define method commit")
      end
    end
    local function _594_(_241)
      return ("#<" .. tostring(_241):gsub("table:", "reify:") .. ": " .. "Handler" .. ">")
    end
    return setmetatable({}, {__fennelview = _594_, __index = _584_, __name = "reify"})
  end
  local function alt_handler(flag, cb)
    local _595_ = {}
    do
      do
        local case_596_ = Handler["active?"]
        if (nil ~= case_596_) then
          local f_3_auto = case_596_
          local function _597_(_)
            return flag["active?"](flag)
          end
          _595_["active?"] = _597_
        else
          local _ = case_596_
          error("Protocol Handler doesn't define method active?")
        end
      end
      do
        local case_599_ = Handler["blockable?"]
        if (nil ~= case_599_) then
          local f_3_auto = case_599_
          local function _600_(_)
            return true
          end
          _595_["blockable?"] = _600_
        else
          local _ = case_599_
          error("Protocol Handler doesn't define method blockable?")
        end
      end
      local case_602_ = Handler.commit
      if (nil ~= case_602_) then
        local f_3_auto = case_602_
        local function _603_(_)
          flag:commit()
          return cb
        end
        _595_["commit"] = _603_
      else
        local _ = case_602_
        error("Protocol Handler doesn't define method commit")
      end
    end
    local function _605_(_241)
      return ("#<" .. tostring(_241):gsub("table:", "reify:") .. ": " .. "Handler" .. ">")
    end
    return setmetatable({}, {__fennelview = _605_, __index = _595_, __name = "reify"})
  end
  local function alts_21(ports, ...)
    assert(not main_thread_3f(), "called alts! on the main thread")
    assert((#ports > 0), "alts must have at least one channel operation")
    local n = #ports
    local arglen = select("#", ...)
    local no_def = {}
    local opts
    do
      local case_606_, case_607_ = select("#", ...), ...
      if (case_606_ == 0) then
        opts = {default = no_def}
      else
        local and_608_ = ((case_606_ == 1) and (nil ~= case_607_))
        if and_608_ then
          local t = case_607_
          and_608_ = ("table" == type(t))
        end
        if and_608_ then
          local t = case_607_
          local res = {default = no_def}
          for k, v in pairs(t) do
            res[k] = v
            res = res
          end
          opts = res
        else
          local _ = case_606_
          local res = {default = no_def}
          for i = 1, arglen, 2 do
            local k, v = select(i, ...)
            res[k] = v
            res = res
          end
          opts = res
        end
      end
    end
    local ids = random_array(n)
    local res_ch = chan(promise_buffer())
    local flag = alt_flag()
    local done = nil
    for i = 1, n do
      if done then break end
      local id
      if (opts and opts.priority) then
        id = i
      else
        id = ids[i]
      end
      local retb, port
      do
        local case_612_ = ports[id]
        local and_613_ = ((_G.type(case_612_) == "table") and true and true)
        if and_613_ then
          local _3fc = case_612_[1]
          local _3fv = case_612_[2]
          and_613_ = chan_3f(_3fc)
        end
        if and_613_ then
          local _3fc = case_612_[1]
          local _3fv = case_612_[2]
          local function _615_(_241)
            put_21(res_ch, {_241, _3fc})
            return close_21(res_ch)
          end
          retb, port = _3fc["put!"](_3fc, _3fv, alt_handler(flag, _615_), true), _3fc
        else
          local and_616_ = true
          if and_616_ then
            local _3fc = case_612_
            and_616_ = chan_3f(_3fc)
          end
          if and_616_ then
            local _3fc = case_612_
            local function _618_(_241)
              put_21(res_ch, {_241, _3fc})
              return close_21(res_ch)
            end
            retb, port = _3fc["take!"](_3fc, alt_handler(flag, _618_), true), _3fc
          else
            local _ = case_612_
            retb, port = error(("expected a channel: " .. tostring(_)))
          end
        end
      end
      if (nil ~= retb) then
        _3e_21(res_ch, {retb[1], port})
        done = true
      else
      end
    end
    if (flag["active?"](flag) and (no_def ~= opts.default)) then
      flag:commit()
      return {opts.default, "default"}
    else
      return _3c_21(res_ch)
    end
  end
  local function offer_21(port, val)
    assert(chan_3f(port), "expected a channel as first argument")
    if (next(port.takes) or (port.buf and not port.buf["full?"](port.buf))) then
      local case_622_ = port["put!"](port, val, fhnop)
      if (nil ~= case_622_) then
        local retb = case_622_
        return retb[1]
      else
        return nil
      end
    else
      return nil
    end
  end
  local function poll_21(port)
    assert(chan_3f(port), "expected a channel")
    if (next(port.puts) or (port.buf and (nil ~= next(port.buf.buf)))) then
      local case_625_ = port["take!"](port, fhnop)
      if (nil ~= case_625_) then
        local retb = case_625_
        return retb[1]
      else
        return nil
      end
    else
      return nil
    end
  end
  local function pipe(from, to, ...)
    local close_3f
    if (select("#", ...) == 0) then
      close_3f = true
    else
      close_3f = ...
    end
    local _let_629_ = require("io.gitlab.andreyorst.async")
    local go_3_auto = _let_629_["go*"]
    local function _630_()
      local function recur()
        local val = _3c_21(from)
        if (nil == val) then
          if close_3f then
            return close_21(to)
          else
            return nil
          end
        else
          _3e_21(to, val)
          return recur()
        end
      end
      return recur()
    end
    return go_3_auto(_630_)
  end
  local function pipeline_2a(n, to, xf, from, close_3f, err_handler, kind)
    local jobs = chan(n)
    local results = chan(n)
    local finishes = ((kind == "async") and chan(n))
    local process
    local function _633_(job)
      if (job == nil) then
        close_21(results)
        return nil
      elseif ((_G.type(job) == "table") and (nil ~= job[1]) and (nil ~= job[2])) then
        local v = job[1]
        local p = job[2]
        local res = chan(1, xf, err_handler)
        do
          local _let_634_ = require("io.gitlab.andreyorst.async")
          local go_1_auto = _let_634_["go*"]
          local function _635_()
            _3e_21(res, v)
            return close_21(res)
          end
          go_1_auto(_635_)
        end
        put_21(p, res)
        return true
      else
        return nil
      end
    end
    process = _633_
    local async
    local function _637_(job)
      if (job == nil) then
        close_21(results)
        close_21(finishes)
        return nil
      elseif ((_G.type(job) == "table") and (nil ~= job[1]) and (nil ~= job[2])) then
        local v = job[1]
        local p = job[2]
        local res = chan(1)
        xf(v, res)
        put_21(p, res)
        return true
      else
        return nil
      end
    end
    async = _637_
    for _ = 1, n do
      if (kind == "compute") then
        local _let_639_ = require("io.gitlab.andreyorst.async")
        local go_3_auto = _let_639_["go*"]
        local function _640_()
          local function recur()
            local job = _3c_21(jobs)
            if process(job) then
              return recur()
            else
              return nil
            end
          end
          return recur()
        end
        go_3_auto(_640_)
      elseif (kind == "async") then
        local _let_642_ = require("io.gitlab.andreyorst.async")
        local go_3_auto = _let_642_["go*"]
        local function _643_()
          local function recur()
            local job = _3c_21(jobs)
            if async(job) then
              _3c_21(finishes)
              return recur()
            else
              return nil
            end
          end
          return recur()
        end
        go_3_auto(_643_)
      else
      end
    end
    do
      local _let_646_ = require("io.gitlab.andreyorst.async")
      local go_3_auto = _let_646_["go*"]
      local function _647_()
        local function recur()
          local case_648_ = _3c_21(from)
          if (case_648_ == nil) then
            return close_21(jobs)
          elseif (nil ~= case_648_) then
            local v = case_648_
            local p = chan(1)
            _3e_21(jobs, {v, p})
            _3e_21(results, p)
            return recur()
          else
            return nil
          end
        end
        return recur()
      end
      go_3_auto(_647_)
    end
    local _let_650_ = require("io.gitlab.andreyorst.async")
    local go_3_auto = _let_650_["go*"]
    local function _651_()
      local function recur()
        local case_652_ = _3c_21(results)
        if (case_652_ == nil) then
          if close_3f then
            return close_21(to)
          else
            return nil
          end
        elseif (nil ~= case_652_) then
          local p = case_652_
          local case_654_ = _3c_21(p)
          if (nil ~= case_654_) then
            local res = case_654_
            local function loop_2a()
              local case_655_ = _3c_21(res)
              if (nil ~= case_655_) then
                local val = case_655_
                _3e_21(to, val)
                return loop_2a()
              else
                return nil
              end
            end
            loop_2a()
            if finishes then
              _3e_21(finishes, "done")
            else
            end
            return recur()
          else
            return nil
          end
        else
          return nil
        end
      end
      return recur()
    end
    return go_3_auto(_651_)
  end
  local function pipeline_async(n, to, af, from, ...)
    local close_3f
    if (select("#", ...) == 0) then
      close_3f = true
    else
      close_3f = ...
    end
    return pipeline_2a(n, to, af, from, close_3f, nil, "async")
  end
  local function pipeline(n, to, xf, from, ...)
    local close_3f, err_handler
    if (select("#", ...) == 0) then
      close_3f, err_handler = true
    else
      close_3f, err_handler = ...
    end
    return pipeline_2a(n, to, xf, from, close_3f, err_handler, "compute")
  end
  local function split(p, ch, t_buf_or_n, f_buf_or_n)
    local tc = chan(t_buf_or_n)
    local fc = chan(f_buf_or_n)
    do
      local _let_662_ = require("io.gitlab.andreyorst.async")
      local go_3_auto = _let_662_["go*"]
      local function _663_()
        local function recur()
          local v = _3c_21(ch)
          if (nil == v) then
            close_21(tc)
            return close_21(fc)
          else
            local _664_
            if p(v) then
              _664_ = tc
            else
              _664_ = fc
            end
            if _3e_21(_664_, v) then
              return recur()
            else
              return nil
            end
          end
        end
        return recur()
      end
      go_3_auto(_663_)
    end
    return {tc, fc}
  end
  local function reduce(f, init, ch)
    local _let_669_ = require("io.gitlab.andreyorst.async")
    local go_3_auto = _let_669_["go*"]
    local function _670_()
      local _2_668_ = init
      local ret = _2_668_
      local function recur(ret0)
        local v = _3c_21(ch)
        if (nil == v) then
          return ret0
        else
          local res = f(ret0, v)
          if reduced_3f(res) then
            return res:unbox()
          else
            return recur(res)
          end
        end
      end
      return recur(_2_668_)
    end
    return go_3_auto(_670_)
  end
  local function transduce(xform, f, init, ch)
    local f0 = xform(f)
    local _let_673_ = require("io.gitlab.andreyorst.async")
    local go_1_auto = _let_673_["go*"]
    local function _674_()
      local ret = _3c_21(reduce(f0, init, ch))
      return f0(ret)
    end
    return go_1_auto(_674_)
  end
  local function onto_chan_21(ch, coll, ...)
    local close_3f
    if (select("#", ...) == 0) then
      close_3f = true
    else
      close_3f = ...
    end
    local _let_676_ = require("io.gitlab.andreyorst.async")
    local go_1_auto = _let_676_["go*"]
    local function _677_()
      for _, v in ipairs(coll) do
        _3e_21(ch, v)
      end
      if close_3f then
        close_21(ch)
      else
      end
      return ch
    end
    return go_1_auto(_677_)
  end
  local function bounded_length(bound, t)
    return m_2fmin(bound, #t)
  end
  local function to_chan_21(coll)
    local ch = chan(bounded_length(100, coll))
    onto_chan_21(ch, coll)
    return ch
  end
  local function pipeline_unordered_2a(n, to, xf, from, close_3f, err_handler, kind)
    local closes
    local function _679_()
      local tbl_26_ = {}
      local i_27_ = 0
      for _ = 1, (n - 1) do
        local val_28_ = "close"
        if (nil ~= val_28_) then
          i_27_ = (i_27_ + 1)
          tbl_26_[i_27_] = val_28_
        else
        end
      end
      return tbl_26_
    end
    closes = to_chan_21(_679_())
    local process
    local function _681_(v, p)
      local res = chan(1, xf, err_handler)
      local _let_682_ = require("io.gitlab.andreyorst.async")
      local go_1_auto = _let_682_["go*"]
      local function _683_()
        _3e_21(res, v)
        close_21(res)
        local function loop()
          local case_684_ = _3c_21(res)
          if (nil ~= case_684_) then
            local v0 = case_684_
            put_21(p, v0)
            return loop()
          else
            return nil
          end
        end
        loop()
        return close_21(p)
      end
      return go_1_auto(_683_)
    end
    process = _681_
    for _ = 1, n do
      local _let_686_ = require("io.gitlab.andreyorst.async")
      local go_3_auto = _let_686_["go*"]
      local function _687_()
        local function recur()
          local case_688_ = _3c_21(from)
          if (nil ~= case_688_) then
            local v = case_688_
            local c = chan(1)
            if (kind == "compute") then
              local _let_689_ = require("io.gitlab.andreyorst.async")
              local go_1_auto = _let_689_["go*"]
              local function _690_()
                return process(v, c)
              end
              go_1_auto(_690_)
            elseif (kind == "async") then
              local _let_691_ = require("io.gitlab.andreyorst.async")
              local go_1_auto = _let_691_["go*"]
              local function _692_()
                return xf(v, c)
              end
              go_1_auto(_692_)
            else
            end
            local function loop()
              local case_694_ = _3c_21(c)
              if (nil ~= case_694_) then
                local res = case_694_
                if _3e_21(to, res) then
                  return loop()
                else
                  return nil
                end
              else
                local _0 = case_694_
                return true
              end
            end
            if loop() then
              return recur()
            else
              return nil
            end
          else
            local _0 = case_688_
            if (close_3f and (nil == _3c_21(closes))) then
              return close_21(to)
            else
              return nil
            end
          end
        end
        return recur()
      end
      go_3_auto(_687_)
    end
    return nil
  end
  local function pipeline_unordered(n, to, xf, from, ...)
    local close_3f, err_handler
    if (select("#", ...) == 0) then
      close_3f, err_handler = true
    else
      close_3f, err_handler = ...
    end
    return pipeline_unordered_2a(n, to, xf, from, close_3f, err_handler, "compute")
  end
  local function pipeline_async_unordered(n, to, af, from, ...)
    local close_3f
    if (select("#", ...) == 0) then
      close_3f = true
    else
      close_3f = ...
    end
    return pipeline_unordered_2a(n, to, af, from, close_3f, nil, "async")
  end
  local function muxch_2a(_)
    return _["muxch*"](_)
  end
  local _local_702_ = {["muxch*"] = muxch_2a}
  local muxch_2a0 = _local_702_["muxch*"]
  local Mux = _local_702_
  local function tap_2a(_, ch, close_3f)
    if (nil == close_3f) then
      _G.error("Missing argument close? on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:1208", 2)
    else
    end
    if (nil == ch) then
      _G.error("Missing argument ch on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:1208", 2)
    else
    end
    return _["tap*"](_, ch, close_3f)
  end
  local function untap_2a(_, ch)
    if (nil == ch) then
      _G.error("Missing argument ch on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:1209", 2)
    else
    end
    return _["untap*"](_, ch)
  end
  local function untap_all_2a(_)
    return _["untap-all*"](_)
  end
  local _local_706_ = {["tap*"] = tap_2a, ["untap*"] = untap_2a, ["untap-all*"] = untap_all_2a}
  local tap_2a0 = _local_706_["tap*"]
  local untap_2a0 = _local_706_["untap*"]
  local untap_all_2a0 = _local_706_["untap-all*"]
  local Mult = _local_706_
  local function mult(ch)
    local dctr = nil
    local atom = {cs = {}}
    local m
    do
      local _707_ = {}
      do
        do
          local case_708_ = Mux["muxch*"]
          if (nil ~= case_708_) then
            local f_3_auto = case_708_
            local function _709_(_)
              return ch
            end
            _707_["muxch*"] = _709_
          else
            local _ = case_708_
            error("Protocol Mux doesn't define method muxch*")
          end
        end
        do
          local case_711_ = Mult["tap*"]
          if (nil ~= case_711_) then
            local f_3_auto = case_711_
            local function _712_(_, ch0, close_3f)
              atom["cs"][ch0] = close_3f
              return nil
            end
            _707_["tap*"] = _712_
          else
            local _ = case_711_
            error("Protocol Mult doesn't define method tap*")
          end
        end
        do
          local case_714_ = Mult["untap*"]
          if (nil ~= case_714_) then
            local f_3_auto = case_714_
            local function _715_(_, ch0)
              atom["cs"][ch0] = nil
              return nil
            end
            _707_["untap*"] = _715_
          else
            local _ = case_714_
            error("Protocol Mult doesn't define method untap*")
          end
        end
        local case_717_ = Mult["untap-all*"]
        if (nil ~= case_717_) then
          local f_3_auto = case_717_
          local function _718_(_)
            atom["cs"] = {}
            return nil
          end
          _707_["untap-all*"] = _718_
        else
          local _ = case_717_
          error("Protocol Mult doesn't define method untap-all*")
        end
      end
      local function _720_(_241)
        return ("#<" .. tostring(_241):gsub("table:", "reify:") .. ": " .. "Mux, Mult" .. ">")
      end
      m = setmetatable({}, {__fennelview = _720_, __index = _707_, __name = "reify"})
    end
    local dchan = chan(1)
    local done
    local function _721_(_)
      dctr = (dctr - 1)
      if (0 == dctr) then
        return put_21(dchan, true)
      else
        return nil
      end
    end
    done = _721_
    do
      local _let_723_ = require("io.gitlab.andreyorst.async")
      local go_3_auto = _let_723_["go*"]
      local function _724_()
        local function recur()
          local val = _3c_21(ch)
          if (nil == val) then
            for c, close_3f in pairs(atom.cs) do
              if close_3f then
                close_21(c)
              else
              end
            end
            return nil
          else
            local chs
            do
              local tbl_26_ = {}
              local i_27_ = 0
              for k in pairs(atom.cs) do
                local val_28_ = k
                if (nil ~= val_28_) then
                  i_27_ = (i_27_ + 1)
                  tbl_26_[i_27_] = val_28_
                else
                end
              end
              chs = tbl_26_
            end
            dctr = #chs
            for _, c in ipairs(chs) do
              if not put_21(c, val, done) then
                untap_2a0(m, c)
              else
              end
            end
            if next(chs) then
              _3c_21(dchan)
            else
            end
            return recur()
          end
        end
        return recur()
      end
      go_3_auto(_724_)
    end
    return m
  end
  local function tap(mult0, ch, ...)
    local close_3f
    if (select("#", ...) == 0) then
      close_3f = true
    else
      close_3f = ...
    end
    tap_2a0(mult0, ch, close_3f)
    return ch
  end
  local function untap(mult0, ch)
    return untap_2a0(mult0, ch)
  end
  local function untap_all(mult0)
    return untap_all_2a0(mult0)
  end
  local function admix_2a(_, ch)
    if (nil == ch) then
      _G.error("Missing argument ch on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:1272", 2)
    else
    end
    return _["admix*"](_, ch)
  end
  local function solo_mode_2a(_, mode)
    if (nil == mode) then
      _G.error("Missing argument mode on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:1276", 2)
    else
    end
    return _["solo-mode*"](_, mode)
  end
  local function toggle_2a(_, state_map)
    if (nil == state_map) then
      _G.error("Missing argument state-map on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:1275", 2)
    else
    end
    return _["toggle*"](_, state_map)
  end
  local function unmix_2a(_, ch)
    if (nil == ch) then
      _G.error("Missing argument ch on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:1273", 2)
    else
    end
    return _["unmix*"](_, ch)
  end
  local function unmix_all_2a(_)
    return _["unmix-all*"](_)
  end
  local _local_735_ = {["admix*"] = admix_2a, ["solo-mode*"] = solo_mode_2a, ["toggle*"] = toggle_2a, ["unmix*"] = unmix_2a, ["unmix-all*"] = unmix_all_2a}
  local admix_2a0 = _local_735_["admix*"]
  local solo_mode_2a0 = _local_735_["solo-mode*"]
  local toggle_2a0 = _local_735_["toggle*"]
  local unmix_2a0 = _local_735_["unmix*"]
  local unmix_all_2a0 = _local_735_["unmix-all*"]
  local Mix = _local_735_
  local function mix(out)
    local atom = {cs = {}, ["solo-mode"] = "mute"}
    local solo_modes = {mute = true, pause = true}
    local change = chan(sliding_buffer(1))
    local changed
    local function _736_()
      return put_21(change, true)
    end
    changed = _736_
    local pick
    local function _737_(attr, chs)
      local tbl_21_ = {}
      for c, v in pairs(chs) do
        local k_22_, v_23_
        if v[attr] then
          k_22_, v_23_ = c, true
        else
          k_22_, v_23_ = nil
        end
        if ((k_22_ ~= nil) and (v_23_ ~= nil)) then
          tbl_21_[k_22_] = v_23_
        else
        end
      end
      return tbl_21_
    end
    pick = _737_
    local calc_state
    local function _740_()
      local chs = atom.cs
      local mode = atom["solo-mode"]
      local solos = pick("solo", chs)
      local pauses = pick("pause", chs)
      local _741_
      do
        local tmp_9_
        if ((mode == "pause") and next(solos)) then
          local tbl_26_ = {}
          local i_27_ = 0
          for k in pairs(solos) do
            local val_28_ = k
            if (nil ~= val_28_) then
              i_27_ = (i_27_ + 1)
              tbl_26_[i_27_] = val_28_
            else
            end
          end
          tmp_9_ = tbl_26_
        else
          local tbl_26_ = {}
          local i_27_ = 0
          for k in pairs(chs) do
            local val_28_
            if not pauses[k] then
              val_28_ = k
            else
              val_28_ = nil
            end
            if (nil ~= val_28_) then
              i_27_ = (i_27_ + 1)
              tbl_26_[i_27_] = val_28_
            else
            end
          end
          tmp_9_ = tbl_26_
        end
        t_2finsert(tmp_9_, change)
        _741_ = tmp_9_
      end
      return {solos = solos, mutes = pick("mute", chs), reads = _741_}
    end
    calc_state = _740_
    local m
    do
      local _746_ = {}
      do
        do
          local case_747_ = Mux["muxch*"]
          if (nil ~= case_747_) then
            local f_3_auto = case_747_
            local function _748_(_)
              return out
            end
            _746_["muxch*"] = _748_
          else
            local _ = case_747_
            error("Protocol Mux doesn't define method muxch*")
          end
        end
        do
          local case_750_ = Mix["admix*"]
          if (nil ~= case_750_) then
            local f_3_auto = case_750_
            local function _751_(_, ch)
              atom.cs[ch] = {}
              return changed()
            end
            _746_["admix*"] = _751_
          else
            local _ = case_750_
            error("Protocol Mix doesn't define method admix*")
          end
        end
        do
          local case_753_ = Mix["unmix*"]
          if (nil ~= case_753_) then
            local f_3_auto = case_753_
            local function _754_(_, ch)
              atom.cs[ch] = nil
              return changed()
            end
            _746_["unmix*"] = _754_
          else
            local _ = case_753_
            error("Protocol Mix doesn't define method unmix*")
          end
        end
        do
          local case_756_ = Mix["unmix-all*"]
          if (nil ~= case_756_) then
            local f_3_auto = case_756_
            local function _757_(_)
              atom.cs = {}
              return changed()
            end
            _746_["unmix-all*"] = _757_
          else
            local _ = case_756_
            error("Protocol Mix doesn't define method unmix-all*")
          end
        end
        do
          local case_759_ = Mix["toggle*"]
          if (nil ~= case_759_) then
            local f_3_auto = case_759_
            local function _760_(_, state_map)
              atom.cs = merge_with(merge_2a, atom.cs, state_map)
              return changed()
            end
            _746_["toggle*"] = _760_
          else
            local _ = case_759_
            error("Protocol Mix doesn't define method toggle*")
          end
        end
        local case_762_ = Mix["solo-mode*"]
        if (nil ~= case_762_) then
          local f_3_auto = case_762_
          local function _763_(_, mode)
            if not solo_modes[mode] then
              local _764_
              do
                local tbl_26_ = {}
                local i_27_ = 0
                for k in pairs(solo_modes) do
                  local val_28_ = k
                  if (nil ~= val_28_) then
                    i_27_ = (i_27_ + 1)
                    tbl_26_[i_27_] = val_28_
                  else
                  end
                end
                _764_ = tbl_26_
              end
              assert(false, ("mode must be one of: " .. t_2fconcat(_764_, ", ")))
            else
            end
            atom["solo-mode"] = mode
            return changed()
          end
          _746_["solo-mode*"] = _763_
        else
          local _ = case_762_
          error("Protocol Mix doesn't define method solo-mode*")
        end
      end
      local function _768_(_241)
        return ("#<" .. tostring(_241):gsub("table:", "reify:") .. ": " .. "Mux, Mix" .. ">")
      end
      m = setmetatable({}, {__fennelview = _768_, __index = _746_, __name = "reify"})
    end
    do
      local _let_770_ = require("io.gitlab.andreyorst.async")
      local go_3_auto = _let_770_["go*"]
      local function _771_()
        local _2_769_ = calc_state()
        local solos = _2_769_.solos
        local mutes = _2_769_.mutes
        local reads = _2_769_.reads
        local state = _2_769_
        local function recur(_772_)
          local solos0 = _772_.solos
          local mutes0 = _772_.mutes
          local reads0 = _772_.reads
          local state0 = _772_
          local _let_773_ = alts_21(reads0)
          local v = _let_773_[1]
          local c = _let_773_[2]
          local res = _let_773_
          if ((nil == v) or (c == change)) then
            if (nil == v) then
              atom.cs[c] = nil
            else
            end
            return recur(calc_state())
          else
            if (solos0[c] or (not next(solos0) and not mutes0[c])) then
              if _3e_21(out, v) then
                return recur(state0)
              else
                return nil
              end
            else
              return recur(state0)
            end
          end
        end
        return recur(_2_769_)
      end
      go_3_auto(_771_)
    end
    return m
  end
  local function admix(mix0, ch)
    return admix_2a0(mix0, ch)
  end
  local function unmix(mix0, ch)
    return unmix_2a0(mix0, ch)
  end
  local function unmix_all(mix0)
    return unmix_all_2a0(mix0)
  end
  local function toggle(mix0, state_map)
    return toggle_2a0(mix0, state_map)
  end
  local function solo_mode(mix0, mode)
    return solo_mode_2a0(mix0, mode)
  end
  local function sub_2a(_, v, ch, close_3f)
    if (nil == close_3f) then
      _G.error("Missing argument close? on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:1377", 2)
    else
    end
    if (nil == ch) then
      _G.error("Missing argument ch on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:1377", 2)
    else
    end
    if (nil == v) then
      _G.error("Missing argument v on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:1377", 2)
    else
    end
    return _["sub*"](_, v, ch, close_3f)
  end
  local function unsub_2a(_, v, ch)
    if (nil == ch) then
      _G.error("Missing argument ch on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:1378", 2)
    else
    end
    if (nil == v) then
      _G.error("Missing argument v on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:1378", 2)
    else
    end
    return _["unsub*"](_, v, ch)
  end
  local function unsub_all_2a(_, v)
    if (nil == v) then
      _G.error("Missing argument v on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:1379", 2)
    else
    end
    return _["unsub-all*"](_, v)
  end
  local _local_784_ = {["sub*"] = sub_2a, ["unsub*"] = unsub_2a, ["unsub-all*"] = unsub_all_2a}
  local sub_2a0 = _local_784_["sub*"]
  local unsub_2a0 = _local_784_["unsub*"]
  local unsub_all_2a0 = _local_784_["unsub-all*"]
  local Pub = _local_784_
  local function pub(ch, topic_fn, buf_fn)
    local buf_fn0
    local or_785_ = buf_fn
    if not or_785_ then
      local function _786_()
        return nil
      end
      or_785_ = _786_
    end
    buf_fn0 = or_785_
    local atom = {mults = {}}
    local ensure_mult
    local function _787_(topic)
      local case_788_ = atom.mults[topic]
      if (nil ~= case_788_) then
        local m = case_788_
        return m
      elseif (case_788_ == nil) then
        local mults = atom.mults
        local m = mult(chan(buf_fn0(topic)))
        do
          mults[topic] = m
        end
        return m
      else
        return nil
      end
    end
    ensure_mult = _787_
    local p
    do
      local _790_ = {}
      do
        do
          local case_791_ = Mux["muxch*"]
          if (nil ~= case_791_) then
            local f_3_auto = case_791_
            local function _792_(_)
              return ch
            end
            _790_["muxch*"] = _792_
          else
            local _ = case_791_
            error("Protocol Mux doesn't define method muxch*")
          end
        end
        do
          local case_794_ = Pub["sub*"]
          if (nil ~= case_794_) then
            local f_3_auto = case_794_
            local function _795_(_, topic, ch0, close_3f)
              local m = ensure_mult(topic)
              return tap_2a0(m, ch0, close_3f)
            end
            _790_["sub*"] = _795_
          else
            local _ = case_794_
            error("Protocol Pub doesn't define method sub*")
          end
        end
        do
          local case_797_ = Pub["unsub*"]
          if (nil ~= case_797_) then
            local f_3_auto = case_797_
            local function _798_(_, topic, ch0)
              local case_799_ = atom.mults[topic]
              if (nil ~= case_799_) then
                local m = case_799_
                return untap_2a0(m, ch0)
              else
                return nil
              end
            end
            _790_["unsub*"] = _798_
          else
            local _ = case_797_
            error("Protocol Pub doesn't define method unsub*")
          end
        end
        local case_802_ = Pub["unsub-all*"]
        if (nil ~= case_802_) then
          local f_3_auto = case_802_
          local function _803_(_, topic)
            if topic then
              atom["mults"][topic] = nil
              return nil
            else
              atom["mults"] = {}
              return nil
            end
          end
          _790_["unsub-all*"] = _803_
        else
          local _ = case_802_
          error("Protocol Pub doesn't define method unsub-all*")
        end
      end
      local function _806_(_241)
        return ("#<" .. tostring(_241):gsub("table:", "reify:") .. ": " .. "Mux, Pub" .. ">")
      end
      p = setmetatable({}, {__fennelview = _806_, __index = _790_, __name = "reify"})
    end
    do
      local _let_807_ = require("io.gitlab.andreyorst.async")
      local go_3_auto = _let_807_["go*"]
      local function _808_()
        local function recur()
          local val = _3c_21(ch)
          if (nil == val) then
            for _, m in pairs(atom.mults) do
              close_21(muxch_2a0(m))
            end
            return nil
          else
            local topic = topic_fn(val)
            do
              local case_809_ = atom.mults[topic]
              if (nil ~= case_809_) then
                local m = case_809_
                if not _3e_21(muxch_2a0(m), val) then
                  atom["mults"][topic] = nil
                else
                end
              else
              end
            end
            return recur()
          end
        end
        return recur()
      end
      go_3_auto(_808_)
    end
    return p
  end
  local function sub(pub0, topic, ch, ...)
    local close_3f
    if (select("#", ...) == 0) then
      close_3f = true
    else
      close_3f = ...
    end
    return sub_2a0(pub0, topic, ch, close_3f)
  end
  local function unsub(pub0, topic, ch)
    return unsub_2a0(pub0, topic, ch)
  end
  local function unsub_all(pub0, topic)
    return unsub_all_2a0(pub0, topic)
  end
  local function map(f, chs, buf_or_n)
    local dctr = nil
    local out = chan(buf_or_n)
    local cnt = #chs
    local rets = {n = cnt}
    local dchan = chan(1)
    local done
    do
      local tbl_26_ = {}
      local i_27_ = 0
      for i = 1, cnt do
        local val_28_
        local function _814_(ret)
          rets[i] = ret
          dctr = (dctr - 1)
          if (0 == dctr) then
            return put_21(dchan, rets)
          else
            return nil
          end
        end
        val_28_ = _814_
        if (nil ~= val_28_) then
          i_27_ = (i_27_ + 1)
          tbl_26_[i_27_] = val_28_
        else
        end
      end
      done = tbl_26_
    end
    if (0 == cnt) then
      close_21(out)
    else
      local _let_817_ = require("io.gitlab.andreyorst.async")
      local go_3_auto = _let_817_["go*"]
      local function _818_()
        local function recur()
          dctr = cnt
          for i = 1, cnt do
            local case_819_ = pcall(take_21, chs[i], done[i])
            if (case_819_ == false) then
              dctr = (dctr - 1)
            else
            end
          end
          local rets0 = _3c_21(dchan)
          local _821_
          do
            local res = false
            for i = 1, rets0.n do
              if res then break end
              res = (nil == rets0[i])
            end
            _821_ = res
          end
          if _821_ then
            return close_21(out)
          else
            _3e_21(out, f(t_2funpack(rets0)))
            return recur()
          end
        end
        return recur()
      end
      go_3_auto(_818_)
    end
    return out
  end
  local function merge(chs, buf_or_n)
    local out = chan(buf_or_n)
    do
      local _let_825_ = require("io.gitlab.andreyorst.async")
      local go_3_auto = _let_825_["go*"]
      local function _826_()
        local _2_824_ = chs
        local cs = _2_824_
        local function recur(cs0)
          if (#cs0 > 0) then
            local _let_827_ = alts_21(cs0)
            local v = _let_827_[1]
            local c = _let_827_[2]
            if (nil == v) then
              local function _828_()
                local tbl_26_ = {}
                local i_27_ = 0
                for _, c_2a in ipairs(cs0) do
                  local val_28_
                  if (c_2a ~= c) then
                    val_28_ = c_2a
                  else
                    val_28_ = nil
                  end
                  if (nil ~= val_28_) then
                    i_27_ = (i_27_ + 1)
                    tbl_26_[i_27_] = val_28_
                  else
                  end
                end
                return tbl_26_
              end
              return recur(_828_())
            else
              _3e_21(out, v)
              return recur(cs0)
            end
          else
            return close_21(out)
          end
        end
        return recur(_2_824_)
      end
      go_3_auto(_826_)
    end
    return out
  end
  local function into(t, ch)
    local function _833_(_241, _242)
      _241[(1 + #_241)] = _242
      return _241
    end
    return reduce(_833_, t, ch)
  end
  local function take(n, ch, buf_or_n)
    local out = chan(buf_or_n)
    do
      local _let_834_ = require("io.gitlab.andreyorst.async")
      local go_1_auto = _let_834_["go*"]
      local function _835_()
        local done = false
        for i = 1, n do
          if done then break end
          local case_836_ = _3c_21(ch)
          if (nil ~= case_836_) then
            local v = case_836_
            _3e_21(out, v)
          elseif (case_836_ == nil) then
            done = true
          else
          end
        end
        return close_21(out)
      end
      go_1_auto(_835_)
    end
    return out
  end
  return {buffer = buffer, ["dropping-buffer"] = dropping_buffer, ["sliding-buffer"] = sliding_buffer, ["promise-buffer"] = promise_buffer, ["unblocking-buffer?"] = unblocking_buffer_3f, ["main-thread?"] = main_thread_3f, chan = chan, ["chan?"] = chan_3f, ["promise-chan"] = promise_chan, ["take!"] = take_21, ["<!!"] = _3c_21_21, ["<!"] = _3c_21, timeout = timeout, ["put!"] = put_21, [">!!"] = _3e_21_21, [">!"] = _3e_21, ["close!"] = close_21, ["go*"] = go_2a, ["alts!"] = alts_21, ["offer!"] = offer_21, ["poll!"] = poll_21, pipe = pipe, ["pipeline-async"] = pipeline_async, pipeline = pipeline, ["pipeline-async-unordered"] = pipeline_async_unordered, ["pipeline-unordered"] = pipeline_unordered, reduce = reduce, reduced = reduced, ["reduced?"] = reduced_3f, transduce = transduce, split = split, ["onto-chan!"] = onto_chan_21, ["to-chan!"] = to_chan_21, mult = mult, tap = tap, untap = untap, ["untap-all"] = untap_all, mix = mix, admix = admix, unmix = unmix, ["unmix-all"] = unmix_all, toggle = toggle, ["solo-mode"] = solo_mode, pub = pub, sub = sub, unsub = unsub, ["unsub-all"] = unsub_all, map = map, merge = merge, into = into, take = take, buffers = {FixedBuffer = FixedBuffer, SlidingBuffer = SlidingBuffer, DroppingBuffer = DroppingBuffer, PromiseBuffer = PromiseBuffer}, __VERSION = "1.6.42"}
end
return require("io.gitlab.andreyorst.cljlib.core")
