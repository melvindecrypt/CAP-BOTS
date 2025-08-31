//+------------------------------------------------------------------+
//|      Free                  Nas100 BaT      |
//+------------------------------------------------------------------+
#property version "1.0"
#property strict

// Input parameters
input double RiskPercentage = 1;         // Risk percentage per trade
input int StartHour = 16;                  // Box start hour
input int StartMinute = 5;                 // Box start minute
input int EndHour = 16;                    // Box end hour
input int EndMinute = 20;                  // Box end minute
input int BoxHigh2Distance = 3400;         // Distance in points above box high
input int BoxLow2Distance = 3400;          // Distance in points below box low
input int TrailingStopStep = 9000;         // Trailing stop step size in points
input int PostBoxHours = 1;                // Hours after box ends for order placement
input int PostBoxMinutes = 40;             // Minutes after box ends for order placement
input int CloseTradesHour = 23;            // Hour to close all open trades
input int Slippage = 50;                   // Maximum allowed slippage in points
input double MaxSpread = 300.0;            // Maximum allowed spread in points
input int MagicNumber = 123456;            // Unique identifier for the EA trades

// Multi-Timeframe Moving Average Filter Inputs
input int MAPeriod = 50;                   // MA Period
input int MAShift = 0;                     // MA Shift
input int MAMethod = MODE_EMA;             // MA Method
input int MAAppliedPrice = PRICE_CLOSE;    // Applied price
input ENUM_TIMEFRAMES MATimeframe = PERIOD_H4; // Timeframe for the MTF MA filter

// Variables
datetime boxStartTime, boxEndTime, orderPlacementEndTime;
double boxHigh, boxLow, boxHigh2, boxLow2;
datetime currentDay = 0;
bool boxDrawn = false;                     // Tracks if the breakout box is drawn
bool orderPlacedToday = false;             // Tracks if an order was placed today
int lastTradeDate = 0;                     // Tracks the date of the last trade

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   Print("Breakout Box EA with MTF MA Filter Initialized.");
   currentDay = iTime(NULL, PERIOD_D1, 0); // Initialize with today's date
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, "BreakoutBox");
   Print("Breakout Box EA Deinitialized.");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   datetime currentTime = TimeCurrent();

   // Reset daily flag at the start of a new day
   if (currentTime >= (currentDay + 86400)) // Check if a new day has started
     {
      currentDay = iTime(NULL, PERIOD_D1, 0);
      orderPlacedToday = false;
      boxDrawn = false; // Reset the box-drawn flag for the new day
      Print("New day detected, flags reset.");
     }

   // Calculate box start, end times, and order placement end time
   boxStartTime = iTime(NULL, PERIOD_D1, 0) + StartHour * 3600 + StartMinute * 60;
   boxEndTime = iTime(NULL, PERIOD_D1, 0) + EndHour * 3600 + EndMinute * 60;
   orderPlacementEndTime = boxEndTime + PostBoxHours * 3600 + PostBoxMinutes * 60;

   // During the box period, calculate high and low, and draw the box
   if (currentTime >= boxStartTime && currentTime <= boxEndTime)
     {
      CalculateBox();
      DrawBox();
     }

   // Draw the post-box order placement end time line only if the box is drawn
   if (boxDrawn)
     {
      DrawOrderPlacementEndTime();
     }

   // After the box period, allow orders to be placed only within the post-box window
   if (currentTime > boxEndTime && currentTime <= orderPlacementEndTime && !orderPlacedToday)
     {
      CheckAndPlaceOrders();
     }

   // Close all trades at the specified time
   CloseAllTradesAtSpecificTime();

   // Manage trailing stop for active orders
   ManageTrailingStop();
  }
