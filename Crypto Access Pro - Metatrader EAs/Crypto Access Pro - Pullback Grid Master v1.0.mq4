//+------------------------------------------------------------------+
//|           Pullback Grid EA                            Free       |
//+------------------------------------------------------------------+

#property version   "1.00"
#property strict ""

enum timeMtd
  {
     minutes,     //Minutes
     hour         //Hours
  };


input string     Time_Filter                                                  = "----------------------------------------------------";              //Time Filter
input string     Start_Time                                                   = "00:00";                                                             //Start Time
input string     End_Time                                                     = "24:00";                                                             //End Time
input string     Time_Delay                                                   = "----------------------------------------------------";              //Time Delay
input timeMtd    time                                                         = minutes;                                                             //Time Method
input int        Time_Delay_Minutes                                           = 0;                                                                   //Time To Delay (Minutes)

input string     Grid_Start            = "----------------------------------------------------"; //1st Grid Settings
extern double    BuyLimit1_Lotsize                                            = 0.01;            //LotSize of 1st Buy Limit
extern double    SellLimit1_Lotsize                                           = 0.01;            //LotSize of 1st Sell Limit
extern double    BuyLimit_Distance_From_Start                                 = 3400;             //Buy Limit distance from start in points
extern double    SellLimit_Distance_From_Start                                = 3400;             //Sell Limit distance from start in points
extern double    BuyLimit1_TP_in_Points                                       = 10;              //Take Profit for 1st Buy Limit
extern double    SellLimit1_TP_in_Points                                      = 10;              //Take Profit for 1st Sell Limit

input string     Grid_SL            = "----------------------------------------------------";    //Stop Loss Settings
extern double    Buylimit1_SL_in_Points                                       = 300000;           //Stop Loss for entire grid cycle - Buy Limit side
extern double    SellLimit1_SL_in_Points                                      = 300000;           //Stop Loss for entire grid cycle - Sell Limit side

input string     Grid_2nd            = "----------------------------------------------------";   //2nd Grid Settings
extern double    BuyLimit2_Lotsize                                            = 0.01;            //LotSize of 2nd Buy Limit
extern double    SellLimit2_Lotsize                                           = 0.01;            //LotSize of 2nd Sell Limit
extern double    BuyLimit2_Distance_From_Start                                 = 3400;            //Buy Limit distance from 1st Buy Limit
extern double    SellLimit2_Distance_From_Start                                = 3400;            //Sell Limit distance from 1st Sell Limit
extern double    BuyLimit2_TP_in_Points                                       = 3000;             //Take Profit for 2nd Buy Limit
extern double    SellLimit2_TP_in_Points                                      = 3000;             //Take Profit for 2nd Buy Limit

input string     Grid_3rd            = "----------------------------------------------------";   //3rd Grid Settings
extern double    BuyLimit3_Lotsize                                            = 0.02;            //LotSize of 3rd Buy Limit
extern double    SellLimit3_Lotsize                                           = 0.02;            //LotSize of 3rd Sell Limit
extern double    BuyLimit3_Distance_From_Start                                 = 3400;            //Buy Limit distance from 2nd Buy Limit
extern double    SellLimit3_Distance_From_Start                                = 3400;            //Sell Limit distance from 2nd Sell Limit
extern double    BuyLimit3_TP_in_Points                                       = 3000;             //Take Profit for 3rd Buy Limit
extern double    SellLimit3_TP_in_Points                                      = 3000;             //Take Profit for 3rd Buy Limit

input string     Grid_4th            = "----------------------------------------------------";   //4th Grid Settings
extern double    BuyLimit4_Lotsize                                            = 0.03;            //LotSize of 4th Buy Limit
extern double    SellLimit4_Lotsize                                           = 0.03;            //LotSize of 4th Sell Limit
extern double    BuyLimit4_Distance_From_Start                                 = 4400;            //Buy Limit distance from 3rd Buy Limit
extern double    SellLimit4_Distance_From_Start                                = 4400;            //Sell Limit distance from 3rd Sell Limit
extern double    BuyLimit4_TP_in_Points                                       = 4000;             //Take Profit for 4th Buy Limit
extern double    SellLimit4_TP_in_Points                                      = 4000;             //Take Profit for 4th Buy Limit

input string     Grid_5th            = "----------------------------------------------------";   //5th Grid Settings
extern double    BuyLimit5_Lotsize                                            = 0.05;            //LotSize of 5th Buy Limit
extern double    SellLimit5_Lotsize                                           = 0.05;            //LotSize of 5th Sell Limit
extern double    BuyLimit5_Distance_From_Start                                 = 4400;            //Buy Limit distance from 4th Buy Limit
extern double    SellLimit5_Distance_From_Start                                = 4400;            //Sell Limit distance from 4th Sell Limit
extern double    BuyLimit5_TP_in_Points                                       = 4000;             //Take Profit for 5th Buy Limit
extern double    SellLimit5_TP_in_Points                                      = 4000;             //Take Profit for 5th Buy Limit

