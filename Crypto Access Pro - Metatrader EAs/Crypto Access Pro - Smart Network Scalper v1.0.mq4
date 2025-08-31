//+------------------------------------------------------------------+
//|                      Neural Network Scalper EA                   |
//|                        Copyright 2023, MetaQuotes Ltd.           |
//|                                        https://www.mql5.com      |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.50"
#property strict

// Neural Network Configuration
#define INPUT_NODES   5
#define HIDDEN_NODES  16
#define OUTPUT_NODES  1

// Neural Network Structure
double inputWeights[INPUT_NODES][HIDDEN_NODES];
double hiddenWeights[HIDDEN_NODES][OUTPUT_NODES];
double inputBias[HIDDEN_NODES];
double hiddenBias[OUTPUT_NODES];

// Trading Parameters
input double RiskPercent        = 0.5;    // Risk percentage per trade
input double MaxSpread          = 2.0;    // Maximum allowed spread (pips)
input int    FastEMAPeriod      = 50;     // Fast EMA period
input int    SlowEMAPeriod      = 200;    // Slow EMA period
input double MinVolatility      = 0.0003; // Minimum ATR value
input double Commission         = 3.0;    // Commission per lot

// Trailing Stop Parameters
input double TrailingStopATRMultiplier = 1.5;
input double TrailingStart             = 15.0;

// System Variables
double learningRate = 0.1;
int lastBar = 0;
double normMean[INPUT_NODES];
double normStd[INPUT_NODES];

// Adam Optimizer Variables
double m[INPUT_NODES][HIDDEN_NODES], v[INPUT_NODES][HIDDEN_NODES];
double m_out[HIDDEN_NODES], v_out[HIDDEN_NODES];
int t = 0;

// Trade tracking structure
struct TradeData {
   int ticket;
   double features[INPUT_NODES];
   double hidden[HIDDEN_NODES];
};
TradeData openTradesList[];

//+------------------------------------------------------------------+
//| Expert Initialization Function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Initialize neural network weights
   for(int i = 0; i < INPUT_NODES; i++) {
      for(int j = 0; j < HIDDEN_NODES; j++) {
         inputWeights[i][j] = (MathRand()/32767.0 - 0.5) * sqrt(6.0/(INPUT_NODES+HIDDEN_NODES));
      }
   }
   for(int k = 0; k < HIDDEN_NODES; k++) {
      hiddenWeights[k][0] = (MathRand()/32767.0 - 0.5) * sqrt(6.0/(HIDDEN_NODES+OUTPUT_NODES));
   }
   ArrayInitialize(inputBias, 0.0);
   ArrayInitialize(hiddenBias, 0.0);

   // Initialize normalization parameters
   InitNormalization();

   // Initialize Adam optimizer parameters
   ArrayInitialize(m, 0.0);
   ArrayInitialize(v, 0.0);
   ArrayInitialize(m_out, 0.0);
   ArrayInitialize(v_out, 0.0);
   t = 0;

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert Deinitialization Function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Comment("");
}

//+------------------------------------------------------------------+
//| Expert Tick Function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   UpdateTrailingStops();
   CheckClosedTrades();
   
   if(!NewBar() || HasPosition())
      return;
   
   double features[INPUT_NODES];
   GetFeatures(features);
   
   double hidden[HIDDEN_NODES];
   double prediction = ForwardPass(features, hidden);
   
   if(SpreadOK() && VolatilityOK()) {
      if(prediction > 0.6 && BullishTrend())
         ExecuteOrder(OP_BUY, features, hidden);
      else if(prediction < 0.4 && BearishTrend())
         ExecuteOrder(OP_SELL, features, hidden);
   }
}

