let { tap, hold, td, combo, macro, ..} = import "fak/keycode.ncl" in

# add number of combos to physical keys for later use
let virtual_key_count = 12 in
let key_count = 34 + virtual_key_count in

# convenience aliases
# taps
let kc = tap.reg.kc in # normal keys
let ks = tap.reg.ks in # shifted keys
let md = tap.reg.mod in # combinable mods (ex.: md.lsft & kc.N1 will result in a shifted One ("!" on US layout))
# mod-hold
let mdh = hold.reg.mod in
# layer control
let lt = hold.reg.layer in
# boot, reset, etc
let fak = tap.custom.fak in
# media and mouse control
let media = tap.custom.media in
let mouse = tap.custom.mouse in
# unmapped / transparent taps and holds (transparent hold can make hrm work on any layer!)
let tx = tap.none in
let tt = tap.trans in
let hx = hold.none in
let ht = hold.trans in

# custom keycodes in a tidy container (access with `cu.COPY` etc.)
# overrides for comma and dot will be activated while shift is
# held, so we need to take that into account.
let cu = {
  COPY = md.lctl & kc.C, # md.lctl & kc.INS,
  PSTE = md.lctl & kc.V, # md.lsft & kc.INS, 
  CUT  = md.lctl & kc.X,
  UNDO  = md.lctl & kc.Z,
  VR = md.lgui & kc.RIGHT,
  VL = md.lgui & kc.LEFT,
  OE = macro.make [ macro.press mdh.ralt, macro.tap kc.O, macro.release mdh.ralt, ],
  AE = macro.make [ macro.press mdh.ralt, macro.tap kc.A, macro.release mdh.ralt, ],
  AO = macro.make [ macro.press mdh.ralt, macro.tap kc.W, macro.release mdh.ralt, ],
  # overrides for comma and dot
  scln = macro.make [
    macro.release hold.reg.mod.lsft, # release shift to be able to
    macro.tap kc.SCLN,               # type semicolon.
    macro.press hold.reg.mod.lsft,   # re-apply shift.
  ],
  coln = kc.SCLN,          # shift held means this'll type colon.
} in

# home row mods
# hold.reg.behavior is required for all hold-taps!
# I've added empty ones here for simplicity. See thumb function below for a slightly more involved approach.
let hrm = {
  # home row mods
  # A = mdh.lgui & kc.A & hold.reg.behavior {},
  # S = mdh.lalt & kc.S & hold.reg.behavior {},
  D = mdh.lsft & lt 3 & kc.D & hold.reg.behavior {},
  N3 = mdh.lsft & kc.N3 & hold.reg.behavior {},
  # F = mdh.lsft & kc.F & hold.reg.behavior {},
  # J = mdh.rsft & kc.J & hold.reg.behavior {},
  K = mdh.rsft & kc.K & hold.reg.behavior {},
  # L = mdh.ralt & kc.L & hold.reg.behavior {},
  # ";" = mdh.rgui & kc.SCLN & hold.reg.behavior {},
} in

# thumb keys defined here
# this function maps the numbers 0, 1, 2, 3 to the below behaviors
let thumb = fun thumb_idx =>
  let thumb_behavior = {
    timeout_ms = 150,
    timeout_decision = 'hold,
    key_interrupts = std.array.replicate key_count { decision = 'hold, trigger_on = 'release },
  } in
  [
    kc.A & lt 2 & hold.reg.behavior thumb_behavior, # thumb 0
    kc.BSPC  & lt 1 & hold.reg.behavior thumb_behavior, # thumb 1
    kc.BSPC & lt 3 & hold.reg.behavior thumb_behavior, # thumb 2
    kc.ENT  & lt 4 & hold.reg.behavior thumb_behavior, # thumb 3
  ]
  |> std.array.at thumb_idx # pick out the appropriate entry from the above list
in