input string     Grid_6th            = "----------------------------------------------------";   //6th Grid Settings
extern double    BuyLimit6_Lotsize                                            = 0.08;               //LotSize of 6th Buy Limit
extern double    SellLimit6_Lotsize                                           = 0.08;               //LotSize of 6th Sell Limit
extern double    BuyLimit6_Distance_From_Start                                 = 4400;            //Buy Limit distance from 5th Buy Limit
extern double    SellLimit6_Distance_From_Start                                = 4400;            //Sell Limit distance from 5th Sell Limit
extern double    BuyLimit6_TP_in_Points                                       = 4000;             //Take Profit for 6th Buy Limit
extern double    SellLimit6_TP_in_Points                                      = 4000;             //Take Profit for 6th Buy Limit

input string     Grid_7th            = "----------------------------------------------------";   //7th Grid Settings
extern double    BuyLimit7_Lotsize                                            = 0.12;             //LotSize of 7th Buy Limit
extern double    SellLimit7_Lotsize                                           = 0.12;             //LotSize of 7th Sell Limit
extern double    BuyLimit7_Distance_From_Start                                 = 4400;            //Buy Limit distance from 6th Buy Limit
extern double    SellLimit7_Distance_From_Start                                = 4400;            //Sell Limit distance from 6th Sell Limit
extern double    BuyLimit7_TP_in_Points                                       = 4000;             //Take Profit for 7th Buy Limit
extern double    SellLimit7_TP_in_Points                                      = 4000;             //Take Profit for 7th Buy Limit

input string     Grid_8th            = "----------------------------------------------------";   //8th Grid Settings
extern double    BuyLimit8_Lotsize                                            = 0.16;             //LotSize of 8th Buy Limit
extern double    SellLimit8_Lotsize                                           = 0.16;             //LotSize of 8th Sell Limit
extern double    BuyLimit8_Distance_From_Start                                 = 5400;            //Buy Limit distance from 7th Buy Limit
extern double    SellLimit8_Distance_From_Start                                = 5400;            //Sell Limit distance from 7th Sell Limit
extern double    BuyLimit8_TP_in_Points                                       = 5000;             //Take Profit for 8th Buy Limit
extern double    SellLimit8_TP_in_Points                                      = 5000;             //Take Profit for 8th Buy Limit

input string     Grid_9th            = "----------------------------------------------------";   //9th Grid Settings
extern double    BuyLimit9_Lotsize                                            = 0.23;              //LotSize of 9th Buy Limit
extern double    SellLimit9_Lotsize                                           = 0.23;              //LotSize of 9th Sell Limit
extern double    BuyLimit9_Distance_From_Start                                 = 6400;            //Buy Limit distance from 8th Buy Limit
extern double    SellLimit9_Distance_From_Start                                = 6400;            //Sell Limit distance from 8th Sell Limit
extern double    BuyLimit9_TP_in_Points                                       = 6000;             //Take Profit for 9th Buy Limit
extern double    SellLimit9_TP_in_Points                                      = 6000;             //Take Profit for 9th Buy Limit

input string     Grid_10th            = "----------------------------------------------------";   //10th Grid Settings
extern double    BuyLimit10_Lotsize                                            = 0.31;              //LotSize of 10th Buy Limit
extern double    SellLimit10_Lotsize                                           = 0.31;              //LotSize of 10th Sell Limit
extern double    BuyLimit10_Distance_From_Start                                 = 7400;            //Buy Limit distance from 9th Buy Limit
extern double    SellLimit10_Distance_From_Start                                = 7400;            //Sell Limit distance from 9th Sell Limit
extern double    BuyLimit10_TP_in_Points                                       = 7000;             //Take Profit for 10th Buy Limit
extern double    SellLimit10_TP_in_Points                                      = 7000;             //Take Profit for 10th Buy Limit

input string     Grid_11th            = "----------------------------------------------------";   //11th Grid Settings
extern double    BuyLimit11_Lotsize                                            = 0.47;              //LotSize of 11th Buy Limit
extern double    SellLimit11_Lotsize                                           = 0.47;              //LotSize of 11th Sell Limit
extern double    BuyLimit11_Distance_From_Start                                 = 8400;            //Buy Limit distance from 10th Buy Limit
extern double    SellLimit11_Distance_From_Start                                = 8400;            //Sell Limit distance from 10th Sell Limit
extern double    BuyLimit11_TP_in_Points                                       = 8000;             //Take Profit for 11th Buy Limit
extern double    SellLimit11_TP_in_Points                                      = 8000;             //Take Profit for 11th Buy Limit

input string     Grid_12th            = "----------------------------------------------------";   //12th Grid Settings
extern double    BuyLimit12_Lotsize                                            = 0.72;             //LotSize of 12th Buy Limit
extern double    SellLimit12_Lotsize                                           = 0.72;             //LotSize of 12th Sell Limit
extern double    BuyLimit12_Distance_From_Start                                 = 9400;            //Buy Limit distance from 11th Buy Limit
extern double    SellLimit12_Distance_From_Start                                = 9400;            //Sell Limit distance from 11th Sell Limit
extern double    BuyLimit12_TP_in_Points                                       = 9000;             //Take Profit for 12th Buy Limit
extern double    SellLimit12_TP_in_Points                                      = 9000;             //Take Profit for 12th Buy Limit

