//+------------------------------------------------------------------+
//| Infinity Hedge tp and sl                                         |
//+------------------------------------------------------------------+

// Input parameters
input double ATRMultiplier = 0.5;
input int ATRPeriod = 14;
input ENUM_TIMEFRAMES ATRTimeframe = PERIOD_CURRENT;
input double LotSize = 1;
input string StartTime = "16:30";
input string EndTime = "17:30";
input int MagicNumber = 12345;

// Global variables
bool sessionStarted = false;
double hedgeLevel = 0;
int activeTradeTicket = -1;
double atrValue = 0;
datetime lastATRCalculation = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                  |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("EA Initialized with Magic Number: ", MagicNumber);
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| OnTick - Optimized for Speed                                    |
//+------------------------------------------------------------------+
void OnTick()
{
   datetime currentTime = TimeCurrent();
   datetime today = currentTime - TimeHour(currentTime) * 3600 - TimeMinute(currentTime) * 60;
   datetime start = StrToTime(TimeToString(today, TIME_DATE) + " " + StartTime);
   datetime end = StrToTime(TimeToString(today, TIME_DATE) + " " + EndTime);

   if (EndTime < StartTime) end += 86400; // Adjust for midnight crossover

   // ATR update only when a new candle appears
   if (lastATRCalculation != iTime(Symbol(), ATRTimeframe, 0))
   {
      atrValue = iATR(Symbol(), ATRTimeframe, ATRPeriod, 0);
      lastATRCalculation = iTime(Symbol(), ATRTimeframe, 0);
   }

   if (currentTime >= start && currentTime <= end)
   {
      if (!sessionStarted)
      {
         hedgeLevel = iOpen(Symbol(), PERIOD_M1, 0);
         PlaceHedgeOrders(hedgeLevel);
         sessionStarted = true;
      }
      ManageTradesAndOrders();
   }
   else if (sessionStarted)
   {
      EndOfDayCleanup();
      sessionStarted = false;
      hedgeLevel = 0;
      activeTradeTicket = -1;
   }
}

//+------------------------------------------------------------------+
//| End-of-day cleanup                                              |
//+------------------------------------------------------------------+
void EndOfDayCleanup()
{
   Print("End of trading session. Closing all trades and deleting all orders.");
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderMagicNumber() == MagicNumber)
      {
         int orderType = OrderType();
         if (orderType == OP_BUY || orderType == OP_SELL)
         {
            if (!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 3, clrRed))
               Print("Error closing trade: ", GetLastError());
         }
         else if (orderType == OP_BUYSTOP || orderType == OP_SELLSTOP)
         {
            if (!OrderDelete(OrderTicket()))
               Print("Error deleting pending order: ", GetLastError());
         }
      }
   }
   Print("All trades and orders closed.");
}

//+------------------------------------------------------------------+
//| Place Buy Stop & Sell Stop Orders                               |
//+------------------------------------------------------------------+
void PlaceHedgeOrders(double level)
{
   if (atrValue <= 0) return; // Avoid errors

   double distance = atrValue * ATRMultiplier;
   double buyStopPrice = NormalizeDouble(level + distance, Digits);
   double sellStopPrice = NormalizeDouble(level - distance, Digits);

   if (SendOrder(OP_BUYSTOP, buyStopPrice, "Buy Stop"))
      Print("Buy Stop placed at: ", buyStopPrice);
   if (SendOrder(OP_SELLSTOP, sellStopPrice, "Sell Stop"))
      Print("Sell Stop placed at: ", sellStopPrice);
}

//+------------------------------------------------------------------+
//| Fast & Reliable Order Execution                                 |
//+------------------------------------------------------------------+
bool SendOrder(int orderType, double price, string comment)
{
   double stopLoss = 0, takeProfit = 0;

   // Calculate midpoint SL and TP
   if (orderType == OP_BUYSTOP)
   {
      stopLoss = NormalizeDouble((price + hedgeLevel) / 2, Digits);
      takeProfit = NormalizeDouble(price + (price - stopLoss), Digits);
   }
   else if (orderType == OP_SELLSTOP)
   {
      stopLoss = NormalizeDouble((price + hedgeLevel) / 2, Digits);
      takeProfit = NormalizeDouble(price - (stopLoss - price), Digits);
   }

   int retry = 3;
   while (retry > 0)
   {
      int ticket = OrderSend(Symbol(), orderType, LotSize, price, 3, stopLoss, takeProfit, comment, MagicNumber, 0, clrGreen);
      if (ticket > 0) return true;

      int error = GetLastError();
      Print("Error placing ", comment, ": ", error);
      if (error == ERR_REQUOTE || error == ERR_OFF_QUOTES)
      {
         Sleep(300); retry--;
      }
      else break;
   }
   return false;
}


//+------------------------------------------------------------------+
//| Manage Active Trades & Orders                                  |
//+------------------------------------------------------------------+
void ManageTradesAndOrders()
{
   bool activeTradeExists = false;
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderMagicNumber() == MagicNumber)
      {
         if (OrderType() == OP_BUY || OrderType() == OP_SELL)
         {
            activeTradeExists = true;
            activeTradeTicket = OrderTicket();
            break;
         }
      }
   }

   if (!activeTradeExists && activeTradeTicket != -1)
   {
      hedgeLevel = GetLastClosedPrice(activeTradeTicket);
      DeleteAllPendingOrders();
      PlaceHedgeOrders(hedgeLevel);
      activeTradeTicket = -1;
   }
}

//+------------------------------------------------------------------+
//| Delete All Pending Orders                                       |
//+------------------------------------------------------------------+
void DeleteAllPendingOrders()
{
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) &&
          (OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP) &&
          OrderMagicNumber() == MagicNumber)
      {
         if (!OrderDelete(OrderTicket()))
            Print("Error deleting pending order: ", GetLastError());
      }
   }
}

//+------------------------------------------------------------------+
//| Get Last Closed Trade Price                                     |
//+------------------------------------------------------------------+
double GetLastClosedPrice(int ticket)
{
   for (int i = OrdersHistoryTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) && OrderTicket() == ticket)
      {
         return OrderClosePrice();
      }
   }
   return 0;
}