//+------------------------------------------------------------------+
//| Calculate box high and low                                       |
//+------------------------------------------------------------------+
void CalculateBox()
  {
   // Reset high and low
   boxHigh = -DBL_MAX;
   boxLow = DBL_MAX;

   // Loop through all bars in the box time range
   for (int i = 0; i < Bars; i++)
     {
      datetime barTime = iTime(NULL, 0, i);

      // If the bar is within the box period, update high and low
      if (barTime >= boxStartTime && barTime <= boxEndTime)
        {
         double barHigh = iHigh(NULL, 0, i);
         double barLow = iLow(NULL, 0, i);

         if (barHigh > boxHigh)
            boxHigh = barHigh;
         if (barLow < boxLow)
            boxLow = barLow;
        }

      // Exit the loop early if bars are outside the range
      if (barTime < boxStartTime)
         break;
     }

   // Calculate secondary breakout levels
   boxHigh2 = boxHigh + BoxHigh2Distance * Point;
   boxLow2 = boxLow - BoxLow2Distance * Point;
  }
//+------------------------------------------------------------------+
//| Draw the breakout box                                            |
//+------------------------------------------------------------------+
void DrawBox()
  {
   // Delete existing objects
   ObjectDelete(0, "BreakoutBoxHigh");
   ObjectDelete(0, "BreakoutBoxLow");
   ObjectDelete(0, "BreakoutBoxHigh2");
   ObjectDelete(0, "BreakoutBoxLow2");
   ObjectDelete(0, "BreakoutBoxStart");
   ObjectDelete(0, "BreakoutBoxEnd");

   // Draw high and low lines
   ObjectCreate(0, "BreakoutBoxHigh", OBJ_HLINE, 0, 0, boxHigh);
   ObjectSetInteger(0, "BreakoutBoxHigh", OBJPROP_COLOR, clrGreen);

   ObjectCreate(0, "BreakoutBoxLow", OBJ_HLINE, 0, 0, boxLow);
   ObjectSetInteger(0, "BreakoutBoxLow", OBJPROP_COLOR, clrRed);

   // Draw secondary levels
   ObjectCreate(0, "BreakoutBoxHigh2", OBJ_HLINE, 0, 0, boxHigh2);
   ObjectSetInteger(0, "BreakoutBoxHigh2", OBJPROP_COLOR, clrBlue);

   ObjectCreate(0, "BreakoutBoxLow2", OBJ_HLINE, 0, 0, boxLow2);
   ObjectSetInteger(0, "BreakoutBoxLow2", OBJPROP_COLOR, clrOrange);

   // Draw vertical lines for box start and end times
   ObjectCreate(0, "BreakoutBoxStart", OBJ_VLINE, 0, boxStartTime, 0);
   ObjectSetInteger(0, "BreakoutBoxStart", OBJPROP_COLOR, clrBlue);

   ObjectCreate(0, "BreakoutBoxEnd", OBJ_VLINE, 0, boxEndTime, 0);
   ObjectSetInteger(0, "BreakoutBoxEnd", OBJPROP_COLOR, clrBlue);

   // Mark the box as drawn
   boxDrawn = true;
  }
//+------------------------------------------------------------------+
//| Draw the post-box order placement end time                      |
//+------------------------------------------------------------------+
void DrawOrderPlacementEndTime()
  {
   ObjectDelete(0, "OrderPlacementEndTime");

   // Draw vertical line for the order placement end time
   ObjectCreate(0, "OrderPlacementEndTime", OBJ_VLINE, 0, orderPlacementEndTime, 0);
   ObjectSetInteger(0, "OrderPlacementEndTime", OBJPROP_COLOR, clrMagenta);
  }  
//+------------------------------------------------------------------+
//| Check for breakout and place market orders                      |
//+------------------------------------------------------------------+
void CheckAndPlaceOrders()
  {
   double lastBarClose = iClose(NULL, 0, 1);
   int currentDate = TimeDay(TimeCurrent());

   // Ensure the spread is within the allowed range
   double spread = (Ask - Bid) / Point;
   if (spread > MaxSpread)
     {
      Print("Spread too high. No trades placed. Spread: ", spread);
      return;
     }

   // Calculate the MTF Moving Average value
   double maValue = iMA(NULL, MATimeframe, MAPeriod, MAShift, MAMethod, MAAppliedPrice, 0);

   // Only trade once per day
   if (lastTradeDate != currentDate)
     {
      // Check if price breaks above boxHigh2 and MA filter condition is satisfied
      if (lastBarClose > boxHigh2 && lastBarClose > maValue)
        {
         PlaceBuyMarket();
         lastTradeDate = currentDate;
        }
      // Check if price breaks below boxLow2 and MA filter condition is satisfied
      else if (lastBarClose < boxLow2 && lastBarClose < maValue)
        {
         PlaceSellMarket();
         lastTradeDate = currentDate;
        }
     }
  }
