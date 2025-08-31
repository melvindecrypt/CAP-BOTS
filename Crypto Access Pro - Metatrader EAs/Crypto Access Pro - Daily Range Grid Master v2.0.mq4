//+------------------------------------------------------------------+
//|       Free                             Daily Adr Grid EA Update  |
//+------------------------------------------------------------------+
#property version "1.0"
#property strict

//--- Input Parameters for Custom Lot Sizes
input double BuyLot1 = 0.01;
input double BuyLot2 = 0.03;
input double BuyLot3 = 0.08;
input double BuyLot4 = 0.35;
input double BuyLot5 = 2.8;

input double SellLot1 = 0.01;
input double SellLot2 = 0.03;
input double SellLot3 = 0.08;
input double SellLot4 = 0.35;
input double SellLot5 = 2.8;

input int ADR_Period = 20;              // ADR calculation period (20 days)
input int StartHour = 8;                // Hour when levels are set
input int StartMinute = 0;              // Minute when levels are set

//--- Global Variables
double Levels[9];                        // Levels (A to I)
datetime LastUpdate = 0;                 // Tracks the last update time for levels
bool LevelsSet = false;                  // Ensures levels remain fixed
bool TargetReached = false;              // Tracks if target level (C or G) is reached
bool BuySideActive = true;               // Tracks if buy-side is active
bool SellSideActive = true;              // Tracks if sell-side is active
int BuyProgressStep = 0;                 // Tracks progression for buy-side grid
int SellProgressStep = 0;                // Tracks progression for sell-side grid

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("Grid EA initialized with single-side logic (Buy or Sell).");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   DeleteGridLines();  // Delete all objects from the chart
   CloseAllTrades();   // Close all open and pending trades
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   datetime currentTime = TimeCurrent();
   int currentHour = TimeHour(currentTime);
   int currentMinute = TimeMinute(currentTime);
   
   //--- Ensure levels are set at the start time
   if (!LevelsSet && currentHour == StartHour && currentMinute >= StartMinute)
   {
      Print("Start time reached. Setting levels.");
      InitializeNewDay();
      LevelsSet = true;
   }

   //--- Close all trades if Level C or G is reached
   if (Ask >= Levels[2] || Bid <= Levels[6])
   {
      Print("Price reached Level C or G. Closing all trades.");
      CloseAllTrades();
      TargetReached = true;
      return;
   }

   //--- Close all trades at 23:30 if not already closed
   if (!TargetReached && currentHour == 23 && currentMinute >= 30)
   {
      Print("Closing all trades and pending orders at 23:30.");
      CloseAllTrades();
      return;
   }

   //--- Manage buy-side and sell-side grid logic
   if (BuySideActive)
      ManageBuySideGrid();

   if (SellSideActive)
      ManageSellSideGrid();
}

//+------------------------------------------------------------------+
//| Function to initialize levels and reset the grid                 |
//+------------------------------------------------------------------+
void InitializeNewDay()
{
   CloseAllTrades();  // Close all trades from the previous session

   CalculateLevels();  // Calculate new levels
   DeleteGridLines();  // Delete old levels
   DrawGridLines();    // Draw updated levels

   // Reset progression
   BuySideActive = true;
   SellSideActive = true;
   BuyProgressStep = 0;
   SellProgressStep = 0;
   TargetReached = false;

   // Place initial buy-side and sell-side orders
   if (!OrderExists("BuyStop_A_B"))
      PlaceBuyStop(GetMidpoint(Levels[0], Levels[1]), BuyLot1, "BuyStop_A_B");

   if (!OrderExists("SellStop_A_F"))
      PlaceSellStop(GetMidpoint(Levels[0], Levels[5]), SellLot1, "SellStop_A_F");
}

