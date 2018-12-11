# Echelon Matrix
import strutils, sequtils

type
  Ratio = ref object
    nume : int # 分子
    deno : int # 分母
  
  Matrix = seq[seq[Ratio]]

# Ratio 関連

proc gcd(a, b: int): int =
  var
    x = a
    y = b
  while true:
    if x > y:
      x = x mod y
      if x == 0:
        return y
    else:
      y = y mod x
      if y == 0:
        return x

proc red(p: Ratio): Ratio =
  var
    n = p.nume
    d = p.deno
    g = gcd(n.abs, d.abs)
  return Ratio(nume: int(n/g), deno: int(d/g))

proc `$`(p: Ratio): string =
  if p.deno != 1:
    return "\"" & $p.nume & "/" & $p.deno & "\""
  else:
    return "\"" & $p.nume & "\""

proc ratioNew(a, b: int): Ratio =
  var
    n = a
    d = b
  # if d == 0: raise newException(ValueError, "0 division")
  if d == 0:
    return Ratio(nume: 1, deno: 0)
  if n == 0:
    return Ratio(nume: 0, deno: 1)

  if d < 0:
    n = -n
    d = -d

  result = Ratio(nume: n, deno: d)
  result = result.red

proc `+`(p: Ratio, q: Ratio): Ratio =
  return ratioNew(p.nume*q.deno+p.deno*q.nume, p.deno*q.deno)

proc `-`(p: Ratio, q: Ratio): Ratio =
  return ratioNew(p.nume*q.deno-p.deno*q.nume, p.deno*q.deno)

proc `*`(p: Ratio, q: Ratio): Ratio =
  return ratioNew(p.nume*q.nume, p.deno*q.deno)

proc `/`(p: Ratio, q: Ratio): Ratio =
  return ratioNew(p.nume*q.deno, p.deno*q.nume)

proc parseRatio(s: string): Ratio =
  var
    sp = s.split("/")
    n, d = 1
  n = sp[0].parseInt
  if sp.len == 2: d = sp[1].parseInt
  return ratioNew(n, d)

proc parseMatrix(mat_s: seq[seq[cstring]]): Matrix =
  result = @[]
  for row_s in mat_s:
    var row: seq[Ratio] = @[]
    for elm in row_s:
      row.add(($elm).parseRatio)
    result.add(row)

# 肝心の簡約化はここから

proc echelonize(mat: Matrix): Matrix =
  result = mat
  let
    row_num = len(result)
    col_num = len(result[0])
  # for j in 0..<col_num:
  var
    i, j = 0
  while j < col_num and i < row_num:
    for k in i..<row_num:
      var a = result[k][j]
      if a.nume == 0:
        if k < row_num-1:
          continue
        else:
          j += 1 # 列カウンタのみ進める
          break

      result[k] = result[k].map(proc(r: Ratio): Ratio = r / a)

      for p in 0..<row_num:
        if p != k:
          var t = result[p][j]
          for q in j..<col_num:
            result[p][q] = result[p][q] - result[k][q] * t

      (result[i], result[k]) = (result[k], result[i])
      i += 1
      j += 1
      break

proc main(mat_s: seq[seq[cstring]]): cstring {. exportc .} =
  var
    mat = mat_s.parseMatrix
    res = mat.echelonize
  
  return ($res).replace("@", "")