//+------------------------------------------------------------------+
//| Place a Buy market order                                         |
//+------------------------------------------------------------------+
void PlaceBuyMarket()
{
   double stopLossDistance = MathAbs(Ask - boxLow); // Stop-loss distance in points
   double lotSize = CalculateLotSize(RiskPercentage, stopLossDistance / Point);

   // Validate Stop Loss price
   double stopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point;
   double stopLossPrice = NormalizeDouble(boxLow, Digits);

   // Ensure Stop Loss is at least the minimum stop level away from the Ask price
   if ((Ask - stopLossPrice) < stopLevel)
   {
      stopLossPrice = NormalizeDouble(Ask - stopLevel, Digits); // Adjust Stop Loss
   }

   // Validate lot size
   if (lotSize < MarketInfo(Symbol(), MODE_MINLOT) || lotSize > MarketInfo(Symbol(), MODE_MAXLOT))
   {
      Print("Invalid lot size: ", lotSize);
      return;
   }

   // Check if there is enough free margin
   double requiredMargin = MarketInfo(Symbol(), MODE_MARGINREQUIRED) * lotSize;
   if (AccountFreeMargin() < requiredMargin)
   {
      Print("Insufficient free margin to place Buy order. Required: ", requiredMargin, " Available: ", AccountFreeMargin());
      return;
   }

   // Place the Buy Order
   int buyTicket = OrderSend(Symbol(), OP_BUY, lotSize, Ask, Slippage, stopLossPrice, 0, "Breakout Buy", MagicNumber, 0, clrGreen);
   if (buyTicket < 0)
      Print("Failed to place Buy Market Order. Error: ", GetLastError());
   else
      Print("Buy Market Order placed. Lot size: ", lotSize, " Stop Loss: ", stopLossPrice);
}


//+------------------------------------------------------------------+
//| Place a Sell market order                                        |
//+------------------------------------------------------------------+
void PlaceSellMarket()
{
   double stopLossDistance = MathAbs(Bid - boxHigh); // Stop-loss distance in points
   double lotSize = CalculateLotSize(RiskPercentage, stopLossDistance / Point);

   // Validate Stop Loss price
   double stopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point;
   double stopLossPrice = NormalizeDouble(boxHigh, Digits);

   // Ensure Stop Loss is at least the minimum stop level away from the Bid price
   if ((stopLossPrice - Bid) < stopLevel)
   {
      stopLossPrice = NormalizeDouble(Bid + stopLevel, Digits); // Adjust Stop Loss
   }

   // Validate lot size
   if (lotSize < MarketInfo(Symbol(), MODE_MINLOT) || lotSize > MarketInfo(Symbol(), MODE_MAXLOT))
   {
      Print("Invalid lot size: ", lotSize);
      return;
   }

   // Check if there is enough free margin
   double requiredMargin = MarketInfo(Symbol(), MODE_MARGINREQUIRED) * lotSize;
   if (AccountFreeMargin() < requiredMargin)
   {
      Print("Insufficient free margin to place Sell order. Required: ", requiredMargin, " Available: ", AccountFreeMargin());
      return;
   }

   // Place the Sell Order
   int sellTicket = OrderSend(Symbol(), OP_SELL, lotSize, Bid, Slippage, stopLossPrice, 0, "Breakout Sell", MagicNumber, 0, clrRed);
   if (sellTicket < 0)
      Print("Failed to place Sell Market Order. Error: ", GetLastError());
   else
      Print("Sell Market Order placed. Lot size: ", lotSize, " Stop Loss: ", stopLossPrice);
}