//+------------------------------------------------------------------+
//| Function to calculate daily levels                               |
//+------------------------------------------------------------------+
void CalculateLevels()
{
   // Get the open price at the specified start time
   datetime startCandleTime = iTime(_Symbol, PERIOD_M1, iBarShift(_Symbol, PERIOD_M1, iTime(_Symbol, PERIOD_D1, 0) + StartHour * 3600 + StartMinute * 60));
   double dailyOpen = iOpen(_Symbol, PERIOD_M1, iBarShift(_Symbol, PERIOD_M1, startCandleTime));
   double adr = CalculateADR(ADR_Period);

   //--- Calculate levels
   Levels[0] = dailyOpen;                       // Level A: Custom open price
   Levels[1] = dailyOpen + (0.15 * adr);        // Level B
   Levels[2] = dailyOpen + (0.30 * adr);        // Level C
   Levels[3] = dailyOpen + (0.45 * adr);        // Level D
   Levels[4] = dailyOpen + (0.60 * adr);        // Level E
   Levels[5] = dailyOpen - (0.15 * adr);        // Level F
   Levels[6] = dailyOpen - (0.30 * adr);        // Level G
   Levels[7] = dailyOpen - (0.45 * adr);        // Level H
   Levels[8] = dailyOpen - (0.60 * adr);        // Level I
}

//+------------------------------------------------------------------+
//| Function to calculate ADR                                        |
//+------------------------------------------------------------------+
double CalculateADR(int period)
{
   double totalRange = 0.0;
   for (int i = 1; i <= period; i++)
   {
      totalRange += (iHigh(_Symbol, PERIOD_D1, i) - iLow(_Symbol, PERIOD_D1, i));
   }
   return totalRange / period;
}

//+------------------------------------------------------------------+
//| Function to place a Buy Stop order                               |
//+------------------------------------------------------------------+
void PlaceBuyStop(double price, double lotSize, string comment)
{
   int slippage = 3;
   int ticket = OrderSend(_Symbol, OP_BUYSTOP, lotSize, price, slippage, 0, 0, comment, 0, 0, clrBlue);
   if (ticket < 0) Print("Failed to place Buy Stop: ", GetLastError());
}

//+------------------------------------------------------------------+
//| Function to place a Sell Stop order                              |
//+------------------------------------------------------------------+
void PlaceSellStop(double price, double lotSize, string comment)
{
   int slippage = 3;
   int ticket = OrderSend(_Symbol, OP_SELLSTOP, lotSize, price, slippage, 0, 0, comment, 0, 0, clrRed);
   if (ticket < 0) Print("Failed to place Sell Stop: ", GetLastError());
}


//+------------------------------------------------------------------+
//| Function to delete all pending buy-side orders                   |
//+------------------------------------------------------------------+
void DeletePendingBuyOrders()
{
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderType() == OP_BUYSTOP && OrderSymbol() == _Symbol)
      {
         if (!OrderDelete(OrderTicket()))
            Print("Failed to delete buy stop on ", _Symbol, ": ", GetLastError());
      }
   }
}


//+------------------------------------------------------------------+
//| Function to delete all pending sell-side orders                  |
//+------------------------------------------------------------------+
void DeletePendingSellOrders()
{
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderType() == OP_SELLSTOP && OrderSymbol() == _Symbol)
      {
         if (!OrderDelete(OrderTicket()))
            Print("Failed to delete sell stop on ", _Symbol, ": ", GetLastError());
      }
   }
}