### Keymap itself! ###
{
  # combos and other virtual keys are defined here
  # (careful, changes here require changes above! marked by "#1")
  virtual_keys = [
    combo.make 50 [0, 9], # Q+P
    combo.make 50 [0, 1], # Q+W
    combo.make 50 [0, 2], # Q+E
    combo.make 50 [11, 12], # S+D
    combo.make 50 [6, 7], # U+I
    combo.make 50 [6, 8], # U+I+O is impossible, let's try U+O
    combo.make 50 [8, 9], # O+P
    combo.make 50 [18, 19], # L+Ö
    combo.make 50 [13, 16], # K+L+Ö is imposible, let's try F+J
    combo.make 50 [26, 27], # m+, or )+>
    combo.make 50 [27, 28], # ,+. or >+=
    combo.make 50 [12, 17], # D+K
  ],
  layers = [
    # ALPHAS
    [
      kc.Q,    kc.W,    kc.E,    kc.R,    kc.T,        kc.Y,     kc.U,    kc.I,    kc.O,   kc.P,
      thumb 0,   kc.S,   hrm.D,   kc.F,   kc.G,        kc.H,     kc.J,   hrm.K,   kc.L,  cu.OE,
      kc.Z,    kc.X,    kc.C,    kc.V,    kc.B,        kc.N,     kc.M,    kc.COMM, kc.DOT, md.lgui,
                                 # thumb keys are defined above in the function "thumb"
                                 md.lctl, thumb 1,     kc.SPACE, md.lalt,
      # combos:
      fak.BOOT,
      kc.ESCAPE,
      kc.DELETE,
      kc.TAB,
      kc.QUOTE,
      ks.DQUO,
      cu.AO,
      cu.AE,
      kc.ENTER,
      ks.QUES,
      kc.SLASH,
      fak.CWTG,
    ],
    # NUM, transparent holds (&hx) to access the right hand hrm
    [
      ks.EXLM,  ks.AT,   ks.HASH, ks.DLR,   ks.PERC,  ks.CIRC,  ks.AMPR,  ks.ASTR,    kc.GRAVE,  kc.BACKSLASH,
      kc.N1,    kc.N2,   hrm.N3,  kc.N4,    kc.N5,    kc.N6,    kc.N7,    kc.N8 & hx, kc.N9,     kc.N0,
      kc.MINUS, ks.UNDS, ks.LABK, ks.LPRN   ks.LCBR,  ks.RCBR,  ks.RPRN,  ks.RABK,    kc.EQUAL,  tx & hx,
                                   tt & ht, tt & ht,  tt & ht,  kc.PRINT_SCREEN,
      # combos (need to add these to every layer)
      tx & hx, tx & hx, tx & hx,  tx & hx,
      tx & hx, tx & hx, tx & hx,  tx & hx,
      tx & hx, ks.PLUS, kc.EQUAL,  tx & hx,
    ],
    # NAV
    [
      tx & hx,    cu.VR      kc.UP,      cu.VL,      tx & hx,   tx & hx,    tx & hx,    tx & hx,    tx & hx,   tx & hx,
      tx & hx,    kc.LEFT,   kc.DOWN,    kc.RIGHT,   kc.END,    tx & hx,    tx & hx,    tx & hx,    tx & hx,   tx & hx,
      tx & hx,    cu.CUT,    cu.COPY,    cu.PSTE,    cu.UNDO,   tx & hx,    tx & hx,    tx & hx,    tx & hx,   tx & hx,
                          kc.CAPS_LOCK,   kc.LEFT_BRACKET,   kc.RIGHT_BRACKET,    tt & ht,
      # combos (need to add these to every layer)
      tx & hx, tx & hx, tx & hx, tx & hx,
      tx & hx, tx & hx, tx & hx, tx & hx,
      tx & hx, tx & hx, tx & hx, tx & hx,
      
    ],
    # KEYOVERRIDE
    [
      tt & ht, tt & ht, tt & ht, tt & ht, tt & ht,   tt & ht, tt & ht, tt & ht, tt & ht, tt & ht,
      tt & ht, tt & ht, tt & ht, tt & ht, tt & ht,   tt & ht, tt & ht, tt & ht, tt & ht, tt & ht,
      tt & ht, tt & ht, tt & ht, tt & ht, tt & ht,   tt & ht, tt & ht, cu.scln, cu.coln, tt & ht,
                                 tt & ht, tt & ht,   tt & ht, tt & ht,
      # combos (need to add these to every layer)
      tx & hx, tx & hx, tx & hx,  tx & hx,
      tx & hx, tx & hx, tx & hx,  tx & hx,
      tx & hx, tx & hx, tx & hx,  tx & hx,
    ],
    # FUN, not in use
    [
      tt,      fak.BOOT, tt & ht, tt & ht, tt & ht,   tt & ht, kc.F7,   kc.F8,   kc.F8,   tt & ht,
      tt & ht, kc.F12,   kc.F11,  kc.F10,  tt & ht,   tt & ht, kc.F4,   kc.F5,   kc.F6,   tt & ht,
      tx & hx, kc.F9,    kc.F8,   kc.F7,   tx & hx,   tx & hx, kc.F1,   kc.F2,   kc.F3,   tx & hx,
                                  tt & ht, tt & ht,   tt & ht, tt & ht,
      # combos (need to add these to every layer)
      tx & hx, tx & hx, tx & hx,  tx & hx,
      tx & hx, tx & hx, tx & hx,  tx & hx,
      tx & hx, tx & hx, tx & hx,  tx & hx,
    ],
  ]
}
