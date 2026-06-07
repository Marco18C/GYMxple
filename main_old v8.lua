-- ====================================================
-- GYM MANAGER - Sistema de Gestión de Gimnasio
-- Desarrollado en Löve2D (Lua) | v1.0
-- ====================================================

local utf8 = require("utf8")

-- ============= DIMENSIONES Y COLORES =============
local W, H = 1280, 720
local SIDEBAR_W = 195
local HEADER_H  = 54

local C = {
    bg          = {0.030, 0.025, 0.045},
    sidebar_bg  = {0.040, 0.032, 0.060},
    sidebar_sel = {0.580, 0.320, 1.000},
    header_bg   = {0.050, 0.040, 0.075},

    card        = {0.075, 0.060, 0.110},
    card2       = {0.065, 0.050, 0.095},
    input_bg    = {0.100, 0.082, 0.150},

    white       = {0.95, 0.95, 1.00},
    gray        = {0.62, 0.60, 0.74},
    dim         = {0.36, 0.34, 0.48},

    blue        = {0.35, 0.60, 1.00},
    green       = {0.28, 0.85, 0.50},
    red         = {1.00, 0.30, 0.40},
    yellow      = {1.00, 0.80, 0.25},
    orange      = {1.00, 0.52, 0.18},
    cyan        = {0.20, 0.90, 1.00},
    purple      = {0.72, 0.42, 1.00},

    btn_green   = {0.18, 0.72, 0.40},
    btn_cancel  = {0.160, 0.130, 0.240},

    border      = {0.180, 0.140, 0.300},

    row_a       = {0.082, 0.066, 0.120},
    row_b       = {0.072, 0.058, 0.108},
    row_red     = {0.220, 0.080, 0.110},
}

-- ============= ESTADO GLOBAL =============
local G = {
    screen       = "inicio",
    clients      = {},
    transactions = {},
    notes        = {},
    notifs       = {},
    next_id      = 1,
    fonts        = {},
    text_inputs  = {},
    focus        = nil,
    dropdown     = nil,
    scroll       = {inicio = 0, clientes = 0, agenda = 0, configuracion = 0, soporte = 0, transacciones = 0},
    settings     = {},
    chart_mode   = "dias",
    ag_view      = "semana",
    ag_week_off  = 0,
    ag_selected  = nil,
    cl_filter    = "todos",
    show_confirm  = false,
    show_close_summary = false,
    close_summary = nil,
    pending_action = nil,
    show_new_note = false,
    new_note_day   = 0,
    new_note_color = "blue",
    edit_note_modal = nil,
    note_amount_confirm = nil,
    edit_client_id = nil,
    renew_modal = nil,
    -- Transaction manager state
    tx_search        = "",
    tx_delete_confirm = nil,   -- {idx, stage}
    tx_edit_modal    = nil,    -- {idx, ts, monto, plan, cliente, tipo, hora, cal_year, cal_month, cal_day, clock_h, clock_m, show_cal, show_clock}
    tx_new_modal     = nil,    -- same shape as tx_edit_modal but new record
    tx_rename_modal  = nil,    -- {idx, field, value}
    edit_client_modal = nil,
    show_bmi_calc = false,
    bmi_weight = "",
    bmi_height = "",
    editor = {},
    req_state = {medical = false, contract = false, terms = false},
    time_str     = "", 
    date_str     = "",
    dt           = 0,
}

local PLAN_PRICES  = {Diario = 5, Semanal = 25, Quincenal = 45, Mensual = 80}
local PLAN_OPTIONS = {"Diario", "Semanal", "Quincenal", "Mensual"}
local SPECIAL_PLAN = "ESPECIAL"
local PAGO_OPTIONS = {"Efectivo", "Tarjeta Crédito", "Tarjeta Débito", "Transferencia"}
local NOTE_COLORS  = {blue = C.blue, green = C.green, yellow = C.yellow, red = C.red, cyan = C.cyan, purple = C.purple}
local MONTH_NAMES  = {"Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"}
local DAY_SHORT    = {"Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"}

local THEME_PRESETS = {
    ["Neo Night"] = {
        bg = {0.030, 0.025, 0.045},
        sidebar_bg = {0.040, 0.032, 0.060},
        sidebar_sel = {0.580, 0.320, 1.000},
        header_bg = {0.050, 0.040, 0.075},
        card = {0.075, 0.060, 0.110},
        card2 = {0.065, 0.050, 0.095},
        input_bg = {0.100, 0.082, 0.150},
        white = {0.95, 0.95, 1.00},
        gray = {0.62, 0.60, 0.74},
        dim = {0.36, 0.34, 0.48},
        blue = {0.35, 0.60, 1.00},
        green = {0.28, 0.85, 0.50},
        red = {1.00, 0.30, 0.40},
        yellow = {1.00, 0.80, 0.25},
        orange = {1.00, 0.52, 0.18},
        cyan = {0.20, 0.90, 1.00},
        purple = {0.72, 0.42, 1.00},
        btn_green = {0.18, 0.72, 0.40},
        btn_cancel = {0.160, 0.130, 0.240},
        border = {0.180, 0.140, 0.300},
        row_a = {0.082, 0.066, 0.120},
        row_b = {0.072, 0.058, 0.108},
        row_red = {0.220, 0.080, 0.110},
    },
    ["Blue Steel"] = {
        bg = {0.028, 0.035, 0.050},
        sidebar_bg = {0.035, 0.045, 0.065},
        sidebar_sel = {0.220, 0.620, 1.000},
        header_bg = {0.040, 0.055, 0.082},
        card = {0.062, 0.075, 0.105},
        card2 = {0.052, 0.064, 0.090},
        input_bg = {0.082, 0.102, 0.142},
        white = {0.95, 0.97, 1.00},
        gray = {0.63, 0.68, 0.80},
        dim = {0.38, 0.42, 0.54},
        blue = {0.28, 0.68, 1.00},
        green = {0.26, 0.82, 0.56},
        red = {1.00, 0.32, 0.42},
        yellow = {1.00, 0.82, 0.32},
        orange = {1.00, 0.56, 0.20},
        cyan = {0.24, 0.94, 1.00},
        purple = {0.78, 0.48, 1.00},
        btn_green = {0.20, 0.68, 0.40},
        btn_cancel = {0.150, 0.160, 0.250},
        border = {0.150, 0.210, 0.320},
        row_a = {0.070, 0.086, 0.118},
        row_b = {0.060, 0.078, 0.110},
        row_red = {0.210, 0.085, 0.110},
    },
    ["Emerald Night"] = {
        bg = {0.022, 0.036, 0.030},
        sidebar_bg = {0.028, 0.046, 0.038},
        sidebar_sel = {0.220, 0.760, 0.520},
        header_bg = {0.030, 0.055, 0.044},
        card = {0.048, 0.074, 0.062},
        card2 = {0.042, 0.064, 0.054},
        input_bg = {0.066, 0.098, 0.086},
        white = {0.95, 0.99, 0.96},
        gray = {0.60, 0.72, 0.66},
        dim = {0.34, 0.46, 0.42},
        blue = {0.20, 0.72, 1.00},
        green = {0.24, 0.88, 0.54},
        red = {1.00, 0.34, 0.42},
        yellow = {1.00, 0.82, 0.28},
        orange = {1.00, 0.60, 0.22},
        cyan = {0.24, 0.96, 0.92},
        purple = {0.72, 0.44, 1.00},
        btn_green = {0.18, 0.66, 0.42},
        btn_cancel = {0.120, 0.180, 0.170},
        border = {0.120, 0.260, 0.220},
        row_a = {0.052, 0.084, 0.072},
        row_b = {0.046, 0.074, 0.064},
        row_red = {0.220, 0.090, 0.110},
    },
    ["Cyberpunk Neon"] = {
        bg          = {0.050, 0.035, 0.090},
        sidebar_bg  = {0.070, 0.050, 0.120},
        sidebar_sel = {1.000, 0.000, 0.600},
        header_bg   = {0.080, 0.060, 0.140},
        card        = {0.110, 0.090, 0.180},
        card2       = {0.090, 0.070, 0.150},
        input_bg    = {0.140, 0.120, 0.240},
        white       = {1.0, 1.0, 1.0},
        gray        = {0.65, 0.65, 0.75},
        dim         = {0.35, 0.35, 0.45},
        blue        = {0.000, 0.800, 1.000},
        green       = {0.000, 1.000, 0.500},
        red         = {1.000, 0.200, 0.350},
        yellow      = {1.000, 0.850, 0.200},
        orange      = {1.000, 0.500, 0.100},
        cyan        = {0.000, 1.000, 1.000},
        purple      = {0.700, 0.200, 1.000},
        btn_green   = {0.000, 0.800, 0.400},
        btn_cancel  = {0.220, 0.140, 0.300},
        border      = {0.250, 0.180, 0.400},
        row_a       = {0.120, 0.090, 0.180},
        row_b       = {0.100, 0.080, 0.160},
        row_red     = {0.250, 0.080, 0.120},
    },
    ["Nature / Forest"] = {
        bg          = {0.055, 0.080, 0.060},
        sidebar_bg  = {0.045, 0.065, 0.050},
        sidebar_sel = {0.220, 0.620, 0.380},
        header_bg   = {0.060, 0.090, 0.070},
        card        = {0.090, 0.120, 0.100},
        card2       = {0.075, 0.105, 0.085},
        input_bg    = {0.110, 0.150, 0.120},
        white       = {0.95, 0.98, 0.95},
        gray        = {0.55, 0.60, 0.55},
        dim         = {0.30, 0.35, 0.30},
        blue        = {0.300, 0.550, 0.850},
        green       = {0.300, 0.850, 0.450},
        red         = {0.780, 0.250, 0.250},
        yellow      = {0.900, 0.750, 0.250},
        orange      = {0.900, 0.500, 0.200},
        cyan        = {0.250, 0.750, 0.700},
        purple      = {0.500, 0.350, 0.750},
        btn_green   = {0.220, 0.700, 0.350},
        btn_cancel  = {0.180, 0.220, 0.180},
        border      = {0.160, 0.220, 0.180},
        row_a       = {0.090, 0.125, 0.100},
        row_b       = {0.080, 0.115, 0.090},
        row_red     = {0.180, 0.090, 0.090},
    },
    ["Light Modern"] = {
        bg          = {0.940, 0.945, 0.960},
        sidebar_bg  = {0.900, 0.910, 0.940},
        sidebar_sel = {0.250, 0.450, 0.950},
        header_bg   = {0.920, 0.930, 0.960},
        card        = {1.000, 1.000, 1.000},
        card2       = {0.970, 0.975, 0.990},
        input_bg    = {0.880, 0.890, 0.940},
        white       = {0.050, 0.050, 0.050},
        gray        = {0.400, 0.400, 0.450},
        dim         = {0.550, 0.550, 0.600},
        blue        = {0.200, 0.450, 0.950},
        green       = {0.150, 0.700, 0.350},
        red         = {0.850, 0.250, 0.250},
        yellow      = {0.900, 0.700, 0.150},
        orange      = {0.950, 0.500, 0.150},
        cyan        = {0.100, 0.700, 0.800},
        purple      = {0.500, 0.300, 0.850},
        btn_green   = {0.150, 0.700, 0.350},
        btn_cancel  = {0.750, 0.760, 0.820},
        border      = {0.820, 0.830, 0.880},
        row_a       = {0.980, 0.980, 1.000},
        row_b       = {0.950, 0.955, 0.980},
        row_red     = {1.000, 0.900, 0.900},
    },
    ["Warm Retro"] = {
        bg          = {0.120, 0.090, 0.070},
        sidebar_bg  = {0.100, 0.075, 0.055},
        sidebar_sel = {0.850, 0.450, 0.180},
        header_bg   = {0.140, 0.100, 0.080},
        card        = {0.180, 0.130, 0.100},
        card2       = {0.160, 0.115, 0.090},
        input_bg    = {0.220, 0.170, 0.130},
        white       = {0.980, 0.940, 0.880},
        gray        = {0.620, 0.550, 0.480},
        dim         = {0.380, 0.320, 0.280},
        blue        = {0.300, 0.550, 0.850},
        green       = {0.450, 0.750, 0.350},
        red         = {0.850, 0.320, 0.250},
        yellow      = {0.950, 0.750, 0.250},
        orange      = {0.950, 0.520, 0.180},
        cyan        = {0.350, 0.700, 0.700},
        purple      = {0.600, 0.350, 0.750},
        btn_green   = {0.350, 0.650, 0.250},
        btn_cancel  = {0.260, 0.200, 0.160},
        border      = {0.280, 0.220, 0.180},
        row_a       = {0.180, 0.130, 0.100},
        row_b       = {0.160, 0.115, 0.090},
        row_red     = {0.280, 0.120, 0.100},
    },
    ["Lava / Red Dark"] = {
        bg          = {0.050, 0.020, 0.020},
        sidebar_bg  = {0.080, 0.030, 0.030},
        sidebar_sel = {0.900, 0.180, 0.180},
        header_bg   = {0.090, 0.040, 0.040},
        card        = {0.130, 0.060, 0.060},
        card2       = {0.110, 0.050, 0.050},
        input_bg    = {0.180, 0.080, 0.080},
        white       = {1.0, 0.95, 0.95},
        gray        = {0.60, 0.50, 0.50},
        dim         = {0.35, 0.28, 0.28},
        blue        = {0.300, 0.550, 1.000},
        green       = {0.250, 0.850, 0.350},
        red         = {1.000, 0.220, 0.220},
        yellow      = {1.000, 0.750, 0.180},
        orange      = {1.000, 0.420, 0.100},
        cyan        = {0.200, 0.750, 0.850},
        purple      = {0.650, 0.350, 0.950},
        btn_green   = {0.250, 0.700, 0.300},
        btn_cancel  = {0.250, 0.120, 0.120},
        border      = {0.280, 0.100, 0.100},
        row_a       = {0.140, 0.060, 0.060},
        row_b       = {0.120, 0.050, 0.050},
        row_red     = {0.320, 0.070, 0.070},
    },
    ["Graphite"] = {
        bg = {0.042, 0.044, 0.050},
        sidebar_bg = {0.050, 0.052, 0.058},
        sidebar_sel = {0.720, 0.720, 0.780},
        header_bg = {0.060, 0.062, 0.068},
        card = {0.085, 0.088, 0.098},
        card2 = {0.075, 0.078, 0.086},
        input_bg = {0.110, 0.114, 0.124},
        white = {0.97, 0.97, 0.99},
        gray = {0.72, 0.74, 0.79},
        dim = {0.46, 0.48, 0.52},
        blue = {0.45, 0.68, 1.00},
        green = {0.36, 0.82, 0.56},
        red = {1.00, 0.38, 0.44},
        yellow = {1.00, 0.84, 0.34},
        orange = {1.00, 0.62, 0.22},
        cyan = {0.32, 0.92, 1.00},
        purple = {0.80, 0.56, 1.00},
        btn_green = {0.20, 0.64, 0.40},
        btn_cancel = {0.180, 0.180, 0.220},
        border = {0.240, 0.240, 0.280},
        row_a = {0.096, 0.098, 0.108},
        row_b = {0.086, 0.088, 0.098},
        row_red = {0.230, 0.090, 0.120},
    },

    -- ==========================================
    -- NUEVOS TEMAS CLAROS (LIGHT THEMES)
    -- ==========================================

    ["Nordic Snow"] = {
        bg          = {0.960, 0.970, 0.980},
        sidebar_bg  = {0.910, 0.930, 0.950},
        sidebar_sel = {0.350, 0.550, 0.700},
        header_bg   = {0.930, 0.950, 0.970},
        card        = {1.000, 1.000, 1.000},
        card2       = {0.975, 0.980, 0.990},
        input_bg    = {0.880, 0.900, 0.930},
        white       = {0.180, 0.220, 0.260}, -- Texto principal oscuro
        gray        = {0.450, 0.500, 0.560},
        dim         = {0.600, 0.650, 0.700},
        blue        = {0.250, 0.500, 0.750},
        green       = {0.200, 0.650, 0.400},
        red         = {0.800, 0.300, 0.300},
        yellow      = {0.850, 0.650, 0.100},
        orange      = {0.900, 0.480, 0.150},
        cyan        = {0.150, 0.620, 0.700},
        purple      = {0.520, 0.350, 0.700},
        btn_green   = {0.220, 0.600, 0.380},
        btn_cancel  = {0.820, 0.840, 0.880},
        border      = {0.840, 0.860, 0.900},
        row_a       = {0.980, 0.985, 0.990},
        row_b       = {0.950, 0.960, 0.970},
        row_red     = {1.000, 0.880, 0.880},
    },
    ["Sepia Vintage"] = {
        bg          = {0.950, 0.910, 0.840},
        sidebar_bg  = {0.890, 0.840, 0.760},
        sidebar_sel = {0.620, 0.400, 0.200},
        header_bg   = {0.910, 0.860, 0.790},
        card        = {0.980, 0.960, 0.910},
        card2       = {0.960, 0.930, 0.870},
        input_bg    = {0.850, 0.800, 0.710},
        white       = {0.230, 0.180, 0.120},
        gray        = {0.520, 0.460, 0.380},
        dim         = {0.680, 0.620, 0.540},
        blue        = {0.180, 0.480, 0.680},
        green       = {0.320, 0.580, 0.320},
        red         = {0.750, 0.280, 0.240},
        yellow      = {0.780, 0.580, 0.100},
        orange      = {0.820, 0.420, 0.120},
        cyan        = {0.200, 0.560, 0.580},
        purple      = {0.540, 0.320, 0.580},
        btn_green   = {0.320, 0.550, 0.320},
        btn_cancel  = {0.800, 0.750, 0.660},
        border      = {0.810, 0.750, 0.650},
        row_a       = {0.970, 0.940, 0.890},
        row_b       = {0.930, 0.890, 0.820},
        row_red     = {0.960, 0.840, 0.820},
    },
    ["Sakura Pastel"] = {
        bg          = {0.990, 0.950, 0.960},
        sidebar_bg  = {0.960, 0.880, 0.900},
        sidebar_sel = {0.880, 0.440, 0.560},
        header_bg   = {0.970, 0.910, 0.930},
        card        = {1.000, 1.000, 1.000},
        card2       = {0.985, 0.965, 0.970},
        input_bg    = {0.930, 0.830, 0.860},
        white       = {0.280, 0.180, 0.200},
        gray        = {0.580, 0.460, 0.490},
        dim         = {0.740, 0.640, 0.660},
        blue        = {0.300, 0.520, 0.780},
        green       = {0.250, 0.620, 0.450},
        red         = {0.850, 0.350, 0.450},
        yellow      = {0.820, 0.640, 0.200},
        orange      = {0.880, 0.500, 0.300},
        cyan        = {0.200, 0.620, 0.680},
        purple      = {0.680, 0.420, 0.720},
        btn_green   = {0.280, 0.580, 0.420},
        btn_cancel  = {0.900, 0.800, 0.830},
        border      = {0.920, 0.820, 0.850},
        row_a       = {0.995, 0.975, 0.980},
        row_b       = {0.975, 0.935, 0.945},
        row_red     = {1.000, 0.880, 0.900},
    },
    ["Ocean Light"] = {
        bg          = {0.920, 0.960, 0.970},
        sidebar_bg  = {0.840, 0.900, 0.930},
        sidebar_sel = {0.120, 0.500, 0.650},
        header_bg   = {0.880, 0.930, 0.950},
        card        = {0.980, 1.000, 1.000},
        card2       = {0.950, 0.975, 0.985},
        input_bg    = {0.780, 0.860, 0.900},
        white       = {0.100, 0.200, 0.250},
        gray        = {0.420, 0.520, 0.580},
        dim         = {0.620, 0.700, 0.750},
        blue        = {0.100, 0.480, 0.780},
        green       = {0.150, 0.600, 0.420},
        red         = {0.820, 0.320, 0.320},
        yellow      = {0.800, 0.620, 0.150},
        orange      = {0.850, 0.460, 0.180},
        cyan        = {0.050, 0.580, 0.650},
        purple      = {0.500, 0.380, 0.720},
        btn_green   = {0.150, 0.580, 0.400},
        btn_cancel  = {0.780, 0.850, 0.880},
        border      = {0.760, 0.850, 0.890},
        row_a       = {0.960, 0.980, 0.990},
        row_b       = {0.930, 0.960, 0.975},
        row_red     = {0.980, 0.860, 0.860},
    },
    ["Mint Fresh"] = {
        bg          = {0.940, 0.970, 0.950},
        sidebar_bg  = {0.860, 0.920, 0.890},
        sidebar_sel = {0.180, 0.580, 0.400},
        header_bg   = {0.900, 0.950, 0.920},
        card        = {0.980, 1.000, 0.990},
        card2       = {0.950, 0.980, 0.965},
        input_bg    = {0.800, 0.880, 0.840},
        white       = {0.120, 0.220, 0.180},
        gray        = {0.420, 0.540, 0.480},
        dim         = {0.640, 0.720, 0.680},
        blue        = {0.200, 0.500, 0.750},
        green       = {0.120, 0.620, 0.380},
        red         = {0.800, 0.300, 0.350},
        yellow      = {0.780, 0.600, 0.100},
        orange      = {0.850, 0.480, 0.150},
        cyan        = {0.100, 0.600, 0.600},
        purple      = {0.550, 0.380, 0.680},
        btn_green   = {0.150, 0.580, 0.350},
        btn_cancel  = {0.800, 0.860, 0.830},
        border      = {0.780, 0.860, 0.820},
        row_a       = {0.960, 0.985, 0.970},
        row_b       = {0.930, 0.965, 0.945},
        row_red     = {0.990, 0.860, 0.860},
    },

    -- ==========================================
    -- NUEVOS TEMAS NORMALES / OSCUROS (DARK THEMES)
    -- ==========================================

    ["Midnight Purple"] = {
        bg          = {0.020, 0.015, 0.035},
        sidebar_bg  = {0.035, 0.025, 0.055},
        sidebar_sel = {0.750, 0.250, 0.950},
        header_bg   = {0.045, 0.030, 0.070},
        card        = {0.070, 0.050, 0.105},
        card2       = {0.055, 0.040, 0.085},
        input_bg    = {0.095, 0.070, 0.145},
        white       = {0.960, 0.940, 0.980},
        gray        = {0.640, 0.580, 0.720},
        dim         = {0.400, 0.350, 0.480},
        blue        = {0.350, 0.650, 1.000},
        green       = {0.300, 0.850, 0.550},
        red         = {1.000, 0.320, 0.450},
        yellow      = {1.000, 0.850, 0.300},
        orange      = {1.000, 0.550, 0.200},
        cyan        = {0.250, 0.920, 1.000},
        purple      = {0.800, 0.450, 1.000},
        btn_green   = {0.220, 0.720, 0.450},
        btn_cancel  = {0.160, 0.120, 0.220},
        border      = {0.180, 0.130, 0.260},
        row_a       = {0.075, 0.055, 0.115},
        row_b       = {0.065, 0.045, 0.100},
        row_red     = {0.250, 0.080, 0.140},
    },
    ["Deep Ocean Deep"] = {
        bg          = {0.010, 0.025, 0.040},
        sidebar_bg  = {0.020, 0.038, 0.058},
        sidebar_sel = {0.000, 0.700, 0.900},
        header_bg   = {0.025, 0.045, 0.070},
        card        = {0.040, 0.068, 0.100},
        card2       = {0.030, 0.055, 0.082},
        input_bg    = {0.055, 0.090, 0.130},
        white       = {0.920, 0.960, 0.980},
        gray        = {0.580, 0.680, 0.780},
        dim         = {0.350, 0.440, 0.540},
        blue        = {0.200, 0.700, 1.000},
        green       = {0.200, 0.850, 0.500},
        red         = {1.000, 0.350, 0.400},
        yellow      = {0.950, 0.800, 0.200},
        orange      = {1.000, 0.580, 0.150},
        cyan        = {0.150, 0.900, 0.950},
        purple      = {0.700, 0.500, 1.000},
        btn_green   = {0.150, 0.700, 0.400},
        btn_cancel  = {0.100, 0.160, 0.220},
        border      = {0.120, 0.200, 0.300},
        row_a       = {0.045, 0.075, 0.110},
        row_b       = {0.035, 0.062, 0.095},
        row_red     = {0.200, 0.080, 0.100},
    },
}

local DEFAULT_SETTINGS = {
    theme = "Neo Night",
    plan_prices = {Diario = 5, Semanal = 25, Quincenal = 45, Mensual = 80},
    notif_color = "blue",
    notif_limit = 25,
}

-- ============= UTILIDADES =============
local function setColor(c, a) 
    love.graphics.setColor(c[1], c[2], c[3], a or 1)
end

local function clamp(v, lo, hi) 
    return math.max(lo, math.min(hi, v))
end

local function rr(x, y, w, h, r, c, a)
    if c then setColor(c, a) end
    love.graphics.rectangle("fill", x, y, w, h, r or 6, r or 6)
end

local function rrLine(x, y, w, h, r, c, a)
    if c then setColor(c, a) end
    love.graphics.rectangle("line", x, y, w, h, r or 6, r or 6)
end

local function hover(x, y, w, h)
    local mx, my = love.mouse.getPosition()
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

local function dateStr(d)
    return string.format("%02d/%02d/%04d", d.day, d.month, d.year)
end


local function utf8_len_safe(s)
    s = s or ""
    local n = utf8.len(s)
    return n or #s
end

