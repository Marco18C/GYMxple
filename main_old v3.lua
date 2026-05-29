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
    scroll       = {inicio = 0, clientes = 0, agenda = 0, configuracion = 0, soporte = 0},
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
    edit_client_id = nil,
    req_state = {medical = false, contract = false, terms = false},
    time_str     = "", 
    date_str     = "",
    dt           = 0,
}

local PLAN_PRICES  = {Diario = 5, Semanal = 25, Mensual = 80}
local PLAN_OPTIONS = {"Diario", "Semanal", "Mensual"}
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
    plan_prices = {Diario = 5, Semanal = 25, Mensual = 80},
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

local function today0()
    local d = os.date("*t")
    return os.time({year = d.year, month = d.month, day = d.day, hour = 0, min = 0, sec = 0})
end

local function subscriptionExpiry(plan, start_ts)
    if plan == "Diario" then
        local d = os.date("*t", start_ts)
        return os.time({year = d.year, month = d.month, day = d.day, hour = 23, min = 59, sec = 59})
    elseif plan == "Semanal" then
        return start_ts + 7 * 86400
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
    local lines = {"id,nombres,apellidos,telefono,plan,start_ts,expiry,tipo_pago,estado_salud,peso,req_medico,req_contrato,req_terminos"}

    for _, c in ipairs(G.clients) do
        table.insert(lines, table.concat({
            escCSV(c.id), escCSV(c.nombres), escCSV(c.apellidos),
            escCSV(c.telefono), escCSV(c.plan),
            escCSV(c.start_ts), escCSV(c.expiry),
            escCSV(c.tipo_pago), escCSV(c.estado_salud), escCSV(c.peso),
            escCSV(csvBool(c.req_medico)), escCSV(csvBool(c.req_contrato)), escCSV(csvBool(c.req_terminos))
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

local function saveNotes()
    ensureDir("data")
    local lines = {"day,hour,text,color,duration"}

    for _, n in ipairs(G.notes) do
        table.insert(lines, string.format("%d,%d,%s,%s,%d",
            n.day, n.hour, escCSV(n.text or ""), n.color or "blue", n.duration or 1))
    end

    love.filesystem.write("data/notes.csv", table.concat(lines, "\n"))
end

local function loadNotes()
    local txt = love.filesystem.read("data/notes.csv")
    if not txt then return end

    G.notes = {}
    for l in txt:gmatch("[^\n]+") do
        if not l:find("^day") then
            local f = parseCSV(l)
            if #f >= 5 then
                table.insert(G.notes, {
                    day = tonumber(f[1]) or 0,
                    hour = tonumber(f[2]) or 8,
                    text = f[3],
                    color = f[4],
                    duration = tonumber(f[5]) or 1
                })
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
    
    rr(x, y, w, h, 5, C.input_bg)
    setColor(focused and C.blue or (hov and {0.25, 0.25, 0.35} or C.border))
    
    love.graphics.setLineWidth(focused and 1.5 or 1)
    rrLine(x, y, w, h, 5)
    love.graphics.setLineWidth(1)
    
    local f = fnt or G.fonts.normal
    love.graphics.setFont(f)
    local th = f:getHeight()
    
    if val == "" and not focused then
        setColor(C.dim)
        love.graphics.print(ph or "", x + 9, y + (h - th) / 2)
    else
        setColor(C.white)
        local disp = focused and (val .. "|") or val
        local tw = f:getWidth(disp)
        
        if tw > w - 18 then
            local s = 1
            while f:getWidth(disp:sub(s)) > w - 18 do 
                s = s + 1 
            end
            disp = disp:sub(s)
        end
        
        love.graphics.print(disp, x + 9, y + (h - th) / 2)
    end
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
        client.expiry = subscriptionExpiry(client.plan, st)
        saveClients()
        saveTx(PLAN_PRICES[client.plan] or 0, client.plan, client.nombres .. " " .. client.apellidos, "renovacion")
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
    love.graphics.print("Historial de Transacciones", x + 14, y + 12)

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

    local cw4 = (aw - 40) / 4
    local card_y = oy + 40
    local card_h = 80

    local cards = {
        {title = "Total Miembros", value = tostring(total_m), sub = string.format("Activos: %d  Vencidos: %d", active_m, expired_m), color = C.blue},
        {title = "Nuevos Registros (Mes)", value = tostring(new_month), sub = "+0% vs. mes anterior", color = C.cyan},
        {title = "Ingresos Mensuales", value = string.format("$%d", monthly_inc), sub = "Meta: $50,000", color = C.green},
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
        love.graphics.print(info, ox + 190, ry + 5)

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
    local pw = fw / 3 - 6

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

    setColor(C.dim)
    love.graphics.setFont(G.fonts.small)
    love.graphics.print("Tipo de Pago", fx, form_y + 394)
    drawDropdown(fx, form_y + 408, fw, 34, "tipo_pago", PAGO_OPTIONS)

    -- Buttons
    local btn_y = form_y + form_h - 52
    local c_hov = hover(ox + form_w - 270, btn_y, 120, 38)
    local s_hov = hover(ox + form_w - 140, btn_y, 125, 38)

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

    -- View selector
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

    -- Week nav
    local ws = getWeekStart(G.ag_week_off)
    local we = ws + 6 * 86400
    local wsd = os.date("*t", ws)
    local wed = os.date("*t", we)
    
    local nav_cx = ox + aw / 2
    local nh_hov1 = hover(nav_cx - 140, oy + 42, 30, 26)
    local nh_hov2 = hover(nav_cx + 112, oy + 42, 30, 26)
    
    drawButton(nav_cx - 140, oy + 42, 30, 26, "◀", C.card, C.white, G.fonts.normal, 4, nh_hov1)
    drawButton(nav_cx + 112, oy + 42, 30, 26, "▶", C.card, C.white, G.fonts.normal, 4, nh_hov2)
    
    setColor(C.white)
    love.graphics.setFont(G.fonts.normal)
    local wstr = string.format("%s %d – %s %d, %d",
        MONTH_NAMES[wsd.month]:sub(1, 3), wsd.day,
        MONTH_NAMES[wed.month]:sub(1, 3), wed.day, wed.year)
    love.graphics.printf(wstr, nav_cx - 108, oy + 48, 218, "center")

    -- New note button
    local nn_hov = hover(ox + aw - 140, oy + 42, 130, 26)
    drawButton(ox + aw - 140, oy + 42, 130, 26, "+ Nueva Nota", C.btn_green, C.white, G.fonts.small, 5, nn_hov)

    -- Grid
    local gx, gy = ox, oy + 78
    local gw, gh = aw, H - gy - 90
    rr(gx, gy, gw, gh, 6, C.card)

    local hcw = 52
    local dcw = (gw - hcw) / 7
    local hour_h = 52
    local hdr_h = 30
    local n_hours = 12

    -- Day headers
    local today_d = os.date("*t")
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
        love.graphics.printf(string.format("%s %d", DAY_SHORT[d + 1], dd.day), dx, gy + 9, dcw, "center")
        
        setColor(C.border)
        love.graphics.setLineWidth(0.5)
        love.graphics.line(dx, gy, dx, gy + gh)
        love.graphics.setLineWidth(1)
    end

    -- Hours
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

    -- Notes
    for _, note in ipairs(G.notes) do
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
            
            -- Selected actions
            if G.ag_selected == note then
                rr(nx2 + nw2 - 72, hy + 2, 20, 16, 3, C.blue)
                rr(nx2 + nw2 - 48, hy + 2, 20, 16, 3, C.green)
                rr(nx2 + nw2 - 24, hy + 2, 20, 16, 3, C.red)
                
                setColor(C.white)
                love.graphics.setFont(G.fonts.tiny)
                love.graphics.print("✓", nx2 + nw2 - 68, hy + 3)
                love.graphics.print("✏", nx2 + nw2 - 44, hy + 3)
                love.graphics.print("✗", nx2 + nw2 - 20, hy + 3)
            end
        end
    end
    love.graphics.setScissor()

    -- Bottom: Today's activities
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

    rr(ox, oy + 42, left_w, 260, 8, C.card)
    setColor(C.white)
    love.graphics.setFont(G.fonts.normal)
    love.graphics.print("💳 Precios por plan", ox + 12, oy + 54)

    setColor(C.gray)
    love.graphics.setFont(G.fonts.small)
    love.graphics.print("Diario", ox + 12, oy + 92)
    drawInput(ox + 12, oy + 108, left_w - 24, 32, "set_price_Diario", tostring(PLAN_PRICES.Diario or 0))
    love.graphics.print("Semanal", ox + 12, oy + 150)
    drawInput(ox + 12, oy + 166, left_w - 24, 32, "set_price_Semanal", tostring(PLAN_PRICES.Semanal or 0))
    love.graphics.print("Mensual", ox + 12, oy + 208)
    drawInput(ox + 12, oy + 224, left_w - 24, 32, "set_price_Mensual", tostring(PLAN_PRICES.Mensual or 0))

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

    rr(ox, oy + 314, aw, H - (oy + 314) - 18, 8, C.card)
    setColor(C.white)
    love.graphics.setFont(G.fonts.normal)
    love.graphics.print("🔔 Notificaciones", ox + 12, oy + 326)

    setColor(C.gray)
    love.graphics.setFont(G.fonts.small)
    love.graphics.print("Color por defecto:", ox + 12, oy + 356)
    local notif_colors = {"blue", "green", "yellow", "red", "cyan", "purple"}
    for i, nc in ipairs(notif_colors) do
        local bx = ox + 12 + (i - 1) * 66
        local by = oy + 374
        local active = (G.settings and G.settings.notif_color) == nc
        rr(bx, by, 60, 26, 5, active and NOTE_COLORS[nc] or C.card2)
        setColor(C.white)
        love.graphics.setFont(G.fonts.tiny)
        love.graphics.printf(nc, bx, by + 7, 60, "center")
    end

    setColor(C.gray)
    love.graphics.setFont(G.fonts.small)
    love.graphics.print("Máximo de notificaciones visibles", ox + 12, oy + 414)
    drawInput(ox + 12, oy + 430, 150, 32, "set_notif_limit", tostring((G.settings and G.settings.notif_limit) or 25))

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
        {"📝  Registro",     string.format("Registra nuevos clientes. Planes: Diario ($%d), Semanal ($%d), Mensual ($%d). Los 3 requisitos se marcan con click antes de guardar.", PLAN_PRICES.Diario or 0, PLAN_PRICES.Semanal or 0, PLAN_PRICES.Mensual or 0)},
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

    local names = {inicio = "Inicio", registro = "Registro", clientes = "Clientes", agenda = "Agenda", configuracion = "Configuración", soporte = "Soporte"}
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
    
    local dw, dh = 460, 290
    local dx, dy = (W - dw) / 2, (H - dh) / 2
    
    rr(dx, dy, dw, dh, 10, C.card)
    setColor(C.border)
    rrLine(dx, dy, dw, dh, 10)
    
    setColor(C.white)
    love.graphics.setFont(G.fonts.medium)
    love.graphics.print("📅  Nueva Anotación", dx + 14, dy + 14)
    
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
        love.graphics.circle("fill", cbx + 12, dy + 179, 10)
        
        if (G.new_note_color or "blue") == nc then
            setColor(C.white)
            love.graphics.setLineWidth(2)
            love.graphics.circle("line", cbx + 12, dy + 179, 13)
            love.graphics.setLineWidth(1)
        end
    end
    
    local c_h = hover(dx + dw - 270, dy + dh - 52, 120, 38)
    local s_h = hover(dx + dw - 138, dy + dh - 52, 122, 38)
    
    drawButton(dx + dw - 270, dy + dh - 52, 120, 38, "Cancelar", C.btn_cancel, C.white, G.fonts.normal, 6, c_h)
    drawButton(dx + dw - 138, dy + dh - 52, 122, 38, "✓ Guardar",  C.btn_green,  C.white, G.fonts.normal, 6, s_h)
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
        new_note_text = "", 
        new_note_hour = "8",
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
    elseif G.screen == "configuracion" then 
        drawConfiguracion()
    elseif G.screen == "soporte" then 
        drawSoporte()
    end

    if G.pending_action or G.show_close_summary then
        drawConfirmDialog()
    end

    if G.show_new_note then
        drawNewNoteDialog()
    end

    -- FPS
    setColor(C.dim)
    love.graphics.setFont(G.fonts.tiny)
    love.graphics.print(string.format("FPS:%d", love.timer.getFPS()), W - 44, H - 14)
end

function love.textinput(t)
    if G.focus then
        G.text_inputs[G.focus] = (G.text_inputs[G.focus] or "") .. t
    end
end


function love.keypressed(key)
    local ctrl = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")

    if key == "backspace" and G.focus then
        local s = G.text_inputs[G.focus] or ""
        if #s > 0 then
            local off = utf8.offset(s, -1)
            if off then
                G.text_inputs[G.focus] = s:sub(1, off - 1)
            end
        end

    elseif key == "escape" then
        if G.pending_action then
            if (G.pending_action.stage or 1) == 2 then
                G.pending_action.stage = 1
            else
                G.pending_action = nil
            end
        elseif G.show_close_summary then
            G.show_close_summary = false
            G.close_summary = nil
        elseif G.show_new_note then
            G.show_new_note = false
        elseif G.dropdown then
            G.dropdown = nil
        else
            G.focus = nil
        end

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
        elseif G.show_new_note then
            local hr = clamp(tonumber(G.text_inputs["new_note_hour"]) or 8, 8, 20)
            table.insert(G.notes, {
                day = G.new_note_day or 0,
                hour = hr,
                text = G.text_inputs["new_note_text"] or "",
                color = G.new_note_color or "blue",
                duration = 1
            })
            saveNotes()
            G.show_new_note = false
            G.text_inputs["new_note_text"] = ""
            addNotif("📅 Nota añadida a la agenda")
        end

    elseif ctrl and key == "n" then
        startNewRegistration()

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

    elseif ctrl and key == "m" then
        G.screen = "agenda"
        G.show_new_note = true
        G.new_note_day = 0
        G.new_note_color = "blue"
        G.text_inputs["new_note_text"] = ""
        G.text_inputs["new_note_hour"] = "8"

    elseif key == "tab" then
        local fields
        if G.screen == "configuracion" then
            fields = {"set_price_Diario", "set_price_Semanal", "set_price_Mensual", "set_notif_limit"}
        else
            fields = {"nombres", "apellidos", "telefono", "estado_salud", "peso"}
        end
        for i, f in ipairs(fields) do
            if G.focus == f then
                G.focus = fields[i % #fields + 1]
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
        G.screen = "configuracion"
    elseif key == "f6" then
        G.screen = "soporte"
    elseif key == "f7" then
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
            local hr = clamp(tonumber(G.text_inputs["new_note_hour"]) or 8, 8, 20)
            table.insert(G.notes, {
                day = G.new_note_day or 0,
                hour = hr,
                text = G.text_inputs["new_note_text"] or "",
                color = G.new_note_color or "blue",
                duration = 1
            })
            saveNotes()
            G.show_new_note = false
            G.text_inputs["new_note_text"] = ""
            addNotif("📅 Nota añadida a la agenda")
        end
        return
    end

    -- Sidebar navigation
    local navKeys = {"inicio", "registro", "clientes", "agenda", "configuracion", "soporte"}
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
                G.focus = inp.key
            end
        end

        -- Plan buttons
        local pw = fw2 / 3 - 6
        for i, p in ipairs(PLAN_OPTIONS) do
            if hover(fx2 + (i - 1) * (pw + 8), form_y2 + 330, pw, 50) then
                G.text_inputs["plan"] = p
            end
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

        if hover(ox + form_w2 - 270, btn_y2, 120, 38) then
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
            local c = {
                id = G.next_id,
                nombres = n2,
                apellidos = G.text_inputs["apellidos"] or "",
                telefono = G.text_inputs["telefono"] or "",
                plan = plan2,
                start_ts = st,
                expiry = subscriptionExpiry(plan2, st),
                tipo_pago = G.text_inputs["tipo_pago"] or "Efectivo",
                estado_salud = G.text_inputs["estado_salud"] or "",
                peso = G.text_inputs["peso"] or "",
                req_medico = G.req_state.medical,
                req_contrato = G.req_state.contract,
                req_terminos = G.req_state.terms,
            }

            G.next_id = G.next_id + 1
            table.insert(G.clients, c)
            saveClients()
            saveTx(PLAN_PRICES[plan2] or 0, plan2, n2 .. " " .. (G.text_inputs["apellidos"] or ""), "registro")

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
                beginClientAction("renew", c)
                return
            end

            if hover(cols[8] + 65, ry + 6, 28, 20) then
                addNotif("✏ Edición: usa los campos del botón Renovar para actualizar el plan")
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
            G.show_new_note = true
            G.new_note_day = 0
            G.new_note_color = "blue"
            G.text_inputs["new_note_text"] = ""
            G.text_inputs["new_note_hour"] = "8"
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
        for _, note in ipairs(G.notes) do
            local nx2 = gx2 + hcw2 + note.day * dcw2 + 2
            local hy = gy2 + hdr_h2 + (note.hour - 8) * hour_h2 + 2 - sc2

            if hover(nx2, hy, dcw2 - 4, hour_h2 - 4) then
                G.ag_selected = note
                local nw2 = dcw2 - 4
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
            G.focus = "set_price_Mensual"
        elseif hover(ox2 + 12, oy2 + 430, 150, 32) then
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
            G.settings.plan_prices.Mensual = tonumber(G.text_inputs.set_price_Mensual) or PLAN_PRICES.Mensual or 0
            G.settings.notif_limit = clamp(tonumber(G.text_inputs.set_notif_limit) or 25, 1, 99)
            syncPlanPrices()
            saveSettings()
            G.text_inputs.set_price_Diario = tostring(PLAN_PRICES.Diario or 0)
            G.text_inputs.set_price_Semanal = tostring(PLAN_PRICES.Semanal or 0)
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
            G.text_inputs.set_price_Mensual = tostring(PLAN_PRICES.Mensual or 0)
            G.text_inputs.set_notif_limit = tostring(G.settings.notif_limit)
            saveSettings()
            addNotif("↩ Configuración restaurada")
            return
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