input string     Grid_13th            = "----------------------------------------------------";   //13th Grid Settings
extern double    BuyLimit13_Lotsize                                            = 1.1;              //LotSize of 13th Buy Limit
extern double    SellLimit13_Lotsize                                           = 1.1;              //LotSize of 13th Sell Limit
extern double    BuyLimit13_Distance_From_Start                                 = 10400;            //Buy Limit distance from 12th Buy Limit
extern double    SellLimit13_Distance_From_Start                                = 10400;            //Sell Limit distance from 12th Sell Limit
extern double    BuyLimit13_TP_in_Points                                       = 10000;             //Take Profit for 13th Buy Limit
extern double    SellLimit13_TP_in_Points                                      = 10000;             //Take Profit for 13th Buy Limit

input string     Grid_14th            = "----------------------------------------------------";   //14th Grid Settings
extern double    BuyLimit14_Lotsize                                            = 1.8;             //LotSize of 14th Buy Limit
extern double    SellLimit14_Lotsize                                           = 1.8;             //LotSize of 14th Sell Limit
extern double    BuyLimit14_Distance_From_Start                                 = 11400;            //Buy Limit distance from 13th Buy Limit
extern double    SellLimit14_Distance_From_Start                                = 11400;            //Sell Limit distance from 13th Sell Limit
extern double    BuyLimit14_TP_in_Points                                       = 11000;             //Take Profit for 14th Buy Limit
extern double    SellLimit14_TP_in_Points                                      = 11000;             //Take Profit for 14th Buy Limit






bool      useProfitToClose       = true;
bool      AllSymbols             = true;
bool      PendingOrders          = true;
  
double pips2dbl, pips2point, pipValue,profit;
            
bool   clear;

int   medzera = 8,
      magicNumber=1234;
int   trades, maxSlippage;
long   lastTime, lastClose;
int    lastTicket, lastType;
string lastSymbol;

