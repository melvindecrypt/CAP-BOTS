//+------------------------------------------------------------------+
//| Session Highlighter Indicator - Supports Two Sessions           |
//+------------------------------------------------------------------+
#property indicator_chart_window

// Input Parameters - Session 1
input string  SessionLabel1  = "Session 1";  
input color   SessionColor1  = clrIndigo;     
input int     StartHour1     = 10;            
input int     StartMinute1   = 0;            
input int     EndHour1       = 15;            
input int     EndMinute1     = 0;             

// Input Parameters - Session 2
input string  SessionLabel2  = "Session 2";  
input color   SessionColor2  = clrPurple;     
input int     StartHour2     = 15;            
input int     StartMinute2   = 0;            
input int     EndHour2       = 22;            
input int     EndMinute2     = 0;            

input int     NumPreviousSessions = 3;  // Number of past sessions to show

//+------------------------------------------------------------------+
//| Indicator Initialization                                        |
//+------------------------------------------------------------------+
int OnInit()
{
   DrawSessionBackgrounds();
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Main Indicator Calculation Function                             |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[], const double &high[],
                const double &low[], const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[])
{
   static datetime lastUpdate = 0;
   if (TimeCurrent() - lastUpdate > 60) // Update only once per minute
   {
      DrawSessionBackgrounds();
      lastUpdate = TimeCurrent();
   }
   return rates_total;
}

//+------------------------------------------------------------------+
//| Function to Draw Session Backgrounds                           |
//+------------------------------------------------------------------+
void DrawSessionBackgrounds()
{
   // Get the current day start time
   MqlDateTime mt;
   TimeToStruct(TimeCurrent(), mt);
   datetime todayStart = StructToTime(mt) - mt.hour * 3600 - mt.min * 60 - mt.sec; // Midnight of current day

   // Get chart price range to ensure full coverage
   double highestPrice = WindowPriceMax();
   double lowestPrice = WindowPriceMin();

   // Loop through previous and upcoming sessions
   for (int i = -1; i <= NumPreviousSessions; i++) // -1 includes the upcoming session
   {
      // First session times
      datetime sessionStartTime1 = todayStart - i * 86400 + StartHour1 * 3600 + StartMinute1 * 60;
      datetime sessionEndTime1   = todayStart - i * 86400 + EndHour1 * 3600 + EndMinute1 * 60;
      string objectName1 = "Session1_" + Symbol() + "_" + IntegerToString(i);

      // Second session times
      datetime sessionStartTime2 = todayStart - i * 86400 + StartHour2 * 3600 + StartMinute2 * 60;
      datetime sessionEndTime2   = todayStart - i * 86400 + EndHour2 * 3600 + EndMinute2 * 60;
      string objectName2 = "Session2_" + Symbol() + "_" + IntegerToString(i);

      // Draw Session 1
      if (ObjectFind(objectName1) < 0)
      {
         if (!ObjectCreate(0, objectName1, OBJ_RECTANGLE, 0, sessionStartTime1, highestPrice))
         {
            Print("Failed to create object: ", objectName1);
            continue;
         }
      }
      ObjectSetInteger(0, objectName1, OBJPROP_TIME1, sessionStartTime1);
      ObjectSetInteger(0, objectName1, OBJPROP_TIME2, sessionEndTime1);
      ObjectSetDouble(0, objectName1, OBJPROP_PRICE1, highestPrice);
      ObjectSetDouble(0, objectName1, OBJPROP_PRICE2, lowestPrice);
      ObjectSetInteger(0, objectName1, OBJPROP_COLOR, SessionColor1);
      ObjectSetInteger(0, objectName1, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, objectName1, OBJPROP_BACK, true);
      ObjectSetInteger(0, objectName1, OBJPROP_HIDDEN, false);
      ObjectSetInteger(0, objectName1, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, objectName1, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, objectName1, OBJPROP_ZORDER, 0);

      // Draw Session 2
      if (ObjectFind(objectName2) < 0)
      {
         if (!ObjectCreate(0, objectName2, OBJ_RECTANGLE, 0, sessionStartTime2, highestPrice))
         {
            Print("Failed to create object: ", objectName2);
            continue;
         }
      }
      ObjectSetInteger(0, objectName2, OBJPROP_TIME1, sessionStartTime2);
      ObjectSetInteger(0, objectName2, OBJPROP_TIME2, sessionEndTime2);
      ObjectSetDouble(0, objectName2, OBJPROP_PRICE1, highestPrice);
      ObjectSetDouble(0, objectName2, OBJPROP_PRICE2, lowestPrice);
      ObjectSetInteger(0, objectName2, OBJPROP_COLOR, SessionColor2);
      ObjectSetInteger(0, objectName2, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, objectName2, OBJPROP_BACK, true);
      ObjectSetInteger(0, objectName2, OBJPROP_HIDDEN, false);
      ObjectSetInteger(0, objectName2, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, objectName2, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, objectName2, OBJPROP_ZORDER, 0);
   }
}

//+------------------------------------------------------------------+
//| Cleanup Function - Remove All Session Objects on Indicator Remove |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   for (int i = -1; i <= NumPreviousSessions; i++)
   {
      string objectName1 = "Session1_" + Symbol() + "_" + IntegerToString(i);
      string objectName2 = "Session2_" + Symbol() + "_" + IntegerToString(i);
      ObjectDelete(objectName1);
      ObjectDelete(objectName2);
   }
}