void UpdateTrailingStops() {
   double atr = iATR(_Symbol, PERIOD_M5, 14, 0);
   double pip = Point;
   if(Digits == 5 || Digits == 3) pip *= 10;
   
   for(int i = OrdersTotal()-1; i >= 0; i--) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if(OrderSymbol() != _Symbol) continue;
         
         int type = OrderType();
         if(type != OP_BUY && type != OP_SELL) continue;
         
         double currentPrice = (type == OP_BUY) ? Bid : Ask;
         double profitPips = MathAbs((currentPrice - OrderOpenPrice()) / pip);
         
         if(profitPips < TrailingStart) continue;
         
         double newSl = OrderStopLoss();
         double atrDistance = atr * TrailingStopATRMultiplier;
         double potentialSl = 0; // Declare potentialSl here
         
         if(type == OP_BUY) {
            potentialSl = currentPrice - atrDistance;
            if(potentialSl > OrderStopLoss() && potentialSl > OrderOpenPrice()) {
               newSl = potentialSl;
            }
         }
         else if(type == OP_SELL) {
            potentialSl = currentPrice + atrDistance;
            if(potentialSl < OrderStopLoss() && potentialSl < OrderOpenPrice()) {
               newSl = potentialSl;
            }
         }
         
         if(newSl != OrderStopLoss()) {
            if(!OrderModify(OrderTicket(), OrderOpenPrice(), newSl, OrderTakeProfit(), 0)) {
               Print("Trailing stop update failed: ", GetLastError());
            }
         }
      }
   }
}
//+------------------------------------------------------------------+
//| Feature Extraction Function                                      |
//+------------------------------------------------------------------+
void GetFeatures(double &features[])
{
   // 1. Price Momentum
   double highVal = iHigh(_Symbol, PERIOD_M5, 14);
   double lowVal  = iLow(_Symbol, PERIOD_M5, 14);
   features[0] = (iClose(_Symbol, PERIOD_M5, 0) - iClose(_Symbol, PERIOD_M5, 14)) / (highVal - lowVal + 1e-10);
   
   // 2. Bollinger Bands
   double upper = iBands(_Symbol, PERIOD_M5, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, 0);
   double lower = iBands(_Symbol, PERIOD_M5, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, 0);
   features[1] = (iClose(_Symbol, PERIOD_M5, 0) - lower) / (upper - lower + 1e-10);
   
   // 3. MACD Histogram Slope
   features[2] = iMACD(_Symbol, PERIOD_M5, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0) -
                 iMACD(_Symbol, PERIOD_M5, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 1);
   
   // 4. Volume Ratio
   features[3] = iVolume(_Symbol, PERIOD_M5, 0) / MathMax(iVolume(_Symbol, PERIOD_M5, 14), 1.0);
   
   // 5. RSI
   features[4] = iRSI(_Symbol, PERIOD_M5, 14, PRICE_CLOSE, 0)/100.0;
   
   // Normalization
   for(int i = 0; i < INPUT_NODES; i++)
      features[i] = (features[i] - normMean[i]) / (normStd[i] + 1e-10);
}

//+------------------------------------------------------------------+
//| Neural Network Forward Pass                                      |
//+------------------------------------------------------------------+
double ForwardPass(double &inputs[], double &hidden[])
{
   // Input to Hidden
   for(int h = 0; h < HIDDEN_NODES; h++) {
      hidden[h] = inputBias[h];
      for(int i = 0; i < INPUT_NODES; i++) {
         hidden[h] += inputs[i] * inputWeights[i][h];
      }
      hidden[h] = Tanh(hidden[h]);
   }
   
   // Hidden to Output
   double output = hiddenBias[0];
   for(int j = 0; j < HIDDEN_NODES; j++) {
      output += hidden[j] * hiddenWeights[j][0];
   }
   
   return 1.0 / (1.0 + MathExp(-output));
}