//+------------------------------------------------------------------+
//| Function to manage the buy-side grid logic                       |
//+------------------------------------------------------------------+
void ManageBuySideGrid()
{
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         string comment = OrderComment();

         if (BuyProgressStep == 0 && comment == "BuyStop_A_B" && OrderType() == OP_BUY)
         {
            BuyProgressStep = 1;
            SellSideActive = false;
            DeletePendingSellOrders();
            PlaceSellStop(GetMidpoint(Levels[0], Levels[5]), SellLot2, "SellStop_A_F");
         }
         else if (BuyProgressStep == 1 && comment == "SellStop_A_F" && OrderType() == OP_SELL)
         {
            BuyProgressStep = 2;
            PlaceBuyStop(Levels[1], BuyLot3, "BuyStop_B");
         }
         else if (BuyProgressStep == 2 && comment == "BuyStop_B" && OrderType() == OP_BUY)
         {
            BuyProgressStep = 3;
            PlaceSellStop(Levels[5], SellLot4, "SellStop_F");
         }
         else if (BuyProgressStep == 3 && comment == "SellStop_F" && OrderType() == OP_SELL)
         {
            BuyProgressStep = 4;
            PlaceBuyStop(GetMidpoint(Levels[1], Levels[2]), BuyLot5, "BuyStop_B_C");
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Function to manage the sell-side grid logic                      |
//+------------------------------------------------------------------+
void ManageSellSideGrid()
{
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         string comment = OrderComment();

         if (SellProgressStep == 0 && comment == "SellStop_A_F" && OrderType() == OP_SELL)
         {
            SellProgressStep = 1;
            BuySideActive = false;
            DeletePendingBuyOrders();
            PlaceBuyStop(GetMidpoint(Levels[0], Levels[1]), BuyLot2, "BuyStop_A_B");
         }
         else if (SellProgressStep == 1 && comment == "BuyStop_A_B" && OrderType() == OP_BUY)
         {
            SellProgressStep = 2;
            PlaceSellStop(Levels[5], SellLot3, "SellStop_F");
         }
         else if (SellProgressStep == 2 && comment == "SellStop_F" && OrderType() == OP_SELL)
         {
            SellProgressStep = 3;
            PlaceBuyStop(Levels[1], BuyLot4, "BuyStop_B");
         }
         else if (SellProgressStep == 3 && comment == "BuyStop_B" && OrderType() == OP_BUY)
         {
            SellProgressStep = 4;
            PlaceSellStop(GetMidpoint(Levels[5], Levels[6]), SellLot5, "SellStop_F_G");
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Function to close all trades and pending orders for this pair    |
//+------------------------------------------------------------------+
void CloseAllTrades()
{
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == _Symbol) 
      {
         if (OrderType() == OP_BUY || OrderType() == OP_SELL)
         {
            if (!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 3, clrGray))
               Print("Failed to close trade on ", _Symbol, ": ", GetLastError());
         }
         else if (OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP)
         {
            if (!OrderDelete(OrderTicket()))
               Print("Failed to delete pending order on ", _Symbol, ": ", GetLastError());
         }
      }
   }
   LevelsSet = false;  // Allow new levels to be set after all trades close
}


//+------------------------------------------------------------------+
//| Function to check if an order with a specific comment exists     |
//+------------------------------------------------------------------+
bool OrderExists(string comment)
{
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == _Symbol)
      {
         if (OrderComment() == comment)
            return true;
      }
   }
   return false;
}


//+------------------------------------------------------------------+
//| Function to draw grid lines and labels                           |
//+------------------------------------------------------------------+
void DrawGridLines()
{
   string labels[] = {"Level A", "Level B", "Level C", "Level D", "Level E",
                      "Level F", "Level G", "Level H", "Level I"};

   for (int i = 0; i < ArraySize(Levels); i++)
   {
      string lineName = "GridLine_" + _Symbol + "_" + IntegerToString(i);
      string labelName = "Label_" + _Symbol + "_" + IntegerToString(i);

      if (ObjectFind(lineName) != -1) ObjectDelete(lineName);
      if (ObjectFind(labelName) != -1) ObjectDelete(labelName);

      color lineColor = clrGray;
      if (i == 0) lineColor = clrWhite;
      else if (i >= 1 && i <= 4) lineColor = clrLimeGreen;
      else if (i >= 5 && i <= 8) lineColor = clrOrangeRed;

      ObjectCreate(0, lineName, OBJ_HLINE, 0, 0, Levels[i]);
      ObjectSetInteger(0, lineName, OBJPROP_COLOR, lineColor);
      ObjectSetInteger(0, lineName, OBJPROP_STYLE, STYLE_DOT);

      ObjectCreate(0, labelName, OBJ_TEXT, 0, 0, Levels[i]);
      ObjectSetString(0, labelName, OBJPROP_TEXT, labels[i]);
      ObjectSetInteger(0, labelName, OBJPROP_COLOR, lineColor);
   }
}


//+------------------------------------------------------------------+
//| Function to get a valid price for pending orders                 |
//+------------------------------------------------------------------+
double GetMidpoint(double level1, double level2)
{
   return NormalizeDouble((level1 + level2) / 2.0, _Digits);
}

//+------------------------------------------------------------------+
//| Function to delete grid lines and labels                         |
//+------------------------------------------------------------------+
void DeleteGridLines()
{
   for (int i = 0; i < 9; i++)
   {
      string lineName = "GridLine_" + _Symbol + "_" + IntegerToString(i);
      string labelName = "Label_" + _Symbol + "_" + IntegerToString(i);
      
      ObjectDelete(0, lineName);
      ObjectDelete(0, labelName);
   }
}