double menulots;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   
   
    return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
    firstGrid();
    otherGrids();
    profitCheck();
   
}

  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void firstGrid()
{
   if(CheckMoneyForTrade(Symbol(),BuyLimit1_Lotsize,OP_BUY)==true)
   if(CheckVolumeValue(BuyLimit1_Lotsize,"Correct volume value")==true)
   if (Count_BuyLimit()==0 && Count_SellLimit()==0)
   if (timeTrade() && timeDelay())
      {
        if (!OrderSend (_Symbol,OP_BUYLIMIT,BuyLimit1_Lotsize,Bid-(BuyLimit_Distance_From_Start*_Point),3,Bid-Buylimit1_SL_in_Points*_Point,Ask+BuyLimit1_TP_in_Points*_Point,NULL,magicNumber,0,clrGreen))
           {
              Print("Order Send Failed! ", ErrorDescription(GetLastError()));
           }
        if (!OrderSend (_Symbol,OP_SELLLIMIT,SellLimit1_Lotsize,Ask+(SellLimit_Distance_From_Start*_Point),3,Ask+SellLimit1_SL_in_Points*_Point,Bid-SellLimit1_TP_in_Points*_Point,NULL,magicNumber,0,clrRed))
           {
              Print("Order Send Failed! ", ErrorDescription(GetLastError()));
           }
      }
} 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void otherGrids()
{
       
       
       if(Count_Buy()==1 && Count_BuyLimit()==0)
         {
            if (!OrderSend (_Symbol,OP_BUYLIMIT,BuyLimit2_Lotsize,Bid-(BuyLimit2_Distance_From_Start*_Point),3,NULL,Ask+BuyLimit2_TP_in_Points*_Point,NULL,magicNumber,0,clrGreen))
               {
                 Print("Order Send Failed! ", ErrorDescription(GetLastError()));
               }
         }

       if(Count_Sell()==1 && Count_SellLimit()==0)
         {
            if (!OrderSend (_Symbol,OP_SELLLIMIT,SellLimit2_Lotsize,Ask+(SellLimit2_Distance_From_Start*_Point),3,NULL,Bid-SellLimit2_TP_in_Points*_Point,NULL,magicNumber,0,clrRed))
               {
                 Print("Order Send Failed! ", ErrorDescription(GetLastError()));
               }
         }
     
       if(Count_Buy()==2 && Count_BuyLimit()==0)
         {
            if (!OrderSend (_Symbol,OP_BUYLIMIT,BuyLimit3_Lotsize,Bid-(BuyLimit3_Distance_From_Start*_Point),3,NULL,Ask+BuyLimit3_TP_in_Points*_Point,NULL,magicNumber,0,clrGreen))
               {
                 Print("Order Send Failed! ", ErrorDescription(GetLastError()));
               }
         }

       if(Count_Sell()==2 && Count_SellLimit()==0)
         {
            if (!OrderSend (_Symbol,OP_SELLLIMIT,SellLimit3_Lotsize,Ask+(SellLimit3_Distance_From_Start*_Point),3,NULL,Bid-SellLimit3_TP_in_Points*_Point,NULL,magicNumber,0,clrRed))
               {
                 Print("Order Send Failed! ", ErrorDescription(GetLastError()));
               }
         }
         
          if(Count_Buy()==3 && Count_BuyLimit()==0)
         {
            if (!OrderSend (_Symbol,OP_BUYLIMIT,BuyLimit4_Lotsize,Bid-(BuyLimit4_Distance_From_Start*_Point),3,NULL,Ask+BuyLimit4_TP_in_Points*_Point,NULL,magicNumber,0,clrGreen))
               {
                 Print("Order Send Failed! ", ErrorDescription(GetLastError()));
               }
         }

       if(Count_Sell()==3 && Count_SellLimit()==0)
         {
            if (!OrderSend (_Symbol,OP_SELLLIMIT,SellLimit4_Lotsize,Ask+(SellLimit4_Distance_From_Start*_Point),3,NULL,Bid-SellLimit4_TP_in_Points*_Point,NULL,magicNumber,0,clrRed))
               {
                 Print("Order Send Failed! ", ErrorDescription(GetLastError()));
               }
         }
         
         if(Count_Buy()==4 && Count_BuyLimit()==0)
         {
            if (!OrderSend (_Symbol,OP_BUYLIMIT,BuyLimit5_Lotsize,Bid-(BuyLimit5_Distance_From_Start*_Point),3,NULL,Ask+BuyLimit5_TP_in_Points*_Point,NULL,magicNumber,0,clrGreen))
               {
                 Print("Order Send Failed! ", ErrorDescription(GetLastError()));
               }
         }

       if(Count_Sell()==4 && Count_SellLimit()==0)
         {
            if (!OrderSend (_Symbol,OP_SELLLIMIT,SellLimit5_Lotsize,Ask+(SellLimit5_Distance_From_Start*_Point),3,NULL,Bid-SellLimit5_TP_in_Points*_Point,NULL,magicNumber,0,clrRed))
               {
                 Print("Order Send Failed! ", ErrorDescription(GetLastError()));
               }
         }
         
         if(Count_Buy()==5 && Count_BuyLimit()==0)
         {
            if (!OrderSend (_Symbol,OP_BUYLIMIT,BuyLimit6_Lotsize,Bid-(BuyLimit6_Distance_From_Start*_Point),3,NULL,Ask+BuyLimit6_TP_in_Points*_Point,NULL,magicNumber,0,clrGreen))
               {
                 Print("Order Send Failed! ", ErrorDescription(GetLastError()));
               }
         }

       if(Count_Sell()==5 && Count_SellLimit()==0)
         {
            if (!OrderSend (_Symbol,OP_SELLLIMIT,SellLimit6_Lotsize,Ask+(SellLimit6_Distance_From_Start*_Point),3,NULL,Bid-SellLimit6_TP_in_Points*_Point,NULL,magicNumber,0,clrRed))
               {
                 Print("Order Send Failed! ", ErrorDescription(GetLastError()));
               }
         }
         
         if(Count_Buy()==6 && Count_BuyLimit()==0)
         {
            if (!OrderSend (_Symbol,OP_BUYLIMIT,BuyLimit7_Lotsize,Bid-(BuyLimit7_Distance_From_Start*_Point),3,NULL,Ask+BuyLimit7_TP_in_Points*_Point,NULL,magicNumber,0,clrGreen))
               {
                 Print("Order Send Failed! ", ErrorDescription(GetLastError()));
               }
         }

       if(Count_Sell()==6 && Count_SellLimit()==0)
         {
            if (!OrderSend (_Symbol,OP_SELLLIMIT,SellLimit7_Lotsize,Ask+(SellLimit7_Distance_From_Start*_Point),3,NULL,Bid-SellLimit7_TP_in_Points*_Point,NULL,magicNumber,0,clrRed))
               {
                 Print("Order Send Failed! ", ErrorDescription(GetLastError()));
               }
         }
         
         if(Count_Buy()==7 && Count_BuyLimit()==0)
         {
            if (!OrderSend (_Symbol,OP_BUYLIMIT,BuyLimit8_Lotsize,Bid-(BuyLimit8_Distance_From_Start*_Point),3,NULL,Ask+BuyLimit8_TP_in_Points*_Point,NULL,magicNumber,0,clrGreen))
               {
                 Print("Order Send Failed! ", ErrorDescription(GetLastError()));
               }
         }

       if(Count_Sell()==7 && Count_SellLimit()==0)
         {
            if (!OrderSend (_Symbol,OP_SELLLIMIT,SellLimit8_Lotsize,Ask+(SellLimit8_Distance_From_Start*_Point),3,NULL,Bid-SellLimit8_TP_in_Points*_Point,NULL,magicNumber,0,clrRed))
               {
                 Print("Order Send Failed! ", ErrorDescription(GetLastError()));
               }
         }
         
         if(Count_Buy()==8 && Count_BuyLimit()==0)
         {
            if (!OrderSend (_Symbol,OP_BUYLIMIT,BuyLimit9_Lotsize,Bid-(BuyLimit9_Distance_From_Start*_Point),3,NULL,Ask+BuyLimit9_TP_in_Points*_Point,NULL,magicNumber,0,clrGreen))
               {
                 Print("Order Send Failed! ", ErrorDescription(GetLastError()));
               }
         }

       if(Count_Sell()==8 && Count_SellLimit()==0)
         {
            if (!OrderSend (_Symbol,OP_SELLLIMIT,SellLimit9_Lotsize,Ask+(SellLimit9_Distance_From_Start*_Point),3,NULL,Bid-SellLimit9_TP_in_Points*_Point,NULL,magicNumber,0,clrRed))
               {
                 Print("Order Send Failed! ", ErrorDescription(GetLastError()));
               }
         }
         
         if(Count_Buy()==9 && Count_BuyLimit()==0)
         {
            if (!OrderSend (_Symbol,OP_BUYLIMIT,BuyLimit10_Lotsize,Bid-(BuyLimit10_Distance_From_Start*_Point),3,NULL,Ask+BuyLimit10_TP_in_Points*_Point,NULL,magicNumber,0,clrGreen))
               {
                 Print("Order Send Failed! ", ErrorDescription(GetLastError()));
               }
         }

       if(Count_Sell()==9 && Count_SellLimit()==0)
         {
            if (!OrderSend (_Symbol,OP_SELLLIMIT,SellLimit10_Lotsize,Ask+(SellLimit10_Distance_From_Start*_Point),3,NULL,Bid-SellLimit10_TP_in_Points*_Point,NULL,magicNumber,0,clrRed))
               {
                 Print("Order Send Failed! ", ErrorDescription(GetLastError()));
               }
         }
         
         if(Count_Buy()==10 && Count_BuyLimit()==0)
         {
            if (!OrderSend (_Symbol,OP_BUYLIMIT,BuyLimit11_Lotsize,Bid-(BuyLimit11_Distance_From_Start*_Point),3,NULL,Ask+BuyLimit11_TP_in_Points*_Point,NULL,magicNumber,0,clrGreen))
               {
                 Print("Order Send Failed! ", ErrorDescription(GetLastError()));
               }
         }

       if(Count_Sell()==10 && Count_SellLimit()==0)
         {
            if (!OrderSend (_Symbol,OP_SELLLIMIT,SellLimit11_Lotsize,Ask+(SellLimit11_Distance_From_Start*_Point),3,NULL,Bid-SellLimit11_TP_in_Points*_Point,NULL,magicNumber,0,clrRed))
               {
                 Print("Order Send Failed! ", ErrorDescription(GetLastError()));
               }
         }
         
         if(Count_Buy()==11 && Count_BuyLimit()==0)
         {
            if (!OrderSend (_Symbol,OP_BUYLIMIT,BuyLimit12_Lotsize,Bid-(BuyLimit12_Distance_From_Start*_Point),3,NULL,Ask+BuyLimit12_TP_in_Points*_Point,NULL,magicNumber,0,clrGreen))
               {
                 Print("Order Send Failed! ", ErrorDescription(GetLastError()));
               }
         }

       if(Count_Sell()==11 && Count_SellLimit()==0)
         {
            if (!OrderSend (_Symbol,OP_SELLLIMIT,SellLimit12_Lotsize,Ask+(SellLimit12_Distance_From_Start*_Point),3,NULL,Bid-SellLimit12_TP_in_Points*_Point,NULL,magicNumber,0,clrRed))
               {
                 Print("Order Send Failed! ", ErrorDescription(GetLastError()));
               }
         }
     
     if(Count_Buy()==12 && Count_BuyLimit()==0)
         {
            if (!OrderSend (_Symbol,OP_BUYLIMIT,BuyLimit13_Lotsize,Bid-(BuyLimit13_Distance_From_Start*_Point),3,NULL,Ask+BuyLimit13_TP_in_Points*_Point,NULL,magicNumber,0,clrGreen))
               {
                 Print("Order Send Failed! ", ErrorDescription(GetLastError()));
               }
         }

       if(Count_Sell()==12 && Count_SellLimit()==0)
         {
            if (!OrderSend (_Symbol,OP_SELLLIMIT,SellLimit13_Lotsize,Ask+(SellLimit13_Distance_From_Start*_Point),3,NULL,Bid-SellLimit13_TP_in_Points*_Point,NULL,magicNumber,0,clrRed))
               {
                 Print("Order Send Failed! ", ErrorDescription(GetLastError()));
               }
         }
   
     if(Count_Buy()==13 && Count_BuyLimit()==0)
         {
            if (!OrderSend (_Symbol,OP_BUYLIMIT,BuyLimit14_Lotsize,Bid-(BuyLimit14_Distance_From_Start*_Point),3,NULL,Ask+BuyLimit14_TP_in_Points*_Point,NULL,magicNumber,0,clrGreen))
               {
                 Print("Order Send Failed! ", ErrorDescription(GetLastError()));
               }
         }

       if(Count_Sell()==13 && Count_SellLimit()==0)
         {
            if (!OrderSend (_Symbol,OP_SELLLIMIT,SellLimit14_Lotsize,Ask+(SellLimit14_Distance_From_Start*_Point),3,NULL,Bid-SellLimit14_TP_in_Points*_Point,NULL,magicNumber,0,clrRed))
               {
                 Print("Order Send Failed! ", ErrorDescription(GetLastError()));
               }
         }
   
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  profitCheck()
{
   delay();
   if(lastClose==1)
     {
         CloseDeleteAll();
         CloseDeleteAllCurrent();
         CloseDeleteAllCurrentNonPending();
         CloseDeleteAllNonPending();
     }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CloseDeleteAll()
{
    int total  = OrdersTotal();
      for (int cnt = total-1 ; cnt >=0 ; cnt--)
      {
         if (!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))    continue;
         if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
         {
            switch(OrderType())
            {
               case OP_BUY       :
               {
                  if(!OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),maxSlippage,Violet))
                     return(false);
               }break;                  
               case OP_SELL      :
               {
                  if(!OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),maxSlippage,Violet))
                     return(false);
               }break;
            }            
        
            
            if(OrderType()==OP_BUYSTOP || OrderType()==OP_SELLSTOP || OrderType()==OP_BUYLIMIT || OrderType()==OP_SELLLIMIT)
               if(!OrderDelete(OrderTicket()))
               {
                  Print("Error deleting " + (string)OrderType() + " order : ",ErrorDescription(GetLastError()));
                  return (false);
               }
          }
      }
      return (true);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