//+------------------------------------------------------------------+
//| Adam Optimizer Weight Update                                     |
//+------------------------------------------------------------------+
void UpdateWeights(bool tradeSuccess, double &inputs[], double &hidden[])
{
   double target = tradeSuccess ? 1.0 : 0.0;
   double prediction = ForwardPass(inputs, hidden);
   double error = target - prediction;
   
   // Adam parameters
   double beta1 = 0.9, beta2 = 0.999, epsilon = 1e-8;
   t++;
   
   // Output layer updates
   double deltaOut = error * prediction * (1 - prediction);
   for(int h = 0; h < HIDDEN_NODES; h++) {
      double grad = deltaOut * hidden[h];
      m_out[h] = beta1 * m_out[h] + (1 - beta1) * grad;
      v_out[h] = beta2 * v_out[h] + (1 - beta2) * grad*grad;
      double m_hat = m_out[h] / (1 - MathPow(beta1, t));
      double v_hat = v_out[h] / (1 - MathPow(beta2, t));
      hiddenWeights[h][0] += learningRate * m_hat / (MathSqrt(v_hat) + epsilon);
   }
   
   // Hidden layer updates
   for(int j = 0; j < HIDDEN_NODES; j++) {
      double deltaHidden = (1 - MathPow(hidden[j], 2)) * deltaOut * hiddenWeights[j][0];
      for(int i = 0; i < INPUT_NODES; i++) {
         double grad = deltaHidden * inputs[i];
         m[i][j] = beta1 * m[i][j] + (1 - beta1) * grad;
         v[i][j] = beta2 * v[i][j] + (1 - beta2) * grad*grad;
         double m_hat = m[i][j] / (1 - MathPow(beta1, t));
         double v_hat = v[i][j] / (1 - MathPow(beta2, t));
         inputWeights[i][j] += learningRate * m_hat / (MathSqrt(v_hat) + epsilon);
      }
   }
}

//+------------------------------------------------------------------+
//| Trade Execution Function                                         |
//+------------------------------------------------------------------+
void ExecuteOrder(int type, double &features[], double &hidden[])
{
   double price = (type == OP_BUY) ? Ask : Bid;
   double atr = iATR(_Symbol, PERIOD_M5, 14, 0);
   
   // Calculate SL/TP
   double sl = (type == OP_BUY) ? price - atr * 3 : price + atr * 3;
   double tp = (type == OP_BUY) ? price + atr * 9 : price - atr * 9;
   
   // Lot size calculation
   double riskAmount = AccountBalance() * RiskPercent / 100.0;
   double pip = Point;
   if(Digits == 5 || Digits == 3) pip *= 10;
   
   double lossPips = MathAbs(price - sl)/pip;
   double tickValue = MarketInfo(_Symbol, MODE_TICKVALUE);
   double tickSize = MarketInfo(_Symbol, MODE_TICKSIZE);
   double pipValue = tickValue * (pip/tickSize);
   
   double lotSize = riskAmount / ((lossPips * pipValue) + Commission);
   lotSize = NormalizeLot(lotSize);
   
   if(lotSize < MarketInfo(_Symbol, MODE_MINLOT)) {
      Print("Lot size too small: ", lotSize);
      return;
   }
   
   int ticket = OrderSend(_Symbol, type, lotSize, price, 3, sl, tp);
   if(ticket > 0) {
      int size = ArraySize(openTradesList);
      ArrayResize(openTradesList, size+1);
      ArrayCopy(openTradesList[size].features, features);
      ArrayCopy(openTradesList[size].hidden, hidden);
      openTradesList[size].ticket = ticket;
   }
   else {
      Print("OrderSend failed: ", GetLastError());
   }
}