//+------------------------------------------------------------------+
//| Calculate lot size based on risk percentage                     |
//+------------------------------------------------------------------+
double CalculateLotSize(double risk, double stopLossPoints)
  {
   double accountBalance = AccountBalance();
   double riskAmount = (accountBalance * risk) / 100.0;
   double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);

   if (tickValue <= 0)
     {
      Print("Error: Invalid tick value. Using default lot size.");
      return 0.01;
     }

   double lotSize = riskAmount / (stopLossPoints * tickValue);

   // Validate and adjust lot size to meet broker requirements
   double minLot = MarketInfo(Symbol(), MODE_MINLOT);
   double maxLot = MarketInfo(Symbol(), MODE_MAXLOT);
   double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);

   if (lotSize < minLot)
      lotSize = minLot;
   if (lotSize > maxLot)
      lotSize = maxLot;

   lotSize = NormalizeDouble(lotSize - MathMod(lotSize - minLot, lotStep), 2);
   return lotSize;
  }
//+------------------------------------------------------------------+
//| Close all trades at a specific time                             |
//+------------------------------------------------------------------+
void CloseAllTradesAtSpecificTime()
  {
   datetime currentTime = TimeCurrent();
   datetime closeTime = iTime(NULL, PERIOD_D1, 0) + CloseTradesHour * 3600;

   if (currentTime >= closeTime)
     {
      for (int i = OrdersTotal() - 1; i >= 0; i--)
        {
         if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == Symbol() && OrderCloseTime() == 0)
           {
            double closePrice = (OrderType() == OP_BUY) ? Bid : Ask;
            if (!OrderClose(OrderTicket(), OrderLots(), closePrice, Slippage, clrRed))
               Print("Failed to close order: ", OrderTicket(), " Error: ", GetLastError());
            else
               Print("Order closed: ", OrderTicket());
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Manage trailing stop for active orders                          |
//+------------------------------------------------------------------+
void ManageTrailingStop()
  {
   double stopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point; // Minimum stop distance
   double freezeLevel = MarketInfo(Symbol(), MODE_FREEZELEVEL) * Point; // Freeze level distance

   for (int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == Symbol())
        {
         double newStopLoss;

         // Manage trailing stop for Buy orders
         if (OrderType() == OP_BUY)
           {
            newStopLoss = NormalizeDouble(Bid - TrailingStopStep * Point, Digits);

            // Ensure new stop-loss level is valid
            if ((Bid - newStopLoss) < stopLevel || (Bid - newStopLoss) < freezeLevel)
              {
               Print("Trailing Stop for Buy order skipped: Invalid stop level. Order: ", OrderTicket());
               continue;
              }

            if (newStopLoss > OrderStopLoss() && newStopLoss > boxLow) // Ensure trailing stop advances
              {
               if (!OrderModify(OrderTicket(), OrderOpenPrice(), newStopLoss, OrderTakeProfit(), 0, clrGreen))
                  Print("Failed to modify Buy Stop Loss. Error: ", GetLastError());
               else
                  Print("Trailing Stop updated for Buy order: ", OrderTicket(), " New Stop Loss: ", newStopLoss);
              }
           }

         // Manage trailing stop for Sell orders
         if (OrderType() == OP_SELL)
           {
            newStopLoss = NormalizeDouble(Ask + TrailingStopStep * Point, Digits);

            // Ensure new stop-loss level is valid
            if ((newStopLoss - Ask) < stopLevel || (newStopLoss - Ask) < freezeLevel)
              {
               Print("Trailing Stop for Sell order skipped: Invalid stop level. Order: ", OrderTicket());
               continue;
              }

            if (newStopLoss < OrderStopLoss() && newStopLoss < boxHigh) // Ensure trailing stop advances
              {
               if (!OrderModify(OrderTicket(), OrderOpenPrice(), newStopLoss, OrderTakeProfit(), 0, clrRed))
                  Print("Failed to modify Sell Stop Loss. Error: ", GetLastError());
               else
                  Print("Trailing Stop updated for Sell order: ", OrderTicket(), " New Stop Loss: ", newStopLoss);
              }
           }
        }
     }
  }
