/**
 * @file
 * Implements CCI strategy based on the Commodity Channel Index indicator.
 */

// User input params.
INPUT float CCI_LotSize = 0;               // Lot size
INPUT int CCI_SignalOpenMethod = 0;        // Signal open method (-63-63)
INPUT float CCI_SignalOpenLevel = 50.0;    // Signal open level (-100-100)
INPUT int CCI_SignalOpenFilterMethod = 1;  // Signal open filter method
INPUT int CCI_SignalOpenBoostMethod = 0;   // Signal open boost method
INPUT int CCI_SignalCloseMethod = 0;       // Signal close method (-63-63)
INPUT float CCI_SignalCloseLevel = 50.0;   // Signal close level (-100-100)
INPUT int CCI_PriceStopMethod = 0;         // Price stop method (0-6)
INPUT float CCI_PriceStopLevel = 0;        // Price stop level
INPUT int CCI_TickFilterMethod = 1;        // Tick filter method
INPUT float CCI_MaxSpread = 4.0;           // Max spread to trade (pips)
INPUT int CCI_Shift = 1;                   // Shift (0 for default)
INPUT int CCI_OrderCloseTime = -20;        // Order close time in mins (>0) or bars (<0)
INPUT string __CCI_Indi_CCI_Parameters__ =
    "-- CCI strategy: CCI indicator params --";                               // >>> CCI strategy: CCI indicator <<<
INPUT int CCI_Indi_CCI_Period = 20;                                           // Period
INPUT ENUM_APPLIED_PRICE CCI_Indi_CCI_Applied_Price = (ENUM_APPLIED_PRICE)2;  // Applied Price

// Structs.

// Defines struct with default user indicator values.
struct Indi_CCI_Params_Defaults : CCIParams {
  Indi_CCI_Params_Defaults() : CCIParams(::CCI_Indi_CCI_Period, ::CCI_Indi_CCI_Applied_Price) {}
} indi_cci_defaults;

// Defines struct with default user strategy values.
struct Stg_CCI_Params_Defaults : StgParams {
  Stg_CCI_Params_Defaults()
      : StgParams(::CCI_SignalOpenMethod, ::CCI_SignalOpenFilterMethod, ::CCI_SignalOpenLevel,
                  ::CCI_SignalOpenBoostMethod, ::CCI_SignalCloseMethod, ::CCI_SignalCloseLevel, ::CCI_PriceStopMethod,
                  ::CCI_PriceStopLevel, ::CCI_TickFilterMethod, ::CCI_MaxSpread, ::CCI_Shift, ::CCI_OrderCloseTime) {}
} stg_cci_defaults;

// Struct to define strategy parameters to override.
struct Stg_CCI_Params : StgParams {
  CCIParams iparams;
  StgParams sparams;

  // Struct constructors.
  Stg_CCI_Params(CCIParams &_iparams, StgParams &_sparams)
      : iparams(indi_cci_defaults, _iparams.tf), sparams(stg_cci_defaults) {
    iparams = _iparams;
    sparams = _sparams;
  }
};

// Loads pair specific param values.
#include "config/EURUSD_H1.h"
#include "config/EURUSD_H4.h"
#include "config/EURUSD_H8.h"
#include "config/EURUSD_M1.h"
#include "config/EURUSD_M15.h"
#include "config/EURUSD_M30.h"
#include "config/EURUSD_M5.h"

class Stg_CCI : public Strategy {
 public:
  Stg_CCI(StgParams &_params, string _name) : Strategy(_params, _name) {}