//+------------------------------------------------------------------+
//| Check Closed Trades Function                                     |
//+------------------------------------------------------------------+
void CheckClosedTrades() {
   for(int i = ArraySize(openTradesList)-1; i >= 0; i--) {
      if(OrderSelect(openTradesList[i].ticket, SELECT_BY_TICKET)) {
         if(OrderCloseTime() > 0) {
            UpdateWeights(OrderProfit() > 0, openTradesList[i].features, openTradesList[i].hidden);
            
            // Manual array removal since ArrayRemove() doesn't exist in MQL4
            int size = ArraySize(openTradesList);
            for(int j = i; j < size-1; j++) {
               openTradesList[j] = openTradesList[j+1];
            }
            ArrayResize(openTradesList, size-1);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Normalization Initialization                                     |
//+------------------------------------------------------------------+
void InitNormalization()
{
   int lookback = 1000;
   for(int i = 0; i < INPUT_NODES; i++) {
      double sum = 0, sumSq = 0;
      for(int j = 0; j < lookback; j++) {
         double val = 0;
         switch(i) {
            case 0:
               val = (iClose(_Symbol, PERIOD_M5, j) - iClose(_Symbol, PERIOD_M5, j+14)) / 
                     (iHigh(_Symbol, PERIOD_M5, j+14) - iLow(_Symbol, PERIOD_M5, j+14) + 1e-10);
               break;
            case 1: {
               double upper = iBands(_Symbol, PERIOD_M5, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, j);
               double lower = iBands(_Symbol, PERIOD_M5, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, j);
               val = (iClose(_Symbol, PERIOD_M5, j) - lower) / (upper - lower + 1e-10);
               break;
            }
            case 2:
               val = iMACD(_Symbol, PERIOD_M5, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, j) -
                     iMACD(_Symbol, PERIOD_M5, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, j+1);
               break;
            case 3:
               val = iVolume(_Symbol, PERIOD_M5, j) / MathMax(iVolume(_Symbol, PERIOD_M5, j+14), 1.0);
               break;
            case 4:
               val = iRSI(_Symbol, PERIOD_M5, 14, PRICE_CLOSE, j)/100.0;
               break;
         }
         sum += val;
         sumSq += val*val;
      }
      normMean[i] = sum/lookback;
      normStd[i] = MathSqrt(MathAbs(sumSq/lookback - normMean[i]*normMean[i]));
   }
}

//+------------------------------------------------------------------+
//| Helper Functions                                                 |
//+------------------------------------------------------------------+
double Tanh(double x) { return (MathExp(2*x) - 1) / (MathExp(2*x) + 1); }



bool NewBar() {
   static datetime lastTime;
   datetime current = iTime(_Symbol, PERIOD_M5, 0);
   if(current != lastTime) { lastTime = current; return true; }
   return false;
}

bool HasPosition() {
   for(int i = 0; i < OrdersTotal(); i++)
      if(OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol) return true;
   return false;
}

bool SpreadOK() { return MarketInfo(_Symbol, MODE_SPREAD)*Point <= MaxSpread*Point; }

bool VolatilityOK() { return iATR(_Symbol, PERIOD_M5, 14, 0) >= MinVolatility; }

bool BullishTrend() {
   return iMA(_Symbol, PERIOD_M5, FastEMAPeriod, 0, MODE_EMA, PRICE_CLOSE, 0) >
          iMA(_Symbol, PERIOD_M5, SlowEMAPeriod, 0, MODE_EMA, PRICE_CLOSE, 0);
}

bool BearishTrend() {
   return iMA(_Symbol, PERIOD_M5, FastEMAPeriod, 0, MODE_EMA, PRICE_CLOSE, 0) <
          iMA(_Symbol, PERIOD_M5, SlowEMAPeriod, 0, MODE_EMA, PRICE_CLOSE, 0);
}
double NormalizeLot(double lot) {
   double step = MarketInfo(_Symbol, MODE_LOTSTEP);
   double minLot = MarketInfo(_Symbol, MODE_MINLOT);
   double maxLot = MarketInfo(_Symbol, MODE_MAXLOT);
   
   // Ensure proper rounding
   lot = MathFloor(lot / step + 0.0000001) * step;
   
   // Clamp to valid lot size range
   lot = MathMax(lot, minLot);
   lot = MathMin(lot, maxLot);
   
   return lot;
}