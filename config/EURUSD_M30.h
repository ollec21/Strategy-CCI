/**
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_CCI_Params_M30 : CCIParams {
  Indi_CCI_Params_M30() : CCIParams(indi_cci_defaults, PERIOD_M30) {
    applied_price = (ENUM_APPLIED_PRICE)1;
    period = 22;
    shift = 0;
  }
} indi_cci_m30;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_CCI_Params_M30 : StgParams {
  // Struct constructor.
  Stg_CCI_Params_M30() : StgParams(stg_cci_defaults) {
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
} stg_cci_m30;
