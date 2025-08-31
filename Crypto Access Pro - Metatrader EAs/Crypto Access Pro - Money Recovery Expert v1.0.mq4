//+------------------------------------------------------------------+
//|                         Recovery EA                              |
//+------------------------------------------------------------------+
#property version "1.0"
#property strict

//--- Indicator Inputs (only the ones in use are shown)
// VWAP is calculated using H1 timeframe price and volume data.
double VWAP;

// RSI and ATR calculations are performed on the H1 timeframe.
input int   RSI_Period         = 14;     // RSI period (H1 timeframe)
input int   ATR_Period         = 14;     // ATR period (H1 timeframe)

//--- Trading Parameters
input double Initial_Lot        = 0.05;    // Starting trade lot size
input int    Recovery_Pip_Dist  = 10;     // Minimum pip distance to trigger a recovery trade
// input int  Max_Recovery_Trades  = 20;    // Maximum allowed recovery trades (no longer used for forced closure)
input double Lot_Multiplier     = 1.0;    // Multiplier for lot size in recovery trades
input double Max_Slippage       = 3;      // Maximum allowed slippage in pips for trade execution
input double TP_ATR_Multiplier  = 3.5;    // Multiplier for ATR to calculate take profit level
input double ATR_Distance_Factor= 2.0;    // Factor for additional pip distance based on ATR
input double ProfitTarget_PerLot= 20;   // Required profit per lot to close the group of trades
input int    Daily_Trade_Limit  = 20;      // Maximum number of trades allowed per day

//--- Trade Management Variables
datetime lastTradeTime      = 0;          // Timestamp of the last trade executed
input int TradeCooldown_Min   = 15;        // Cooldown period (in minutes) between trades
bool   inRecoveryMode       = false;      // Flag indicating if recovery mode is active
double globalBreakEven      = 0;          // Break-even price calculated from open positions
int    dailyTradeCount      = 0;          // Counter for the number of trades executed today
datetime lastDayChecked;                 // Used to reset the daily trade counter

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   lastDayChecked = TimeCurrent();
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Spread Calculation                                               |
//+------------------------------------------------------------------+
double GetSpread()
{
   return NormalizeDouble((Ask - Bid) / Point, 1);
}

//+------------------------------------------------------------------+
//| VWAP Calculation (using last 20 H1 bars)                         |
//+------------------------------------------------------------------+
double GetVWAP()
{
   int total_bars = iBars(Symbol(), PERIOD_H1);
   if(total_bars < 20) return 0;

   double vwap_sum   = 0.0;
   double volume_sum = 0.0;
   for(int i = 0; i < 20; i++)
   {
      double typicalPrice = (iHigh(Symbol(), PERIOD_H1, i) + 
                             iLow(Symbol(), PERIOD_H1, i) + 
                             iClose(Symbol(), PERIOD_H1, i)) / 3.0;
      double volume = iVolume(Symbol(), PERIOD_H1, i);
      if(volume <= 0) continue;
      vwap_sum   += typicalPrice * volume;
      volume_sum += volume;
   }
   return (volume_sum > 0) ? (vwap_sum / volume_sum) : 0;
}

//+------------------------------------------------------------------+
//| ATR Calculation (H1 timeframe)                                   |
//+------------------------------------------------------------------+
double GetATR()
{
   return iATR(Symbol(), PERIOD_H1, ATR_Period, 0);
}

//+------------------------------------------------------------------+
//| Order Opening Functions                                          |
//+------------------------------------------------------------------+
void OpenBuy(double lotSize)
{
   if(dailyTradeCount >= Daily_Trade_Limit)
      return;
   
   double atr = GetATR();
   double tp  = Ask + (atr * TP_ATR_Multiplier);
   if(OrderSend(Symbol(), OP_BUY, lotSize, Ask, Max_Slippage, 0, tp, "DayBuy", 0, 0, Blue) > 0)
   {
      lastTradeTime = TimeCurrent();
      dailyTradeCount++;
   }
}

void OpenSell(double lotSize)
{
   if(dailyTradeCount >= Daily_Trade_Limit)
      return;
   
   double atr = GetATR();
   double tp  = Bid - (atr * TP_ATR_Multiplier);
   if(OrderSend(Symbol(), OP_SELL, lotSize, Bid, Max_Slippage, 0, tp, "DaySell", 0, 0, Red) > 0)
   {
      lastTradeTime = TimeCurrent();
      dailyTradeCount++;
   }
}