// delete all on current chart
bool CloseDeleteAllCurrent()
{
    int total  = OrdersTotal();
      for (int cnt = total-1 ; cnt >=0 ; cnt--)
      {
         if (!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))   continue;
         if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
         {
            if(OrderSymbol()==Symbol())
            {
               switch(OrderType())
               {
                  case OP_BUY       :
                  {
                     if(!OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),maxSlippage,Violet))
                        return(false);
                  }break;
                  
                  case OP_SELL      :
                  {
                     if(!OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),maxSlippage,Violet))
                        return(false);
                  }break;
               }            
            
            
            if(OrderType()==OP_BUYSTOP || OrderType()==OP_SELLSTOP || OrderType()==OP_BUYLIMIT || OrderType()==OP_SELLLIMIT)
               if(!OrderDelete(OrderTicket()))
               {
                  return (false);
               }
            }
         }
      }
      return (true);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
// left pending orders
bool CloseDeleteAllNonPending()
{
    int total  = OrdersTotal();
      for (int cnt = total-1 ; cnt >=0 ; cnt--)
      {
         if (!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))   continue;
         if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
         {
            switch(OrderType())
            {
               case OP_BUY       :
               {
                  if(!OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),maxSlippage,Violet))
                     return(false);
               }break;                  
               case OP_SELL      :
               {
                  if(!OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),maxSlippage,Violet))
                     return(false);
               }break;
            }            
         }
      }
      return (true);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
