/**
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_CCI_Params_M15 : CCIParams {
  Indi_CCI_Params_M15() : CCIParams(indi_cci_defaults, PERIOD_M15) {
    applied_price = (ENUM_APPLIED_PRICE)4;
    period = 28;
    shift = 0;
  }
} indi_cci_m15;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_CCI_Params_M15 : StgParams {
  // Struct constructor.
  Stg_CCI_Params_M15() : StgParams(stg_cci_defaults) {
    lot_size = 0;
    signal_open_method = 0;
    signal_open_filter = 1;
    signal_open_level = (float)20.0;
    signal_open_boost = 0;
    signal_close_method = 0;
    signal_close_level = (float)0;
    price_stop_method = 0;
    price_stop_level = (float)1;
    tick_filter_method = 1;
    max_spread = 0;
  }
} stg_cci_m15;