  static Stg_CCI *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    CCIParams _indi_params(indi_cci_defaults, _tf);
    StgParams _stg_params(stg_cci_defaults);
    if (!Terminal::IsOptimization()) {
      SetParamsByTf<CCIParams>(_indi_params, _tf, indi_cci_m1, indi_cci_m5, indi_cci_m15, indi_cci_m30, indi_cci_h1,
                               indi_cci_h4, indi_cci_h8);
      SetParamsByTf<StgParams>(_stg_params, _tf, stg_cci_m1, stg_cci_m5, stg_cci_m15, stg_cci_m30, stg_cci_h1,
                               stg_cci_h4, stg_cci_h8);
    }
    // Initialize indicator.
    CCIParams cci_params(_indi_params);
    _stg_params.SetIndicator(new Indi_CCI(_indi_params));
    // Initialize strategy parameters.
    _stg_params.GetLog().SetLevel(_log_level);
    _stg_params.SetMagicNo(_magic_no);
    _stg_params.SetTf(_tf, _Symbol);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_CCI(_stg_params, "CCI");
    _stg_params.SetStops(_strat, _strat);
    return _strat;
  }

  /**
   * Check if CCI indicator is on buy or sell.
   *
   * @param
   *   _cmd (int) - type of trade order command
   *   period (int) - period to check for
   *   _method (int) - signal method to use by using bitwise AND operation
   *   _level (double) - signal level to consider the signal
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f, int _shift = 0) {
    Chart *_chart = sparams.GetChart();
    Indi_CCI *_indi = Data();
    bool _is_valid = _indi[CURR].IsValid() && _indi[PREV].IsValid() && _indi[PPREV].IsValid();
    bool _result = _is_valid;
    if (!_result) {
      // Returns false when indicator data is not valid.
      return false;
    }
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        _result = _indi[CURR][0] > _level || _indi[CURR][0] < -_level;
        _result &= _indi.IsIncreasing(3);
        if (_method != 0) {
          if (METHOD(_method, 0)) _result &= _indi.IsIncreasing(2, 0, 3);
          if (METHOD(_method, 1)) _result &= _indi[PREV][0] > _indi[PPREV][0];
          if (METHOD(_method, 2)) _result &= _indi[PREV][0] < -_level;
          if (METHOD(_method, 3)) _result &= _indi[PPREV][0] < -_level;
          if (METHOD(_method, 4)) _result &= _indi[CURR][0] - _indi[PREV][0] > _indi[PREV][0] - _indi[PPREV][0];
          if (METHOD(_method, 5)) _result &= _indi[PPREV][0] > 0;
        }
        break;
      case ORDER_TYPE_SELL:
        _result = _indi[CURR][0] > _level || _indi[CURR][0] < -_level;
        _result &= _indi.IsDecreasing(3);
        if (_method != 0) {
          if (METHOD(_method, 0)) _result &= _indi.IsDecreasing(2, 0, 3);
          if (METHOD(_method, 1)) _result &= _indi[PREV][0] < _indi[PPREV][0];
          if (METHOD(_method, 2)) _result &= _indi[PREV][0] > _level;
          if (METHOD(_method, 3)) _result &= _indi[PPREV][0] > _level;
          if (METHOD(_method, 4)) _result &= _indi[PREV][0] - _indi[CURR][0] > _indi[PPREV][0] - _indi[PREV][0];
          if (METHOD(_method, 5)) _result &= _indi[PPREV][0] < 0;
        }
        break;
    }
    return _result;
  }

  /**
   * Gets price stop value for profit take or stop loss.
   */
  float PriceStop(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, float _level = 0.0) {
    Indi_CCI *_indi = Data();
    double _trail = _level * Market().GetPipSize();
    int _direction = Order::OrderDirection(_cmd, _mode);
    double _default_value = Market().GetCloseOffer(_cmd) + _trail * _method * _direction;
    double _result = _default_value;
    switch (_method) {
      case 1: {
        int _bar_count = (int)_level * (int)_indi.GetPeriod();
        _result = _direction > 0 ? _indi.GetPrice(PRICE_HIGH, _indi.GetHighest<double>(_bar_count))
                                 : _indi.GetPrice(PRICE_LOW, _indi.GetLowest<double>(_bar_count));
        break;
      }
    }
    return (float)_result;
  }
};