// delete all on current chart left pending
bool CloseDeleteAllCurrentNonPending()
{
    int total  = OrdersTotal();
      for (int cnt = total-1 ; cnt >=0 ; cnt--)
      {
         if (!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))   continue;
         if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
         {
            if(OrderSymbol()==Symbol())
            {
               switch(OrderType())
               {
                  case OP_BUY       :
                  {
                     if(!OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),maxSlippage,Violet))
                        return(false);
                  }break;
                  
                  case OP_SELL      :
                  {
                     if(!OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),maxSlippage,Violet))
                        return(false);
                  }break;
               }            
            }
         }
      }
      return (true);
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
double ProfitCheck()
{
   double profit_=0;
   int total  = OrdersTotal();
      for (int cnt = total-1 ; cnt >=0 ; cnt--)
      {
         if (!OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES)) continue;
         if(AllSymbols)
            profit_+=OrderProfit();
         else if(OrderSymbol()==Symbol())
            profit_+=OrderProfit();
      }
   return(profit_);        
}

int Count_Sell(){
 int OpenSellOrders=0;
   for(int i=0;i<OrdersTotal(); i++ )
   {
      if(OrderSelect(i, SELECT_BY_POS)==true)
         {
         

         if (OrderType()==OP_SELL)
            OpenSellOrders++;  
         }
   }
   return(OpenSellOrders); 
   }

int Count_Buy(){
 int OpenBuyOrders=0;
   for(int i=0;i<OrdersTotal(); i++ )
   {
      if(OrderSelect(i, SELECT_BY_POS)==true)
         {
         

         if (OrderType()==OP_BUY)
            OpenBuyOrders++;  
         }
   }
   return(OpenBuyOrders); 
   }
   
int Count_SellLimit(){
 int OpenSellLimitOrders=0;
 
   for(int i=0;i<OrdersTotal(); i++ )
   {
      if(OrderSelect(i, SELECT_BY_POS)==true)
         {
         

         if (OrderType()==OP_SELLLIMIT && OrderSymbol()==_Symbol)
         {
            
            OpenSellLimitOrders++;  
            
         }
         }
   
   }
   return(OpenSellLimitOrders); 
   }

int Count_BuyLimit(){
 int OpenBuyLimitOrders=0;

   for(int i=0;i<OrdersTotal(); i++ )
   {
      if(OrderSelect(i, SELECT_BY_POS)==true)
         {
         

         if (OrderType()==OP_BUYLIMIT && OrderSymbol()==_Symbol)
         {
        
            OpenBuyLimitOrders++;  
         }
         
   }
   }
   return(OpenBuyLimitOrders); 
   }

//+------------------------------------------------------------------+
//| Check the correctness of the order volume                        |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume,string description)
  {
//--- minimal allowed volume for trade operations
   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(volume<min_volume)
     {
      description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }

//--- maximal allowed volume of trade operations
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(volume>max_volume)
     {
      description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }

//--- get minimal step of volume changing
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);

   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                               volume_step,ratio*volume_step);
      return(false);
     }
   description="Correct volume value";
   return(true);
  }
bool CheckMoneyForTrade(string symb, double lots,int type)
  {
   double free_margin=AccountFreeMarginCheck(symb,type, lots);
   //-- if there is not enough money
   if(free_margin<0)
     {
      string oper=(type==OP_BUY)? "Buy":"Sell";
      Print("Not enough money for ", oper," ",lots, " ", symb, " Error code=",GetLastError());
      return(false);
     }
   //--- checking successful
   return(true);
  }
