//+------------------------------------------------------------------+
//|   Indicator: 10-Day Average High, Mid, Low with Extensions       |
//|   Author: MQL4 Code Wizard                                       |
//|   Purpose: Draws key levels based on past 10 days' data          |
//+------------------------------------------------------------------+
#property indicator_chart_window

// User input: Number of days to display (including today)
extern int DaysToShow = 3;  // Default: Show today + 2 previous days

//+------------------------------------------------------------------+
//| Custom Indicator Initialization                                 |
//+------------------------------------------------------------------+
int OnInit()
{
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Indicator Cleanup When Removed                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Loop through all the days displayed and remove all objects
    for (int i = 0; i < DaysToShow; i++)
    {
        string suffix = "_" + IntegerToString(i);

        // Delete Lines
        ObjectDelete("HighAvgLine" + suffix);
        ObjectDelete("MidAvgLine" + suffix);
        ObjectDelete("LowAvgLine" + suffix);
        ObjectDelete("High1Line" + suffix);
        ObjectDelete("High2Line" + suffix);
        ObjectDelete("High3Line" + suffix);
        ObjectDelete("Low1Line" + suffix);
        ObjectDelete("Low2Line" + suffix);
        ObjectDelete("Low3Line" + suffix);

        // Delete Labels
        ObjectDelete("HighAvgLabel" + suffix);
        ObjectDelete("MidAvgLabel" + suffix);
        ObjectDelete("LowAvgLabel" + suffix);
        ObjectDelete("High1Label" + suffix);
        ObjectDelete("High2Label" + suffix);
        ObjectDelete("High3Label" + suffix);
        ObjectDelete("Low1Label" + suffix);
        ObjectDelete("Low2Label" + suffix);
        ObjectDelete("Low3Label" + suffix);
    }
}

//+------------------------------------------------------------------+
//| Indicator Calculation Function                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,      // Rates
                const int prev_calculated,  // Calculate previous 
                const datetime &time[],     // Time 
                const double &open[],       // Open 
                const double &high[],       // High 
                const double &low[],        // Low 
                const double &close[],      // Close 
                const long &tick_volume[],  // Tick Volume 
                const long &volume[],       // Real Volume 
                const int &spread[])        
{
    if (rates_total < 10) return 0;  // Ensure there are at least 10 days of data

    // Loop through each day to calculate its own previous 10 days' average
    for (int dayOffset = 0; dayOffset < DaysToShow; dayOffset++)
    {
        double highSum = 0, lowSum = 0;
        
        // Get previous 10 days' High and Low for the current dayOffset
        for (int i = 1; i <= 10; i++)  
        {
            highSum += iHigh(NULL, PERIOD_D1, i + dayOffset);  
            lowSum  += iLow(NULL, PERIOD_D1, i + dayOffset);
        }

        // Compute Averages for this specific day
        double HighAvg = highSum / 10;
        double LowAvg  = lowSum / 10;
        double MidAvg  = (HighAvg + LowAvg) / 2;

        // Calculate 3 levels above and below
        double range = HighAvg - MidAvg;
        double High1 = HighAvg + range;
        double High2 = High1 + range;
        double High3 = High2 + range;
        double Low1 = LowAvg - range;
        double Low2 = Low1 - range;
        double Low3 = Low2 - range;

        // Get the start and end time of the day being processed
        datetime dayStart = iTime(NULL, PERIOD_D1, dayOffset);
        datetime dayEnd = dayStart + 86400; // Add 24 hours (86400 seconds)

        // Unique names for each day's levels
        string suffix = "_" + IntegerToString(dayOffset);

        // Remove previous objects before drawing new ones
        ObjectDelete("HighAvgLine" + suffix);
        ObjectDelete("MidAvgLine" + suffix);
        ObjectDelete("LowAvgLine" + suffix);
        ObjectDelete("High1Line" + suffix);
        ObjectDelete("High2Line" + suffix);
        ObjectDelete("High3Line" + suffix);
        ObjectDelete("Low1Line" + suffix);
        ObjectDelete("Low2Line" + suffix);
        ObjectDelete("Low3Line" + suffix);

        ObjectDelete("HighAvgLabel" + suffix);
        ObjectDelete("MidAvgLabel" + suffix);
        ObjectDelete("LowAvgLabel" + suffix);
        ObjectDelete("High1Label" + suffix);
        ObjectDelete("High2Label" + suffix);
        ObjectDelete("High3Label" + suffix);
        ObjectDelete("Low1Label" + suffix);
        ObjectDelete("Low2Label" + suffix);
        ObjectDelete("Low3Label" + suffix);

        // Draw levels
        DrawLevelLine("HighAvgLine" + suffix, HighAvg, clrRed, dayStart, dayEnd, "High Avg");
        DrawLevelLine("MidAvgLine" + suffix, MidAvg, clrBlue, dayStart, dayEnd, "Mid Avg");
        DrawLevelLine("LowAvgLine" + suffix, LowAvg, clrGreen, dayStart, dayEnd, "Low Avg");

        DrawLevelLine("High1Line" + suffix, High1, clrMagenta, dayStart, dayEnd, "High 1");
        DrawLevelLine("High2Line" + suffix, High2, clrMagenta, dayStart, dayEnd, "High 2");
        DrawLevelLine("High3Line" + suffix, High3, clrMagenta, dayStart, dayEnd, "High 3");

        DrawLevelLine("Low1Line" + suffix, Low1, clrMagenta, dayStart, dayEnd, "Low 1");
        DrawLevelLine("Low2Line" + suffix, Low2, clrMagenta, dayStart, dayEnd, "Low 2");
        DrawLevelLine("Low3Line" + suffix, Low3, clrMagenta, dayStart, dayEnd, "Low 3");
    }

    return rates_total;  // Ensure function returns a value
}

//+------------------------------------------------------------------+
//| Function to draw a line for each day                            |
//+------------------------------------------------------------------+
void DrawLevelLine(string name, double price, color lineColor, datetime startTime, datetime endTime, string labelText)
{
    // Create a trendline from the start to the end of the specified day
    ObjectCreate(0, name, OBJ_TREND, 0, startTime, price, endTime, price);
    ObjectSetInteger(0, name, OBJPROP_COLOR, lineColor);
    ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);
    ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
    ObjectSetInteger(0, name, OBJPROP_RAY_LEFT, false);
    
    // Create a text label near the end of the line
    string labelName = name + "_Label";
    ObjectCreate(0, labelName, OBJ_TEXT, 0, endTime, price);
    ObjectSetInteger(0, labelName, OBJPROP_COLOR, lineColor);
    ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 10);
    ObjectSetString(0, labelName, OBJPROP_TEXT, labelText);
    ObjectSetInteger(0, labelName, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
}