local function utf8_byte_at_char(s, char_index)
    s = s or ""
    local n = utf8_len_safe(s)
    char_index = clamp(math.floor(char_index or 1), 1, n + 1)
    if char_index == n + 1 then
        return #s + 1
    end
    return utf8.offset(s, char_index) or (#s + 1)
end

local function utf8_slice_chars(s, start_char, end_char)
    s = s or ""
    local n = utf8_len_safe(s)
    if n == 0 then return "" end
    start_char = clamp(math.floor(start_char or 1), 1, n + 1)
    end_char = clamp(math.floor(end_char or n), 0, n)
    if end_char < start_char then return "" end
    local a = utf8_byte_at_char(s, start_char)
    local b = utf8_byte_at_char(s, end_char + 1) - 1
    if b < a then return "" end
    return s:sub(a, b)
end

local function editorState(key)
    G.editor = G.editor or {}
    local st = G.editor[key]
    if not st then
        st = {cursor = 1, anchor = 1, view_start = 1}
        G.editor[key] = st
    end
    return st
end

local function editorCursorSelection(key)
    local st = editorState(key)
    if st.cursor < st.anchor then
        return st.cursor, st.anchor
    end
    return st.anchor, st.cursor
end

local function editorClearSelection(key)
    local st = editorState(key)
    st.anchor = st.cursor
end

local function editorDeleteSelection(key)
    local st = editorState(key)
    local value = G.text_inputs[key] or ""
    local a, b = editorCursorSelection(key)
    if a == b then
        return value, false
    end

    local bs = utf8_byte_at_char(value, a)
    local be = utf8_byte_at_char(value, b) - 1
    local new_value = value:sub(1, bs - 1) .. value:sub(be + 1)
    st.cursor = a
    st.anchor = a
    st.view_start = math.min(st.view_start or 1, st.cursor)
    return new_value, true
end

local function editorInsertText(key, t)
    if not t or t == "" then return end
    local st = editorState(key)
    local value = G.text_inputs[key] or ""
    value = (select(1, editorDeleteSelection(key)))
    local insert_at = utf8_byte_at_char(value, st.cursor)
    value = value:sub(1, insert_at - 1) .. t .. value:sub(insert_at)
    G.text_inputs[key] = value
    st.cursor = st.cursor + utf8_len_safe(t)
    st.anchor = st.cursor
end

local function editorDeleteBackspace(key)
    local st = editorState(key)
    local value = G.text_inputs[key] or ""
    local a, b = editorCursorSelection(key)
    if a ~= b then
        G.text_inputs[key] = select(1, editorDeleteSelection(key))
        return
    end
    if st.cursor <= 1 then return end
    local b1 = utf8_byte_at_char(value, st.cursor - 1)
    local b2 = utf8_byte_at_char(value, st.cursor) - 1
    G.text_inputs[key] = value:sub(1, b1 - 1) .. value:sub(b2 + 1)
    st.cursor = st.cursor - 1
    st.anchor = st.cursor
end

local function editorDeleteForward(key)
    local st = editorState(key)
    local value = G.text_inputs[key] or ""
    local a, b = editorCursorSelection(key)
    if a ~= b then
        G.text_inputs[key] = select(1, editorDeleteSelection(key))
        return
    end
    local len = utf8_len_safe(value)
    if st.cursor > len then return end
    local b1 = utf8_byte_at_char(value, st.cursor)
    local b2 = utf8_byte_at_char(value, st.cursor + 1) - 1
    G.text_inputs[key] = value:sub(1, b1 - 1) .. value:sub(b2 + 1)
end

local function editorMoveCursor(key, delta, extend)
    local st = editorState(key)
    local value = G.text_inputs[key] or ""
    local len = utf8_len_safe(value)
    st.cursor = clamp(st.cursor + delta, 1, len + 1)
    if not extend then
        st.anchor = st.cursor
    end
end

local function editorSelectAll(key)
    local st = editorState(key)
    local len = utf8_len_safe(G.text_inputs[key] or "")
    st.anchor = 1
    st.cursor = len + 1
end

local function editorCopySelection(key, cut)
    local st = editorState(key)
    local value = G.text_inputs[key] or ""
    local a, b = editorCursorSelection(key)
    if a == b then return false end
    local clip = utf8_slice_chars(value, a, b - 1)
    if love.system and love.system.setClipboardText then
        love.system.setClipboardText(clip or "")
    end
    if cut then
        G.text_inputs[key] = select(1, editorDeleteSelection(key))
    end
    return true
end

local function editorPaste(key)
    if not (love.system and love.system.getClipboardText) then return end
    local clip = love.system.getClipboardText() or ""
    if clip ~= "" then
        editorInsertText(key, clip)
    end
end

local function editorIndexFromX(font, value, start_char, local_x)
    value = value or ""
    local len = utf8_len_safe(value)
    if len == 0 then return 1 end
    start_char = clamp(start_char or 1, 1, len + 1)
    local x = 0
    local prev = start_char
    for i = start_char, len do
        local ch = utf8_slice_chars(value, i, i)
        local w = font:getWidth(ch)
        if local_x < x + (w / 2) then
            return i
        end
        x = x + w
        prev = i + 1
    end
    return len + 1
end

local function editorEnsureVisible(key, font, w)
    local st = editorState(key)
    local value = G.text_inputs[key] or ""
    local len = utf8_len_safe(value)
    local avail = math.max(1, w - 18)
    local start = clamp(st.view_start or 1, 1, len + 1)

    if st.cursor < start then
        start = st.cursor
    end

    while start < st.cursor do
        local slice = utf8_slice_chars(value, start, st.cursor - 1)
        if font:getWidth(slice) <= avail then
            break
        end
        start = start + 1
    end

    st.view_start = clamp(start, 1, len + 1)
end

local function focusTextInputAt(key, x, y, w, h, mx, my)
    local st = editorState(key)
    local value = G.text_inputs[key] or ""
    local font = G.fonts.normal or love.graphics.getFont()
    local pad = 9
    local avail = math.max(1, w - 18)
    local start = clamp(st.view_start or 1, 1, utf8_len_safe(value) + 1)
    local rel_x = clamp((mx or x) - (x + pad), 0, avail)
    local cursor = editorIndexFromX(font, value, start, rel_x)
    st.cursor = cursor
    st.anchor = cursor
    st.view_start = start
    G.focus = key
    G.dropdown = nil
end

local function textInputFocused()
    return G.focus and G.text_inputs and (G.text_inputs[G.focus] ~= nil)
end

local function editorHandleShortcut(key, ctrl, shift)
    if not G.focus or G.text_inputs[G.focus] == nil then return false end

    if ctrl and key == "a" then
        editorSelectAll(G.focus)
        return true
    elseif ctrl and key == "c" then
        editorCopySelection(G.focus, false)
        return true
    elseif ctrl and key == "x" then
        editorCopySelection(G.focus, true)
        return true
    elseif ctrl and key == "v" then
        editorPaste(G.focus)
        return true
    elseif key == "backspace" then
        editorDeleteBackspace(G.focus)
        return true
    elseif key == "delete" then
        editorDeleteForward(G.focus)
        return true
    elseif key == "left" then
        editorMoveCursor(G.focus, -1, shift)
        return true
    elseif key == "right" then
        editorMoveCursor(G.focus, 1, shift)
        return true
    elseif key == "home" then
        local st = editorState(G.focus)
        st.cursor = 1
        if not shift then st.anchor = st.cursor end
        return true
    elseif key == "end" then
        local st = editorState(G.focus)
        local len = utf8_len_safe(G.text_inputs[G.focus] or "")
        st.cursor = len + 1
        if not shift then st.anchor = st.cursor end
        return true
    end

    return false
end

local function daysInMonth(year, month)
    local next_month = month + 1
    local next_year = year
    if next_month > 12 then
        next_month = 1
        next_year = year + 1
    end
    local first_next = os.time({year = next_year, month = next_month, day = 1, hour = 12, min = 0, sec = 0})
    local last_day = os.date("*t", first_next - 86400)
    return last_day.day
end

local function weekdayMondayFirst(ts)
    local d = os.date("*t", ts)
    return ((d.wday + 5) % 7) + 1
end

local function getClientById(id)
    for _, c in ipairs(G.clients) do
        if c.id == id then
            return c
        end
    end
end

local function bmiClass(bmi)
    if bmi < 18.5 then
        return "Bajo peso"
    elseif bmi < 25 then
        return "Peso normal"
    elseif bmi < 30 then
        return "Sobrepeso"
    elseif bmi < 35 then
        return "Obesidad grado I"
    elseif bmi < 40 then
        return "Obesidad grado II"
    else
        return "Obesidad grado III"
    end
end

local function parseDatePartsFromTs(ts)
    local d = os.date("*t", ts or os.time())
    return d.year, d.month, d.day
end

local function tsFromDateParts(year, month, day)
    return os.time({year = year, month = month, day = day, hour = 0, min = 0, sec = 0})
end

local function openRenewModal(client)
    if not client then return end
    G.renew_modal = {
        client_id = client.id,
        plan = client.plan or "Mensual",
        special_days = math.max(1, math.floor(tonumber(client.plan_dias) or 1)),
        special_price = tonumber(client.plan_precio_dia) or 0,
    }
    G.text_inputs.renew_special_days = tostring(math.max(1, math.floor(tonumber(client.plan_dias) or 1)))
    G.text_inputs.renew_special_price = tostring(tonumber(client.plan_precio_dia) or 0)
    editorState("renew_special_days").cursor = utf8_len_safe(G.text_inputs.renew_special_days) + 1
    editorState("renew_special_days").anchor = editorState("renew_special_days").cursor
    editorState("renew_special_price").cursor = utf8_len_safe(G.text_inputs.renew_special_price) + 1
    editorState("renew_special_price").anchor = editorState("renew_special_price").cursor
    G.focus = nil
    G.dropdown = nil
end

local function openEditClientModal(client)
    if not client then return end
    local y, m, d = parseDatePartsFromTs(client.start_ts or os.time())
    G.edit_client_modal = {
        client_id = client.id,
        cal_year = y,
        cal_month = m,
        selected_day = d,
    }
    G.text_inputs.edit_phone = tostring(client.telefono or "")
    G.text_inputs.edit_weight = tostring(client.peso or "")
    G.text_inputs.edit_health = tostring(client.estado_salud or "")
    G.edit_plan = client.plan or "Mensual"
    G.text_inputs.edit_plan_special_days = tostring(math.max(1, math.floor(tonumber(client.plan_dias) or 1)))
    G.text_inputs.edit_plan_special_price = tostring(tonumber(client.plan_precio_dia) or 0)
    G.focus = nil
    G.dropdown = nil
    editorState("edit_phone").cursor = utf8_len_safe(G.text_inputs.edit_phone) + 1
    editorState("edit_phone").anchor = editorState("edit_phone").cursor
    editorState("edit_weight").cursor = utf8_len_safe(G.text_inputs.edit_weight) + 1
    editorState("edit_weight").anchor = editorState("edit_weight").cursor
    editorState("edit_health").cursor = utf8_len_safe(G.text_inputs.edit_health) + 1
    editorState("edit_health").anchor = editorState("edit_health").cursor
    editorState("edit_plan_special_days").cursor = utf8_len_safe(G.text_inputs.edit_plan_special_days) + 1
    editorState("edit_plan_special_days").anchor = editorState("edit_plan_special_days").cursor
    editorState("edit_plan_special_price").cursor = utf8_len_safe(G.text_inputs.edit_plan_special_price) + 1
    editorState("edit_plan_special_price").anchor = editorState("edit_plan_special_price").cursor
end

local function openBmiModal()
    G.show_bmi_calc = true
    if G.text_inputs.bmi_weight == "" then
        G.text_inputs.bmi_weight = tostring(G.text_inputs.peso or "")
    end
    if G.text_inputs.bmi_height == "" then
        G.text_inputs.bmi_height = ""
    end
    editorState("bmi_weight").cursor = utf8_len_safe(G.text_inputs.bmi_weight) + 1
    editorState("bmi_weight").anchor = editorState("bmi_weight").cursor
    editorState("bmi_height").cursor = utf8_len_safe(G.text_inputs.bmi_height) + 1
    editorState("bmi_height").anchor = editorState("bmi_height").cursor
end

local function today0()
    local d = os.date("*t")
    return os.time({year = d.year, month = d.month, day = d.day, hour = 0, min = 0, sec = 0})
end

local function subscriptionExpiry(plan, start_ts, special_days)
    plan = tostring(plan or "Mensual")
    start_ts = tonumber(start_ts) or os.time()
    if plan == "Diario" then
        local d = os.date("*t", start_ts)
        return os.time({year = d.year, month = d.month, day = d.day, hour = 23, min = 59, sec = 59})
    elseif plan == "Semanal" then
        return start_ts + 7 * 86400 - 1
    elseif plan == "Quincenal" then
        return start_ts + 15 * 86400 - 1
    elseif plan == SPECIAL_PLAN then
        local days = math.max(1, math.floor(tonumber(special_days) or 1))
        return start_ts + days * 86400 - 1
    else -- Mensual
        local d = os.date("*t", start_ts)
        local nm = d.month + 1
        local ny = d.year
        if nm > 12 then
            nm = 1
            ny = ny + 1
        end
        return os.time({year = ny, month = nm, day = d.day, hour = 23, min = 59, sec = 59})
    end
end

local function planDurationLabel(plan, special_days)
    plan = tostring(plan or "Mensual")
    if plan == "Diario" then
        return "1 día"
    elseif plan == "Semanal" then
        return "7 días"
    elseif plan == "Quincenal" then
        return "15 días"
    elseif plan == SPECIAL_PLAN then
        local days = math.max(1, math.floor(tonumber(special_days) or 1))
        return tostring(days) .. " días"
    end
    return "1 mes"
end

local function planAmount(plan, special_days, special_daily_price)
    plan = tostring(plan or "Mensual")
    if plan == "Diario" then
        return tonumber(PLAN_PRICES.Diario) or 0
    elseif plan == "Semanal" then
        return tonumber(PLAN_PRICES.Semanal) or 0
    elseif plan == "Quincenal" then
        return tonumber(PLAN_PRICES.Quincenal) or 0
    elseif plan == SPECIAL_PLAN then
        local days = math.max(1, math.floor(tonumber(special_days) or 1))
        local per_day = tonumber(special_daily_price) or 0
        return days * per_day
    end
    return tonumber(PLAN_PRICES.Mensual) or 0
end

local function clientPlanDays(client)
    if not client then return 0 end
    return math.max(0, math.floor(tonumber(client.plan_dias) or 0))
end

local function clientPlanDailyPrice(client)
    if not client then return 0 end
    return tonumber(client.plan_precio_dia) or 0
end

local function isActive(c)
    if not c or not c.expiry then return false end
    return os.time() <= c.expiry
end

local function addNotif(msg)
    local color = (G.settings and G.settings.notif_color) or "blue"
    table.insert(G.notifs, 1, {msg = msg, ts = os.time(), color = color})
    local limit = tonumber(G.settings and G.settings.notif_limit) or 25
    limit = math.max(1, math.floor(limit))
    while #G.notifs > limit do
        table.remove(G.notifs)
    end
end

-- ============= CSV / PERSISTENCIA =============
local function escCSV(s)
    s = tostring(s or "")
    if s:find('[,"\n\r]') then 
        s = '"' .. s:gsub('"', '""') .. '"' 
    end
    return s
end

local function parseCSV(line)
    local r, i = {}, 1
    while i <= #line do
        if line:sub(i, i) == '"' then
            local j, f = i + 1, ""
            while j <= #line do
                if line:sub(j, j) == '"' then
                    if line:sub(j + 1, j + 1) == '"' then 
                        f = f .. '"'
                        j = j + 2
                    else 
                        j = j + 1
                        break 
                    end
                else 
                    f = f .. line:sub(j, j)
                    j = j + 1 
                end
            end
            table.insert(r, f)
            i = j
            if line:sub(i, i) == ',' then 
                i = i + 1 
            end
        else
            local j = line:find(',', i) or (#line + 1)
            table.insert(r, line:sub(i, j - 1))
            i = j + 1
        end
    end
    return r
end

local function ensureDir(d) 
    love.filesystem.createDirectory(d) 
end

local function copyTable(t)
    local r = {}
    for k, v in pairs(t or {}) do
        if type(v) == "table" then
            local sub = {}
            for k2, v2 in pairs(v) do sub[k2] = v2 end
            r[k] = sub
        else
            r[k] = v
        end
    end
    return r
end

local function csvBool(v)
    return v and "1" or "0"
end

local function parseBool(v)
    v = tostring(v or ""):lower()
    return v == "1" or v == "true" or v == "yes" or v == "si"
end

local function applyTheme(themeName)
    local preset = THEME_PRESETS[themeName] or THEME_PRESETS[DEFAULT_SETTINGS.theme]
    G.settings = G.settings or {}
    G.settings.theme = THEME_PRESETS[themeName] and themeName or DEFAULT_SETTINGS.theme
    for k, v in pairs(preset) do
        if type(v) == "table" then
            C[k] = {v[1], v[2], v[3]}
        else
            C[k] = v
        end
    end
    NOTE_COLORS.blue = C.blue
    NOTE_COLORS.green = C.green
    NOTE_COLORS.yellow = C.yellow
    NOTE_COLORS.red = C.red
    NOTE_COLORS.cyan = C.cyan
    NOTE_COLORS.purple = C.purple
end

local function syncPlanPrices()
    G.settings = G.settings or {}
    G.settings.plan_prices = G.settings.plan_prices or copyTable(DEFAULT_SETTINGS.plan_prices)
    for k, v in pairs(DEFAULT_SETTINGS.plan_prices) do
        PLAN_PRICES[k] = tonumber(G.settings.plan_prices[k]) or v
    end
end

local function saveSettings()
    ensureDir("data")
    G.settings = G.settings or copyTable(DEFAULT_SETTINGS)
    local lines = {"key,value"}
    table.insert(lines, "theme," .. escCSV(G.settings.theme or DEFAULT_SETTINGS.theme))
    table.insert(lines, "notif_color," .. escCSV(G.settings.notif_color or DEFAULT_SETTINGS.notif_color))
    table.insert(lines, "notif_limit," .. escCSV(tostring(G.settings.notif_limit or DEFAULT_SETTINGS.notif_limit)))
    for _, p in ipairs(PLAN_OPTIONS) do
        table.insert(lines, "price_" .. p .. "," .. escCSV(tostring((G.settings.plan_prices or {})[p] or DEFAULT_SETTINGS.plan_prices[p])))
    end
    love.filesystem.write("data/settings.csv", table.concat(lines, "\n"))
end

local function loadSettings()
    G.settings = copyTable(DEFAULT_SETTINGS)
    local txt = love.filesystem.read("data/settings.csv")
    if txt then
        for line in txt:gmatch("[^\n]+") do
            if not line:match("^key,") and line ~= "" then
                local f = parseCSV(line)
                local k, v = f[1], f[2]
                if k == "theme" and v ~= "" then
                    G.settings.theme = v
                elseif k == "notif_color" and v ~= "" then
                    G.settings.notif_color = v
                elseif k == "notif_limit" then
                    G.settings.notif_limit = tonumber(v) or G.settings.notif_limit
                elseif k == "price_Diario" then
                    G.settings.plan_prices.Diario = tonumber(v) or G.settings.plan_prices.Diario
                elseif k == "price_Semanal" then
                    G.settings.plan_prices.Semanal = tonumber(v) or G.settings.plan_prices.Semanal
                elseif k == "price_Quincenal" then
                    G.settings.plan_prices.Quincenal = tonumber(v) or G.settings.plan_prices.Quincenal
                elseif k == "price_Mensual" then
                    G.settings.plan_prices.Mensual = tonumber(v) or G.settings.plan_prices.Mensual
                end
            end
        end
    end
    applyTheme(G.settings.theme)
    syncPlanPrices()
end


local function saveClients()
    ensureDir("data")
    local lines = {"id,nombres,apellidos,telefono,plan,start_ts,expiry,tipo_pago,estado_salud,peso,req_medico,req_contrato,req_terminos,plan_dias,plan_precio_dia"}

    for _, c in ipairs(G.clients) do
        table.insert(lines, table.concat({
            escCSV(c.id), escCSV(c.nombres), escCSV(c.apellidos),
            escCSV(c.telefono), escCSV(c.plan),
            escCSV(c.start_ts), escCSV(c.expiry),
            escCSV(c.tipo_pago), escCSV(c.estado_salud), escCSV(c.peso),
            escCSV(csvBool(c.req_medico)), escCSV(csvBool(c.req_contrato)), escCSV(csvBool(c.req_terminos)),
            escCSV(c.plan_dias or 0), escCSV(c.plan_precio_dia or 0)
        }, ","))
    end

    love.filesystem.write("data/clientes.csv", table.concat(lines, "\n"))
end

local function loadClients()
    local txt = love.filesystem.read("data/clientes.csv")
    if not txt then return end

    local ls = {}
    for l in txt:gmatch("[^\n]+") do
        table.insert(ls, l)
    end

    G.clients = {}
    for i = 2, #ls do
        local f = parseCSV(ls[i])
        if #f >= 10 then
            local c = {
                id = tonumber(f[1]) or i - 1,
                nombres = f[2],
                apellidos = f[3],
                telefono = f[4],
                plan = f[5],
                start_ts = tonumber(f[6]) or os.time(),
                expiry = tonumber(f[7]) or os.time(),
                tipo_pago = f[8],
                estado_salud = f[9],
                peso = f[10],
                req_medico = parseBool(f[11]),
                req_contrato = parseBool(f[12]),
                req_terminos = parseBool(f[13]),
                plan_dias = tonumber(f[14]) or 0,
                plan_precio_dia = tonumber(f[15]) or 0,
            }
            table.insert(G.clients, c)
            if c.id >= G.next_id then
                G.next_id = c.id + 1
            end
        end
    end
end

local function monthFolder()
    local d = os.date("*t")
    return string.format("%04d-%02d", d.year, d.month)
end


local function saveTx(amount, plan, client_name, kind)
    local folder = "transacciones/" .. monthFolder()
    ensureDir("transacciones")
    ensureDir(folder)

    local path = folder .. "/tx.csv"
    local existing = love.filesystem.read(path)
    local lines = {"ts,fecha,hora,monto,plan,cliente,tipo"}

    if existing and existing ~= "" then
        for i, line in ipairs((function()
            local t = {}
            for l in existing:gmatch("[^\n]+") do
                table.insert(t, l)
            end
            return t
        end)()) do
            if i == 1 and (line:match("^ts,fecha,hora,monto,plan,cliente") or line:match("^ts,fecha,hora,monto,plan,cliente,tipo")) then
                -- skip legacy header
            elseif line ~= "" then
                table.insert(lines, line)
            end
        end
    end

    local ts = os.time()
    local d = os.date("*t", ts)
    table.insert(lines, string.format(
        "%d,%s,%02d:%02d,%s,%s,%s,%s",
        ts, dateStr(d), d.hour, d.min, escCSV(tostring(amount)), escCSV(plan), escCSV(client_name), escCSV(kind or "registro")
    ))

    love.filesystem.write(path, table.concat(lines, "\n"))

    table.insert(G.transactions, {
        ts = ts,
        monto = amount,
        plan = plan,
        cliente = client_name,
        tipo = kind or "registro",
        hora = string.format("%02d:%02d", d.hour, d.min)
    })
end

local function loadTx()
    G.transactions = {}
    for offset = 0, 11 do
        local d = os.date("*t")
        local m = d.month - offset
        local y = d.year

        while m <= 0 do
            m = m + 12
            y = y - 1
        end

        local folder = string.format("%04d-%02d", y, m)
        local txt = love.filesystem.read("transacciones/" .. folder .. "/tx.csv")

        if txt then
            local ls = {}
            for l in txt:gmatch("[^\n]+") do
                table.insert(ls, l)
            end

            for i = 2, #ls do
                local row = ls[i]
                if not row:match("^ts,") then
                    local f = parseCSV(row)
                    if #f >= 6 then
                        table.insert(G.transactions, {
                            ts = tonumber(f[1]) or 0,
                            monto = tonumber(f[4]) or 0,
                            plan = f[5],
                            cliente = f[6],
                            tipo = f[7] or "registro",
                            hora = f[3]
                        })
                    end
                end
            end
        end
    end
    table.sort(G.transactions, function(a, b) return a.ts < b.ts end)
end


local function encodeAmounts(amounts)
    local parts = {}
    for _, v in ipairs(amounts or {}) do
        table.insert(parts, tostring(tonumber(v) or 0))
    end
    return table.concat(parts, "|")
end

local function parseAmounts(encoded)
    local amounts = {}
    encoded = tostring(encoded or "")
    for part in encoded:gmatch("[^|]+") do
        local n = tonumber(part)
        if n ~= nil then
            table.insert(amounts, n)
        end
    end
    if #amounts == 0 then
        table.insert(amounts, 0)
    end
    return amounts
end

local function normalizeAmounts(amounts)
    local out = {}
    for _, v in ipairs(amounts or {}) do
        local n = tonumber(v)
        if n ~= nil then
            table.insert(out, n)
        end
    end
    if #out == 0 then
        table.insert(out, 0)
    end
    return out
end

local function noteTotal(note)
    local total = 0
    for _, v in ipairs(normalizeAmounts(note and note.amounts)) do
        total = total + (tonumber(v) or 0)
    end
    return total
end

local function noteMoneyLabel(v)
    v = tonumber(v) or 0
    local sign = v < 0 and "-" or ""
    local abs_v = math.abs(v)
    if abs_v == math.floor(abs_v) then
        return string.format("%s$%d", sign, math.floor(abs_v))
    end
    return string.format("%s$%.2f", sign, abs_v)
end

local function ensureNoteAmounts(note)
    if not note then return end
    note.amounts = normalizeAmounts(note.amounts)
end

local function noteMovementTimestamp(note, week_offset)
    local now = os.date("*t")
    local base_ts = os.time(now)
    local wd = now.wday - 2
    if wd < 0 then wd = wd + 7 end
    local week_start = base_ts - wd * 86400 + (tonumber(week_offset) or 0) * 7 * 86400
    local day_off = clamp(tonumber(note and note.day) or 0, 0, 6)
    local hour = clamp(tonumber(note and note.hour) or 8, 0, 23)
    return week_start + day_off * 86400 + hour * 3600
end

local function noteAmountFieldPrefix(mode)
    return mode == "edit" and "edit_note_amount" or "new_note_amount"
end

local function noteAmountCount(mode)
    if mode == "edit" and G.edit_note_modal then
        return tonumber(G.edit_note_modal.amount_count) or 1
    elseif mode == "new" then
        return tonumber(G.new_note_amount_count) or 1
    end
    return 1
end

local function setNoteAmountCount(mode, count)
    count = math.max(1, math.floor(tonumber(count) or 1))
    if mode == "edit" and G.edit_note_modal then
        G.edit_note_modal.amount_count = count
    elseif mode == "new" then
        G.new_note_amount_count = count
    end
end

local function initNoteAmountInputs(mode, amounts)
    local prefix = noteAmountFieldPrefix(mode)
    amounts = normalizeAmounts(amounts)
    setNoteAmountCount(mode, #amounts)
    for i = 1, #amounts do
        local key = prefix .. "_" .. i
        G.text_inputs[key] = tostring(amounts[i] or 0)
        local st = editorState(key)
        st.cursor = utf8_len_safe(G.text_inputs[key]) + 1
        st.anchor = st.cursor
    end
end

local function collectNoteAmounts(mode)
    local prefix = noteAmountFieldPrefix(mode)
    local count = noteAmountCount(mode)
    local amounts = {}
    for i = 1, count do
        local key = prefix .. "_" .. i
        local n = tonumber(G.text_inputs[key]) or 0
        table.insert(amounts, n)
    end
    return normalizeAmounts(amounts)
end

local function openNewNoteModal(day, hour, color)
    G.show_new_note = true
    G.new_note_day = day or 0
    G.new_note_color = color or "blue"
    G.text_inputs["new_note_text"] = ""
    G.text_inputs["new_note_hour"] = tostring(hour or 8)
    initNoteAmountInputs("new", {0})
    editorState("new_note_text").cursor = 1
    editorState("new_note_text").anchor = 1
    editorState("new_note_hour").cursor = utf8_len_safe(G.text_inputs["new_note_hour"]) + 1
    editorState("new_note_hour").anchor = editorState("new_note_hour").cursor
    G.focus = nil
    G.dropdown = nil
end

local function openEditNoteModal(note, extra_row)
    if not note then return end
    ensureNoteAmounts(note)
    G.edit_note_modal = {
        note = note,
        amount_count = #note.amounts,
    }
    G.text_inputs["edit_note_text"] = note.text or ""
    G.text_inputs["edit_note_hour"] = tostring(note.hour or 8)
    G.text_inputs["edit_note_color"] = note.color or "blue"
    initNoteAmountInputs("edit", note.amounts)
    if extra_row then
        local cnt = noteAmountCount("edit")
        setNoteAmountCount("edit", cnt + 1)
        local key = "edit_note_amount_" .. (cnt + 1)
        G.text_inputs[key] = "0"
        local st = editorState(key)
        st.cursor = utf8_len_safe(G.text_inputs[key]) + 1
        st.anchor = st.cursor
    end
    editorState("edit_note_text").cursor = utf8_len_safe(G.text_inputs["edit_note_text"]) + 1
    editorState("edit_note_text").anchor = editorState("edit_note_text").cursor
    editorState("edit_note_hour").cursor = utf8_len_safe(G.text_inputs["edit_note_hour"]) + 1
    editorState("edit_note_hour").anchor = editorState("edit_note_hour").cursor
    G.focus = nil
    G.dropdown = nil
end

local function saveNotes()
    ensureDir("data")
    local lines = {"day,hour,text,color,duration,amounts"}

    for _, n in ipairs(G.notes) do
        ensureNoteAmounts(n)
        table.insert(lines, string.format("%d,%d,%s,%s,%d,%s",
            n.day, n.hour, escCSV(n.text or ""), n.color or "blue", n.duration or 1, escCSV(encodeAmounts(n.amounts))))
    end

    love.filesystem.write("data/notes.csv", table.concat(lines, "\n"))
end

local function saveNewNoteFromModal()
    local hr = clamp(tonumber(G.text_inputs["new_note_hour"]) or 8, 8, 20)
    local amounts = collectNoteAmounts("new")
    table.insert(G.notes, {
        day = G.new_note_day or 0,
        hour = hr,
        text = G.text_inputs["new_note_text"] or "",
        color = G.new_note_color or "blue",
        duration = 1,
        amounts = amounts,
    })
    saveNotes()
    G.show_new_note = false
    G.text_inputs["new_note_text"] = ""
    addNotif("📅 Nota añadida a la agenda")
end

local function saveEditNoteFromModal()
    local action = G.edit_note_modal
    if not action or not action.note then return end
    local note = action.note
    note.text = G.text_inputs["edit_note_text"] or note.text or ""
    note.hour = clamp(tonumber(G.text_inputs["edit_note_hour"]) or note.hour or 8, 8, 20)
    note.color = G.text_inputs["edit_note_color"] or note.color or "blue"
    note.amounts = collectNoteAmounts("edit")
    note.duration = note.duration or 1
    saveNotes()
    addNotif("✏ Nota actualizada")
    G.edit_note_modal = nil
end

local function requestRemoveNoteAmount(row)
    if not G.edit_note_modal then return end
    G.note_amount_confirm = {
        row = row,
        amount = tonumber(G.text_inputs["edit_note_amount_" .. tostring(row)]) or 0
    }
end

local function confirmRemoveNoteAmount()
    local action = G.note_amount_confirm
    if not action or not G.edit_note_modal then return end
    local amounts = collectNoteAmounts("edit")
    if #amounts <= 1 then
        G.text_inputs["edit_note_amount_1"] = "0"
        G.note_amount_confirm = nil
        return
    end
    table.remove(amounts, action.row)
    if #amounts == 0 then
        amounts = {0}
    end
    initNoteAmountInputs("edit", amounts)
    G.note_amount_confirm = nil
end

local function loadNotes()
    local txt = love.filesystem.read("data/notes.csv")
    if not txt then return end

    G.notes = {}
    for l in txt:gmatch("[^\n]+") do
        if not l:find("^day") then
            local f = parseCSV(l)
            if #f >= 5 then
                local note = {
                    day = tonumber(f[1]) or 0,
                    hour = tonumber(f[2]) or 8,
                    text = f[3],
                    color = f[4],
                    duration = tonumber(f[5]) or 1,
                    amounts = (#f >= 6 and parseAmounts(f[6])) or {0},
                }
                ensureNoteAmounts(note)
                table.insert(G.notes, note)
            end
        end
    end
end

-- ============= COMPONENTES UI =============
local function drawButton(x, y, w, h, label, bgColor, textColor, fnt, r, isHov)
    local bc = isHov and {bgColor[1] * 1.18, bgColor[2] * 1.18, bgColor[3] * 1.18} or bgColor
    rr(x, y, w, h, r or 5, bc)
    
    setColor(textColor or C.white)
    local f = fnt or G.fonts.normal
    love.graphics.setFont(f)
    
    local tw = f:getWidth(label)
    local th = f:getHeight()
    love.graphics.print(label, x + (w - tw) / 2, y + (h - th) / 2)
end


local function drawInput(x, y, w, h, key, ph, fnt)
    local focused = G.focus == key
    local val = G.text_inputs[key] or ""
    local hov = hover(x, y, w, h)
    local st = editorState(key)

    rr(x, y, w, h, 5, C.input_bg)
    setColor(focused and C.blue or (hov and {0.25, 0.25, 0.35} or C.border))

    love.graphics.setLineWidth(focused and 1.5 or 1)
    rrLine(x, y, w, h, 5)
    love.graphics.setLineWidth(1)

    local f = fnt or G.fonts.normal
    love.graphics.setFont(f)
    local th = f:getHeight()
    local pad = 9
    local avail = math.max(1, w - 18)

    if val == "" and not focused then
        setColor(C.dim)
        love.graphics.print(ph or "", x + pad, y + (h - th) / 2)
        return
    end

    local start_char = 1
    if focused then
        editorEnsureVisible(key, f, w)
        start_char = st.view_start or 1
    else
        st.view_start = 1
        start_char = 1
    end

    local len = utf8_len_safe(val)
    local cursor = clamp(st.cursor or 1, 1, len + 1)
    local a, b = editorCursorSelection(key)
    local text_y = y + (h - th) / 2
    local text_x = x + pad

    love.graphics.setScissor(x + 2, y + 2, w - 4, h - 4)

    if focused and a ~= b then
        local sel_start = math.max(a, start_char)
        local sel_end = math.min(b, len + 1)
        if sel_start < sel_end then
            local pre = utf8_slice_chars(val, start_char, sel_start - 1)
            local sel = utf8_slice_chars(val, sel_start, sel_end - 1)
            local sx = text_x + f:getWidth(pre)
            local sw = f:getWidth(sel)
            rr(sx - 1, y + 4, math.max(2, sw + 2), h - 8, 3, {0.18, 0.32, 0.75}, 0.45)
        end
    end

    setColor(C.white)
    local visible = utf8_slice_chars(val, start_char, len)
    love.graphics.print(visible, text_x, text_y)

    if focused then
        local pre = utf8_slice_chars(val, start_char, cursor - 1)
        local cx = text_x + f:getWidth(pre)
        local blink_on = math.floor((G.dt * 2) % 2) == 0
        if blink_on then
            setColor(C.white)
            love.graphics.rectangle("fill", cx, y + 6, 1.5, h - 12)
        end
    end

    love.graphics.setScissor()
end

local function drawDropdown(x, y, w, h, key, options)
    local sel = G.text_inputs[key] or options[1]
    local hov = hover(x, y, w, h)
    
    rr(x, y, w, h, 5, C.input_bg)
    setColor(hov and {0.25, 0.25, 0.35} or C.border)
    rrLine(x, y, w, h, 5)
    
    setColor(C.white)
    love.graphics.setFont(G.fonts.normal)
    love.graphics.print(sel, x + 9, y + (h - G.fonts.normal:getHeight()) / 2)
    
    setColor(C.dim)
    love.graphics.print("▾", x + w - 20, y + (h - G.fonts.normal:getHeight()) / 2)

    if G.dropdown == key then
        local dy = y + h + 2
        local dh = #options * 30 + 8
        
        rr(x, dy, w, dh, 5, {0.12, 0.12, 0.20})
        setColor(C.border)
        rrLine(x, dy, w, dh, 5)
        
        for i, opt in ipairs(options) do
            local oy = dy + 4 + (i - 1) * 30
            if hover(x + 2, oy, w - 4, 28) then
                rr(x + 2, oy, w - 4, 28, 4, {0.20, 0.20, 0.32})
            end
            
            setColor(sel == opt and C.blue or C.white)
            love.graphics.setFont(G.fonts.normal)
            love.graphics.print(opt, x + 10, oy + 6)
        end
    end
end


local function resetRegistrationForm()
    for _, k in ipairs({"nombres", "apellidos", "telefono", "estado_salud", "peso"}) do
        G.text_inputs[k] = ""
    end
    G.text_inputs.plan = "Mensual"
    G.text_inputs.plan_special_days = "1"
    G.text_inputs.plan_special_price = "0"
    G.text_inputs.tipo_pago = "Efectivo"
    G.req_state = {medical = false, contract = false, terms = false}
    G.focus = nil
    G.dropdown = nil
end

local function registrationReady()
    return (G.req_state and G.req_state.medical)
        and (G.req_state and G.req_state.contract)
        and (G.req_state and G.req_state.terms)
end

local function startNewRegistration()
    G.screen = "registro"
    resetRegistrationForm()
end

local function buildCloseSummary()
    local now = os.time()
    local d = os.date("*t", now)
    local day_start = os.time({year = d.year, month = d.month, day = d.day, hour = 0, min = 0, sec = 0})
    local day_end = day_start + 86399

    local summary = {
        day = dateStr(d),
        income = 0,
        entries = {},
        renewals = {},
    }

    local seen_entries = {}
    local seen_renewals = {}

    for _, t in ipairs(G.transactions) do
        if t.ts >= day_start and t.ts <= day_end then
            summary.income = summary.income + (tonumber(t.monto) or 0)
            local kind = (t.tipo or "registro"):lower()
            local item = {
                name = t.cliente or "Sin nombre",
                plan = t.plan or "—",
                amount = tonumber(t.monto) or 0,
                kind = kind,
                hour = t.hora or "--:--",
            }
            if kind == "renovacion" then
                if not seen_renewals[item.name] then
                    seen_renewals[item.name] = true
                    table.insert(summary.renewals, item)
                end
            else
                if not seen_entries[item.name] then
                    seen_entries[item.name] = true
                    table.insert(summary.entries, item)
                end
            end
        end
    end

    table.sort(summary.entries, function(a, b) return a.name < b.name end)
    table.sort(summary.renewals, function(a, b) return a.name < b.name end)

    return summary
end

local function executeCloseCash()
    local n = 0
    for _, c in ipairs(G.clients) do
        if c.plan == "Diario" and isActive(c) then
            c.expiry = os.time() - 1
            n = n + 1
        end
    end
    saveClients()
    addNotif(string.format("💰 Caja cerrada — %d membresía(s) diaria(s) vencida(s)", n))
end

local function openCloseCashSummary()
    G.close_summary = buildCloseSummary()
    G.show_close_summary = true
end

local function beginClientAction(kind, client)
    G.pending_action = {
        kind = kind,
        client_id = client.id,
        client_name = (client.nombres or "") .. " " .. (client.apellidos or ""),
        plan = client.plan or "",
        stage = 1,
    }
end

local function executePendingAction()
    local action = G.pending_action
    if not action then return end

    local idx = nil
    local client = nil
    for i, c in ipairs(G.clients) do
        if c.id == action.client_id then
            idx = i
            client = c
            break
        end
    end

    if action.kind == "renew" and client then
        local st = os.time()
        client.start_ts = st
        client.expiry = subscriptionExpiry(client.plan, st, client.plan_dias)
        saveClients()
        saveTx(planAmount(client.plan, client.plan_dias, client.plan_precio_dia), client.plan, client.nombres .. " " .. client.apellidos, "renovacion")
        addNotif(string.format("🔄 Suscripción de %s renovada (%s)", client.nombres, client.plan))
    elseif action.kind == "delete" and idx then
        local name = client.nombres or "Cliente"
        table.remove(G.clients, idx)
        saveClients()
        addNotif(string.format("🗑 Cliente %s eliminado", name))
    end

    G.pending_action = nil
end

local function actionModalRects(stage)
    if stage == 1 then
        return (W - 430) / 2, (H - 205) / 2, 430, 205
    end
    return 32, H - 230, 430, 198
end

local function drawPendingActionDialog()
    local action = G.pending_action
    if not action then return end

    local mx, my = love.mouse.getPosition()
    setColor({0, 0, 0}, 0.62)
    love.graphics.rectangle("fill", 0, 0, W, H)

    local dx, dy, dw, dh = actionModalRects(action.stage or 1)
    rr(dx, dy, dw, dh, 10, C.card)
    setColor(C.border)
    rrLine(dx, dy, dw, dh, 10)

    local title = action.kind == "renew" and "RENOVAR CLIENTE" or "ELIMINAR CLIENTE"
    setColor(action.kind == "renew" and C.green or C.red)
    love.graphics.setFont(G.fonts.large)
    love.graphics.printf("⚠  " .. title, dx, dy + 16, dw, "center")

    setColor(C.gray)
    love.graphics.setFont(G.fonts.small)
    local msg = action.stage == 1
        and string.format("Primera confirmación para %s:\n%s", action.kind == "renew" and "renovar" or "eliminar", action.client_name)
        or string.format("Última verificación. Esta acción se aplicará ahora a:\n%s", action.client_name)
    love.graphics.printf(msg, dx + 18, dy + 56, dw - 36, "center")

    local left_label = action.stage == 1 and "Cancelar" or "Volver"
    local right_label = action.stage == 1 and "Siguiente" or "Confirmar"
    local left_x, right_x = dx + 42, dx + dw - 172
    local by = dy + dh - 54
    local left_hov = hover(left_x, by, 120, 38)
    local right_hov = hover(right_x, by, 130, 38)

    drawButton(left_x, by, 120, 38, left_label, C.btn_cancel, C.white, G.fonts.normal, 6, left_hov)
    drawButton(right_x, by, 130, 38, right_label, action.stage == 1 and C.yellow or {0.65, 0.08, 0.08}, C.white, G.fonts.normal, 6, right_hov)
end

local function drawCloseSummaryDialog()
    if not G.close_summary then
        G.close_summary = buildCloseSummary()
    end

    local summary = G.close_summary
    local mx, my = love.mouse.getPosition()
    setColor({0, 0, 0}, 0.62)
    love.graphics.rectangle("fill", 0, 0, W, H)

    local dw, dh = 560, 440
    local dx, dy = (W - dw) / 2, (H - dh) / 2
    rr(dx, dy, dw, dh, 10, C.card)
    setColor(C.border)
    rrLine(dx, dy, dw, dh, 10)

    setColor(C.yellow)
    love.graphics.setFont(G.fonts.large)
    love.graphics.printf("💰 RESUMEN DE CIERRE DE CAJA", dx, dy + 14, dw, "center")

    setColor(C.gray)
    love.graphics.setFont(G.fonts.small)
    love.graphics.printf("Fecha: " .. (summary.day or dateStr(os.date("*t"))), dx, dy + 48, dw, "center")

    local cards = {
        {"Ingresos del día", string.format("$%d", math.floor(summary.income or 0))},
        {"Personas ingresadas", tostring(#(summary.entries or {}))},
        {"Personas renovadas", tostring(#(summary.renewals or {}))},
    }

    local card_y = dy + 78
    local cw = (dw - 46) / 3
    for i, cd in ipairs(cards) do
        local cx = dx + 16 + (i - 1) * (cw + 6)
        rr(cx, card_y, cw, 68, 8, C.card2)
        setColor(C.gray)
        love.graphics.setFont(G.fonts.tiny)
        love.graphics.print(cd[1], cx + 10, card_y + 10)
        setColor(C.white)
        love.graphics.setFont(G.fonts.normal)
        love.graphics.print(cd[2], cx + 10, card_y + 30)
    end

    local list_y = dy + 166
    rr(dx + 16, list_y, dw - 32, 184, 8, C.card2)
    setColor(C.white)
    love.graphics.setFont(G.fonts.normal)
    love.graphics.print("Planes de personas ingresadas hoy", dx + 26, list_y + 10)

    love.graphics.setScissor(dx + 20, list_y + 40, dw - 40, 130)
    local entries = summary.entries or {}
    if #entries == 0 then
        setColor(C.dim)
        love.graphics.setFont(G.fonts.small)
        love.graphics.print("No hubo ingresos registrados hoy.", dx + 26, list_y + 58)
    else
        for i, item in ipairs(entries) do
            local ry = list_y + 44 + (i - 1) * 26
            if ry > list_y + 160 then break end
            setColor(C.white)
            love.graphics.setFont(G.fonts.small)
            love.graphics.print(item.name, dx + 26, ry)
            local pc = item.plan == "Mensual" and C.blue or (item.plan == "Semanal" and C.cyan or C.yellow)
            rr(dx + 250, ry - 1, 84, 18, 4, pc)
            setColor(C.white)
            love.graphics.setFont(G.fonts.tiny)
            love.graphics.printf(item.plan, dx + 250, ry + 2, 84, "center")
            setColor(C.gray)
            love.graphics.print(string.format("$%d", math.floor(item.amount or 0)), dx + 350, ry)
        end
    end
    love.graphics.setScissor()

    local renew_y = dy + 352
    setColor(C.gray)
    love.graphics.setFont(G.fonts.small)
    love.graphics.print("Renovaciones del día: " .. tostring(#(summary.renewals or {})), dx + 26, renew_y)

    local cancel_hov = hover(dx + 260, dy + dh - 54, 120, 38)
    local ok_hov = hover(dx + 390, dy + dh - 54, 140, 38)
    drawButton(dx + 260, dy + dh - 54, 120, 38, "Cancelar", C.btn_cancel, C.white, G.fonts.normal, 6, cancel_hov)
    drawButton(dx + 390, dy + dh - 54, 140, 38, "✓ Cerrar caja", {0.65, 0.08, 0.08}, C.white, G.fonts.normal, 6, ok_hov)
end

-- ============= CERRAR CAJA =============
local function cerrarCaja()
    executeCloseCash()
end

-- ============= PANTALLA: INICIO =============
local function drawChart(x, y, w, h)
    rr(x, y, w, h, 8, C.card)
    setColor(C.white)
    love.graphics.setFont(G.fonts.normal)
    love.graphics.print("Historial de Movimientos", x + 14, y + 12)

    -- Mode buttons
    local modes = {"Horas", "Días", "Meses"}
    local mkeys = {"horas", "dias", "meses"}
    local bw, bh = 68, 24
    
    for i, m in ipairs(modes) do
        local bx = x + w - (4 - i) * (bw + 6) - 14
        local by = y + 9
        local active = G.chart_mode == mkeys[i]
        
        rr(bx, by, bw, bh, 4, active and C.sidebar_sel or C.card2)
        setColor(C.white)
        love.graphics.setFont(G.fonts.small)
        love.graphics.printf(m, bx, by + (bh - G.fonts.small:getHeight()) / 2, bw, "center")
    end

    -- Data preparation
    local data, labels = {}, {}
    local now = os.time()
    
    if G.chart_mode == "horas" then
        local d = os.date("*t")
        for hr = 0, 23 do
            local tot = 0
            for _, t in ipairs(G.transactions) do
                local td = os.date("*t", t.ts)
                if td.year == d.year and td.month == d.month and td.day == d.day and td.hour == hr then
                    tot = tot + (t.monto or 0)
                end
            end
            for _, note in ipairs(G.notes) do
                local nts = noteMovementTimestamp(note, 0)
                local nd = os.date("*t", nts)
                if nd.year == d.year and nd.month == d.month and nd.day == d.day and nd.hour == hr then
                    tot = tot + noteTotal(note)
                end
            end
            table.insert(data, tot)
            table.insert(labels, hr % 4 == 0 and string.format("%02d:00", hr) or "")
        end
    elseif G.chart_mode == "dias" then
        for off = 29, 0, -1 do
            local ts = now - off * 86400
            local d = os.date("*t", ts)
            local tot = 0
            for _, t in ipairs(G.transactions) do
                local td = os.date("*t", t.ts)
                if td.year == d.year and td.month == d.month and td.day == d.day then
                    tot = tot + (t.monto or 0) 
                end
            end
            for _, note in ipairs(G.notes) do
                local nts = noteMovementTimestamp(note, 0)
                local nd = os.date("*t", nts)
                if nd.year == d.year and nd.month == d.month and nd.day == d.day then
                    tot = tot + noteTotal(note)
                end
            end
            table.insert(data, tot)
            table.insert(labels, off % 5 == 0 and string.format("%d/%d", d.day, d.month) or "")
        end
    else -- meses
        local d0 = os.date("*t")
        for off = 11, 0, -1 do
            local m = d0.month - off
            local y = d0.year
            while m <= 0 do 
                m = m + 12
                y = y - 1 
            end
            
            local tot = 0
            for _, t in ipairs(G.transactions) do
                local td = os.date("*t", t.ts)
                if td.year == y and td.month == m then 
                    tot = tot + (t.monto or 0) 
                end
            end
            for _, note in ipairs(G.notes) do
                local nts = noteMovementTimestamp(note, 0)
                local nd = os.date("*t", nts)
                if nd.year == y and nd.month == m then
                    tot = tot + noteTotal(note)
                end
            end
            table.insert(data, tot)
            local mnames = {"Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"}
            table.insert(labels, mnames[m])
        end
    end

    local maxv = 1
    for _, v in ipairs(data) do 
        if v > maxv then maxv = v end 
    end

    local cx2, cy2 = x + 50, y + 50
    local cw2, ch2 = w - 60, h - 72

    -- Grid
    setColor(C.border)
    love.graphics.setLineWidth(0.5)
    for i = 0, 4 do
        local gy = cy2 + ch2 - i / 4 * ch2
        love.graphics.line(cx2, gy, cx2 + cw2, gy)
        
        setColor(C.dim)
        love.graphics.setFont(G.fonts.tiny)
        love.graphics.print(string.format("$%d", math.floor(maxv * i / 4)), x + 2, gy - 6)
        setColor(C.border)
    end
    love.graphics.setLineWidth(1)

    local n = #data
    if n == 0 then
        setColor(C.dim)
        love.graphics.setFont(G.fonts.normal)
        love.graphics.printf("Sin datos todavía", cx2, cy2 + ch2 / 2 - 10, cw2, "center")
        return
    end

    local bw2 = cw2 / n - 1.5
    for i, v in ipairs(data) do
        local bx2 = cx2 + (i - 1) * cw2 / n
        local bh2 = math.max((v / maxv) * ch2, v > 0 and 2 or 0)
        local by2 = cy2 + ch2 - bh2
        local t = v / maxv
        
        setColor({0.15 + t * 0.1, 0.35 + t * 0.4, 0.75 + t * 0.2})
        love.graphics.rectangle("fill", bx2, by2, math.max(bw2, 1), bh2, 2, 2)
        
        if labels[i] ~= "" then
            setColor(C.dim)
            love.graphics.setFont(G.fonts.tiny)
            local lw = G.fonts.tiny:getWidth(labels[i])
            love.graphics.print(labels[i], bx2 + (cw2 / n - lw) / 2, cy2 + ch2 + 3)
        end
    end
end

local function drawInicio()
    local ox, oy = SIDEBAR_W + 15, HEADER_H + 10
    local aw = W - SIDEBAR_W - 25

    -- Title + refresh
    setColor(C.white)
    love.graphics.setFont(G.fonts.large)
    love.graphics.print("Panel de Control Principal", ox, oy + 4)
    
    local ref_hov = hover(ox + aw - 135, oy, 120, 30)
    drawButton(ox + aw - 135, oy, 120, 30, "↺  Refrescar", C.card2, C.white, G.fonts.small, 5, ref_hov)

    -- Stat cards
    local now_d = os.date("*t")
    local total_m = #G.clients
    local active_m, expired_m = 0, 0
    
    for _, c in ipairs(G.clients) do
        if isActive(c) then 
            active_m = active_m + 1 
        else 
            expired_m = expired_m + 1 
        end
    end
    
    local new_month = 0
    for _, c in ipairs(G.clients) do
        local d = os.date("*t", c.start_ts or 0)
        if d.month == now_d.month and d.year == now_d.year then 
            new_month = new_month + 1 
        end
    end
    
    local monthly_inc = 0
    local agenda_inc = 0
    local today_att = 0
    for _, t in ipairs(G.transactions) do
        local d = os.date("*t", t.ts)
        if d.month == now_d.month and d.year == now_d.year then 
            monthly_inc = monthly_inc + (t.monto or 0) 
        end
        if d.year == now_d.year and d.month == now_d.month and d.day == now_d.day then 
            today_att = today_att + 1 
        end
    end

    for _, note in ipairs(G.notes) do
        local nts = noteMovementTimestamp(note, 0)
        local nd = os.date("*t", nts)
        if nd.month == now_d.month and nd.year == now_d.year then
            agenda_inc = agenda_inc + noteTotal(note)
        end
    end

    local balance_total = monthly_inc + agenda_inc

    local cw4 = (aw - 40) / 4
    local card_y = oy + 40
    local card_h = 80

    local cards = {
        {title = "Total Miembros", value = tostring(total_m), sub = string.format("Activos: %d  Vencidos: %d", active_m, expired_m), color = C.blue},
        {title = "Nuevos Registros (Mes)", value = tostring(new_month), sub = "+0% vs. mes anterior", color = C.cyan},
        {title = "Balance del Mes", value = string.format("$%d", balance_total), sub = string.format("Transacciones: $%d | Agenda: $%d", monthly_inc, agenda_inc), color = C.green},
        {title = "Asistencias Hoy", value = tostring(today_att), sub = "Hora pico: 18:00", color = C.yellow},
    }
    
    for i, cd in ipairs(cards) do
        local cx2 = ox + (i - 1) * (cw4 + 8)
        rr(cx2, card_y, cw4, card_h, 8, C.card)
        
        setColor(cd.color)
        love.graphics.rectangle("fill", cx2, card_y, 4, card_h, 2, 2)
        
        setColor(C.gray)
        love.graphics.setFont(G.fonts.small)
        love.graphics.print(cd.title, cx2 + 13, card_y + 10)
        
        setColor(C.white)
        love.graphics.setFont(G.fonts.large)
        love.graphics.print(cd.value, cx2 + 13, card_y + 28)
        
        setColor(cd.color)
        love.graphics.setFont(G.fonts.tiny)
        love.graphics.print(cd.sub, cx2 + 13, card_y + 62)
    end

    -- Chart + notifs layout
    local chart_y = card_y + card_h + 12
    local notif_w = 245
    local chart_w = aw - notif_w - 16

    drawChart(ox, chart_y, chart_w, 180)

    -- Notifications panel
    local nx = ox + chart_w + 8
    local ny = chart_y
    local nw = notif_w
    local nh_full = H - ny - 12

    rr(nx, ny, nw, nh_full, 8, C.card)
    setColor(C.white)
    love.graphics.setFont(G.fonts.normal)
    love.graphics.print("Notificaciones", nx + 10, ny + 10)

    love.graphics.setScissor(nx, ny + 34, nw, nh_full - 34)
    for i, n in ipairs(G.notifs) do
        local ity = ny + 34 + (i - 1) * 46
        if ity > ny + nh_full then break end

        rr(nx + 6, ity, nw - 12, 40, 5, C.card2)
        setColor(C.blue)
        love.graphics.circle("fill", nx + 16, ity + 12, 4)

        setColor(C.white)
        love.graphics.setFont(G.fonts.tiny)
        love.graphics.printf(n.msg, nx + 24, ity + 4, nw - 30, "left")

        setColor(C.dim)
        local d = os.date("*t", n.ts)
        love.graphics.print(string.format("%02d:%02d", d.hour, d.min), nx + 10, ity + 26)
    end
    love.graphics.setScissor()

    -- Client list
    local list_y = chart_y + 180 + 10
    local list_h = H - list_y - 12

    if list_h < 60 then return end

    rr(ox, list_y, chart_w, list_h, 8, C.card)
    setColor(C.white)
    love.graphics.setFont(G.fonts.normal)
    love.graphics.print("Clientes", ox + 12, list_y + 9)

    -- Sort
    local sorted = {}
    for _, c in ipairs(G.clients) do 
        table.insert(sorted, c) 
    end

    table.sort(sorted, function(a, b)
        local aa = isActive(a) and 1 or 0
        local ba = isActive(b) and 1 or 0
        if aa ~= ba then return aa > ba end
        return (a.start_ts or 0) > (b.start_ts or 0)
    end)

    local row_h = 48
    local sc = G.scroll.inicio

    love.graphics.setScissor(ox + 4, list_y + 32, chart_w - 8, list_h - 36)
    for i, c in ipairs(sorted) do
        local ry = list_y + 32 + (i - 1) * row_h - sc
        if ry + row_h < list_y + 32 then goto cont end
        if ry > list_y + list_h then break end

        local act = isActive(c)
        setColor(act and (i % 2 == 0 and C.row_b or C.row_a) or C.row_red)
        love.graphics.rectangle("fill", ox + 6, ry, chart_w - 12, row_h - 2, 4, 4)

        -- Status dot
        setColor(act and C.green or C.red)
        love.graphics.circle("fill", ox + 20, ry + row_h / 2, 6)

        -- Name
        setColor(C.white)
        love.graphics.setFont(G.fonts.normal)
        love.graphics.print(c.nombres .. " " .. c.apellidos, ox + 34, ry + 5)

        -- Plan badge
        local pc = c.plan == "Mensual" and C.blue or (c.plan == "Semanal" and C.cyan or C.yellow)
        rr(ox + 34, ry + 24, 62, 16, 3, pc)

        setColor(C.white)
        love.graphics.setFont(G.fonts.tiny)
        love.graphics.printf(c.plan, ox + 34, ry + 27, 62, "center")

        -- Weight/health
        setColor(C.gray)
        love.graphics.setFont(G.fonts.small)
        local info = (c.peso ~= "" and c.peso .. "kg" or "—") .. "  " .. (c.estado_salud or "")
        love.graphics.print(info, ox + 400, ry + 5)

        -- Expiry
        if c.expiry then
            local d = os.date("*t", c.expiry)
            setColor(act and C.gray or C.red)
            love.graphics.print(dateStr(d), ox + 190, ry + 22)
        end

        -- Status text
        setColor(act and C.green or C.red)
        love.graphics.setFont(G.fonts.tiny)
        love.graphics.print(act and "Activo" or "Vencido", ox + chart_w - 90, ry + 18)

        ::cont::
    end
    love.graphics.setScissor()
end

-- ============= PANTALLA: REGISTRO =============

local function drawRegistro()
    local ox, oy = SIDEBAR_W + 18, HEADER_H + 8
    local aw = W - SIDEBAR_W - 30

    setColor(C.white)
    love.graphics.setFont(G.fonts.large)
    love.graphics.print("REGISTRO DE NUEVO CLIENTE", ox, oy + 4)

    setColor(C.yellow)
    love.graphics.setFont(G.fonts.normal)
    love.graphics.print(string.format("Cliente #%04d", G.next_id), ox + 6, oy + 38)

    local form_w = aw - 215
    local form_y = oy + 64
    local form_h = H - form_y - 50

    rr(ox, form_y, form_w, form_h, 8, C.card)

    local fx = ox + 14
    local fw = form_w - 28

    -- Personal data
    setColor(C.gray)
    love.graphics.setFont(G.fonts.small)
    love.graphics.print("DATOS PERSONALES", fx, form_y + 14)

    setColor(C.dim)
    love.graphics.setFont(G.fonts.small)
    love.graphics.print("Nombres", fx, form_y + 38)
    drawInput(fx, form_y + 52, fw, 34, "nombres", "Nombres completos...")

    love.graphics.print("Apellidos", fx, form_y + 100)
    drawInput(fx, form_y + 114, fw, 34, "apellidos", "Apellidos...")

    love.graphics.print("Teléfono", fx, form_y + 162)
    drawInput(fx, form_y + 176, fw, 34, "telefono", "+57 300 000 0000...")

    love.graphics.print("Estado de Salud", fx, form_y + 224)
    drawInput(fx, form_y + 238, fw / 2 - 6, 34, "estado_salud", "Condición física...")

    love.graphics.print("Peso (kg)", fx + fw / 2 + 6, form_y + 224)
    drawInput(fx + fw / 2 + 6, form_y + 238, fw / 2 - 6, 34, "peso", "70")

    -- Membership data
    setColor(C.gray)
    love.graphics.setFont(G.fonts.small)
    love.graphics.print("DATOS DE LA MEMBRESÍA", fx, form_y + 292)

    local sel_plan = G.text_inputs["plan"] or "Mensual"
    local pw = (fw - 3 * 8) / 4

    setColor(C.dim)
    love.graphics.setFont(G.fonts.small)
    love.graphics.print("Plan", fx, form_y + 315)

    for i, p in ipairs(PLAN_OPTIONS) do
        local px = fx + (i - 1) * (pw + 8)
        local active = sel_plan == p

        rr(px, form_y + 330, pw, 50, 6, active and C.sidebar_sel or C.card2)

        setColor(active and C.white or C.gray)
        love.graphics.setFont(G.fonts.normal)
        love.graphics.printf(p, px, form_y + 338, pw, "center")

        setColor(active and C.cyan or C.dim)
        love.graphics.setFont(G.fonts.small)
        love.graphics.printf(string.format("$%d", PLAN_PRICES[p] or 0), px, form_y + 360, pw, "center")
    end

    local sp_y = form_y + 388
    local sp_active = sel_plan == SPECIAL_PLAN
    rr(fx, sp_y, fw, 58, 6, sp_active and C.sidebar_sel or C.card2)
    setColor(C.white)
    love.graphics.setFont(G.fonts.small)
    love.graphics.print("ESPECIAL", fx + 8, sp_y + 7)
    setColor(C.dim)
    love.graphics.setFont(G.fonts.tiny)
    love.graphics.print("Días", fx + 8, sp_y + 28)
    love.graphics.print("Precio/día", fx + 126, sp_y + 28)
    drawInput(fx + 38, sp_y + 20, 76, 28, "plan_special_days", "1")
    drawInput(fx + 176, sp_y + 20, 110, 28, "plan_special_price", "0")
    setColor(C.gray)
    love.graphics.printf("El monto total será días × precio/día.", fx + 298, sp_y + 24, fw - 302, "left")

    setColor(C.dim)
    love.graphics.setFont(G.fonts.small)
    love.graphics.print("Tipo de Pago", fx, form_y + 456)
    drawDropdown(fx, form_y + 470, fw, 34, "tipo_pago", PAGO_OPTIONS)

    -- Buttons
    local btn_y = form_y + form_h - 52
    local bmi_hov = hover(fx, btn_y, 110, 38)
    local c_hov = hover(ox + form_w - 270, btn_y, 120, 38)
    local s_hov = hover(ox + form_w - 140, btn_y, 125, 38)

    drawButton(fx, btn_y, 110, 38, "⚖ IMC", C.orange, C.white, G.fonts.normal, 6, bmi_hov)
    drawButton(ox + form_w - 270, btn_y, 120, 38, "CANCELAR", C.btn_cancel, C.white, G.fonts.normal, 6, c_hov)
    drawButton(ox + form_w - 140, btn_y, 125, 38, "✓ GUARDAR", C.btn_green, C.white, G.fonts.normal, 6, s_hov)

    -- Photo panel
    local px2 = ox + form_w + 10
    local py2 = form_y
    local pw2 = 205
    local ph2 = 200

    rr(px2, py2, pw2, ph2, 8, C.card)

    setColor(C.gray)
    love.graphics.setFont(G.fonts.small)
    love.graphics.print("PERFIL Y FOTO", px2 + 10, py2 + 12)

    rr(px2 + 12, py2 + 32, pw2 - 24, 130, 4, C.card2)
    setColor(C.border)
    rrLine(px2 + 12, py2 + 32, pw2 - 24, 130, 4)

    setColor(C.dim)
    love.graphics.setFont(G.fonts.large)
    love.graphics.printf("👤", px2 + 12, py2 + 72, pw2 - 24, "center")

    local up_hov = hover(px2 + 12, py2 + 170, pw2 - 24, 30)
    drawButton(px2 + 12, py2 + 170, pw2 - 24, 30, "📷 Subir Foto", C.sidebar_sel, C.white, G.fonts.small, 5, up_hov)

    -- Requirements
    local req_y = py2 + ph2 + 8
    rr(px2, req_y, pw2, 150, 8, C.card)

    setColor(C.gray)
    love.graphics.setFont(G.fonts.small)
    love.graphics.print("REQUISITOS", px2 + 10, req_y + 10)

    local reqs = {
        {key = "medical", label = "Examen Médico"},
        {key = "contract", label = "Contrato Firmado"},
        {key = "terms", label = "Términos Aceptados"},
    }

    for i, req in ipairs(reqs) do
        local ry2 = req_y + 30 + (i - 1) * 34
        local checked = G.req_state and G.req_state[req.key]

        rr(px2 + 10, ry2, 18, 18, 4, checked and C.green or C.card2)
        setColor(checked and C.white or C.dim)
        love.graphics.setFont(G.fonts.normal)
        love.graphics.printf(checked and "✓" or "", px2 + 10, ry2 + 1, 18, "center")

        setColor(C.white)
        love.graphics.setFont(G.fonts.tiny)
        love.graphics.print(req.label, px2 + 34, ry2 + 1)

        setColor(checked and C.green or C.red)
        love.graphics.setFont(G.fonts.tiny)
        love.graphics.print(checked and "Cumplido" or "Pendiente", px2 + 120, ry2 + 1)
    end

    setColor(C.dim)
    love.graphics.setFont(G.fonts.tiny)
    love.graphics.print("Marca los 3 requisitos para poder guardar.", px2 + 10, req_y + 122)

    -- Recent clients table
    local rec_y = form_y + form_h + 5
    local rec_h = H - rec_y - 8

    if rec_h < 50 then return end

    rr(ox, rec_y, form_w, rec_h, 8, C.card)

    setColor(C.white)
    love.graphics.setFont(G.fonts.normal)
    love.graphics.print("CLIENTES RECIENTES", ox + 12, rec_y + 9)

    local cols = {ox + 10, ox + 65, ox + 240, ox + 410, ox + 560, ox + 650}
    local hdrs = {"ID", "Nombre", "Plan", "Fecha Reg.", "Estado", "Acciones"}

    setColor(C.gray)
    love.graphics.setFont(G.fonts.small)
    for i, h in ipairs(hdrs) do
        love.graphics.print(h, cols[i], rec_y + 32)
    end

    setColor(C.border)
    love.graphics.setLineWidth(0.5)
    love.graphics.line(ox + 6, rec_y + 48, ox + form_w - 6, rec_y + 48)
    love.graphics.setLineWidth(1)

    local start_i = math.max(1, #G.clients - 5)
    local ri = 0

    for i = #G.clients, start_i, -1 do
        local c = G.clients[i]
        local ry3 = rec_y + 52 + ri * 28

        if ry3 + 22 > rec_y + rec_h then break end

        local act = isActive(c)
        setColor(C.white)
        love.graphics.setFont(G.fonts.small)

        setColor(C.yellow)
        love.graphics.print(string.format("#%04d", c.id), cols[1], ry3)

        setColor(C.white)
        love.graphics.print(c.nombres .. " " .. c.apellidos, cols[2], ry3)
        love.graphics.print(c.plan, cols[3], ry3)

        if c.start_ts then
            local d = os.date("*t", c.start_ts)
            love.graphics.print(dateStr(d), cols[4], ry3)
        end

        setColor(act and C.green or C.red)
        love.graphics.circle("fill", cols[5] + 5, ry3 + 7, 4)

        love.graphics.setFont(G.fonts.tiny)
        love.graphics.print(act and "Activo" or "Vencido", cols[5] + 12, ry3 + 3)

        ri = ri + 1
    end
end

-- ============= PANTALLA: CLIENTES =============
local function drawClientes()
    local ox, oy = SIDEBAR_W + 15, HEADER_H + 8
    local aw = W - SIDEBAR_W - 25

    setColor(C.white)
    love.graphics.setFont(G.fonts.large)
    love.graphics.print("GESTIÓN DE CLIENTES", ox, oy + 4)

    -- Search
    drawInput(ox + aw - 260, oy + 2, 245, 33, "cl_search", "🔍 Buscar cliente...")

    -- New client button
    local nc_hov = hover(ox + aw - 390, oy + 2, 120, 33)
    drawButton(ox + aw - 390, oy + 2, 120, 33, "+ Nuevo", C.btn_green, C.white, G.fonts.normal, 5, nc_hov)

    -- Filter tabs
    local tab_y = oy + 44
    local filters = {"Todos", "Activos", "Vencidos"}
    local fkeys   = {"todos", "activos", "vencidos"}
    
    for i, f in ipairs(filters) do
        local tx = ox + (i - 1) * 100
        local active = G.cl_filter == fkeys[i]
        
        rr(tx, tab_y, 95, 28, 5, active and C.sidebar_sel or C.card)
        setColor(C.white)
        love.graphics.setFont(G.fonts.small)
        love.graphics.printf(f, tx, tab_y + 7, 95, "center")
    end

    -- Table
    local ty = tab_y + 36
    local th = H - ty - 10
    rr(ox, ty, aw, th, 8, C.card)

    local cols = {ox + 8, ox + 52, ox + 102, ox + 320, ox + 420, ox + 570, ox + 715, ox + 800}
    local hdrs = {"#", "Foto", "Nombre", "Plan", "Peso/Salud", "Vencimiento", "Estado", "Acciones"}
    
    setColor(C.gray)
    love.graphics.setFont(G.fonts.small)
    for i, h in ipairs(hdrs) do 
        love.graphics.print(h, cols[i], ty + 10) 
    end
    
    setColor(C.border)
    love.graphics.setLineWidth(0.5)
    love.graphics.line(ox + 4, ty + 28, ox + aw - 4, ty + 28)
    love.graphics.setLineWidth(1)

    -- Filter + sort
    local sv = (G.text_inputs["cl_search"] or ""):lower()
    local filtered = {}
    
    for _, c in ipairs(G.clients) do
        local act = isActive(c)
        local mf = G.cl_filter == "todos" or (G.cl_filter == "activos" and act) or (G.cl_filter == "vencidos" and not act)
        local ms = sv == "" or (c.nombres .. " " .. c.apellidos):lower():find(sv, 1, true)
        if mf and ms then 
            table.insert(filtered, c) 
        end
    end
    
    table.sort(filtered, function(a, b)
        return (isActive(a) and 1 or 0) > (isActive(b) and 1 or 0)
    end)

    local rh = 54
    local sc = G.scroll.clientes or 0
    love.graphics.setScissor(ox + 2, ty + 30, aw - 4, th - 34)
    
    for i, c in ipairs(filtered) do
        local ry = ty + 32 + (i - 1) * rh - sc
        if ry + rh < ty + 32 then goto cont2 end
        if ry > ty + th then break end
        
        local act = isActive(c)
        setColor(act and (i % 2 == 0 and C.row_b or C.row_a) or C.row_red)
        love.graphics.rectangle("fill", ox + 4, ry, aw - 8, rh - 2, 4, 4)

        -- ID
        setColor(C.yellow)
        love.graphics.setFont(G.fonts.tiny)
        love.graphics.print(string.format("#%04d", c.id), cols[1], ry + 18)
        
        -- Photo circle
        setColor(C.card2)
        love.graphics.circle("fill", cols[2] + 20, ry + 24, 20)
        setColor(C.dim)
        love.graphics.circle("line", cols[2] + 20, ry + 24, 20)
        love.graphics.setFont(G.fonts.normal)
        love.graphics.printf("👤", cols[2] + 5, ry + 14, 30, "center")
        
        -- Name
        setColor(C.white)
        love.graphics.setFont(G.fonts.normal)
        love.graphics.print(c.nombres .. " " .. c.apellidos, cols[3], ry + 7)
        setColor(C.gray)
        love.graphics.setFont(G.fonts.tiny)
        love.graphics.print(c.telefono or "", cols[3], ry + 28)
        
        -- Plan badge
        local pc = c.plan == "Mensual" and C.blue or (c.plan == "Semanal" and C.cyan or C.yellow)
        rr(cols[4], ry + 14, 78, 20, 4, pc)
        setColor(C.white)
        love.graphics.setFont(G.fonts.tiny)
        love.graphics.printf(c.plan, cols[4], ry + 17, 78, "center")
        
        -- Health
        setColor(C.white)
        love.graphics.setFont(G.fonts.small)
        love.graphics.print((c.peso ~= "" and c.peso .. "kg" or "—"), cols[5], ry + 7)
        setColor(C.gray)
        love.graphics.setFont(G.fonts.tiny)
        love.graphics.print(c.estado_salud or "", cols[5], ry + 27)
        
        -- Expiry
        if c.expiry then
            local d = os.date("*t", c.expiry)
            local dl = math.floor((c.expiry - os.time()) / 86400)
            
            setColor(act and (dl <= 3 and C.yellow or C.white) or C.red)
            love.graphics.setFont(G.fonts.small)
            love.graphics.print(dateStr(d), cols[6], ry + 7)
            
            love.graphics.setFont(G.fonts.tiny)
            setColor(act and (dl <= 3 and C.yellow or C.gray) or C.red)
            love.graphics.print(act and dl .. " días" or "VENCIDO", cols[6], ry + 27)
        end
        
        -- Status
        setColor(act and C.green or C.red)
        love.graphics.circle("fill", cols[7] + 8, ry + 16, 6)
        love.graphics.setFont(G.fonts.tiny)
        love.graphics.print(act and "Activo" or "Vencido", cols[7] + 17, ry + 11)
        
        -- Buttons
        local r1h = hover(cols[8], ry + 6, 60, 20)
        local r2h = hover(cols[8] + 65, ry + 6, 28, 20)
        local r3h = hover(cols[8] + 98, ry + 6, 28, 20)
        
        drawButton(cols[8],      ry + 6, 60, 20, "Renovar", C.btn_green,    C.white, G.fonts.tiny, 4, r1h)
        drawButton(cols[8] + 65, ry + 6, 28, 20, "✏",       C.sidebar_sel,  C.white, G.fonts.tiny, 4, r2h)
        drawButton(cols[8] + 98, ry + 6, 28, 20, "🗑",       {0.55, 0.1, 0.1}, C.white, G.fonts.tiny, 4, r3h)
        
        ::cont2::
    end
    love.graphics.setScissor()

    -- Row count
    setColor(C.dim)
    love.graphics.setFont(G.fonts.tiny)
    love.graphics.print(string.format("%d cliente(s) mostrado(s)", #filtered), ox + 10, ty + th - 16)
end

-- ============= PANTALLA: AGENDA =============
local function getWeekStart(offset)
    local now = os.date("*t")
    local ts = os.time(now)
    local wd = now.wday - 2
    if wd < 0 then wd = wd + 7 end
    return ts - wd * 86400 + offset * 7 * 86400
end


local function drawAgenda()
    local ox, oy = SIDEBAR_W + 12, HEADER_H + 8
    local aw = W - SIDEBAR_W - 20

    setColor(C.white)
    love.graphics.setFont(G.fonts.large)
    love.graphics.print("PANEL DE ANOTACIONES", ox, oy + 4)

    drawInput(ox + aw - 250, oy + 2, 235, 32, "ag_search", "🔍 Buscar anotaciones...")

    local views = {"Día", "Semana", "Mes"}
    local vkeys = {"dia", "semana", "mes"}
    for i, v in ipairs(views) do
        local vx = ox + (i - 1) * 78
        local active = G.ag_view == vkeys[i]
        rr(vx, oy + 42, 73, 26, 5, active and C.blue or C.card)
        setColor(C.white)
        love.graphics.setFont(G.fonts.small)
        love.graphics.printf(v, vx, oy + 49, 73, "center")
    end

    local ws = getWeekStart(G.ag_week_off)
    local we = ws + 6 * 86400
    local wsd = os.date("*t", ws)
    local wed = os.date("*t", we)

    local nav_cx = ox + aw / 2
    drawButton(nav_cx - 140, oy + 42, 30, 26, "◀", C.card, C.white, G.fonts.normal, 4, hover(nav_cx - 140, oy + 42, 30, 26))
    drawButton(nav_cx + 112, oy + 42, 30, 26, "▶", C.card, C.white, G.fonts.normal, 4, hover(nav_cx + 112, oy + 42, 30, 26))

    setColor(C.white)
    love.graphics.setFont(G.fonts.normal)
    love.graphics.printf(string.format("%s %d – %s %d, %d",
        MONTH_NAMES[wsd.month]:sub(1, 3), wsd.day,
        MONTH_NAMES[wed.month]:sub(1, 3), wed.day, wed.year), nav_cx - 108, oy + 48, 218, "center")

    drawButton(ox + aw - 140, oy + 42, 130, 26, "+ Nueva Nota", C.btn_green, C.white, G.fonts.small, 5, hover(ox + aw - 140, oy + 42, 130, 26))

    local gx, gy = ox, oy + 78
    local gw, gh = aw, H - gy - 90
    rr(gx, gy, gw, gh, 6, C.card)

    local hcw = 52
    local dcw = (gw - hcw) / 7
    local hour_h = 52
    local hdr_h = 30
    local n_hours = 12

    local today_d = os.date("*t")
    local day_totals = {}
    for _, note in ipairs(G.notes) do
        ensureNoteAmounts(note)
        day_totals[note.day or 0] = (day_totals[note.day or 0] or 0) + noteTotal(note)
    end

    for d = 0, 6 do
        local dx = gx + hcw + d * dcw
        local dts = ws + d * 86400
        local dd = os.date("*t", dts)
        local is_today = dd.year == today_d.year and dd.month == today_d.month and dd.day == today_d.day

        if is_today then
            rr(dx, gy, dcw, hdr_h, 3, C.sidebar_sel)
        end

        setColor(is_today and C.white or C.gray)
        love.graphics.setFont(G.fonts.small)
        love.graphics.printf(string.format("%s %d", DAY_SHORT[d + 1], dd.day), dx, gy + 5, dcw, "center")
        local dt = day_totals[d] or 0
        setColor(dt >= 0 and C.green or C.red)
        love.graphics.setFont(G.fonts.tiny)
        love.graphics.printf(noteMoneyLabel(dt), dx, gy + 18, dcw, "center")

        setColor(C.border)
        love.graphics.setLineWidth(0.5)
        love.graphics.line(dx, gy, dx, gy + gh)
        love.graphics.setLineWidth(1)
    end

    local sc = G.scroll.agenda or 0
    love.graphics.setScissor(gx, gy + hdr_h, gw, gh - hdr_h)

    for h = 0, n_hours do
        local hour = 8 + h
        local hy = gy + hdr_h + h * hour_h - sc
        if hy >= gy + hdr_h - hour_h and hy <= gy + gh then
            setColor(C.dim)
            love.graphics.setFont(G.fonts.tiny)
            love.graphics.printf(string.format("%02d:00", hour), gx, hy + 4, hcw - 4, "right")

            setColor(C.border)
            love.graphics.setLineWidth(0.5)
            love.graphics.line(gx + hcw, hy, gx + gw, hy)
            love.graphics.setLineWidth(1)
        end
    end

    local sv = (G.text_inputs["ag_search"] or ""):lower()

    for _, note in ipairs(G.notes) do
        local txt = (note.text or ""):lower()
        if sv == "" or txt:find(sv, 1, true) then
            local nx2 = gx + hcw + note.day * dcw + 2
            local hy = gy + hdr_h + (note.hour - 8) * hour_h + 2 - sc
            local nw2 = dcw - 4
            local nh2 = hour_h * (note.duration or 1) - 4

            if hy >= gy + hdr_h - nh2 and hy <= gy + gh then
                local nc = NOTE_COLORS[note.color] or C.blue
                setColor({nc[1], nc[2], nc[3], 0.88})
                love.graphics.rectangle("fill", nx2, hy, nw2, nh2, 3, 3)

                setColor(C.white)
                love.graphics.setFont(G.fonts.tiny)
                love.graphics.printf(note.text or "", nx2 + 3, hy + 3, nw2 - 6, "left")

                local total = noteTotal(note)
                setColor(total >= 0 and C.green or C.red)
                love.graphics.print(noteMoneyLabel(total), nx2 + 3, hy + nh2 - 13)

                if G.ag_selected == note then
                    rr(nx2 + nw2 - 72, hy + 2, 20, 16, 3, C.green)
                    rr(nx2 + nw2 - 48, hy + 2, 20, 16, 3, C.blue)
                    rr(nx2 + nw2 - 24, hy + 2, 20, 16, 3, C.red)
                    setColor(C.white)
                    love.graphics.setFont(G.fonts.tiny)
                    love.graphics.print("+", nx2 + nw2 - 68, hy + 3)
                    love.graphics.print("✏", nx2 + nw2 - 44, hy + 3)
                    love.graphics.print("✗", nx2 + nw2 - 20, hy + 3)
                end
            end
        end
    end
    love.graphics.setScissor()

    local by2 = gy + gh + 5
    local bh2 = H - by2 - 8
    if bh2 > 28 then
        rr(gx, by2, gw, bh2, 6, C.card)
        setColor(C.gray)
        love.graphics.setFont(G.fonts.small)
        love.graphics.print("ACTIVIDADES DE HOY", gx + 10, by2 + 8)

        local today_wd = today_d.wday - 2
        if today_wd < 0 then today_wd = today_wd + 7 end

        local cols2 = {gx + 10, gx + 75, gx + 340, gx + 500}
        local hdrs2 = {"Hora", "Actividad", "Tipo", "Estado"}
        setColor(C.gray)
        love.graphics.setFont(G.fonts.tiny)
        for i, h in ipairs(hdrs2) do
            love.graphics.print(h, cols2[i], by2 + 26)
        end

        local ri = 0
        for _, n in ipairs(G.notes) do
            if n.day == today_wd then
                local ny3 = by2 + 40 + ri * 20
                if ny3 + 15 > by2 + bh2 then break end

                setColor(C.white)
                love.graphics.setFont(G.fonts.tiny)
                love.graphics.print(string.format("%02d:00", n.hour), cols2[1], ny3)
                love.graphics.print(n.text or "", cols2[2], ny3)

                local nc = NOTE_COLORS[n.color] or C.blue
                rr(cols2[3] - 2, ny3 - 1, 56, 14, 3, nc)

                setColor(C.white)
                love.graphics.printf(n.color or "", cols2[3] - 2, ny3 + 1, 56, "center")

                setColor(C.green)
                love.graphics.circle("fill", cols2[4] + 5, ny3 + 6, 4)
                love.graphics.print("Activo", cols2[4] + 13, ny3)

                ri = ri + 1
            end
        end
    end
end

-- ============= PANTALLA: CONFIGURACIÓN =============

local function drawConfiguracion()
    local ox, oy = SIDEBAR_W + 15, HEADER_H + 8
    local aw = W - SIDEBAR_W - 25
    local theme_scroll = G.scroll.configuracion or 0

    setColor(C.white)
    love.graphics.setFont(G.fonts.large)
    love.graphics.print("CONFIGURACIÓN", ox, oy + 4)

    setColor(C.gray)
    love.graphics.setFont(G.fonts.small)
    love.graphics.print("Ajusta precios, tema visual y notificaciones", ox, oy + 30)

    local left_w = math.floor((aw - 12) * 0.42)
    local right_w = aw - left_w - 12

    G.text_inputs.set_price_Diario = G.text_inputs.set_price_Diario or tostring(PLAN_PRICES.Diario or 0)
    G.text_inputs.set_price_Semanal = G.text_inputs.set_price_Semanal or tostring(PLAN_PRICES.Semanal or 0)
    G.text_inputs.set_price_Quincenal = G.text_inputs.set_price_Quincenal or tostring(PLAN_PRICES.Quincenal or 0)
    G.text_inputs.set_price_Mensual = G.text_inputs.set_price_Mensual or tostring(PLAN_PRICES.Mensual or 0)
    G.text_inputs.set_notif_limit = G.text_inputs.set_notif_limit or tostring((G.settings and G.settings.notif_limit) or 25)

    rr(ox, oy + 42, left_w, 312, 8, C.card)
    setColor(C.white)
    love.graphics.setFont(G.fonts.normal)
    love.graphics.print("💳 Precios por plan", ox + 12, oy + 54)

    setColor(C.gray)
    love.graphics.setFont(G.fonts.small)
    love.graphics.print("Diario", ox + 12, oy + 92)
    drawInput(ox + 12, oy + 108, left_w - 24, 32, "set_price_Diario", tostring(PLAN_PRICES.Diario or 0))
    love.graphics.print("Semanal", ox + 12, oy + 150)
    drawInput(ox + 12, oy + 166, left_w - 24, 32, "set_price_Semanal", tostring(PLAN_PRICES.Semanal or 0))
    love.graphics.print("Quincenal", ox + 12, oy + 208)
    drawInput(ox + 12, oy + 224, left_w - 24, 32, "set_price_Quincenal", tostring(PLAN_PRICES.Quincenal or 0))
    love.graphics.print("Mensual", ox + 12, oy + 266)
    drawInput(ox + 12, oy + 282, left_w - 24, 32, "set_price_Mensual", tostring(PLAN_PRICES.Mensual or 0))

    rr(ox + left_w + 12, oy + 42, right_w, 260, 8, C.card)
    setColor(C.white)
    love.graphics.setFont(G.fonts.normal)
    love.graphics.print("🎨 Tema de colores", ox + left_w + 24, oy + 54)

    setColor(C.gray)
    love.graphics.setFont(G.fonts.small)
    love.graphics.print("Selecciona un estilo visual predefinido", ox + left_w + 24, oy + 76)

    local themes = {}
    for i, _ in pairs(THEME_PRESETS) do
        table.insert(themes, i)
    end
    table.sort(themes)

    local tx0 = ox + left_w + 24
    local ty0 = oy + 100
    local th_view = 150
    local tw = (right_w - 24 - 8) / 2
    local row_h = 66
    local max_scroll = math.max(0, math.ceil(#themes / 2) * row_h - th_view)
    G.scroll.configuracion = clamp(theme_scroll, 0, max_scroll)

    love.graphics.setScissor(tx0, ty0, right_w - 24, th_view)
    for i, th in ipairs(themes) do
        local tx = tx0 + ((i - 1) % 2) * (tw + 8)
        local ty = ty0 + math.floor((i - 1) / 2) * row_h - G.scroll.configuracion
        local active = (G.settings and G.settings.theme) == th
        if ty + 58 < ty0 or ty > ty0 + th_view then goto continue_theme end

        rr(tx, ty, tw, 58, 7, active and C.sidebar_sel or C.card2)
        local p = THEME_PRESETS[th]
        if p then
            rr(tx + 8, ty + 8, 42, 10, 3, p.sidebar_bg)
            rr(tx + 8, ty + 22, 42, 10, 3, p.sidebar_sel)
            rr(tx + 8, ty + 36, 42, 10, 3, p.card)
        end
        setColor(active and C.white or C.gray)
        love.graphics.setFont(G.fonts.small)
        love.graphics.print(th, tx + 58, ty + 12)
        setColor(active and C.cyan or C.dim)
        love.graphics.setFont(G.fonts.tiny)
        love.graphics.print(active and "Activo" or "Click para aplicar", tx + 58, ty + 31)

        ::continue_theme::
    end
    love.graphics.setScissor()

    if max_scroll > 0 then
        local bar_h = math.max(26, th_view * th_view / (th_view + max_scroll))
        local bar_y = ty0 + (G.scroll.configuracion / max_scroll) * (th_view - bar_h)
        rr(tx0 + right_w - 20, ty0, 10, th_view, 4, C.card2)
        rr(tx0 + right_w - 20, bar_y, 10, bar_h, 4, C.sidebar_sel)
    end

    rr(ox, oy + 366, aw, H - (oy + 366) - 18, 8, C.card)
    setColor(C.white)
    love.graphics.setFont(G.fonts.normal)
    love.graphics.print("🔔 Notificaciones", ox + 12, oy + 378)

    setColor(C.gray)
    love.graphics.setFont(G.fonts.small)
    love.graphics.print("Color por defecto:", ox + 12, oy + 408)
    local notif_colors = {"blue", "green", "yellow", "red", "cyan", "purple"}
    for i, nc in ipairs(notif_colors) do
        local bx = ox + 12 + (i - 1) * 66
        local by = oy + 426
        local active = (G.settings and G.settings.notif_color) == nc
        rr(bx, by, 60, 26, 5, active and NOTE_COLORS[nc] or C.card2)
        setColor(C.white)
        love.graphics.setFont(G.fonts.tiny)
        love.graphics.printf(nc, bx, by + 7, 60, "center")
    end

    setColor(C.gray)
    love.graphics.setFont(G.fonts.small)
    love.graphics.print("Máximo de notificaciones visibles", ox + 12, oy + 466)
    drawInput(ox + 12, oy + 482, 150, 32, "set_notif_limit", tostring((G.settings and G.settings.notif_limit) or 25))

    local save_hov = hover(ox + aw - 260, H - 66, 120, 38)
    local reset_hov = hover(ox + aw - 130, H - 66, 120, 38)
    drawButton(ox + aw - 260, H - 66, 120, 38, "Guardar", C.btn_green, C.white, G.fonts.normal, 6, save_hov)
    drawButton(ox + aw - 130, H - 66, 120, 38, "Restaurar", C.btn_cancel, C.white, G.fonts.normal, 6, reset_hov)
end

-- ============= PANTALLA: SOPORTE =============

local function drawSoporte()
    local ox, oy = SIDEBAR_W + 15, HEADER_H + 8
    local aw = W - SIDEBAR_W - 25

    setColor(C.white)
    love.graphics.setFont(G.fonts.large)
    love.graphics.print("SOPORTE Y DOCUMENTACIÓN", ox, oy + 4)

    local hw = (aw - 12) / 2

    -- App info
    rr(ox, oy + 38, hw, 110, 8, C.card)
    setColor(C.blue)
    love.graphics.setFont(G.fonts.medium)
    love.graphics.print("⚡ GymManager v1.0", ox + 12, oy + 50)

    setColor(C.gray)
    love.graphics.setFont(G.fonts.small)
    love.graphics.print("Sistema de Gestión de Gimnasio", ox + 12, oy + 74)
    love.graphics.print("Desarrollado en Löve2D (Lua)", ox + 12, oy + 92)
    love.graphics.print("Datos guardados en CSV por mes", ox + 12, oy + 110)

    setColor(C.green)
    love.graphics.circle("fill", ox + 20, oy + 138, 5)

    setColor(C.white)
    love.graphics.setFont(G.fonts.small)
    love.graphics.print("Sistema operativo normalmente", ox + 30, oy + 132)

    -- System stats
    rr(ox + hw + 12, oy + 38, hw, 110, 8, C.card)
    setColor(C.yellow)
    love.graphics.setFont(G.fonts.normal)
    love.graphics.print("📊 Estado del Sistema", ox + hw + 24, oy + 50)

    setColor(C.white)
    love.graphics.setFont(G.fonts.small)
    love.graphics.print(string.format("Clientes registrados: %d", #G.clients), ox + hw + 24, oy + 74)
    love.graphics.print(string.format("Transacciones totales: %d", #G.transactions), ox + hw + 24, oy + 92)
    love.graphics.print(string.format("Notas de agenda: %d", #G.notes), ox + hw + 24, oy + 110)

    setColor(C.dim)
    love.graphics.setFont(G.fonts.tiny)
    love.graphics.print("Dir: " .. love.filesystem.getSaveDirectory(), ox + hw + 24, oy + 130)

    -- Guide
    local gy = oy + 162
    local gh = H - gy - 50
    rr(ox, gy, aw, gh, 8, C.card)

    setColor(C.white)
    love.graphics.setFont(G.fonts.medium)
    love.graphics.print("📖 Guía de Uso", ox + 12, gy + 12)

    local guide = {
        {"🏠  Inicio",       "Panel principal con estadísticas, gráfica de transacciones y lista de clientes. Los clientes en rojo tienen membresía vencida."},
        {"📝  Registro",     string.format("Registra nuevos clientes. Planes: Diario ($%d), Semanal ($%d), Quincenal ($%d), Mensual ($%d) y ESPECIAL (días × precio/día). Los 3 requisitos se marcan con click antes de guardar.", PLAN_PRICES.Diario or 0, PLAN_PRICES.Semanal or 0, PLAN_PRICES.Quincenal or 0, PLAN_PRICES.Mensual or 0)},
        {"👥  Clientes",     "Busca, filtra, renueva o elimina clientes. Renovar y eliminar ahora piden confirmación en dos pasos para evitar errores."},
        {"📅  Agenda",       "Crea y administra anotaciones por día y hora. Navega por semanas con los botones y usa el buscador para encontrar notas."},
        {"💰  Cerrar Caja",  "Abre un resumen del día con ingresos, ingresos nuevos, renovaciones y planes antes de cerrar la caja."},
        {"⚙  Configuración", "Cambia precios, tema visual y notificaciones. El bloque de temas ahora se puede desplazar con la rueda del mouse."},
        {"💾  Persistencia", "Todo se guarda automáticamente en CSV: clientes, transacciones y notas."},
    }

    local row_y = gy + 42
    love.graphics.setScissor(ox + 4, gy + 35, aw - 8, gh - 35)

    for _, item in ipairs(guide) do
        if row_y + 40 > gy + gh then break end

        setColor(C.cyan)
        love.graphics.setFont(G.fonts.normal)
        love.graphics.print(item[1], ox + 12, row_y)

        setColor(C.gray)
        love.graphics.setFont(G.fonts.small)
        love.graphics.printf(item[2], ox + 180, row_y + 2, aw - 200, "left")

        setColor(C.border)
        love.graphics.setLineWidth(0.5)
        love.graphics.line(ox + 8, row_y + 28, ox + aw - 8, row_y + 28)
        love.graphics.setLineWidth(1)

        row_y = row_y + 36
    end

    if row_y + 160 < gy + gh then
        setColor(C.yellow)
        love.graphics.setFont(G.fonts.normal)
        love.graphics.print("⌨  Atajos de Teclado", ox + 12, row_y + 8)

        local shortcuts = {
            "F1 → Inicio",
            "F2 → Registro",
            "F3 → Clientes",
            "F4 → Agenda",
            "F5 → Configuración",
            "F6 → Soporte",
            "F7 → Refrescar datos",
            "Ctrl+N → Nuevo registro",
            "Ctrl+S → Guardar configuración",
            "Ctrl+M → Nueva anotación",
            "Esc → Cerrar diálogo / cancelar",
            "Enter → Confirmar acción",
            "Tab → Siguiente campo",
        }

        setColor(C.gray)
        love.graphics.setFont(G.fonts.small)
        for i, sc in ipairs(shortcuts) do
            local sx = ox + 12 + ((i - 1) % 3) * 210
            local sy = row_y + 28 + math.floor((i - 1) / 3) * 18
            if sy < gy + gh - 5 then
                love.graphics.print(sc, sx, sy)
            end
        end
    end

    love.graphics.setScissor()
end

-- ============= TRANSACCIONES: HELPERS =============

local function saveTxAll()
    -- Rebuild all monthly CSV files from G.transactions (sorted by ts)
    -- We group by year-month
    local by_month = {}
    for _, t in ipairs(G.transactions) do
        local d = os.date("*t", t.ts or os.time())
        local key = string.format("%04d-%02d", d.year, d.month)
        if not by_month[key] then by_month[key] = {} end
        table.insert(by_month[key], t)
    end
    -- Write each month file
    for folder, txs in pairs(by_month) do
        local path = "transacciones/" .. folder .. "/tx.csv"
        ensureDir("transacciones")
        ensureDir("transacciones/" .. folder)
        local lines = {"ts,fecha,hora,monto,plan,cliente,tipo"}
        for _, t in ipairs(txs) do
            local d = os.date("*t", t.ts or os.time())
            table.insert(lines, string.format(
                "%d,%s,%s,%s,%s,%s,%s",
                t.ts,
                escCSV(dateStr(d)),
                escCSV(t.hora or string.format("%02d:%02d", d.hour, d.min)),
                escCSV(tostring(t.monto or 0)),
                escCSV(t.plan or ""),
                escCSV(t.cliente or ""),
                escCSV(t.tipo or "registro")
            ))
        end
        love.filesystem.write(path, table.concat(lines, "\n"))
    end
end

local function txTimestamp(t)
    -- Reconstruct a full timestamp from t.ts (date) and t.hora (HH:MM string)
    local d = os.date("*t", t.ts or os.time())
    local h, m = 0, 0
    if t.hora then
        h, m = t.hora:match("(%d+):(%d+)")
        h = tonumber(h) or 0
        m = tonumber(m) or 0
    end
    return os.time({year = d.year, month = d.month, day = d.day, hour = h, min = m, sec = 0})
end

local function openTxEditModal(idx)
    local t = G.transactions[idx]
    if not t then return end
    local d = os.date("*t", t.ts or os.time())
    local h, m = 0, 0
    if t.hora then
        local hh, mm = t.hora:match("(%d+):(%d+)")
        h = tonumber(hh) or 0
        m = tonumber(mm) or 0
    end
    G.tx_edit_modal = {
        idx        = idx,
        ts         = t.ts,
        monto      = t.monto or 0,
        plan       = t.plan or "",
        cliente    = t.cliente or "",
        tipo       = t.tipo or "registro",
        hora       = t.hora or "00:00",
        cal_year   = d.year,
        cal_month  = d.month,
        cal_day    = d.day,
        clock_h    = h,
        clock_m    = m,
        show_cal   = false,
        show_clock = false,
    }
    G.text_inputs["txe_monto"]   = tostring(t.monto or 0)
    G.text_inputs["txe_plan"]    = t.plan or ""
    G.text_inputs["txe_cliente"] = t.cliente or ""
    G.text_inputs["txe_tipo"]    = t.tipo or "registro"
    editorState("txe_monto").cursor   = utf8_len_safe(G.text_inputs["txe_monto"]) + 1
    editorState("txe_monto").anchor   = editorState("txe_monto").cursor
    editorState("txe_plan").cursor    = utf8_len_safe(G.text_inputs["txe_plan"]) + 1
    editorState("txe_plan").anchor    = editorState("txe_plan").cursor
    editorState("txe_cliente").cursor = utf8_len_safe(G.text_inputs["txe_cliente"]) + 1
    editorState("txe_cliente").anchor = editorState("txe_cliente").cursor
    G.focus = nil
end

local function openTxNewModal()
    local now = os.date("*t")
    G.tx_new_modal = {
        ts         = os.time(),
        monto      = 0,
        plan       = "Mensual",
        cliente    = "",
        tipo       = "registro",
        hora       = string.format("%02d:%02d", now.hour, now.min),
        cal_year   = now.year,
        cal_month  = now.month,
        cal_day    = now.day,
        clock_h    = now.hour,
        clock_m    = now.min,
        show_cal   = false,
        show_clock = false,
    }
    G.text_inputs["txn_monto"]   = "0"
    G.text_inputs["txn_plan"]    = "Mensual"
    G.text_inputs["txn_cliente"] = ""
    G.text_inputs["txn_tipo"]    = "registro"
    editorState("txn_monto").cursor   = 2
    editorState("txn_monto").anchor   = 2
    editorState("txn_plan").cursor    = utf8_len_safe("Mensual") + 1
    editorState("txn_plan").anchor    = editorState("txn_plan").cursor
    editorState("txn_cliente").cursor = 1
    editorState("txn_cliente").anchor = 1
    G.focus = nil
end

local function saveTxEditModal()
    local m = G.tx_edit_modal
    if not m then return end
    local t = G.transactions[m.idx]
    if not t then G.tx_edit_modal = nil; return end

    t.monto   = tonumber(G.text_inputs["txe_monto"]) or 0
    t.plan    = G.text_inputs["txe_plan"] or ""
    t.cliente = G.text_inputs["txe_cliente"] or ""
    t.tipo    = G.text_inputs["txe_tipo"] or "registro"
    t.hora    = string.format("%02d:%02d", m.clock_h, m.clock_m)

    -- Rebuild ts from calendar selection
    local new_ts = os.time({year = m.cal_year, month = m.cal_month, day = m.cal_day,
                             hour = m.clock_h, min = m.clock_m, sec = 0})
    t.ts = new_ts

    -- Re-sort
    table.sort(G.transactions, function(a, b) return a.ts < b.ts end)
    saveTxAll()
    addNotif("✏ Transacción actualizada")
    G.tx_edit_modal = nil
end

local function saveTxNewModal()
    local m = G.tx_new_modal
    if not m then return end

    local new_ts = os.time({year = m.cal_year, month = m.cal_month, day = m.cal_day,
                             hour = m.clock_h, min = m.clock_m, sec = 0})
    local nt = {
        ts      = new_ts,
        monto   = tonumber(G.text_inputs["txn_monto"]) or 0,
        plan    = G.text_inputs["txn_plan"] or "",
        cliente = G.text_inputs["txn_cliente"] or "",
        tipo    = G.text_inputs["txn_tipo"] or "registro",
        hora    = string.format("%02d:%02d", m.clock_h, m.clock_m),
    }
    table.insert(G.transactions, nt)
    table.sort(G.transactions, function(a, b) return a.ts < b.ts end)
    saveTxAll()
    addNotif("➕ Nueva transacción creada")
    G.tx_new_modal = nil
end

-- ============= TRANSACCIONES: MINI CALENDAR + CLOCK WIDGETS =============

local function drawMiniCal(modal, prefix, dx, dy, dw)
    -- prefix: "txe_" or "txn_"
    local cal_w, cal_h = dw, 220
    rr(dx, dy, cal_w, cal_h, 8, C.card2)
    setColor(C.border)
    rrLine(dx, dy, cal_w, cal_h, 8)

    -- Nav row
    local nav_y = dy + 8
    local prev_hov = hover(dx + 8, nav_y, 26, 22)
    local next_hov = hover(dx + cal_w - 34, nav_y, 26, 22)
    drawButton(dx + 8, nav_y, 26, 22, "‹", C.btn_cancel, C.white, G.fonts.small, 4, prev_hov)
    drawButton(dx + cal_w - 34, nav_y, 26, 22, "›", C.btn_cancel, C.white, G.fonts.small, 4, next_hov)

    local mname = MONTH_NAMES[modal.cal_month] or tostring(modal.cal_month)
    setColor(C.yellow)
    love.graphics.setFont(G.fonts.small)
    love.graphics.printf(mname .. " " .. tostring(modal.cal_year), dx + 36, nav_y + 3, cal_w - 72, "center")

    local cell_w = math.floor((cal_w - 16) / 7)
    local cell_h = 24
    local grid_x = dx + 8
    local grid_y = dy + 38

    -- Day headers
    for i, dn in ipairs(DAY_SHORT) do
        setColor(C.dim)
        love.graphics.setFont(G.fonts.tiny)
        love.graphics.printf(dn, grid_x + (i - 1) * cell_w, grid_y, cell_w, "center")
    end

    local first_wday = ((os.date("*t", os.time({year = modal.cal_year, month = modal.cal_month, day = 1, hour = 12, min = 0, sec = 0})).wday + 5) % 7)
    local total_days = daysInMonth(modal.cal_year, modal.cal_month)
    local day = 1
    for row = 0, 5 do
        for col = 0, 6 do
            local idx = row * 7 + col
            local bx = grid_x + col * cell_w
            local by2 = grid_y + 16 + row * cell_h
            if idx >= first_wday and day <= total_days then
                local active = modal.cal_day == day
                rr(bx + 1, by2 + 1, cell_w - 2, cell_h - 2, 4, active and C.sidebar_sel or C.card)
                setColor(active and C.white or C.white)
                love.graphics.setFont(G.fonts.tiny)
                love.graphics.printf(tostring(day), bx, by2 + 5, cell_w, "center")
                day = day + 1
            end
        end
        if day > total_days then break end
    end
end

local function drawMiniClock(modal, dx, dy, dw)
    local cw, ch = dw, 90
    rr(dx, dy, cw, ch, 8, C.card2)
    setColor(C.border)
    rrLine(dx, dy, cw, ch, 8)

    setColor(C.white)
    love.graphics.setFont(G.fonts.normal)
    love.graphics.printf("Hora", dx, dy + 8, cw, "center")

    local time_str = string.format("%02d:%02d", modal.clock_h, modal.clock_m)
    setColor(C.yellow)
    love.graphics.setFont(G.fonts.large)
    love.graphics.printf(time_str, dx, dy + 30, cw, "center")

    -- Hour +/-
    local bw = 24
    local hx = dx + cw / 2 - 60
    local hy = dy + 58

    drawButton(hx,      hy, bw, 22, "−", C.btn_cancel, C.white, G.fonts.normal, 4, hover(hx, hy, bw, 22))
    setColor(C.gray)
    love.graphics.setFont(G.fonts.tiny)
    love.graphics.printf("H", hx + bw + 2, hy + 4, 16, "center")
    drawButton(hx + bw + 18, hy, bw, 22, "+", C.btn_green, C.white, G.fonts.normal, 4, hover(hx + bw + 18, hy, bw, 22))

    -- Min +/-
    local mx2 = dx + cw / 2 + 10
    drawButton(mx2,          hy, bw, 22, "−", C.btn_cancel, C.white, G.fonts.normal, 4, hover(mx2, hy, bw, 22))
    setColor(C.gray)
    love.graphics.setFont(G.fonts.tiny)
    love.graphics.printf("M", mx2 + bw + 2, hy + 4, 16, "center")
    drawButton(mx2 + bw + 18, hy, bw, 22, "+", C.btn_green, C.white, G.fonts.normal, 4, hover(mx2 + bw + 18, hy, bw, 22))
end

-- ============= TRANSACCIONES: EDIT / NEW MODAL =============

local function drawTxModal(modal, is_new)
    if not modal then return end
    local mx2, my2 = love.mouse.getPosition()

    setColor({0, 0, 0}, 0.65)
    love.graphics.rectangle("fill", 0, 0, W, H)

    local dw, dh = 660, 480
    local dx, dy = (W - dw) / 2, (H - dh) / 2
    rr(dx, dy, dw, dh, 10, C.card)
    setColor(C.border)
    rrLine(dx, dy, dw, dh, 10)

    local title = is_new and "➕ Nueva Transacción" or "✏ Editar Transacción"
    setColor(is_new and C.green or C.yellow)
    love.graphics.setFont(G.fonts.medium)
    love.graphics.printf(title, dx, dy + 14, dw, "center")

    local prefix = is_new and "txn_" or "txe_"
    local fx, fy = dx + 18, dy + 52
    local fw = 290

    -- Left column: text fields
    setColor(C.dim)
    love.graphics.setFont(G.fonts.small)
    love.graphics.print("Cliente", fx, fy)
    drawInput(fx, fy + 16, fw, 30, prefix .. "cliente", "Nombre del cliente...")

    love.graphics.print("Plan / concepto", fx, fy + 58)
    drawInput(fx, fy + 74, fw, 30, prefix .. "plan", "Ej: Mensual, Especial...")

    love.graphics.print("Monto ($)", fx, fy + 116)
    drawInput(fx, fy + 132, 120, 30, prefix .. "monto", "0")

    -- Date / time display + toggle buttons
    local dt_label = string.format("%02d/%02d/%04d  %02d:%02d",
        modal.cal_day, modal.cal_month, modal.cal_year,
        modal.clock_h, modal.clock_m)
    setColor(C.gray)
    love.graphics.setFont(G.fonts.small)
    love.graphics.print("Fecha y hora", fx, fy + 178)

    rr(fx, fy + 194, fw, 30, 5, C.input_bg)
    setColor(C.white)
    love.graphics.setFont(G.fonts.normal)
    love.graphics.print(dt_label, fx + 8, fy + 200)

    love.graphics.print("Tipo", fx + 136, fy + 116)
    drawDropdown(fx + 136, fy + 132, fw - 136, 30, prefix .. "tipo", {"registro", "renovacion", "agenda", "otro"})

    local cal_btn_hov  = hover(fx + fw + 6,      fy + 194, 50, 30)
    local clk_btn_hov  = hover(fx + fw + 62,     fy + 194, 50, 30)
    drawButton(fx + fw + 6,  fy + 194, 50, 30, "U", modal.show_cal   and C.blue or C.card2, C.white, G.fonts.normal, 5, cal_btn_hov)
    drawButton(fx + fw + 62, fy + 194, 50, 30, "O", modal.show_clock and C.blue or C.card2, C.white, G.fonts.normal, 5, clk_btn_hov)

    -- Right column: calendar / clock
    local rx = dx + dw - 310
    local ry = dy + 52

    if modal.show_cal then
        drawMiniCal(modal, prefix, rx, ry, 286)
    elseif modal.show_clock then
        drawMiniClock(modal, rx, ry, 286)
    else
        -- Info card
        rr(rx, ry, 286, 120, 8, C.card2)
        setColor(C.gray)
        love.graphics.setFont(G.fonts.small)
        love.graphics.printf("Usa 📅 para cambiar la fecha\ny 🕐 para ajustar la hora.", rx + 12, ry + 20, 262, "left")
        setColor(C.dim)
        love.graphics.setFont(G.fonts.tiny)
        love.graphics.printf("Los cambios se reflejan al guardar.", rx + 12, ry + 80, 262, "left")
    end

    -- Buttons
    local cancel_hov = hover(dx + dw - 290, dy + dh - 50, 130, 36)
    local save_hov   = hover(dx + dw - 148, dy + dh - 50, 130, 36)
    drawButton(dx + dw - 290, dy + dh - 50, 130, 36, "Cancelar",  C.btn_cancel, C.white, G.fonts.normal, 6, cancel_hov)
    drawButton(dx + dw - 148, dy + dh - 50, 130, 36, "✓ Guardar", C.btn_green,  C.white, G.fonts.normal, 6, save_hov)
end

-- ============= TRANSACCIONES: DELETE CONFIRM =============

local function drawTxDeleteConfirm()
    local info = G.tx_delete_confirm
    if not info then return end
    local t = G.transactions[info.idx]
    if not t then G.tx_delete_confirm = nil; return end

    setColor({0, 0, 0}, 0.68)
    love.graphics.rectangle("fill", 0, 0, W, H)

    local dw, dh = 460, 230
    local dx, dy = (W - dw) / 2, (H - dh) / 2
    rr(dx, dy, dw, dh, 10, C.card)
    setColor(C.border)
    rrLine(dx, dy, dw, dh, 10)

    setColor(C.red)
    love.graphics.setFont(G.fonts.medium)
    if info.stage == 1 then
        love.graphics.printf("⚠  Eliminar transacción", dx, dy + 16, dw, "center")
    else
        love.graphics.printf("⚠  ¿Confirmar eliminación?", dx, dy + 16, dw, "center")
    end

    setColor(C.white)
    love.graphics.setFont(G.fonts.small)
    local d = os.date("*t", t.ts or os.time())
    local msg = string.format("Cliente: %s\nMonto: $%s   Plan: %s\nFecha: %s  %s",
        t.cliente or "—", tostring(t.monto or 0), t.plan or "—",
        dateStr(d), t.hora or "")
    love.graphics.printf(msg, dx + 18, dy + 60, dw - 36, "center")

    if info.stage == 2 then
        setColor(C.orange)
        love.graphics.setFont(G.fonts.tiny)
        love.graphics.printf("Esta es la segunda confirmación. La acción es irreversible.", dx + 18, dy + 150, dw - 36, "center")
    end

    local left_lbl  = info.stage == 1 and "Cancelar" or "Volver"
    local right_lbl = info.stage == 1 and "Siguiente" or "Eliminar"
    local lhov = hover(dx + 50,         dy + dh - 50, 130, 36)
    local rhov = hover(dx + dw - 180,   dy + dh - 50, 130, 36)
    drawButton(dx + 50,       dy + dh - 50, 130, 36, left_lbl,  C.btn_cancel, C.white, G.fonts.normal, 6, lhov)
    drawButton(dx + dw - 180, dy + dh - 50, 130, 36, right_lbl, info.stage == 1 and C.yellow or C.red, C.white, G.fonts.normal, 6, rhov)
end

-- ============= PANTALLA: TRANSACCIONES =============

local function drawTransacciones()
    local ox, oy = SIDEBAR_W + 15, HEADER_H + 8
    local aw = W - SIDEBAR_W - 25

    -- Title
    setColor(C.white)
    love.graphics.setFont(G.fonts.large)
    love.graphics.print("GESTIÓN DE TRANSACCIONES", ox, oy + 4)

    -- Summary badge
    local total_income = 0
    for _, t in ipairs(G.transactions) do total_income = total_income + (t.monto or 0) end
    setColor(C.green)
    love.graphics.setFont(G.fonts.normal)
    love.graphics.print(string.format("Total acumulado: $%d", math.floor(total_income)), ox + 4, oy + 34)

    -- Search bar
    local search_x = ox + aw - 320
    drawInput(search_x, oy + 2, 305, 33, "tx_search", "🔍 Buscar cliente, plan, tipo...")

    -- New transaction button
    local new_hov = hover(ox + aw - 470, oy + 2, 140, 33)
    drawButton(ox + aw - 470, oy + 2, 140, 33, "+ Nueva Tx", C.btn_green, C.white, G.fonts.normal, 5, new_hov)

    -- Table area
    local ty = oy + 56
    local th = H - ty - 10
    rr(ox, ty, aw, th, 8, C.card)

    -- Column headers
    local cols = {ox + 10, ox + 90, ox + 280, ox + 420, ox + 520, ox + 630, ox + 740}
    local hdrs = {"#", "Fecha/Hora", "Cliente", "Plan", "Monto", "Tipo", "Acciones"}
    setColor(C.gray)
    love.graphics.setFont(G.fonts.small)
    for i, h in ipairs(hdrs) do
        love.graphics.print(h, cols[i], ty + 10)
    end
    setColor(C.border)
    love.graphics.setLineWidth(0.5)
    love.graphics.line(ox + 4, ty + 28, ox + aw - 4, ty + 28)
    love.graphics.setLineWidth(1)

    -- Filter & sort (newest first)
    local sv = (G.text_inputs["tx_search"] or ""):lower()
    local filtered = {}
    for i, t in ipairs(G.transactions) do
        local match = sv == ""
            or (t.cliente or ""):lower():find(sv, 1, true)
            or (t.plan or ""):lower():find(sv, 1, true)
            or (t.tipo or ""):lower():find(sv, 1, true)
        if match then
            table.insert(filtered, {orig_idx = i, tx = t})
        end
    end
    -- Reverse for newest-first display
    local display = {}
    for i = #filtered, 1, -1 do
        table.insert(display, filtered[i])
    end

    local rh = 48
    local sc = G.scroll.transacciones or 0
    love.graphics.setScissor(ox + 2, ty + 30, aw - 4, th - 34)

    for disp_i, item in ipairs(display) do
        local t   = item.tx
        local ry  = ty + 32 + (disp_i - 1) * rh - sc
        if ry + rh < ty + 32 then goto cont_tx end
        if ry > ty + th      then break end

        -- Row bg
        local tipo = (t.tipo or "registro"):lower()
        local row_bg
        if tipo == "renovacion" then
            row_bg = disp_i % 2 == 0 and {0.06, 0.10, 0.07} or {0.07, 0.11, 0.08}
        else
            row_bg = disp_i % 2 == 0 and C.row_b or C.row_a
        end
        setColor(row_bg)
        love.graphics.rectangle("fill", ox + 4, ry, aw - 8, rh - 2, 4, 4)

        -- Index (from end)
        setColor(C.dim)
        love.graphics.setFont(G.fonts.tiny)
        love.graphics.print(tostring(#G.transactions - item.orig_idx + 1), cols[1], ry + 18)

        -- Date / time
        local d = os.date("*t", t.ts or os.time())
        setColor(C.white)
        love.graphics.setFont(G.fonts.small)
        love.graphics.print(dateStr(d), cols[2], ry + 6)
        setColor(C.gray)
        love.graphics.setFont(G.fonts.tiny)
        love.graphics.print(t.hora or "--:--", cols[2], ry + 26)

        -- Client
        setColor(C.white)
        love.graphics.setFont(G.fonts.normal)
        love.graphics.print(t.cliente or "—", cols[3], ry + 14)

        -- Plan badge
        local pc = t.plan == "Mensual" and C.blue or (t.plan == "Semanal" and C.cyan or C.yellow)
        rr(cols[4], ry + 12, 90, 18, 4, pc)
        setColor(C.white)
        love.graphics.setFont(G.fonts.tiny)
        love.graphics.printf(t.plan or "—", cols[4], ry + 15, 90, "center")

        -- Amount
        setColor(C.green)
        love.graphics.setFont(G.fonts.normal)
        love.graphics.print(string.format("$%d", math.floor(t.monto or 0)), cols[5], ry + 14)

        -- Type badge
        local tc = tipo == "renovacion" and C.cyan or (tipo == "agenda" and C.purple or C.blue)
        rr(cols[6], ry + 12, 86, 18, 4, tc)
        setColor(C.white)
        love.graphics.setFont(G.fonts.tiny)
        love.graphics.printf(tipo, cols[6], ry + 15, 86, "center")

        -- Action buttons: Edit, Delete
        local e_hov = hover(cols[7],      ry + 10, 56, 24)
        local d_hov = hover(cols[7] + 62, ry + 10, 26, 24)
        drawButton(cols[7],      ry + 10, 56, 24, "Editar", C.sidebar_sel,      C.white, G.fonts.tiny, 4, e_hov)
        drawButton(cols[7] + 62, ry + 10, 26, 24, "D",       {0.55, 0.1, 0.1},   C.white, G.fonts.tiny, 4, d_hov)

        ::cont_tx::
    end
    love.graphics.setScissor()

    -- Row count
    setColor(C.dim)
    love.graphics.setFont(G.fonts.tiny)
    love.graphics.print(string.format("%d transacción(es) mostrada(s) de %d total", #display, #G.transactions), ox + 10, ty + th - 16)
end

-- ============= SIDEBAR + HEADER =============
local function drawSidebar()
    local mx, my = love.mouse.getPosition()
    rr(0, 0, SIDEBAR_W, H, 0, C.sidebar_bg)

    -- Logo
    rr(10, 10, 36, 36, 6, C.sidebar_sel)
    setColor(C.white)
    love.graphics.setFont(G.fonts.large)
    love.graphics.print("G", 20, 12)
    
    setColor(C.white)
    love.graphics.setFont(G.fonts.medium)
    love.graphics.print("GymManager", 54, 11)
    
    setColor(C.dim)
    love.graphics.setFont(G.fonts.tiny)
    love.graphics.print("Gestión de Clientes", 54, 30)
    
    setColor(C.border)
    love.graphics.setLineWidth(0.5)
    love.graphics.line(8, 54, SIDEBAR_W - 8, 54)
    love.graphics.setLineWidth(1)

    local navItems = {
        {icon = "🏠", label = "Inicio",   key = "inicio"},
        {icon = "📝", label = "Registro", key = "registro"},
        {icon = "👥", label = "Clientes", key = "clientes"},
        {icon = "📅", label = "Agenda",        key = "agenda"},
        {icon = "💳", label = "Transacciones", key = "transacciones"},
        {icon = "⚙",  label = "Configuración", key = "configuracion"},
        {icon = "ℹ",  label = "Soporte",        key = "soporte"},
    }
    
    for i, item in ipairs(navItems) do
        local ny = 62 + (i - 1) * 50
        local active = G.screen == item.key
        local hov = mx >= 5 and mx <= SIDEBAR_W - 5 and my >= ny and my <= ny + 42
        
        if active then
            rr(5, ny, SIDEBAR_W - 10, 42, 6, C.sidebar_sel)
            setColor(C.white)
            love.graphics.rectangle("fill", SIDEBAR_W - 7, ny + 8, 4, 26, 2, 2)
        elseif hov then
            rr(5, ny, SIDEBAR_W - 10, 42, 6, {0.12, 0.14, 0.22})
        end
        
        setColor(active and C.white or C.gray)
        love.graphics.setFont(G.fonts.normal)
        love.graphics.print(item.icon .. "  " .. item.label, 18, ny + 13)
    end

    -- Cerrar Caja
    local cc_y = H - 62
    local cc_hov = mx >= 8 and mx <= SIDEBAR_W - 8 and my >= cc_y and my <= cc_y + 48
    rr(8, cc_y, SIDEBAR_W - 16, 48, 8, cc_hov and {0.65, 0.08, 0.08} or {0.42, 0.05, 0.05})
    
    setColor(C.white)
    love.graphics.setFont(G.fonts.normal)
    love.graphics.printf("💰 CERRAR CAJA", 8, cc_y + 15, SIDEBAR_W - 16, "center")
end

local function drawHeader()
    rr(SIDEBAR_W, 0, W - SIDEBAR_W, HEADER_H, 0, C.header_bg)
    setColor(C.border)
    love.graphics.setLineWidth(0.5)
    love.graphics.line(SIDEBAR_W, HEADER_H, W, HEADER_H)
    love.graphics.setLineWidth(1)

    local names = {inicio = "Inicio", registro = "Registro", clientes = "Clientes", agenda = "Agenda", transacciones = "Transacciones", configuracion = "Configuración", soporte = "Soporte"}
    setColor(C.dim)
    love.graphics.setFont(G.fonts.small)
    love.graphics.print("GymManager", SIDEBAR_W + 14, 8)
    
    setColor(C.gray)
    love.graphics.print(" › ", SIDEBAR_W + 86, 8)
    
    setColor(C.white)
    love.graphics.setFont(G.fonts.normal)
    love.graphics.print(names[G.screen] or G.screen, SIDEBAR_W + 108, 5)

    setColor(C.dim)
    love.graphics.setFont(G.fonts.small)
    love.graphics.print(G.date_str .. "   " .. G.time_str, SIDEBAR_W + 14, 30)

    setColor(C.gray)
    love.graphics.setFont(G.fonts.small)
    love.graphics.print("🔔  Admin  |  Cerrar Sesión", W - 185, 18)
    
    if #G.notifs > 0 then
        setColor(C.red)
        love.graphics.circle("fill", W - 194, 13, 7)
        setColor(C.white)
        love.graphics.setFont(G.fonts.tiny)
        love.graphics.print(tostring(math.min(#G.notifs, 9)), W - 198, 8)
    end
end

-- ============= DIALOGS =============

local function drawConfirmDialog()
    if G.pending_action then
        drawPendingActionDialog()
    else
        drawCloseSummaryDialog()
    end
end


local function drawNewNoteDialog()
    local mx, my = love.mouse.getPosition()
    setColor({0, 0, 0}, 0.62)
    love.graphics.rectangle("fill", 0, 0, W, H)

    local amount_count = noteAmountCount("new")
    local base_h = 290
    local dh = base_h + math.max(0, amount_count - 1) * 44
    local dw = 500
    local dx, dy = (W - dw) / 2, (H - dh) / 2

    rr(dx, dy, dw, dh, 10, C.card)
    setColor(C.border)
    rrLine(dx, dy, dw, dh, 10)

    setColor(C.white)
    love.graphics.setFont(G.fonts.medium)
    love.graphics.print("Nueva Anotación", dx + 14, dy + 14)

    setColor(C.dim)
    love.graphics.setFont(G.fonts.small)
    love.graphics.print("Texto:", dx + 14, dy + 50)
    drawInput(dx + 14, dy + 65, dw - 28, 34, "new_note_text", "Escribir la anotación...")

    love.graphics.print("Día:", dx + 14, dy + 114)
    for d = 0, 6 do
        local bx2 = dx + 14 + d * 57
        local active = (G.new_note_day or 0) == d
        rr(bx2, dy + 130, 52, 24, 4, active and C.sidebar_sel or C.card2)
        setColor(C.white)
        love.graphics.setFont(G.fonts.tiny)
        love.graphics.printf(DAY_SHORT[d + 1], bx2, dy + 136, 52, "center")
    end

    love.graphics.setFont(G.fonts.small)
    love.graphics.print("Hora:", dx + 14, dy + 170)
    drawInput(dx + 60, dy + 165, 58, 28, "new_note_hour", "8")

    love.graphics.print("Color:", dx + 140, dy + 170)
    local nc_list = {"blue", "green", "yellow", "red"}
    for i, nc in ipairs(nc_list) do
        local cbx = dx + 200 + (i - 1) * 38
        setColor(NOTE_COLORS[nc])
        love.graphics.circle("fill", cbx + 32, dy + 179, 10)
        if (G.new_note_color or "blue") == nc then
            setColor(C.white)
            love.graphics.setLineWidth(2)
            love.graphics.circle("line", cbx + 32, dy + 179, 13)
            love.graphics.setLineWidth(1)
        end
    end

    -- love.graphics.setFont(G.fonts.small)
    -- love.graphics.print("Montos:", dx + 14, dy + 205)
    -- local row_y = dy + 222
    -- for i = 1, amount_count do
    --     local key = "new_note_amount_" .. i
    --     drawInput(dx + 14, row_y, dw - 82, 30, key, "0")
    --     local plus_x = dx + dw - 58
    --     rr(plus_x, row_y, 22, 30, 4, C.btn_green)
    --     setColor(C.white)
    --     love.graphics.setFont(G.fonts.normal)
    --     love.graphics.printf("+", plus_x, row_y + 4, 22, "center")
    --     row_y = row_y + 38
    -- end

    local total = 0
    for _, v in ipairs(collectNoteAmounts("new")) do total = total + v end
    setColor(total >= 0 and C.green or C.red)
    love.graphics.setFont(G.fonts.small)
    love.graphics.print("Total: " .. noteMoneyLabel(total), dx + 14, dy + dh - 84)

    local c_h = hover(dx + dw - 270, dy + dh - 52, 120, 38)
    local s_h = hover(dx + dw - 138, dy + dh - 52, 122, 38)

    drawButton(dx + dw - 270, dy + dh - 52, 120, 38, "Cancelar", C.btn_cancel, C.white, G.fonts.normal, 6, c_h)
    drawButton(dx + dw - 138, dy + dh - 52, 122, 38, "✓ Guardar", C.btn_green, C.white, G.fonts.normal, 6, s_h)
end

local function drawEditNoteDialog()
    local action = G.edit_note_modal
    if not action or not action.note then return end
    local note = action.note
    local mx, my = love.mouse.getPosition()
    setColor({0, 0, 0}, 0.62)
    love.graphics.rectangle("fill", 0, 0, W, H)

    local amount_count = noteAmountCount("edit")
    local base_h = 356
    local dh = base_h + math.max(0, amount_count - 1) * 44
    local dw = 530
    local dx, dy = (W - dw) / 2, (H - dh) / 2

    rr(dx, dy, dw, dh, 10, C.card)
    setColor(C.border)
    rrLine(dx, dy, dw, dh, 10)

    setColor(C.yellow)
    love.graphics.setFont(G.fonts.medium)
    love.graphics.print("✏  Editar anotación", dx + 14, dy + 14)

    setColor(C.gray)
    love.graphics.setFont(G.fonts.small)
    love.graphics.print(string.format("Día: %s | Hora: %s", DAY_SHORT[(note.day or 0) + 1] or "—", tostring(note.hour or 8)), dx + 14, dy + 44)

    love.graphics.print("Nombre:", dx + 14, dy + 74)
    drawInput(dx + 14, dy + 90, dw - 28, 34, "edit_note_text", "Nombre de la nota")

    love.graphics.print("Hora:", dx + 14, dy + 136)
    drawInput(dx + 60, dy + 131, 58, 28, "edit_note_hour", "8")

    love.graphics.print("Color:", dx + 140, dy + 136)
    local nc_list = {"blue", "green", "yellow", "red"}
    for i, nc in ipairs(nc_list) do
        local cbx = dx + 200 + (i - 1) * 38
        setColor(NOTE_COLORS[nc])
        love.graphics.circle("fill", cbx + 12, dy + 145, 10)
        if (G.text_inputs["edit_note_color"] or note.color or "blue") == nc then
            setColor(C.white)
            love.graphics.setLineWidth(2)
            love.graphics.circle("line", cbx + 12, dy + 145, 13)
            love.graphics.setLineWidth(1)
        end
    end

    love.graphics.setFont(G.fonts.small)
    love.graphics.print("Montos:", dx + 14, dy + 170)
    local row_y = dy + 188
    for i = 1, amount_count do
        local key = "edit_note_amount_" .. i
        drawInput(dx + 14, row_y, dw - 82, 30, key, "0")
        local remove_x = dx + dw - 58
        rr(remove_x, row_y, 22, 30, 4, C.red)
        setColor(C.white)
        love.graphics.setFont(G.fonts.normal)
        love.graphics.printf("−", remove_x, row_y + 3, 22, "center")
        row_y = row_y + 38
    end

    rr(dx + 14, row_y + 2, 120, 24, 4, C.btn_green)
    setColor(C.white)
    love.graphics.setFont(G.fonts.small)
    love.graphics.printf("+ Añadir monto", dx + 14, row_y + 6, 120, "center")

    local total = noteTotal(note)
    setColor(total >= 0 and C.green or C.red)
    love.graphics.setFont(G.fonts.small)
    love.graphics.print("Total: " .. noteMoneyLabel(total), dx + 14, dy + dh - 84)

    setColor(C.dim)
    love.graphics.setFont(G.fonts.tiny)
    love.graphics.printf("Puedes agregar más montos con + y quitar con −, con confirmación.", dx + 14, dy + dh - 64, dw - 28, "left")

    local c_h = hover(dx + dw - 270, dy + dh - 52, 120, 38)
    local s_h = hover(dx + dw - 138, dy + dh - 52, 122, 38)

    drawButton(dx + dw - 270, dy + dh - 52, 120, 38, "Cancelar", C.btn_cancel, C.white, G.fonts.normal, 6, c_h)
    drawButton(dx + dw - 138, dy + dh - 52, 122, 38, "✓ Guardar", C.btn_green, C.white, G.fonts.normal, 6, s_h)
end

local function drawNoteAmountConfirmDialog()
    local action = G.note_amount_confirm
    local modal = G.edit_note_modal
    if not action or not modal then return end
    setColor({0, 0, 0}, 0.70)
    love.graphics.rectangle("fill", 0, 0, W, H)

    local dw, dh = 420, 190
    local dx, dy = (W - dw) / 2, (H - dh) / 2
    rr(dx, dy, dw, dh, 10, C.card)
    setColor(C.border)
    rrLine(dx, dy, dw, dh, 10)

    setColor(C.red)
    love.graphics.setFont(G.fonts.medium)
    love.graphics.printf("¿Eliminar este monto?", dx, dy + 16, dw, "center")

    setColor(C.white)
    love.graphics.setFont(G.fonts.small)
    love.graphics.printf(string.format("Monto: %s", noteMoneyLabel(action.amount or 0)), dx + 18, dy + 56, dw - 36, "center")
    love.graphics.printf("Esta acción no se puede deshacer.", dx + 18, dy + 78, dw - 36, "center")

    local c_h = hover(dx + 46, dy + dh - 52, 120, 36)
    local ok_h = hover(dx + dw - 166, dy + dh - 52, 120, 36)
    drawButton(dx + 46, dy + dh - 52, 120, 36, "Cancelar", C.btn_cancel, C.white, G.fonts.normal, 6, c_h)
    drawButton(dx + dw - 166, dy + dh - 52, 120, 36, "Eliminar", C.red, C.white, G.fonts.normal, 6, ok_h)
end

local function drawRenewDialog()
    local action = G.renew_modal
    if not action then return end

    local client = getClientById(action.client_id)
    if not client then
        G.renew_modal = nil
        return
    end

    setColor({0, 0, 0}, 0.62)
    love.graphics.rectangle("fill", 0, 0, W, H)

    local dw, dh = 560, 310
    local dx, dy = (W - dw) / 2, (H - dh) / 2
    rr(dx, dy, dw, dh, 10, C.card)
    setColor(C.border)
    rrLine(dx, dy, dw, dh, 10)

    setColor(C.yellow)
    love.graphics.setFont(G.fonts.medium)
    love.graphics.printf("🔄 Renovar suscripción", dx, dy + 14, dw, "center")

    setColor(C.white)
    love.graphics.setFont(G.fonts.small)
    love.graphics.printf((client.nombres or "") .. " " .. (client.apellidos or ""), dx + 16, dy + 48, dw - 32, "center")

    setColor(C.gray)
    love.graphics.setFont(G.fonts.small)
    love.graphics.printf("Elige la suscripción que se renovará:", dx + 16, dy + 74, dw - 32, "center")

    local plan_w = (dw - 36) / 2
    local plan_h = 34
    local row1_y = dy + 104
    local row2_y = dy + 150
    local plans1 = {"Diario", "Semanal"}
    local plans2 = {"Quincenal", "Mensual"}

    for i, p in ipairs(plans1) do
        local bx = dx + 18 + (i - 1) * plan_w
        local active = action.plan == p
        rr(bx, row1_y, plan_w - 9, plan_h, 6, active and C.sidebar_sel or C.card2)
        setColor(C.white)
        love.graphics.setFont(G.fonts.small)
        love.graphics.printf(p, bx, row1_y + 8, plan_w - 9, "center")
        setColor(C.dim)
        love.graphics.setFont(G.fonts.tiny)
        love.graphics.printf("$" .. tostring(PLAN_PRICES[p] or 0), bx, row1_y + 20, plan_w - 9, "center")
    end

    for i, p in ipairs(plans2) do
        local bx = dx + 18 + (i - 1) * plan_w
        local active = action.plan == p
        rr(bx, row2_y, plan_w - 9, plan_h, 6, active and C.sidebar_sel or C.card2)
        setColor(C.white)
        love.graphics.setFont(G.fonts.small)
        love.graphics.printf(p, bx, row2_y + 8, plan_w - 9, "center")
        setColor(C.dim)
        love.graphics.setFont(G.fonts.tiny)
        love.graphics.printf("$" .. tostring(PLAN_PRICES[p] or 0), bx, row2_y + 20, plan_w - 9, "center")
    end

    local special_y = dy + 196
    local special_active = action.plan == SPECIAL_PLAN
    rr(dx + 18, special_y, dw - 36, 56, 6, special_active and C.sidebar_sel or C.card2)
    setColor(C.white)
    love.graphics.setFont(G.fonts.small)
    love.graphics.print("ESPECIAL", dx + 28, special_y + 7)
    setColor(C.dim)
    love.graphics.setFont(G.fonts.tiny)
    love.graphics.print("Días", dx + 28, special_y + 27)
    love.graphics.print("Precio/día", dx + 150, special_y + 27)

    local days_key = "renew_special_days"
    local price_key = "renew_special_price"
    G.text_inputs[days_key] = G.text_inputs[days_key] or tostring(action.special_days or 1)
    G.text_inputs[price_key] = G.text_inputs[price_key] or tostring(action.special_price or 0)
    drawInput(dx + 70, special_y + 20, 92, 28, days_key, "1")
    drawInput(dx + 232, special_y + 20, 120, 28, price_key, "0")

    setColor(C.gray)
    love.graphics.setFont(G.fonts.tiny)
    love.graphics.printf("Se cobrará días × precio/día.", dx + 364, special_y + 27, 170, "left")

    local c_hov = hover(dx + 102, dy + dh - 50, 120, 34)
    local r_hov = hover(dx + dw - 222, dy + dh - 50, 120, 34)
    drawButton(dx + 102, dy + dh - 50, 120, 34, "Cancelar", C.btn_cancel, C.white, G.fonts.normal, 6, c_hov)
    drawButton(dx + dw - 222, dy + dh - 50, 120, 34, "Renovar", C.btn_green, C.white, G.fonts.normal, 6, r_hov)
end

local function applyRenewModal()
    local action = G.renew_modal
    if not action then return end
    local client = getClientById(action.client_id)
    if not client then
        G.renew_modal = nil
        return
    end

    client.plan = action.plan or client.plan or "Mensual"
    client.plan_dias = 0
    client.plan_precio_dia = 0
    if client.plan == SPECIAL_PLAN then
        client.plan_dias = math.max(1, math.floor(tonumber(G.text_inputs.renew_special_days) or tonumber(action.special_days) or 1))
        client.plan_precio_dia = tonumber(G.text_inputs.renew_special_price) or tonumber(action.special_price) or 0
    end
    local st = os.time()
    client.start_ts = st
    client.expiry = subscriptionExpiry(client.plan, st, client.plan_dias)
    saveClients()
    saveTx(planAmount(client.plan, client.plan_dias, client.plan_precio_dia), client.plan, (client.nombres or "") .. " " .. (client.apellidos or ""), "renovacion")
    addNotif(string.format("🔄 Suscripción de %s renovada (%s)", client.nombres or "Cliente", client.plan or "—"))
    G.renew_modal = nil
end

local function drawEditClientDialog()
    local action = G.edit_client_modal
    if not action then return end

    local client = getClientById(action.client_id)
    if not client then
        G.edit_client_modal = nil
        return
    end

    local dw, dh = 760, 560
    local dx, dy = (W - dw) / 2, (H - dh) / 2

    setColor({0, 0, 0}, 0.62)
    love.graphics.rectangle("fill", 0, 0, W, H)
    rr(dx, dy, dw, dh, 10, C.card)
    setColor(C.border)
    rrLine(dx, dy, dw, dh, 10)

    setColor(C.white)
    love.graphics.setFont(G.fonts.medium)
    love.graphics.printf("✏ Editar cliente", dx, dy + 14, dw, "center")

    setColor(C.gray)
    love.graphics.setFont(G.fonts.small)
    love.graphics.printf((client.nombres or "") .. " " .. (client.apellidos or ""), dx, dy + 40, dw, "center")

    local fx, fy = dx + 18, dy + 72
    local fw = 330

    love.graphics.setFont(G.fonts.small)
    setColor(C.dim)
    love.graphics.print("Teléfono", fx, fy)
    drawInput(fx, fy + 16, fw, 32, "edit_phone", "Número de teléfono...")

    love.graphics.print("Peso (kg)", fx, fy + 62)
    drawInput(fx, fy + 78, 150, 32, "edit_weight", "70")

    love.graphics.print("Estado de salud", fx + 170, fy + 62)
    drawInput(fx + 170, fy + 78, fw - 170, 32, "edit_health", "Estado de salud...")

    love.graphics.print("Suscripción", fx, fy + 124)
    local bw = 78
    local gap = 6
    local by = fy + 140
    for i, p in ipairs(PLAN_OPTIONS) do
        local bx = fx + (i - 1) * (bw + gap)
        local active = (G.edit_plan or client.plan or "Mensual") == p
        rr(bx, by, bw, 32, 6, active and C.sidebar_sel or C.card2)
        setColor(C.white)
        love.graphics.setFont(G.fonts.small)
        love.graphics.printf(p, bx, by + 8, bw, "center")
        setColor(C.dim)
        love.graphics.setFont(G.fonts.tiny)
        love.graphics.printf("$" .. tostring(PLAN_PRICES[p] or 0), bx, by + 20, bw, "center")
    end

    local special_x = fx
    local special_y = fy + 178
    local special_w = fw
    local active_plan = G.edit_plan or client.plan or "Mensual"
    local special_active = active_plan == SPECIAL_PLAN
    rr(special_x, special_y, special_w, 52, 6, special_active and C.sidebar_sel or C.card2)
    setColor(C.white)
    love.graphics.setFont(G.fonts.small)
    love.graphics.print("ESPECIAL", special_x + 8, special_y + 7)
    setColor(C.dim)
    love.graphics.setFont(G.fonts.tiny)
    love.graphics.print("Días", special_x + 8, special_y + 26)
    love.graphics.print("Precio/día", special_x + 120, special_y + 26)
    G.text_inputs.edit_plan_special_days = G.text_inputs.edit_plan_special_days or tostring(client.plan_dias or 1)
    G.text_inputs.edit_plan_special_price = G.text_inputs.edit_plan_special_price or tostring(client.plan_precio_dia or 0)
    drawInput(special_x + 38, special_y + 19, 76, 28, "edit_plan_special_days", "1")
    drawInput(special_x + 176, special_y + 19, 110, 28, "edit_plan_special_price", "0")

    love.graphics.setFont(G.fonts.small)
    love.graphics.print("Inicio de la suscripción", fx, fy + 242)
    setColor(C.gray)
    local start_ts = tsFromDateParts(action.cal_year, action.cal_month, action.selected_day or 1)
    love.graphics.printf(dateStr(os.date("*t", start_ts)), fx, fy + 260, fw, "left")
    local exp_ts = subscriptionExpiry(active_plan, start_ts, G.text_inputs.edit_plan_special_days)
    love.graphics.printf("Vence: " .. dateStr(os.date("*t", exp_ts)), fx, fy + 278, fw, "left")
    setColor(C.dim)
    love.graphics.printf("Duración: " .. planDurationLabel(active_plan, G.text_inputs.edit_plan_special_days), fx, fy + 296, fw, "left")

    local cal_x, cal_y = dx + 380, dy + 78
    local cal_w, cal_h = 340, 310
    rr(cal_x, cal_y, cal_w, cal_h, 8, C.card2)
    setColor(C.white)
    love.graphics.setFont(G.fonts.normal)
    love.graphics.print("Mini calendario", cal_x + 12, cal_y + 10)

    local nav_y = cal_y + 34
    local prev_hov = hover(cal_x + 12, nav_y, 28, 24)
    local next_hov = hover(cal_x + cal_w - 40, nav_y, 28, 24)
    drawButton(cal_x + 12, nav_y, 28, 24, "‹", C.btn_cancel, C.white, G.fonts.normal, 4, prev_hov)
    drawButton(cal_x + cal_w - 40, nav_y, 28, 24, "›", C.btn_cancel, C.white, G.fonts.normal, 4, next_hov)

    local month_name = MONTH_NAMES[action.cal_month] or tostring(action.cal_month)
    love.graphics.setFont(G.fonts.small)
    setColor(C.yellow)
    love.graphics.printf(month_name .. " " .. tostring(action.cal_year), cal_x + 46, nav_y + 4, cal_w - 92, "center")

    local grid_x, grid_y = cal_x + 12, cal_y + 70
    local cell_w, cell_h = 42, 30
    for i, dname in ipairs(DAY_SHORT) do
        setColor(C.dim)
        love.graphics.setFont(G.fonts.tiny)
        love.graphics.printf(dname, grid_x + (i - 1) * cell_w, grid_y - 18, cell_w, "center")
    end

    local first_wday = ((os.date("*t", os.time({year = action.cal_year, month = action.cal_month, day = 1, hour = 12, min = 0, sec = 0})).wday + 5) % 7)
    local total_days = daysInMonth(action.cal_year, action.cal_month)
    local day = 1
    for row = 0, 5 do
        for col = 0, 6 do
            local idx = row * 7 + col
            local bx = grid_x + col * cell_w
            local by2 = grid_y + row * cell_h
            if idx >= first_wday and day <= total_days then
                local active = action.selected_day == day
                rr(bx + 1, by2 + 1, cell_w - 3, cell_h - 3, 5, active and C.sidebar_sel or C.card)
                setColor(active and C.white or C.white)
                love.graphics.setFont(G.fonts.small)
                love.graphics.printf(tostring(day), bx, by2 + 7, cell_w - 2, "center")
                day = day + 1
            else
                rr(bx + 1, by2 + 1, cell_w - 3, cell_h - 3, 5, C.card, 0.6)
            end
        end
    end

    setColor(C.dim)
    love.graphics.setFont(G.fonts.tiny)
    love.graphics.printf("Haz clic en una fecha para cambiar el día de inicio.", cal_x + 12, cal_y + cal_h - 22, cal_w - 24, "center")

    local c_hov = hover(dx + 510, dy + dh - 52, 110, 36)
    local s_hov = hover(dx + 632, dy + dh - 52, 110, 36)
    drawButton(dx + 510, dy + dh - 52, 110, 36, "Cancelar", C.btn_cancel, C.white, G.fonts.normal, 6, c_hov)
    drawButton(dx + 632, dy + dh - 52, 110, 36, "Guardar", C.btn_green, C.white, G.fonts.normal, 6, s_hov)
end

local function saveEditClientModal()
    local action = G.edit_client_modal
    if not action then return end
    local client = getClientById(action.client_id)
    if not client then
        G.edit_client_modal = nil
        return
    end

    client.telefono = G.text_inputs.edit_phone or ""
    client.peso = G.text_inputs.edit_weight or ""
    client.estado_salud = G.text_inputs.edit_health or ""
    client.plan = G.edit_plan or client.plan or "Mensual"
    client.plan_dias = 0
    client.plan_precio_dia = 0
    if client.plan == SPECIAL_PLAN then
        client.plan_dias = math.max(1, math.floor(tonumber(G.text_inputs.edit_plan_special_days) or 1))
        client.plan_precio_dia = tonumber(G.text_inputs.edit_plan_special_price) or 0
    end
    client.start_ts = tsFromDateParts(action.cal_year, action.cal_month, action.selected_day or 1)
    client.expiry = subscriptionExpiry(client.plan, client.start_ts, client.plan_dias)
    saveClients()
    addNotif(string.format("✏ %s actualizado correctamente", client.nombres or "Cliente"))
    G.edit_client_modal = nil
end

local function drawBMICalcDialog()
    if not G.show_bmi_calc then return end
    local dw, dh = 420, 280
    local dx, dy = (W - dw) / 2, (H - dh) / 2

    setColor({0, 0, 0}, 0.62)
    love.graphics.rectangle("fill", 0, 0, W, H)
    rr(dx, dy, dw, dh, 10, C.card)
    setColor(C.border)
    rrLine(dx, dy, dw, dh, 10)

    setColor(C.white)
    love.graphics.setFont(G.fonts.medium)
    love.graphics.printf("⚖ Calculadora de IMC", dx, dy + 14, dw, "center")

    setColor(C.gray)
    love.graphics.setFont(G.fonts.small)
    love.graphics.printf("Introduce peso y estatura para ver el resultado según la OMS.", dx + 18, dy + 42, dw - 36, "center")

    local fx = dx + 24
    local fw = dw - 48
    love.graphics.setFont(G.fonts.small)
    setColor(C.dim)
    love.graphics.print("Peso (kg)", fx, dy + 78)
    drawInput(fx, dy + 94, fw / 2 - 8, 32, "bmi_weight", "70")

    love.graphics.print("Estatura (cm)", fx + fw / 2 + 8, dy + 78)
    drawInput(fx + fw / 2 + 8, dy + 94, fw / 2 - 8, 32, "bmi_height", "170")

    local weight = tonumber(G.text_inputs.bmi_weight or "")
    local height_cm = tonumber(G.text_inputs.bmi_height or "")
    local bmi = nil
    local classification = "Ingresa los datos."
    if weight and height_cm and weight > 0 and height_cm > 0 then
        local h = height_cm / 100
        bmi = weight / (h * h)
        classification = bmiClass(bmi)
    end

    rr(dx + 24, dy + 140, dw - 48, 76, 8, C.card2)
    setColor(C.yellow)
    love.graphics.setFont(G.fonts.normal)
    love.graphics.print("Resultado", dx + 36, dy + 150)

    setColor(C.white)
    love.graphics.setFont(G.fonts.large)
    if bmi then
        love.graphics.print(string.format("%.1f", bmi), dx + 36, dy + 172)
    else
        love.graphics.print("—", dx + 36, dy + 172)
    end

    setColor(C.gray)
    love.graphics.setFont(G.fonts.small)
    love.graphics.print(classification, dx + 130, dy + 178)

    local c_hov = hover(dx + 150, dy + dh - 52, 120, 34)
    local o_hov = hover(dx + 250, dy + dh - 52, 120, 34)
    drawButton(dx + 150, dy + dh - 52, 120, 34, "Cerrar", C.btn_cancel, C.white, G.fonts.normal, 6, c_hov)
    drawButton(dx + 250, dy + dh - 52, 120, 34, "Listo", C.btn_green, C.white, G.fonts.normal, 6, o_hov)
end

-- ============= LOVE CALLBACKS =============
function love.load()
    W, H = love.graphics.getDimensions()
    love.window.setMode(W, H, {resizable = true, minwidth = 1100, minheight = 620})
    love.window.setTitle("GymManager — Sistema de Gestión de Gimnasio")

    G.fonts.tiny   = love.graphics.newFont(11)
    G.fonts.small  = love.graphics.newFont(13)
    G.fonts.normal = love.graphics.newFont(14)
    G.fonts.medium = love.graphics.newFont(17)
    G.fonts.large  = love.graphics.newFont(21)

    G.text_inputs = {
        nombres = "", 
        apellidos = "", 
        telefono = "",
        plan = "Mensual", 
        tipo_pago = "Efectivo",
        estado_salud = "", 
        peso = "",
        cl_search = "", 
        ag_search = "",
        tx_search = "",
        txe_monto = "0", txe_plan = "", txe_cliente = "", txe_tipo = "registro",
        txn_monto = "0", txn_plan = "", txn_cliente = "", txn_tipo = "registro",
        new_note_text = "", 
        new_note_hour = "8",
        bmi_weight = "",
        bmi_height = "",
        edit_phone = "",
        edit_weight = "",
        edit_health = "",
        set_price_Diario = tostring(DEFAULT_SETTINGS.plan_prices.Diario),
        set_price_Semanal = tostring(DEFAULT_SETTINGS.plan_prices.Semanal),
        set_price_Mensual = tostring(DEFAULT_SETTINGS.plan_prices.Mensual),
        set_notif_limit = tostring(DEFAULT_SETTINGS.notif_limit),
    }

    G.cl_filter      = "todos"
    G.ag_view        = "semana"
    G.new_note_day   = 0
    G.new_note_color = "blue"
    G.req_state      = {medical = false, contract = false, terms = false}
    G.pending_action = nil
    G.show_close_summary = false
    G.close_summary = nil

    loadSettings()
    G.text_inputs.set_price_Diario = tostring(PLAN_PRICES.Diario or 0)
    G.text_inputs.set_price_Semanal = tostring(PLAN_PRICES.Semanal or 0)
    G.text_inputs.set_price_Mensual = tostring(PLAN_PRICES.Mensual or 0)
    G.text_inputs.set_notif_limit = tostring((G.settings and G.settings.notif_limit) or DEFAULT_SETTINGS.notif_limit)

    loadClients()
    loadTx()
    loadNotes()

    addNotif("✅ Sistema iniciado correctamente")
    addNotif("👋 Bienvenido a GymManager v1.0")

    -- Expiry warnings
    for _, c in ipairs(G.clients) do
        if c.expiry then
            local dl = (c.expiry - os.time()) / 86400
            if dl > 0 and dl <= 3 then
                addNotif(string.format("⚠ %s %s vence en %d día(s)", c.nombres, c.apellidos, math.ceil(dl)))
            end
        end
    end
end

function love.update(dt)
    G.dt = G.dt + dt
    local d = os.date("*t")
    G.time_str = string.format("%02d:%02d:%02d", d.hour, d.min, d.sec)
    G.date_str = dateStr(d)
    W, H = love.graphics.getDimensions()
end

function love.draw()
    setColor(C.bg)
    love.graphics.rectangle("fill", 0, 0, W, H)
    
    drawSidebar()
    drawHeader()

    if G.screen == "inicio" then 
        drawInicio()
    elseif G.screen == "registro" then 
        drawRegistro()
    elseif G.screen == "clientes" then 
        drawClientes()
    elseif G.screen == "agenda" then 
        drawAgenda()
    elseif G.screen == "transacciones" then
        drawTransacciones()
    elseif G.screen == "configuracion" then 
        drawConfiguracion()
    elseif G.screen == "soporte" then 
        drawSoporte()
    end

    if G.pending_action or G.show_close_summary then
        drawConfirmDialog()
    end

    if G.renew_modal then
        drawRenewDialog()
    end

    if G.edit_client_modal then
        drawEditClientDialog()
    end

    if G.show_bmi_calc then
        drawBMICalcDialog()
    end

    if G.show_new_note then
        drawNewNoteDialog()
    end

    if G.edit_note_modal then
        drawEditNoteDialog()
    end

    if G.note_amount_confirm then
        drawNoteAmountConfirmDialog()
    end

    -- Transaction modals
    if G.tx_delete_confirm then
        drawTxDeleteConfirm()
    end
    if G.tx_edit_modal then
        drawTxModal(G.tx_edit_modal, false)
    end
    if G.tx_new_modal then
        drawTxModal(G.tx_new_modal, true)
    end

    -- FPS
    setColor(C.dim)
    love.graphics.setFont(G.fonts.tiny)
    love.graphics.print(string.format("FPS:%d", love.timer.getFPS()), W - 44, H - 14)
end


function love.textinput(t)
    if G.focus and G.text_inputs and G.text_inputs[G.focus] ~= nil then
        editorInsertText(G.focus, t)
    end
end

function love.keypressed(key)
    local ctrl = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")
    local shift = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")

    if G.focus and G.text_inputs and G.text_inputs[G.focus] ~= nil then
        if editorHandleShortcut(key, ctrl, shift) then
            return
        end
    end

    if key == "escape" then
        if G.pending_action then
            if (G.pending_action.stage or 1) == 2 then
                G.pending_action.stage = 1
            else
                G.pending_action = nil
            end
        elseif G.show_close_summary then
            G.show_close_summary = false
            G.close_summary = nil
        elseif G.renew_modal then
            G.renew_modal = nil
        elseif G.edit_client_modal then
            G.edit_client_modal = nil
        elseif G.show_bmi_calc then
            G.show_bmi_calc = false
        elseif G.note_amount_confirm then
            G.note_amount_confirm = nil
        elseif G.edit_note_modal then
            G.edit_note_modal = nil
        elseif G.show_new_note then
            G.show_new_note = false
        elseif G.tx_delete_confirm then
            if (G.tx_delete_confirm.stage or 1) == 2 then
                G.tx_delete_confirm.stage = 1
            else
                G.tx_delete_confirm = nil
            end
        elseif G.tx_edit_modal then
            G.tx_edit_modal = nil
        elseif G.tx_new_modal then
            G.tx_new_modal = nil
        elseif G.dropdown then
            G.dropdown = nil
        else
            G.focus = nil
        end
        return

    elseif key == "return" or key == "kpenter" then
        if G.pending_action then
            if (G.pending_action.stage or 1) == 1 then
                G.pending_action.stage = 2
            else
                executePendingAction()
            end
        elseif G.show_close_summary then
            executeCloseCash()
            G.show_close_summary = false
            G.close_summary = nil
        elseif G.renew_modal then
            applyRenewModal()
        elseif G.edit_client_modal then
            saveEditClientModal()
        elseif G.show_bmi_calc then
            G.show_bmi_calc = false
        elseif G.note_amount_confirm then
            confirmRemoveNoteAmount()
        elseif G.edit_note_modal then
            saveEditNoteFromModal()
        elseif G.show_new_note then
            saveNewNoteFromModal()
        elseif G.tx_delete_confirm then
            local info = G.tx_delete_confirm
            if (info.stage or 1) == 1 then
                info.stage = 2
            else
                table.remove(G.transactions, info.idx)
                saveTxAll()
                addNotif("🗑 Transacción eliminada")
                G.tx_delete_confirm = nil
            end
        elseif G.tx_edit_modal then
            saveTxEditModal()
        elseif G.tx_new_modal then
            saveTxNewModal()
        end
        return

    elseif ctrl and key == "n" then
        startNewRegistration()
        return

    elseif ctrl and key == "s" then
        if G.screen == "configuracion" then
            G.settings.plan_prices.Diario = tonumber(G.text_inputs.set_price_Diario) or PLAN_PRICES.Diario or 0
            G.settings.plan_prices.Semanal = tonumber(G.text_inputs.set_price_Semanal) or PLAN_PRICES.Semanal or 0
            G.settings.plan_prices.Mensual = tonumber(G.text_inputs.set_price_Mensual) or PLAN_PRICES.Mensual or 0
            G.settings.notif_limit = clamp(tonumber(G.text_inputs.set_notif_limit) or 25, 1, 99)
            syncPlanPrices()
            saveSettings()
            addNotif("💾 Configuración guardada")
        else
            addNotif("ℹ Ctrl+S guarda la configuración en la pestaña de ajustes")
        end
        return

    elseif ctrl and key == "m" then
        G.screen = "agenda"
        openNewNoteModal(0, 8, "blue")
        return

    elseif key == "tab" then
        local fields
        if G.show_bmi_calc then
            fields = {"bmi_weight", "bmi_height"}
        elseif G.edit_client_modal then
            fields = {"edit_phone", "edit_weight", "edit_health"}
        elseif G.edit_note_modal then
            fields = {"edit_note_text", "edit_note_hour"}
            for i = 1, noteAmountCount("edit") do
                table.insert(fields, "edit_note_amount_" .. i)
            end
        elseif G.show_new_note then
            fields = {"new_note_text", "new_note_hour"}
            for i = 1, noteAmountCount("new") do
                table.insert(fields, "new_note_amount_" .. i)
            end
        elseif G.screen == "configuracion" then
            fields = {"set_price_Diario", "set_price_Semanal", "set_price_Mensual", "set_notif_limit"}
        else
            fields = {"nombres", "apellidos", "telefono", "estado_salud", "peso"}
        end
        for i, f in ipairs(fields) do
            if G.focus == f then
                G.focus = fields[i % #fields + 1]
                editorState(G.focus).cursor = utf8_len_safe(G.text_inputs[G.focus] or "") + 1
                editorState(G.focus).anchor = editorState(G.focus).cursor
                return
            end
        end

    elseif key == "f1" then
        G.screen = "inicio"
    elseif key == "f2" then
        startNewRegistration()
    elseif key == "f3" then
        G.screen = "clientes"
    elseif key == "f4" then
        G.screen = "agenda"
    elseif key == "f5" then
        G.screen = "transacciones"
    elseif key == "f6" then
        G.screen = "configuracion"
    elseif key == "f7" then
        G.screen = "soporte"
    elseif key == "f8" then
        loadClients()
        loadTx()
        loadNotes()
        addNotif("🔄 Datos recargados")
    end
end
function love.mousepressed(x, y, btn)
    if btn ~= 1 then return end
    local mx, my = x, y

    -- Dialogs take priority
    if G.pending_action then
        local action = G.pending_action
        local dx, dy, dw, dh = actionModalRects(action.stage or 1)
        local left_x, right_x = dx + 42, dx + dw - 172
        local by = dy + dh - 54

        if hover(left_x, by, 120, 38) then
            if (action.stage or 1) == 2 then
                action.stage = 1
            else
                G.pending_action = nil
            end
            return
        end

        if hover(right_x, by, 130, 38) then
            if (action.stage or 1) == 1 then
                action.stage = 2
            else
                executePendingAction()
            end
            return
        end
        return
    end

    if G.show_close_summary then
        local dw, dh = 560, 440
        local dx, dy = (W - dw) / 2, (H - dh) / 2

        if hover(dx + 260, dy + dh - 54, 120, 38) then
            G.show_close_summary = false
            G.close_summary = nil
            return
        end
        if hover(dx + 390, dy + dh - 54, 140, 38) then
            executeCloseCash()
            G.show_close_summary = false
            G.close_summary = nil
            return
        end
        return
    end

    if G.renew_modal then
        local dw, dh = 560, 310
        local dx, dy = (W - dw) / 2, (H - dh) / 2
        local client = getClientById(G.renew_modal.client_id)

        if client then
            local plan_w = (dw - 36) / 2
            local row1_y = dy + 104
            local row2_y = dy + 150
            local plans1 = {"Diario", "Semanal"}
            local plans2 = {"Quincenal", "Mensual"}
            for i, p in ipairs(plans1) do
                local bx = dx + 18 + (i - 1) * plan_w
                if hover(bx, row1_y, plan_w - 9, 34) then
                    G.renew_modal.plan = p
                    return
                end
            end
            for i, p in ipairs(plans2) do
                local bx = dx + 18 + (i - 1) * plan_w
                if hover(bx, row2_y, plan_w - 9, 34) then
                    G.renew_modal.plan = p
                    return
                end
            end
            if hover(dx + 18, dy + 196, dw - 36, 56) then
                G.renew_modal.plan = SPECIAL_PLAN
                if hover(dx + 70, dy + 216, 92, 28) then
                    focusTextInputAt("renew_special_days", dx + 70, dy + 216, 92, 28, mx, my)
                    return
                elseif hover(dx + 232, dy + 216, 120, 28) then
                    focusTextInputAt("renew_special_price", dx + 232, dy + 216, 120, 28, mx, my)
                    return
                end
                return
            end
        end

        if hover(dx + 102, dy + dh - 50, 120, 34) then
            G.renew_modal = nil
            return
        end
        if hover(dx + dw - 222, dy + dh - 50, 120, 34) then
            applyRenewModal()
            return
        end
        return
    end

    if G.edit_client_modal then
        local dw, dh = 760, 560
        local dx, dy = (W - dw) / 2, (H - dh) / 2
        local fx, fy = dx + 18, dy + 72
        local fw = 330
        local cal_x, cal_y = dx + 380, dy + 78
        local cal_w, cal_h = 340, 310
        local cal = G.edit_client_modal

        -- Text inputs
        if hover(fx, fy + 16, fw, 32) then
            focusTextInputAt("edit_phone", fx, fy + 16, fw, 32, mx, my)
            return
        elseif hover(fx, fy + 78, 150, 32) then
            focusTextInputAt("edit_weight", fx, fy + 78, 150, 32, mx, my)
            return
        elseif hover(fx + 170, fy + 78, fw - 170, 32) then
            focusTextInputAt("edit_health", fx + 170, fy + 78, fw - 170, 32, mx, my)
            return
        elseif hover(fx + 38, fy + 197, 76, 28) then
            G.edit_plan = SPECIAL_PLAN
            focusTextInputAt("edit_plan_special_days", fx + 38, fy + 197, 76, 28, mx, my)
            return
        elseif hover(fx + 176, fy + 197, 110, 28) then
            G.edit_plan = SPECIAL_PLAN
            focusTextInputAt("edit_plan_special_price", fx + 176, fy + 197, 110, 28, mx, my)
            return
        end

        -- Plan buttons
        local bw = 78
        local gap = 6
        local by = fy + 140
        for i, p in ipairs(PLAN_OPTIONS) do
            if hover(fx + (i - 1) * (bw + gap), by, bw, 32) then
                G.edit_plan = p
                return
            end
        end
        if hover(fx, fy + 178, fw, 52) then
            G.edit_plan = SPECIAL_PLAN
            if hover(fx + 38, fy + 197, 76, 28) then
                focusTextInputAt("edit_plan_special_days", fx + 38, fy + 197, 76, 28, mx, my)
                return
            elseif hover(fx + 176, fy + 197, 110, 28) then
                focusTextInputAt("edit_plan_special_price", fx + 176, fy + 197, 110, 28, mx, my)
                return
            end
            return
        end

        -- Calendar nav
        local nav_y = cal_y + 34
        if hover(cal_x + 12, nav_y, 28, 24) then
            cal.cal_month = cal.cal_month - 1
            if cal.cal_month < 1 then
                cal.cal_month = 12
                cal.cal_year = cal.cal_year - 1
            end
            local md = daysInMonth(cal.cal_year, cal.cal_month)
            cal.selected_day = math.min(cal.selected_day or 1, md)
            return
        elseif hover(cal_x + cal_w - 40, nav_y, 28, 24) then
            cal.cal_month = cal.cal_month + 1
            if cal.cal_month > 12 then
                cal.cal_month = 1
                cal.cal_year = cal.cal_year + 1
            end
            local md = daysInMonth(cal.cal_year, cal.cal_month)
            cal.selected_day = math.min(cal.selected_day or 1, md)
            return
        end

        -- Calendar day grid
        local grid_x, grid_y = cal_x + 12, cal_y + 70
        local cell_w, cell_h = 42, 30
        local first_wday = ((os.date("*t", os.time({year = cal.cal_year, month = cal.cal_month, day = 1, hour = 12, min = 0, sec = 0})).wday + 5) % 7)
        local total_days = daysInMonth(cal.cal_year, cal.cal_month)
        local day = 1
        for row = 0, 5 do
            for col = 0, 6 do
                local idx = row * 7 + col
                if idx >= first_wday and day <= total_days then
                    local bx = grid_x + col * cell_w
                    local by2 = grid_y + row * cell_h
                    if hover(bx + 1, by2 + 1, cell_w - 3, cell_h - 3) then
                        cal.selected_day = day
                        return
                    end
                    day = day + 1
                end
            end
        end

        if hover(dx + 510, dy + dh - 52, 110, 36) then
            G.edit_client_modal = nil
            return
        end
        if hover(dx + 632, dy + dh - 52, 110, 36) then
            saveEditClientModal()
            return
        end
        return
    end

    if G.show_bmi_calc then
        local dw, dh = 420, 280
        local dx, dy = (W - dw) / 2, (H - dh) / 2
        local fx = dx + 24
        local fw = dw - 48

        if hover(fx, dy + 94, fw / 2 - 8, 32) then
            focusTextInputAt("bmi_weight", fx, dy + 94, fw / 2 - 8, 32, mx, my)
            return
        elseif hover(fx + fw / 2 + 8, dy + 94, fw / 2 - 8, 32) then
            focusTextInputAt("bmi_height", fx + fw / 2 + 8, dy + 94, fw / 2 - 8, 32, mx, my)
            return
        end

        if hover(dx + 150, dy + dh - 52, 120, 34) then
            G.show_bmi_calc = false
            return
        end
        if hover(dx + 250, dy + dh - 52, 120, 34) then
            G.show_bmi_calc = false
            return
        end
        return
    end

    if G.show_new_note then
        local dw, dh = 460, 290
        local dx, dy = (W - dw) / 2, (H - dh) / 2

        -- Day buttons
        for d = 0, 6 do
            if hover(dx + 14 + d * 57, dy + 130, 52, 24) then
                G.new_note_day = d
            end
        end

        -- Color buttons
        local nc_list = {"blue", "green", "yellow", "red"}
        for i, nc in ipairs(nc_list) do
            if hover(dx + 200 + (i - 1) * 38, dy + 168, 28, 24) then
                G.new_note_color = nc
            end
        end

        -- Inputs
        if hover(dx + 14, dy + 65, dw - 28, 34) then
            G.focus = "new_note_text"
        elseif hover(dx + 60, dy + 165, 58, 28) then
            G.focus = "new_note_hour"
        else
            G.focus = nil
        end

        -- Buttons
        if hover(dx + dw - 270, dy + dh - 52, 120, 38) then
            G.show_new_note = false
        elseif hover(dx + dw - 138, dy + dh - 52, 122, 38) then
            saveNewNoteFromModal()
        end
        return
    end


    if G.note_amount_confirm then
        local dw, dh = 420, 190
        local dx, dy = (W - dw) / 2, (H - dh) / 2
        if hover(dx + 46, dy + dh - 52, 120, 36) then
            G.note_amount_confirm = nil
            return
        end
        if hover(dx + dw - 166, dy + dh - 52, 120, 36) then
            confirmRemoveNoteAmount()
            return
        end
        return
    end

    if G.edit_note_modal then
        local amount_count = noteAmountCount("edit")
        local base_h = 356
        local dh = base_h + math.max(0, amount_count - 1) * 44
        local dw = 530
        local dx, dy = (W - dw) / 2, (H - dh) / 2

        if hover(dx + dw - 270, dy + dh - 52, 120, 38) then
            G.edit_note_modal = nil
            return
        end
        if hover(dx + dw - 138, dy + dh - 52, 122, 38) then
            saveEditNoteFromModal()
            return
        end

        local row_y = dy + 188
        for i = 1, amount_count do
            local key = "edit_note_amount_" .. i
            if hover(dx + 14, row_y, dw - 82, 30) then
                G.focus = key
            end
            local remove_x = dx + dw - 58
            if hover(remove_x, row_y, 22, 30) then
                requestRemoveNoteAmount(i)
                return
            end
            row_y = row_y + 38
        end

        if hover(dx + 14, row_y + 2, 120, 24) then
            local cnt = amount_count + 1
            setNoteAmountCount("edit", cnt)
            local key = "edit_note_amount_" .. cnt
            G.text_inputs[key] = "0"
            local st = editorState(key)
            st.cursor = 2
            st.anchor = 2
            return
        end

        if hover(dx + 14, dy + 90, dw - 28, 34) then
            G.focus = "edit_note_text"
        elseif hover(dx + 60, dy + 131, 58, 28) then
            G.focus = "edit_note_hour"
        else
            for i = 1, 4 do
                local cbx = dx + 200 + (i - 1) * 38
                if hover(cbx, dy + 134, 24, 24) then
                    local colors = {"blue", "green", "yellow", "red"}
                    G.text_inputs["edit_note_color"] = colors[i]
                    return
                end
            end
        end
        return
    end

    if G.show_new_note then
        local amount_count = noteAmountCount("new")
        local base_h = 290
        local dh = base_h + math.max(0, amount_count - 1) * 44
        local dw = 500
        local dx, dy = (W - dw) / 2, (H - dh) / 2

        for d = 0, 6 do
            if hover(dx + 14 + d * 57, dy + 130, 52, 24) then
                G.new_note_day = d
            end
        end

        local nc_list = {"blue", "green", "yellow", "red"}
        for i, nc in ipairs(nc_list) do
            if hover(dx + 200 + (i - 1) * 38, dy + 168, 28, 24) then
                G.new_note_color = nc
            end
        end

        if hover(dx + 14, dy + 65, dw - 28, 34) then
            G.focus = "new_note_text"
        elseif hover(dx + 60, dy + 165, 58, 28) then
            G.focus = "new_note_hour"
        else
            local row_y = dy + 222
            for i = 1, amount_count do
                local key = "new_note_amount_" .. i
                if hover(dx + 14, row_y, dw - 82, 30) then
                    G.focus = key
                    break
                end
                row_y = row_y + 38
            end
        end

        local row_y = dy + 222
        for i = 1, amount_count do
            local plus_x = dx + dw - 58
            if hover(plus_x, row_y, 22, 30) then
                local cnt = amount_count + 1
                setNoteAmountCount("new", cnt)
                local key = "new_note_amount_" .. cnt
                G.text_inputs[key] = "0"
                local st = editorState(key)
                st.cursor = 2
                st.anchor = 2
                return
            end
            row_y = row_y + 38
        end

        if hover(dx + dw - 270, dy + dh - 52, 120, 38) then
            G.show_new_note = false
        elseif hover(dx + dw - 138, dy + dh - 52, 122, 38) then
            saveNewNoteFromModal()
        end
        return
    end

    -- Transaction delete confirm
    if G.tx_delete_confirm then
        local info = G.tx_delete_confirm
        local dw, dh = 460, 230
        local dx, dy = (W - dw) / 2, (H - dh) / 2
        if hover(dx + 50, dy + dh - 50, 130, 36) then
            if (info.stage or 1) == 2 then info.stage = 1
            else G.tx_delete_confirm = nil end
            return
        end
        if hover(dx + dw - 180, dy + dh - 50, 130, 36) then
            if (info.stage or 1) == 1 then
                info.stage = 2
            else
                table.remove(G.transactions, info.idx)
                saveTxAll()
                addNotif("🗑 Transacción eliminada")
                G.tx_delete_confirm = nil
            end
            return
        end
        return
    end

    -- Transaction edit modal
    if G.tx_edit_modal then
        local m = G.tx_edit_modal
        local dw, dh = 660, 480
        local dx, dy = (W - dw) / 2, (H - dh) / 2
        local fx, fy = dx + 18, dy + 52
        local fw = 290
        local prefix = "txe_"

        if hover(dx + dw - 290, dy + dh - 50, 130, 36) then G.tx_edit_modal = nil; return end
        if hover(dx + dw - 148, dy + dh - 50, 130, 36) then saveTxEditModal(); return end

        -- Toggle calendar / clock
        if hover(fx + fw + 6, fy + 194, 50, 30) then m.show_cal = not m.show_cal; m.show_clock = false; return end
        if hover(fx + fw + 62, fy + 194, 50, 30) then m.show_clock = not m.show_clock; m.show_cal = false; return end

        -- Calendar interactions
        if m.show_cal then
            local rx = dx + dw - 310
            local ry2 = dy + 52
            local cal_w = 286
            local nav_y = ry2 + 8
            if hover(rx + 8, nav_y, 26, 22) then
                m.cal_month = m.cal_month - 1
                if m.cal_month < 1 then m.cal_month = 12; m.cal_year = m.cal_year - 1 end
                local md = daysInMonth(m.cal_year, m.cal_month)
                m.cal_day = math.min(m.cal_day, md)
                return
            end
            if hover(rx + cal_w - 34, nav_y, 26, 22) then
                m.cal_month = m.cal_month + 1
                if m.cal_month > 12 then m.cal_month = 1; m.cal_year = m.cal_year + 1 end
                local md = daysInMonth(m.cal_year, m.cal_month)
                m.cal_day = math.min(m.cal_day, md)
                return
            end
            local cell_w2 = math.floor((cal_w - 16) / 7)
            local cell_h2 = 24
            local grid_x2 = rx + 8
            local grid_y2 = ry2 + 38
            local first_wday2 = ((os.date("*t", os.time({year = m.cal_year, month = m.cal_month, day = 1, hour = 12, min = 0, sec = 0})).wday + 5) % 7)
            local total_days2 = daysInMonth(m.cal_year, m.cal_month)
            local day2 = 1
            for row2 = 0, 5 do
                for col2 = 0, 6 do
                    local idx2 = row2 * 7 + col2
                    local bx2 = grid_x2 + col2 * cell_w2
                    local by2 = grid_y2 + 16 + row2 * cell_h2
                    if idx2 >= first_wday2 and day2 <= total_days2 then
                        if hover(bx2 + 1, by2 + 1, cell_w2 - 2, cell_h2 - 2) then
                            m.cal_day = day2
                            return
                        end
                        day2 = day2 + 1
                    end
                end
                if day2 > total_days2 then break end
            end
        end

        -- Clock interactions
        if m.show_clock then
            local rx = dx + dw - 310
            local ry2 = dy + 52
            local cw2 = 286
            local bw2 = 24
            local hx2 = rx + cw2 / 2 - 60
            local hy2 = ry2 + 58
            local mx3 = rx + cw2 / 2 + 10
            if hover(hx2, hy2, bw2, 22) then m.clock_h = (m.clock_h - 1 + 24) % 24; return end
            if hover(hx2 + bw2 + 18, hy2, bw2, 22) then m.clock_h = (m.clock_h + 1) % 24; return end
            if hover(mx3, hy2, bw2, 22) then m.clock_m = (m.clock_m - 1 + 60) % 60; return end
            if hover(mx3 + bw2 + 18, hy2, bw2, 22) then m.clock_m = (m.clock_m + 1) % 60; return end
        end

        -- Type dropdown
        if hover(fx + 136, fy + 132, fw - 136, 30) then
            G.dropdown = G.dropdown == prefix .. "tipo" and nil or (prefix .. "tipo")
            return
        elseif G.dropdown == prefix .. "tipo" then
            local tipo_opts = {"registro", "renovacion", "agenda", "otro"}
            local ddy2 = fy + 162 + 2
            for i, opt in ipairs(tipo_opts) do
                if hover(fx + 136 + 2, ddy2 + 4 + (i - 1) * 30, (fw - 136) - 4, 28) then
                    G.text_inputs[prefix .. "tipo"] = opt
                    G.dropdown = nil
                    return
                end
            end
        end

        -- Text inputs
        if hover(fx, fy + 16, fw, 30) then
            focusTextInputAt(prefix .. "cliente", fx, fy + 16, fw, 30, mx, my); return
        elseif hover(fx, fy + 74, fw, 30) then
            focusTextInputAt(prefix .. "plan", fx, fy + 74, fw, 30, mx, my); return
        elseif hover(fx, fy + 132, 120, 30) then
            focusTextInputAt(prefix .. "monto", fx, fy + 132, 120, 30, mx, my); return
        end
        G.focus = nil
        return
    end

    -- Transaction new modal (same layout as edit)
    if G.tx_new_modal then
        local m = G.tx_new_modal
        local dw, dh = 660, 480
        local dx, dy = (W - dw) / 2, (H - dh) / 2
        local fx, fy = dx + 18, dy + 52
        local fw = 290
        local prefix = "txn_"

        if hover(dx + dw - 290, dy + dh - 50, 130, 36) then G.tx_new_modal = nil; return end
        if hover(dx + dw - 148, dy + dh - 50, 130, 36) then saveTxNewModal(); return end

        if hover(fx + fw + 6, fy + 194, 50, 30) then m.show_cal = not m.show_cal; m.show_clock = false; return end
        if hover(fx + fw + 62, fy + 194, 50, 30) then m.show_clock = not m.show_clock; m.show_cal = false; return end

        if m.show_cal then
            local rx = dx + dw - 310
            local ry2 = dy + 52
            local cal_w = 286
            local nav_y = ry2 + 8
            if hover(rx + 8, nav_y, 26, 22) then
                m.cal_month = m.cal_month - 1
                if m.cal_month < 1 then m.cal_month = 12; m.cal_year = m.cal_year - 1 end
                local md = daysInMonth(m.cal_year, m.cal_month)
                m.cal_day = math.min(m.cal_day, md)
                return
            end
            if hover(rx + cal_w - 34, nav_y, 26, 22) then
                m.cal_month = m.cal_month + 1
                if m.cal_month > 12 then m.cal_month = 1; m.cal_year = m.cal_year + 1 end
                local md = daysInMonth(m.cal_year, m.cal_month)
                m.cal_day = math.min(m.cal_day, md)
                return
            end
            local cell_w2 = math.floor((cal_w - 16) / 7)
            local cell_h2 = 24
            local grid_x2 = rx + 8
            local grid_y2 = ry2 + 38
            local first_wday2 = ((os.date("*t", os.time({year = m.cal_year, month = m.cal_month, day = 1, hour = 12, min = 0, sec = 0})).wday + 5) % 7)
            local total_days2 = daysInMonth(m.cal_year, m.cal_month)
            local day2 = 1
            for row2 = 0, 5 do
                for col2 = 0, 6 do
                    local idx2 = row2 * 7 + col2
                    local bx2 = grid_x2 + col2 * cell_w2
                    local by2 = grid_y2 + 16 + row2 * cell_h2
                    if idx2 >= first_wday2 and day2 <= total_days2 then
                        if hover(bx2 + 1, by2 + 1, cell_w2 - 2, cell_h2 - 2) then
                            m.cal_day = day2
                            return
                        end
                        day2 = day2 + 1
                    end
                end
                if day2 > total_days2 then break end
            end
        end

        if m.show_clock then
            local rx = dx + dw - 310
            local ry2 = dy + 52
            local cw2 = 286
            local bw2 = 24
            local hx2 = rx + cw2 / 2 - 60
            local hy2 = ry2 + 58
            local mx3 = rx + cw2 / 2 + 10
            if hover(hx2, hy2, bw2, 22) then m.clock_h = (m.clock_h - 1 + 24) % 24; return end
            if hover(hx2 + bw2 + 18, hy2, bw2, 22) then m.clock_h = (m.clock_h + 1) % 24; return end
            if hover(mx3, hy2, bw2, 22) then m.clock_m = (m.clock_m - 1 + 60) % 60; return end
            if hover(mx3 + bw2 + 18, hy2, bw2, 22) then m.clock_m = (m.clock_m + 1) % 60; return end
        end

        if hover(fx + 136, fy + 132, fw - 136, 30) then
            G.dropdown = G.dropdown == prefix .. "tipo" and nil or (prefix .. "tipo")
            return
        elseif G.dropdown == prefix .. "tipo" then
            local tipo_opts = {"registro", "renovacion", "agenda", "otro"}
            local ddy2 = fy + 162 + 2
            for i, opt in ipairs(tipo_opts) do
                if hover(fx + 136 + 2, ddy2 + 4 + (i - 1) * 30, (fw - 136) - 4, 28) then
                    G.text_inputs[prefix .. "tipo"] = opt
                    G.dropdown = nil
                    return
                end
            end
        end

        if hover(fx, fy + 16, fw, 30) then
            focusTextInputAt(prefix .. "cliente", fx, fy + 16, fw, 30, mx, my); return
        elseif hover(fx, fy + 74, fw, 30) then
            focusTextInputAt(prefix .. "plan", fx, fy + 74, fw, 30, mx, my); return
        elseif hover(fx, fy + 132, 120, 30) then
            focusTextInputAt(prefix .. "monto", fx, fy + 132, 120, 30, mx, my); return
        end
        G.focus = nil
        return
    end

    -- Sidebar navigation
    local navKeys = {"inicio", "registro", "clientes", "agenda", "transacciones", "configuracion", "soporte"}
    for i, key in ipairs(navKeys) do
        local ny = 62 + (i - 1) * 50
        if mx >= 5 and mx <= SIDEBAR_W - 5 and my >= ny and my <= ny + 42 then
            if key == "registro" then
                startNewRegistration()
            else
                G.screen = key
                G.focus = nil
                G.dropdown = nil
            end
            return
        end
    end

    -- Cerrar Caja
    if mx >= 8 and mx <= SIDEBAR_W - 8 and my >= H - 62 and my <= H - 14 then
        openCloseCashSummary()
        return
    end

    -- Screen-specific
    if G.screen == "registro" then
        local ox, oy2 = SIDEBAR_W + 18, HEADER_H + 8
        local aw2 = W - SIDEBAR_W - 30
        local form_w2 = aw2 - 215
        local fw2 = form_w2 - 28
        local form_y2 = oy2 + 64
        local fx2 = ox + 14

        G.dropdown = nil
        G.focus = nil

        -- Text inputs
        local inputs = {
            {key = "nombres",      x = fx2,               y = form_y2 + 52,  w = fw2,             h = 34},
            {key = "apellidos",    x = fx2,               y = form_y2 + 114, w = fw2,             h = 34},
            {key = "telefono",     x = fx2,               y = form_y2 + 176, w = fw2,             h = 34},
            {key = "estado_salud", x = fx2,               y = form_y2 + 238, w = fw2 / 2 - 6,     h = 34},
            {key = "peso",         x = fx2 + fw2 / 2 + 6, y = form_y2 + 238, w = fw2 / 2 - 6,     h = 34},
        }
        for _, inp in ipairs(inputs) do
            if hover(inp.x, inp.y, inp.w, inp.h) then
                focusTextInputAt(inp.key, inp.x, inp.y, inp.w, inp.h, mx, my)
                return
            end
        end

        -- Plan buttons
        local pw = (fw2 - 3 * 8) / 4
        local by = form_y2 + 330
        for i, p in ipairs(PLAN_OPTIONS) do
            local bx = fx2 + (i - 1) * (pw + 8)
            if hover(bx, by, pw, 50) then
                G.text_inputs["plan"] = p
                return
            end
        end
        local sx = fx2
        local sy = by + 58
        local sw = fw2
        if hover(sx, sy, sw, 58) then
            G.text_inputs["plan"] = SPECIAL_PLAN
            if hover(sx + 38, sy + 20, 76, 28) then
                focusTextInputAt("plan_special_days", sx + 38, sy + 20, 76, 28, mx, my)
                return
            elseif hover(sx + 176, sy + 20, 110, 28) then
                focusTextInputAt("plan_special_price", sx + 176, sy + 20, 110, 28, mx, my)
                return
            end
            return
        end

        -- Tipo pago dropdown
        if hover(fx2, form_y2 + 408, fw2, 34) then
            G.dropdown = G.dropdown == "tipo_pago" and nil or "tipo_pago"
        elseif G.dropdown == "tipo_pago" then
            local ddy = form_y2 + 408 + 34 + 2
            for i, opt in ipairs(PAGO_OPTIONS) do
                if hover(fx2 + 2, ddy + 4 + (i - 1) * 30, fw2 - 4, 28) then
                    G.text_inputs["tipo_pago"] = opt
                    G.dropdown = nil
                end
            end
        end

        -- Requirement checkboxes
        local px2 = ox + form_w2 + 10
        local py2 = form_y2
        local pw2 = 205
        local ph2 = 200
        local req_y = py2 + ph2 + 8
        local reqs = {
            {key = "medical"},
            {key = "contract"},
            {key = "terms"},
        }
        for i, req in ipairs(reqs) do
            local ry2 = req_y + 30 + (i - 1) * 34
            if hover(px2 + 10, ry2, 18, 18) or hover(px2 + 10, ry2, 150, 18) then
                G.req_state[req.key] = not G.req_state[req.key]
                return
            end
        end

        -- Save / Cancel
        local form_h2 = H - form_y2 - 50
        local btn_y2 = form_y2 + form_h2 - 52

        if hover(fx2, btn_y2, 110, 38) then
            openBmiModal()
            return
        elseif hover(ox + form_w2 - 270, btn_y2, 120, 38) then
            resetRegistrationForm()
            return

        elseif hover(ox + form_w2 - 140, btn_y2, 125, 38) then
            local n2 = G.text_inputs["nombres"] or ""
            if n2 == "" then
                addNotif("⚠ Ingresa al menos el nombre del cliente")
                return
            end
            if not registrationReady() then
                addNotif("⚠ Marca los 3 requisitos antes de guardar")
                return
            end

            local plan2 = G.text_inputs["plan"] or "Mensual"
            local st = os.time()
            local plan_days = 0
            local plan_price_day = 0
            if plan2 == SPECIAL_PLAN then
                plan_days = math.max(1, math.floor(tonumber(G.text_inputs["plan_special_days"]) or 1))
                plan_price_day = tonumber(G.text_inputs["plan_special_price"]) or 0
            end
            local c = {
                id = G.next_id,
                nombres = n2,
                apellidos = G.text_inputs["apellidos"] or "",
                telefono = G.text_inputs["telefono"] or "",
                plan = plan2,
                start_ts = st,
                expiry = subscriptionExpiry(plan2, st, plan_days),
                tipo_pago = G.text_inputs["tipo_pago"] or "Efectivo",
                estado_salud = G.text_inputs["estado_salud"] or "",
                peso = G.text_inputs["peso"] or "",
                req_medico = G.req_state.medical,
                req_contrato = G.req_state.contract,
                req_terminos = G.req_state.terms,
                plan_dias = plan_days,
                plan_precio_dia = plan_price_day,
            }

            G.next_id = G.next_id + 1
            table.insert(G.clients, c)
            saveClients()
            saveTx(planAmount(plan2, plan_days, plan_price_day), plan2, n2 .. " " .. (G.text_inputs["apellidos"] or ""), "registro")

            resetRegistrationForm()

            addNotif(string.format("✅ Cliente %s registrado — Plan %s", n2, plan2))
            G.screen = "clientes"
        end

    elseif G.screen == "clientes" then
        local ox2, oy2 = SIDEBAR_W + 15, HEADER_H + 8
        local aw2 = W - SIDEBAR_W - 25
        G.focus = nil
        G.dropdown = nil

        -- New client button
        if hover(ox2 + aw2 - 390, oy2 + 2, 120, 33) then
            startNewRegistration()
            return
        end

        -- Search input
        if hover(ox2 + aw2 - 260, oy2 + 2, 245, 33) then
            G.focus = "cl_search"
        end

        -- Filter tabs
        local fkeys = {"todos", "activos", "vencidos"}
        for i = 1, 3 do
            if hover(ox2 + (i - 1) * 100, oy2 + 44, 95, 28) then
                G.cl_filter = fkeys[i]
            end
        end

        -- Table rows
        local ty = oy2 + 44 + 36
        local cols = {ox2 + 8, ox2 + 52, ox2 + 102, ox2 + 320, ox2 + 420, ox2 + 570, ox2 + 715, ox2 + 800}
        local sv = (G.text_inputs["cl_search"] or ""):lower()
        local filtered = {}

        for _, c in ipairs(G.clients) do
            local act = isActive(c)
            local mf = G.cl_filter == "todos" or (G.cl_filter == "activos" and act) or (G.cl_filter == "vencidos" and not act)
            local ms = sv == "" or (c.nombres .. " " .. c.apellidos):lower():find(sv, 1, true)
            if mf and ms then
                table.insert(filtered, c)
            end
        end

        table.sort(filtered, function(a, b)
            return (isActive(a) and 1 or 0) > (isActive(b) and 1 or 0)
        end)

        local rh = 54
        local sc = G.scroll.clientes or 0

        for i, c in ipairs(filtered) do
            local ry = ty + 32 + (i - 1) * rh - sc

            if hover(cols[8], ry + 6, 60, 20) then
                openRenewModal(c)
                return
            end

            if hover(cols[8] + 65, ry + 6, 28, 20) then
                openEditClientModal(c)
                return
            end

            if hover(cols[8] + 98, ry + 6, 28, 20) then
                beginClientAction("delete", c)
                return
            end
        end

    elseif G.screen == "agenda" then
        local ox2, oy2 = SIDEBAR_W + 12, HEADER_H + 8
        local aw2 = W - SIDEBAR_W - 20
        G.dropdown = nil

        -- Search
        if hover(ox2 + aw2 - 250, oy2 + 2, 235, 32) then
            G.focus = "ag_search"
        else
            G.focus = nil
        end

        -- View tabs
        local vkeys = {"dia", "semana", "mes"}
        for i = 1, 3 do
            if hover(ox2 + (i - 1) * 78, oy2 + 42, 73, 26) then
                G.ag_view = vkeys[i]
            end
        end

        -- Week nav
        local nav_cx = ox2 + aw2 / 2
        if hover(nav_cx - 140, oy2 + 42, 30, 26) then
            G.ag_week_off = G.ag_week_off - 1
        end
        if hover(nav_cx + 112, oy2 + 42, 30, 26) then
            G.ag_week_off = G.ag_week_off + 1
        end

        -- New note
        if hover(ox2 + aw2 - 140, oy2 + 42, 130, 26) then
            openNewNoteModal(0, 8, "blue")
            return
        end

        -- Note selection
        local gx2, gy2 = ox2, oy2 + 78
        local gw2 = aw2
        local hcw2 = 52
        local dcw2 = (gw2 - hcw2) / 7
        local hour_h2 = 52
        local hdr_h2 = 30
        local sc2 = G.scroll.agenda or 0

        G.ag_selected = nil
        local sv = (G.text_inputs["ag_search"] or ""):lower()
        for _, note in ipairs(G.notes) do
            local txt = (note.text or ""):lower()
            if sv == "" or txt:find(sv, 1, true) then
                local nx2 = gx2 + hcw2 + note.day * dcw2 + 2
                local hy = gy2 + hdr_h2 + (note.hour - 8) * hour_h2 + 2 - sc2

                if hover(nx2, hy, dcw2 - 4, hour_h2 - 4) then
                    G.ag_selected = note
                    local nw2 = dcw2 - 4
                    if hover(nx2 + nw2 - 72, hy + 2, 20, 16) then
                        openEditNoteModal(note, true)
                        return
                    end
                    if hover(nx2 + nw2 - 48, hy + 2, 20, 16) then
                        openEditNoteModal(note)
                        return
                    end
                    if hover(nx2 + nw2 - 24, hy + 2, 20, 16) then
                        for i = #G.notes, 1, -1 do
                            if G.notes[i] == note then
                                table.remove(G.notes, i)
                                break
                            end
                        end
                        saveNotes()
                        G.ag_selected = nil
                        addNotif("🗑 Nota eliminada de la agenda")
                    end
                    return
                end
            end
        end

    elseif G.screen == "configuracion" then
        local ox2, oy2 = SIDEBAR_W + 15, HEADER_H + 8
        local aw2 = W - SIDEBAR_W - 25
        G.dropdown = nil

        local left_w = math.floor((aw2 - 12) * 0.42)
        local right_w = aw2 - left_w - 12

        if hover(ox2 + 12, oy2 + 108, left_w - 24, 32) then
            G.focus = "set_price_Diario"
        elseif hover(ox2 + 12, oy2 + 166, left_w - 24, 32) then
            G.focus = "set_price_Semanal"
        elseif hover(ox2 + 12, oy2 + 224, left_w - 24, 32) then
            G.focus = "set_price_Quincenal"
        elseif hover(ox2 + 12, oy2 + 282, left_w - 24, 32) then
            G.focus = "set_price_Mensual"
        elseif hover(ox2 + 12, oy2 + 482, 150, 32) then
            G.focus = "set_notif_limit"
        else
            G.focus = nil
        end

        local themes = {}
        for i, _ in pairs(THEME_PRESETS) do
            table.insert(themes, i)
        end
        table.sort(themes)

        local tx0 = ox2 + left_w + 24
        local ty0 = oy2 + 100
        local th_view = 150
        local tw = (right_w - 24 - 8) / 2
        local row_h = 66
        local max_scroll = math.max(0, math.ceil(#themes / 2) * row_h - th_view)
        G.scroll.configuracion = clamp(G.scroll.configuracion or 0, 0, max_scroll)

        for i, th in ipairs(themes) do
            local tx = tx0 + ((i - 1) % 2) * (tw + 8)
            local ty = ty0 + math.floor((i - 1) / 2) * row_h - G.scroll.configuracion
            if ty + 58 < ty0 or ty > ty0 + th_view then
                goto continue_theme_click
            end
            if hover(tx, ty, tw, 58) then
                applyTheme(th)
                saveSettings()
                addNotif("🎨 Tema aplicado: " .. th)
                return
            end
            ::continue_theme_click::
        end

        local notif_colors = {"blue", "green", "yellow", "red", "cyan", "purple"}
        for i, nc in ipairs(notif_colors) do
            local bx = ox2 + 12 + (i - 1) * 66
            local by = oy2 + 374
            if hover(bx, by, 60, 26) then
                G.settings.notif_color = nc
                saveSettings()
                addNotif("🔔 Color de notificación: " .. nc)
                return
            end
        end

        if hover(ox2 + aw2 - 260, H - 66, 120, 38) then
            G.settings.plan_prices.Diario = tonumber(G.text_inputs.set_price_Diario) or PLAN_PRICES.Diario or 0
            G.settings.plan_prices.Semanal = tonumber(G.text_inputs.set_price_Semanal) or PLAN_PRICES.Semanal or 0
            G.settings.plan_prices.Quincenal = tonumber(G.text_inputs.set_price_Quincenal) or PLAN_PRICES.Quincenal or 0
            G.settings.plan_prices.Mensual = tonumber(G.text_inputs.set_price_Mensual) or PLAN_PRICES.Mensual or 0
            G.settings.notif_limit = clamp(tonumber(G.text_inputs.set_notif_limit) or 25, 1, 99)
            syncPlanPrices()
            saveSettings()
            G.text_inputs.set_price_Diario = tostring(PLAN_PRICES.Diario or 0)
            G.text_inputs.set_price_Semanal = tostring(PLAN_PRICES.Semanal or 0)
            G.text_inputs.set_price_Quincenal = tostring(PLAN_PRICES.Quincenal or 0)
            G.text_inputs.set_price_Mensual = tostring(PLAN_PRICES.Mensual or 0)
            G.text_inputs.set_notif_limit = tostring(G.settings.notif_limit)
            addNotif("💾 Configuración guardada")
            return
        elseif hover(ox2 + aw2 - 130, H - 66, 120, 38) then
            G.settings = copyTable(DEFAULT_SETTINGS)
            applyTheme(G.settings.theme)
            syncPlanPrices()
            G.text_inputs.set_price_Diario = tostring(PLAN_PRICES.Diario or 0)
            G.text_inputs.set_price_Semanal = tostring(PLAN_PRICES.Semanal or 0)
            G.text_inputs.set_price_Quincenal = tostring(PLAN_PRICES.Quincenal or 0)
            G.text_inputs.set_price_Mensual = tostring(PLAN_PRICES.Mensual or 0)
            G.text_inputs.set_notif_limit = tostring(G.settings.notif_limit)
            saveSettings()
            addNotif("↩ Configuración restaurada")
            return
        end

    elseif G.screen == "transacciones" then
        local ox2, oy2 = SIDEBAR_W + 15, HEADER_H + 8
        local aw2 = W - SIDEBAR_W - 25
        G.dropdown = nil

        -- Search input
        if hover(ox2 + aw2 - 320, oy2 + 2, 305, 33) then
            focusTextInputAt("tx_search", ox2 + aw2 - 320, oy2 + 2, 305, 33, mx, my)
            return
        end

        -- New transaction button
        if hover(ox2 + aw2 - 470, oy2 + 2, 140, 33) then
            openTxNewModal()
            return
        end

        -- Table rows
        local sv = (G.text_inputs["tx_search"] or ""):lower()
        local filtered = {}
        for i, t in ipairs(G.transactions) do
            local match = sv == ""
                or (t.cliente or ""):lower():find(sv, 1, true)
                or (t.plan or ""):lower():find(sv, 1, true)
                or (t.tipo or ""):lower():find(sv, 1, true)
            if match then table.insert(filtered, {orig_idx = i, tx = t}) end
        end
        local display = {}
        for i = #filtered, 1, -1 do table.insert(display, filtered[i]) end

        local ty = oy2 + 56
        local rh = 48
        local sc = G.scroll.transacciones or 0
        local cols = {ox2 + 10, ox2 + 90, ox2 + 280, ox2 + 420, ox2 + 520, ox2 + 630, ox2 + 740}

        for disp_i, item in ipairs(display) do
            local ry = ty + 32 + (disp_i - 1) * rh - sc
            if hover(cols[7], ry + 10, 56, 24) then
                openTxEditModal(item.orig_idx)
                return
            end
            if hover(cols[7] + 62, ry + 10, 26, 24) then
                G.tx_delete_confirm = {idx = item.orig_idx, stage = 1}
                return
            end
        end

    elseif G.screen == "inicio" then
        local ox2, oy2 = SIDEBAR_W + 15, HEADER_H + 10
        local aw2 = W - SIDEBAR_W - 25
        local card_y = oy2 + 40
        local card_h = 80
        local notif_w = 245
        local chart_w = aw2 - notif_w - 16
        local chart_y = card_y + card_h + 12
        local bw, bh = 68, 24
        local mkeys = {"horas", "dias", "meses"}

        for i = 1, 3 do
            local bx2 = ox2 + chart_w - (4 - i) * (bw + 6) - 14
            if hover(bx2, chart_y + 9, bw, bh) then
                G.chart_mode = mkeys[i]
                return
            end
        end
    end
end
function love.wheelmoved(x, y)
    if G.pending_action or G.show_close_summary or G.show_new_note then return end

    if G.screen == "inicio" then
        G.scroll.inicio = clamp((G.scroll.inicio or 0) - y * 28, 0, math.max(0, #G.clients * 48 - 160))
    elseif G.screen == "clientes" then
        G.scroll.clientes = clamp((G.scroll.clientes or 0) - y * 28, 0, math.max(0, #G.clients * 54 - 200))
    elseif G.screen == "transacciones" then
        G.scroll.transacciones = clamp((G.scroll.transacciones or 0) - y * 28, 0, math.max(0, #G.transactions * 48 - 200))
    elseif G.screen == "agenda" then
        G.scroll.agenda = clamp((G.scroll.agenda or 0) - y * 28, 0, 12 * 52 - 180)
    elseif G.screen == "configuracion" then
        local themes = {}
        for i, _ in pairs(THEME_PRESETS) do
            table.insert(themes, i)
        end
        table.sort(themes)
        local row_h = 66
        local th_view = 150
        local max_scroll = math.max(0, math.ceil(#themes / 2) * row_h - th_view)
        G.scroll.configuracion = clamp((G.scroll.configuracion or 0) - y * 28, 0, max_scroll)
    elseif G.screen == "soporte" then
        G.scroll.soporte = clamp((G.scroll.soporte or 0) - y * 28, 0, 500)
    end
end

function love.resize(w, h) 
    W = w
    H = h
end