//+------------------------------------------------------------------+
//| return error description                                         |
//+------------------------------------------------------------------+
string ErrorDescription(int error_code)
  {
   string error_string;
//---
   switch(error_code)
     {
      //--- codes returned from trade server
      case 0:   error_string="no error";                                                   break;
      case 1:   error_string="no error, trade conditions not changed";                     break;
      case 2:   error_string="common error";                                               break;
      case 3:   error_string="invalid trade parameters";                                   break;
      case 4:   error_string="trade server is busy";                                       break;
      case 5:   error_string="old version of the client terminal";                         break;
      case 6:   error_string="no connection with trade server";                            break;
      case 7:   error_string="not enough rights";                                          break;
      case 8:   error_string="too frequent requests";                                      break;
      case 9:   error_string="malfunctional trade operation (never returned error)";       break;
      case 64:  error_string="account disabled";                                           break;
      case 65:  error_string="invalid account";                                            break;
      case 128: error_string="trade timeout";                                              break;
      case 129: error_string="invalid price";                                              break;
      case 130: error_string="invalid stops";                                              break;
      case 131: error_string="invalid trade volume";                                       break;
      case 132: error_string="market is closed";                                           break;
      case 133: error_string="trade is disabled";                                          break;
      case 134: error_string="not enough money";                                           break;
      case 135: error_string="price changed";                                              break;
      case 136: error_string="off quotes";                                                 break;
      case 137: error_string="broker is busy (never returned error)";                      break;
      case 138: error_string="requote";                                                    break;
      case 139: error_string="order is locked";                                            break;
      case 140: error_string="long positions only allowed";                                break;
      case 141: error_string="too many requests";                                          break;
      case 145: error_string="modification denied because order is too close to market";   break;
      case 146: error_string="trade context is busy";                                      break;
      case 147: error_string="expirations are denied by broker";                           break;
      case 148: error_string="amount of open and pending orders has reached the limit";    break;
      case 149: error_string="hedging is prohibited";                                      break;
      case 150: error_string="prohibited by FIFO rules";                                   break;
      //--- mql4 errors
      case 4000: error_string="no error (never generated code)";                           break;
      case 4001: error_string="wrong function pointer";                                    break;
      case 4002: error_string="array index is out of range";                               break;
      case 4003: error_string="no memory for function call stack";                         break;
      case 4004: error_string="recursive stack overflow";                                  break;
      case 4005: error_string="not enough stack for parameter";                            break;
      case 4006: error_string="no memory for parameter string";                            break;
      case 4007: error_string="no memory for temp string";                                 break;
      case 4008: error_string="non-initialized string";                                    break;
      case 4009: error_string="non-initialized string in array";                           break;
      case 4010: error_string="no memory for array\' string";                              break;
      case 4011: error_string="too long string";                                           break;
      case 4012: error_string="remainder from zero divide";                                break;
      case 4013: error_string="zero divide";                                               break;
      case 4014: error_string="unknown command";                                           break;
      case 4015: error_string="wrong jump (never generated error)";                        break;
      case 4016: error_string="non-initialized array";                                     break;
      case 4017: error_string="dll calls are not allowed";                                 break;
      case 4018: error_string="cannot load library";                                       break;
      case 4019: error_string="cannot call function";                                      break;
      case 4020: error_string="expert function calls are not allowed";                     break;
      case 4021: error_string="not enough memory for temp string returned from function";  break;
      case 4022: error_string="system is busy (never generated error)";                    break;
      case 4023: error_string="dll-function call critical error";                          break;
      case 4024: error_string="internal error";                                            break;
      case 4025: error_string="out of memory";                                             break;
      case 4026: error_string="invalid pointer";                                           break;
      case 4027: error_string="too many formatters in the format function";                break;
      case 4028: error_string="parameters count is more than formatters count";            break;
      case 4029: error_string="invalid array";                                             break;
      case 4030: error_string="no reply from chart";                                       break;
      case 4050: error_string="invalid function parameters count";                         break;
      case 4051: error_string="invalid function parameter value";                          break;
      case 4052: error_string="string function internal error";                            break;
      case 4053: error_string="some array error";                                          break;
      case 4054: error_string="incorrect series array usage";                              break;
      case 4055: error_string="custom indicator error";                                    break;
      case 4056: error_string="arrays are incompatible";                                   break;
      case 4057: error_string="global variables processing error";                         break;
      case 4058: error_string="global variable not found";                                 break;
      case 4059: error_string="function is not allowed in testing mode";                   break;
      case 4060: error_string="function is not confirmed";                                 break;
      case 4061: error_string="send mail error";                                           break;
      case 4062: error_string="string parameter expected";                                 break;
      case 4063: error_string="integer parameter expected";                                break;
      case 4064: error_string="double parameter expected";                                 break;
      case 4065: error_string="array as parameter expected";                               break;
      case 4066: error_string="requested history data is in update state";                 break;
      case 4067: error_string="internal trade error";                                      break;
      case 4068: error_string="resource not found";                                        break;
      case 4069: error_string="resource not supported";                                    break;
      case 4070: error_string="duplicate resource";                                        break;
      case 4071: error_string="cannot initialize custom indicator";                        break;
      case 4072: error_string="cannot load custom indicator";                              break;
      case 4073: error_string="no history data";                                           break;
      case 4074: error_string="not enough memory for history data";                        break;
      case 4075: error_string="not enough memory for indicator";                           break;
      case 4099: error_string="end of file";                                               break;
      case 4100: error_string="some file error";                                           break;
      case 4101: error_string="wrong file name";                                           break;
      case 4102: error_string="too many opened files";                                     break;
      case 4103: error_string="cannot open file";                                          break;
      case 4104: error_string="incompatible access to a file";                             break;
      case 4105: error_string="no order selected";                                         break;
      case 4106: error_string="unknown symbol";                                            break;
      case 4107: error_string="invalid price parameter for trade function";                break;
      case 4108: error_string="invalid ticket";                                            break;
      case 4109: error_string="trade is not allowed in the expert properties";             break;
      case 4110: error_string="longs are not allowed in the expert properties";            break;
      case 4111: error_string="shorts are not allowed in the expert properties";           break;
      case 4200: error_string="object already exists";                                     break;
      case 4201: error_string="unknown object property";                                   break;
      case 4202: error_string="object does not exist";                                     break;
      case 4203: error_string="unknown object type";                                       break;
      case 4204: error_string="no object name";                                            break;
      case 4205: error_string="object coordinates error";                                  break;
      case 4206: error_string="no specified subwindow";                                    break;
      case 4207: error_string="graphical object error";                                    break;
      case 4210: error_string="unknown chart property";                                    break;
      case 4211: error_string="chart not found";                                           break;
      case 4212: error_string="chart subwindow not found";                                 break;
      case 4213: error_string="chart indicator not found";                                 break;
      case 4220: error_string="symbol select error";                                       break;
      case 4250: error_string="notification error";                                        break;
      case 4251: error_string="notification parameter error";                              break;
      case 4252: error_string="notifications disabled";                                    break;
      case 4253: error_string="notification send too frequent";                            break;
      case 4260: error_string="ftp server is not specified";                               break;
      case 4261: error_string="ftp login is not specified";                                break;
      case 4262: error_string="ftp connect failed";                                        break;
      case 4263: error_string="ftp connect closed";                                        break;
      case 4264: error_string="ftp change path error";                                     break;
      case 4265: error_string="ftp file error";                                            break;
      case 4266: error_string="ftp error";                                                 break;
      case 5001: error_string="too many opened files";                                     break;
      case 5002: error_string="wrong file name";                                           break;
      case 5003: error_string="too long file name";                                        break;
      case 5004: error_string="cannot open file";                                          break;
      case 5005: error_string="text file buffer allocation error";                         break;
      case 5006: error_string="cannot delete file";                                        break;
      case 5007: error_string="invalid file handle (file closed or was not opened)";       break;
      case 5008: error_string="wrong file handle (handle index is out of handle table)";   break;
      case 5009: error_string="file must be opened with FILE_WRITE flag";                  break;
      case 5010: error_string="file must be opened with FILE_READ flag";                   break;
      case 5011: error_string="file must be opened with FILE_BIN flag";                    break;
      case 5012: error_string="file must be opened with FILE_TXT flag";                    break;
      case 5013: error_string="file must be opened with FILE_TXT or FILE_CSV flag";        break;
      case 5014: error_string="file must be opened with FILE_CSV flag";                    break;
      case 5015: error_string="file read error";                                           break;
      case 5016: error_string="file write error";                                          break;
      case 5017: error_string="string size must be specified for binary file";             break;
      case 5018: error_string="incompatible file (for string arrays-TXT, for others-BIN)"; break;
      case 5019: error_string="file is directory, not file";                               break;
      case 5020: error_string="file does not exist";                                       break;
      case 5021: error_string="file cannot be rewritten";                                  break;
      case 5022: error_string="wrong directory name";                                      break;
      case 5023: error_string="directory does not exist";                                  break;
      case 5024: error_string="specified file is not directory";                           break;
      case 5025: error_string="cannot delete directory";                                   break;
      case 5026: error_string="cannot clean directory";                                    break;
      case 5027: error_string="array resize error";                                        break;
      case 5028: error_string="string resize error";                                       break;
      case 5029: error_string="structure contains strings or dynamic arrays";              break;
      default:   error_string="";
     }
//---
   return(error_string);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool timeTrade()
{
   bool t = (TimeCurrent()>=StringToTime(Start_Time)) && (TimeCurrent()<StringToTime(End_Time))  ?  true  :  false;
   return t;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  delay()
{
uchar  Position_Count = 0;
long   trades_of_day=0;
long   t  = 0;
lastTime     = 0;
lastClose    = 0;
for (int i=0; i<OrdersHistoryTotal(); i++)
   { 
      if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
      t = OrderOpenTime();
      if(t>trades_of_day)
          {
            trades_of_day    =  t;
            lastTime         =  OrderCloseTime();
            if((OrderClosePrice()==OrderTakeProfit() || OrderClosePrice()==OrderStopLoss()) && TimeCurrent()-lastTime<5)
              {
                  lastClose=1;
              }
          }
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool timeDelay()
{
   delay();
   int  t = time==minutes   ?  (Time_Delay_Minutes*60) : (Time_Delay_Minutes*60*60);
        t = Time_Delay_Minutes==0 ?  10  :  t;
   bool b = (TimeCurrent()-lastTime)>=t  ?  true  :  false;
   return b;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