//+------------------------------------------------------------------+
//| Entry Conditions                                                 |
//+------------------------------------------------------------------+
void CheckEntry()
{
   // Reset daily trade count at the start of a new day
   if(TimeDay(TimeCurrent()) != TimeDay(lastDayChecked))
   {
      dailyTradeCount = 0;
      lastDayChecked  = TimeCurrent();
   }
   
   // Do not enter new trades if already in recovery mode or if any trades are open
   if(inRecoveryMode || OrdersTotal() > 0)
      return;
      
   // Respect the cooldown period between trades
   if(TimeCurrent() - lastTradeTime < TradeCooldown_Min * 60)
      return;

   VWAP = GetVWAP();
   if(VWAP == 0)
      return;

   double RSI = iRSI(Symbol(), PERIOD_H1, RSI_Period, PRICE_CLOSE, 0);
   double atr = GetATR();
   if(atr < 10 * Point) // Filter out low-volatility periods
      return;

   // Entry conditions: more conservative thresholds
   if(Bid < VWAP && RSI < 35)  // Condition for a buy signal
      OpenBuy(Initial_Lot);
   else if(Ask > VWAP && RSI > 65) // Condition for a sell signal
      OpenSell(Initial_Lot);
}

//+------------------------------------------------------------------+
//| Enhanced Recovery System (without forced close on loss)         |
//+------------------------------------------------------------------+
void RecoverySystem()
{
   int tradeCount = OrdersTotal();
   if(tradeCount == 0)
   {
      inRecoveryMode  = false;
      globalBreakEven = 0;
      return;
   }

   //--- Removed forced close when the number of trades exceeds a limit.
   //    (The previous check that forced a CloseAllTrades() is no longer present.)

   // Calculate the weighted average entry price and total volume
   double totalVolume   = 0;
   double weightedPrice = 0;
   int    direction     = -1;
   for(int i = 0; i < tradeCount; i++)
   {
      if(OrderSelect(i, SELECT_BY_POS))
      {
         totalVolume   += OrderLots();
         weightedPrice += OrderOpenPrice() * OrderLots();
         direction      = OrderType();
      }
   }
   double averagePrice = weightedPrice / totalVolume;
   globalBreakEven   = averagePrice;

   // Determine the current distance from the average price in pips
   double atr = GetATR();
   double priceDistance = (direction == OP_BUY) ? (averagePrice - Bid) : (Ask - averagePrice);
   priceDistance = MathAbs(priceDistance) / Point;
   double requiredDistance = Recovery_Pip_Dist + (ATR_Distance_Factor * (atr / Point));

   // If the price has moved sufficiently, open a recovery trade with an increased lot size.
   if(priceDistance >= requiredDistance)
   {
      double newLotSize = Initial_Lot * MathPow(Lot_Multiplier, tradeCount);
      if(direction == OP_BUY)
         OpenBuy(newLotSize);
      else
         OpenSell(newLotSize);
   }

   CheckGroupProfit();
}

//+------------------------------------------------------------------+
//| Profit Management: Close trades if the group has reached target  |
//+------------------------------------------------------------------+
void CheckGroupProfit()
{
   double totalProfit = 0;
   double totalVolume = 0;
   
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS))
      {
         totalProfit += OrderProfit() + OrderSwap() + OrderCommission();
         totalVolume += OrderLots();
      }
   }

   double requiredProfit = totalVolume * ProfitTarget_PerLot;
   if(totalProfit >= requiredProfit)
      CloseAllTrades();
}

//+------------------------------------------------------------------+
//| Emergency: Close All Open Trades                                 |
//+------------------------------------------------------------------+
void CloseAllTrades()
{
   for(int i = OrdersTotal()-1; i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS))
      {
         bool closed = OrderClose(OrderTicket(), OrderLots(), 
                     (OrderType() == OP_BUY ? Bid : Ask), Max_Slippage, CLR_NONE);
         if(!closed)
            Print("CloseAllTrades Error: ", GetLastError());
      }
   }
   inRecoveryMode  = false;
   globalBreakEven = 0;
}

//+------------------------------------------------------------------+
//| Main EA Execution Function                                       |
//+------------------------------------------------------------------+
void OnTick()
{
   // Only check for a fresh entry if not already in recovery mode.
   if(!inRecoveryMode)
      CheckEntry();

   // Always run the recovery system logic on every tick.
   RecoverySystem();
}
