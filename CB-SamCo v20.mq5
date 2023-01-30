//+------------------------------------------------------------------+
//|                                                         TEST.mq5 |
//|                                                   Chris Bakowski |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Chris Bakowski"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#include <CustomFunctions.mqh>


//+------------------------------------------------------------------+
//| indicator properties                                             |
//+------------------------------------------------------------------+

#property indicator_buffers 10
#property indicator_plots 8

#property indicator_color1 clrRed
#property indicator_label1 "Daily FastMA"
#property indicator_style1 STYLE_SOLID
#property indicator_type1 DRAW_LINE
#property indicator_width1 2

#property indicator_color2 clrGreen
#property indicator_label2 "Daily SlowMA"
#property indicator_style2 STYLE_SOLID
#property indicator_type2 DRAW_LINE
#property indicator_width2 2

#property indicator_color3 clrRed
#property indicator_label3 "Hourly FastMA"
#property indicator_style3 STYLE_SOLID
#property indicator_type3 DRAW_LINE
#property indicator_width3 1

#property indicator_color4 clrGreen
#property indicator_label4 "Hourly SlowMA"
#property indicator_style4 STYLE_SOLID
#property indicator_type4 DRAW_LINE
#property indicator_width4 1

#property indicator_color5 clrOrange
#property indicator_label5 "Daily High"
#property indicator_style5 STYLE_SOLID
#property indicator_type5 DRAW_LINE
#property indicator_width5 1

#property indicator_color6 clrDarkBlue
#property indicator_label6 "Daily Low"
#property indicator_style6 STYLE_SOLID
#property indicator_type6 DRAW_LINE
#property indicator_width6 1

#property indicator_color7 clrDarkBlue
#property indicator_label7 "Pivot"
#property indicator_style7 STYLE_SOLID
#property indicator_type7 DRAW_LINE
#property indicator_width7 1


//+------------------------------------------------------------------+
//|inputs                                                            |
//+------------------------------------------------------------------+
sinput   group        "Visualisation"
input    bool         showHighLows  =  false;    //Show High & Low of the Day on Chart?
input    bool         printCandles  =  true;     //Print all candles?


//+------------------------------------------------------------------+
//|global variables                                                  |
//+------------------------------------------------------------------+

int               dailyFastPeriod      =  8;
int               dailySlowPeriod      =  21;
int               hourlyFastPeriod     =  50;
int               hourlySlowPeriod     =  200;
int               maxLookbackPeriod    =  MathMax(MathMax(hourlySlowPeriod, hourlyFastPeriod), MathMax(dailyFastPeriod, dailySlowPeriod));

int               max_lookback         =  PERIOD_D1 + 1;
string            indicatorName        =  "CB-SamCo v20";
color             highColor, lowColor, buyCandleColor, sellCandleColor;
int               shift                =  10;
bool              buyCandle, sellCandle;
int               gridSpace            = 50;
color             lineColor            = clrPurple;
ENUM_LINE_STYLE   lineStyle            = STYLE_SOLID;
datetime          InpStartDate         = TimeCurrent() - (PeriodSeconds(PERIOD_D1) * maxLookbackPeriod);
string            pivotResetTime       = "01:01";
double            r3, r2, r1, pp, s1, s2, s3;

//+------------------------------------------------------------------+
//|buffers and handles                                               |
//+------------------------------------------------------------------+

//daily
double   dailyFastBuffer[], dailyFastValues[];
double   dailySlowBuffer[], dailySlowValues[];
int      dailyFastHandle, dailySlowHandle;

//hourly
double   hourlyFastBuffer[], hourlyFastValues[];
double   hourlySlowBuffer[], hourlySlowValues[];
int      hourlyFastHandle, hourlySlowHandle;

//daily highs & lows
double   dailyHighBuffer[], dailyLowBuffer[], pivot[];

//object name buffer
string   arrowName[];



///+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {

//highlow  colours
   highColor         = showHighLows ? clrDarkOrange   : clrNONE;
   lowColor          = showHighLows ? clrDarkBlue     : clrNONE;

   buyCandleColor    = printCandles ? clrGreen        : clrNONE;
   sellCandleColor   = printCandles ? clrRed          : clrNONE;


//--- indicator buffers mapping
   SetIndexBuffer(0, dailyFastBuffer, INDICATOR_DATA);
   ArraySetAsSeries(dailyFastBuffer, true);
   ArraySetAsSeries(dailyFastValues, true);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);

   SetIndexBuffer(1, dailySlowBuffer, INDICATOR_DATA);
   ArraySetAsSeries(dailySlowBuffer, true);
   ArraySetAsSeries(dailySlowValues, true);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0.0);

   SetIndexBuffer(2, hourlyFastBuffer, INDICATOR_DATA);
   ArraySetAsSeries(hourlyFastBuffer, true);
   ArraySetAsSeries(hourlyFastValues, true);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, 0.0);

   SetIndexBuffer(3, hourlySlowBuffer, INDICATOR_DATA);
   ArraySetAsSeries(hourlySlowBuffer, true);
   ArraySetAsSeries(hourlySlowValues, true);
   PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, 0.0);

   SetIndexBuffer(4, dailyHighBuffer, INDICATOR_DATA);
   ArraySetAsSeries(dailyHighBuffer, true);
   PlotIndexSetInteger(4, PLOT_LINE_COLOR, highColor);

   SetIndexBuffer(5, dailyLowBuffer, INDICATOR_DATA);
   ArraySetAsSeries(dailyLowBuffer, true);
   PlotIndexSetInteger(5, PLOT_LINE_COLOR, lowColor);
   
   SetIndexBuffer(6, pivot, INDICATOR_DATA);
   //ArraySetAsSeries(pivot, true);
   PlotIndexSetDouble(6, PLOT_EMPTY_VALUE, 0.0);


//--- handle creation
   dailyFastHandle   =  iMA(Symbol(), PERIOD_D1, 8, 0, MODE_EMA, PRICE_CLOSE);
   dailySlowHandle   =  iMA(Symbol(), PERIOD_D1, 21, 0, MODE_EMA, PRICE_CLOSE);
   hourlyFastHandle  =  iMA(Symbol(), PERIOD_H1, 50, 0, MODE_EMA, PRICE_CLOSE);
   hourlySlowHandle  =  iMA(Symbol(), PERIOD_H1, 200, 0, MODE_EMA, PRICE_CLOSE);


// error message if handles unable to be created
   if(dailyFastHandle == INVALID_HANDLE || dailySlowHandle == INVALID_HANDLE || hourlyFastHandle == INVALID_HANDLE || hourlySlowHandle == INVALID_HANDLE)
     {
      printf("Failed to create " + indicatorName + "handles");
      return(INIT_FAILED);
     }
   printf(indicatorName + " handles created successfully");
/*
   r3 = NormalizeDouble(ObjectGetDouble(0, "DM5", OBJPROP_PRICE), 4);
   r2 = NormalizeDouble(ObjectGetDouble(0, "DM4", OBJPROP_PRICE), 4);
   r1 = NormalizeDouble(ObjectGetDouble(0, "DM3", OBJPROP_PRICE), 4);
   pp = NormalizeDouble(ObjectGetDouble(0, "DPP", OBJPROP_PRICE), 4);
   s1 = NormalizeDouble(ObjectGetDouble(0, "DM2", OBJPROP_PRICE), 4);
   s2 = NormalizeDouble(ObjectGetDouble(0, "DM1", OBJPROP_PRICE), 4);
   s3 = NormalizeDouble(ObjectGetDouble(0, "DPP0", OBJPROP_PRICE), 4);
*/

   return(INIT_SUCCEEDED);
  }


//---
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {


//--- array series setting

   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(tick_volume, true);
   ArraySetAsSeries(volume, true);
   ArraySetAsSeries(spread, true);

//+------------------------------------------------------------------+
//| control statement                                                |
//+------------------------------------------------------------------+


   int limit = (prev_calculated > rates_total || prev_calculated <= 0) ? 0 : prev_calculated - 1, dailyBar = iBarShift(Symbol(), PERIOD_D1, time[rates_total - 1]);

   if(BarsCalculated(dailyFastHandle) < dailyBar)
      return(0);

//+------------------------------------------------------------------+
//| Download Missing History                                         |
//+------------------------------------------------------------------+

   static int  waitCount = 20;
   if(prev_calculated == 0)
     {
      if(waitCount > 0)
        {
         datetime t     =  iTime(Symbol(), PERIOD_D1, 0);
         int      err   =  GetLastError();

         if(t == 0)
           {
            waitCount--;
            printf("Waiting for " + indicatorName + " data");
            Sleep(3000);
            return(prev_calculated);
           }
         printf("Data is now available for " + indicatorName);
        }
      else
        {
         printf("Can't wait any longer for " + indicatorName + " data");
         //+------------------------------------------------------------------+
         //| CheckLoadHistory()                                               |
         //+------------------------------------------------------------------+

         Print("Start load", Symbol() + "," + GetPeriodName(PERIOD_D1), "from", InpStartDate);
         //---
         int res = CheckLoadHistory(Symbol(), PERIOD_D1, InpStartDate);
         switch(res)
           {
            case -1 :
               Print("Unknown symbol ", Symbol());
               break;
            case -2 :
               Print("Requested bars more than max bars in chart");
               break;
            case -3 :
               Print("Program was stopped");
               break;
            case -4 :
               Print("Indicator shouldn't load its own data");
               break;
            case -5 :
               Print("Load failed");
               break;
            case  0 :
               Print("Loaded OK");
               break;
            case  1 :
               Print("Loaded previously");
               break;
            case  2 :
               Print("Loaded previously and built");
               break;
            default :
               Print("Unknown result");
           }
         //---
         datetime first_date;
         SeriesInfoInteger(Symbol(), PERIOD_D1, SERIES_FIRSTDATE, first_date);
         int bars = Bars(Symbol(), PERIOD_D1);
         Print("First date ", first_date, " - ", bars, " bars");
        }
     }

//+------------------------------------------------------------------+
//| Repainting Function                                              |
//+------------------------------------------------------------------+

   if(prev_calculated > 0)
     {
      if(limit < PeriodSeconds(PERIOD_D1) / PeriodSeconds(Period()))
         limit = PeriodSeconds(PERIOD_D1) / PeriodSeconds(Period());
      if(limit > ArraySize(time))
         limit = ArraySize(time);
     }

//+------------------------------------------------------------------+
//| rounds                                                           |
//+------------------------------------------------------------------+
   /*
   //int      counted_bars = prev_calculated;
      double   j = 0;
      double   HighPrice = 0;
      double   LowPrice = 0;
      int      GridS = 0;
      int      SL = 0;
      int      digits     = Digits();
      double   point      = Point();
      double   PointRatio = MathPow(10, MathMod(digits, 2));
      double   Divisor = 0.1 / point / PointRatio;


      HighPrice   = MathRound(iHigh(Symbol(), PERIOD_CURRENT, (iHighest(Symbol(), PERIOD_CURRENT, MODE_HIGH, (rates_total - 2), 2))) * Divisor);
      LowPrice    = MathRound(iLow(Symbol(), PERIOD_CURRENT, (iLowest(Symbol(), PERIOD_CURRENT, MODE_LOW, (rates_total - 1), 2))) * Divisor);

      GridS       = gridSpace / 10;

      for(j = LowPrice; j <= HighPrice; j++)
        {
         if(MathMod(j, GridS) == 0)
           {
            if(ObjectFind(0, "Grid" + (string)j) != 0)
              {
               ObjectCreate(0, "Grid" + (string)j, OBJ_HLINE, 0, time[1], j / Divisor);
               ObjectSetInteger(0, "Grid" + (string)j, OBJPROP_STYLE, lineStyle);
               ObjectSetInteger(0, "Grid" + (string)j, OBJPROP_COLOR, lineColor);
              }
           }
        }

   */



//+------------------------------------------------------------------+
//| for loop                                                         |
//+------------------------------------------------------------------+

   for(int i = limit; i < rates_total && !_StopFlag; i++)
     {
      buyCandle   = false;
      sellCandle  =  false;

      //+------------------------------------------------------------------+
      //| moving averages                                                  |
      //+------------------------------------------------------------------+

      //daily
      dailyBar = iBarShift(_Symbol, PERIOD_D1, time[i], false);

      if(CopyBuffer(dailyFastHandle, 0, dailyBar, 1, dailyFastValues) != -1)
        {
         dailyFastBuffer[i] = dailyFastValues[0];
        }

      if(CopyBuffer(dailySlowHandle, 0, dailyBar, 1, dailySlowValues) != -1)
        {
         dailySlowBuffer[i] = dailySlowValues[0];
        }


      //hourly
      int hourlyBar = iBarShift(_Symbol, PERIOD_H1, time[i], false);

      if(CopyBuffer(hourlyFastHandle, 0, hourlyBar, 1, hourlyFastValues) != -1)
        {
         hourlyFastBuffer[i] = hourlyFastValues[0];
        }

      if(CopyBuffer(hourlySlowHandle, 0, hourlyBar, 1, hourlySlowValues) != -1)
        {
         hourlySlowBuffer[i] = hourlySlowValues[0];
        }

      bool     EMA_Bull = (dailyFastBuffer[i]   >  dailySlowBuffer[i]) && (hourlyFastBuffer[i]  >  hourlySlowBuffer[i]);
      bool     EMA_Bear = (dailyFastBuffer[i]   <  dailySlowBuffer[i]) && (hourlyFastBuffer[i]  <  hourlySlowBuffer[i]);



      //+------------------------------------------------------------------+
      //|highs & lows                                                      |
      //+------------------------------------------------------------------+

      //--- attached saily highs and lows to bufer
      dailyHighBuffer[i]   =  iHigh(Symbol(), PERIOD_D1, dailyBar);
      dailyLowBuffer[i]    =  iLow(Symbol(), PERIOD_D1, dailyBar);

      //--- boolean to define if it is or isnt daily high
      bool isDailyHigh     =  high[i] == dailyHighBuffer[i];
      bool isDailyLow      =  low[i]  == dailyLowBuffer[i];


      //+------------------------------------------------------------------+
      //|Market conditions                                                 |
      //+------------------------------------------------------------------+

      // check whether the past 3 candles from i are swing lows or hihgs
      bool  isSwingHigh       = IsSwingHigh(i, 10, i);
      bool  isSwingLow        = IsSwingLow(i, 10, i);


      //+------------------------------------------------------------------+
      //| Candles                                                          |
      //+------------------------------------------------------------------+

      //--- EC_Bull
      if(EC_Bull(i) && EMA_Bull && isSwingLow)
        {
         double   price    = low[i] - 10 * Point();
         datetime _time    = time[i];
         CandleDrawArrow(price, _time, buyCandleColor, "Buy", 141, ANCHOR_TOP);
         buyCandle = true;
        }


      //--- EC_Bear
      if(EC_Bear(i) && EMA_Bear && isSwingHigh)
        {
         double   price    = high[i] + 10 * Point();
         datetime _time    = time[i];
         CandleDrawArrow(price, _time, sellCandleColor, "Sell", 141, ANCHOR_BOTTOM);
         sellCandle = true;
        }


      //--- PB_Green_Bull
      if((PB_Bull_JD(i) && EMA_Bull && isSwingLow) || (PB_Bull_TV(i) && EMA_Bull && isSwingLow))
        {
         double   price    = low[i] - 10 * Point();
         datetime _time    = time[i];
         CandleDrawArrow(price, _time, buyCandleColor, "Buy", 140, ANCHOR_TOP);
         buyCandle = true;
        }

      if((PB_Bear_JD(i) && EMA_Bear && isSwingHigh) || (PB_Bear_TV(i) && EMA_Bear && isSwingHigh))
        {
         double   price    = high[i] + 10 * Point();
         datetime _time    = time[i];
         CandleDrawArrow(price, _time, sellCandleColor, "Sell", 140, ANCHOR_BOTTOM);
         sellCandle = true;
        }



      //+------------------------------------------------------------------+
      //|pivots                                                            |
      //+------------------------------------------------------------------+

    /*  
         r3 = NormalizeDouble(ObjectGetDouble(0, "DM5", OBJPROP_PRICE), 4);
         r2 = NormalizeDouble(ObjectGetDouble(0, "DM4", OBJPROP_PRICE), 4);
         r1 = NormalizeDouble(ObjectGetDouble(0, "DM3", OBJPROP_PRICE), 4);
         pivot[i] = NormalizeDouble(ObjectGetDouble(0, "DPP", OBJPROP_PRICE), 4);
         s1 = NormalizeDouble(ObjectGetDouble(0, "DM2", OBJPROP_PRICE), 4);
         s2 = NormalizeDouble(ObjectGetDouble(0, "DM1", OBJPROP_PRICE), 4);
         s3 = NormalizeDouble(ObjectGetDouble(0, "DPP0", OBJPROP_PRICE), 4);

  */
        




      //+------------------------------------------------------------------+
      //|master signal                                                     |
      //+------------------------------------------------------------------+

      bool goLong    =  EMA_Bull && isSwingLow  && isDailyLow  && buyCandle;
      bool goShort   =  EMA_Bear && isSwingHigh && isDailyHigh && sellCandle;

      if(goLong)
        {
         double   price    = low[i] - 50 * Point();
         datetime _time    = time[i];
         SignalDrawArrow(price, _time, clrGreen, "goLong", 233, ANCHOR_TOP);
        }

      if(goShort)
        {
         double   price    = high[i] + 50 * Point();
         datetime _time    = time[i];
         SignalDrawArrow(price, _time, clrRed, "goShort", 234, ANCHOR_BOTTOM);
        }


      //+------------------------------------------------------------------+
      //| for loop                                                         |
      //+------------------------------------------------------------------+

     }

   return(rates_total);
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(dailyFastHandle);
   IndicatorRelease(dailySlowHandle);
   Comment("");
   Print(indicatorName + " removed");

   int createdArrows = ArraySize(arrowName);

   for(int i = createdArrows - 1; i >= 0; i--)
     {
      if(ObjectFind(0, arrowName[i]) >= 0)
         ArrowDelete(0, arrowName[i]);
     }

   /*//fix this infinite loop

         ObjectsDeleteAll(0, "Grid");
         double k             = 0;
         double HighPrice     = 0;
         double LowPrice      = 0;

         double Divisor       = 0.1 / Point();

         for(k = LowPrice; k <= HighPrice; shift++)
           {
            ObjectDelete(0, "Grid" + (string)k);
           }
        */
  }
//+------------------------------------------------------------------+





//+------------------------------------------------------------------+
//|CandleDrawArrow()                                                       |
//+------------------------------------------------------------------+
void CandleDrawArrow(const double price1, const datetime time1, const color colour, const string M_type, const uchar code = 159, const ENUM_ARROW_ANCHOR anchor = ANCHOR_BOTTOM)
  {
//--- arrow name
   string   name  = StringFormat("%s %s time: %s", M_type, DoubleToString(price1), TimeToString(time1));
//---
   if(ObjectFind(0, name) < 0)
     {
      if(CandleArrowCreate(0, name, 0, time1, price1, code, anchor, colour))
        {
         int size  =  ArraySize(arrowName);
         ArrayResize(arrowName, size + 1, 1000);
         arrowName[size]  =  name;
        }
     }
   else
      ArrowMove(0, name, time1, price1);
  }





//+------------------------------------------------------------------+
//| CandleArrowCreate()                                              |
//+------------------------------------------------------------------+
bool CandleArrowCreate(const long              chart_ID = 0,         // chart's ID
                       const string            name = "Arrow",       // arrow name
                       const int               sub_window = 0,       // subwindow index
                       datetime                time = 0,             // anchor point time
                       double                  price = 0,            // anchor point price
                       const uchar             arrow_code = 252,     // arrow code
                       const ENUM_ARROW_ANCHOR anchor = ANCHOR_BOTTOM, // anchor point position
                       const color             clr = clrRed,         // arrow color
                       const ENUM_LINE_STYLE   style = STYLE_SOLID,  // border line style
                       const int               width = 1,            // arrow size
                       const bool              back = false,         // in the background
                       const bool              selection = false,     // highlight to move
                       const bool              hidden = true,        // hidden in the object list
                       const long              z_order = 0)          // priority for mouse click
  {
//--- set anchor point coordinates if they are not set
   ChangeArrowEmptyPoint(time, price);
//--- reset the error value
   ResetLastError();
//--- create an arrow
   if(!ObjectCreate(chart_ID, name, OBJ_ARROW, sub_window, time, price))
     {
      Print(__FUNCTION__,
            ": failed to create an arrow! Error code = ", GetLastError());
      return(false);
     }
//--- set the arrow code
   ObjectSetInteger(chart_ID, name, OBJPROP_ARROWCODE, arrow_code);
//--- set anchor type
   ObjectSetInteger(chart_ID, name, OBJPROP_ANCHOR, anchor);
//--- set the arrow color
   ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
//--- set the border line style
   ObjectSetInteger(chart_ID, name, OBJPROP_STYLE, style);
//--- set the arrow's size
   ObjectSetInteger(chart_ID, name, OBJPROP_WIDTH, width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
//--- enable (true) or disable (false) the mode of moving the arrow by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
//--- successful execution
   return(true);
  }




//+------------------------------------------------------------------+
//|SignalDrawArrow()                                                 |
//+------------------------------------------------------------------+
void SignalDrawArrow(const double price1, const datetime time1, const color colour, const string M_type, const uchar code = 159, const ENUM_ARROW_ANCHOR anchor = ANCHOR_BOTTOM)
  {
//--- arrow name
   string   name  = StringFormat("%s %s time: %s", M_type, DoubleToString(price1), TimeToString(time1));
//---
   if(ObjectFind(0, name) < 0)
     {
      if(SignalArrowCreate(0, name, 0, time1, price1, code, anchor, colour))
        {
         int size  =  ArraySize(arrowName);
         ArrayResize(arrowName, size + 1, 1000);
         arrowName[size]  =  name;
        }
     }
   else
      ArrowMove(0, name, time1, price1);
  }







//+------------------------------------------------------------------+
//| SignalArrowCreate()                                              |
//+------------------------------------------------------------------+
bool SignalArrowCreate(const long              chart_ID = 0,         // chart's ID
                       const string            name = "Arrow",       // arrow name
                       const int               sub_window = 0,       // subwindow index
                       datetime                time = 0,             // anchor point time
                       double                  price = 0,            // anchor point price
                       const uchar             arrow_code = 252,     // arrow code
                       const ENUM_ARROW_ANCHOR anchor = ANCHOR_BOTTOM, // anchor point position
                       const color             clr = clrRed,         // arrow color
                       const ENUM_LINE_STYLE   style = STYLE_SOLID,  // border line style
                       const int               width = 3,            // arrow size
                       const bool              back = false,         // in the background
                       const bool              selection = false,     // highlight to move
                       const bool              hidden = true,        // hidden in the object list
                       const long              z_order = 0)          // priority for mouse click
  {
//--- set anchor point coordinates if they are not set
   ChangeArrowEmptyPoint(time, price);
//--- reset the error value
   ResetLastError();
//--- create an arrow
   if(!ObjectCreate(chart_ID, name, OBJ_ARROW, sub_window, time, price))
     {
      Print(__FUNCTION__,
            ": failed to create an arrow! Error code = ", GetLastError());
      return(false);
     }
//--- set the arrow code
   ObjectSetInteger(chart_ID, name, OBJPROP_ARROWCODE, arrow_code);
//--- set anchor type
   ObjectSetInteger(chart_ID, name, OBJPROP_ANCHOR, anchor);
//--- set the arrow color
   ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
//--- set the border line style
   ObjectSetInteger(chart_ID, name, OBJPROP_STYLE, style);
//--- set the arrow's size
   ObjectSetInteger(chart_ID, name, OBJPROP_WIDTH, width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
//--- enable (true) or disable (false) the mode of moving the arrow by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
//--- successful execution
   return(true);
  }




//+------------------------------------------------------------------+
//| Move the anchor point                                            |
//+------------------------------------------------------------------+
bool ArrowMove(const long   chart_ID = 0, // chart's ID
               const string name = "Arrow", // object name
               datetime     time = 0,     // anchor point time coordinate
               double       price = 0)    // anchor point price coordinate
  {
//--- if point position is not set, move it to the current bar having Bid price
   if(!time)
      time = TimeCurrent();
   if(!price)
      price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
//--- reset the error value
   ResetLastError();
//--- move the anchor point
   if(!ObjectMove(chart_ID, name, 0, time, price))
     {
      Print(__FUNCTION__,
            ": failed to move the anchor point! Error code = ", GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }





//+------------------------------------------------------------------+
//| Change the arrow code                                            |
//+------------------------------------------------------------------+
bool ArrowCodeChange(const long   chart_ID = 0, // chart's ID
                     const string name = "Arrow", // object name
                     const uchar  code = 252)   // arrow code
  {
//--- reset the error value
   ResetLastError();
//--- change the arrow code
   if(!ObjectSetInteger(chart_ID, name, OBJPROP_ARROWCODE, code))
     {
      Print(__FUNCTION__,
            ": failed to change the arrow code! Error code = ", GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }




//+------------------------------------------------------------------+
//| Change anchor type                                               |
//+------------------------------------------------------------------+
bool ArrowAnchorChange(const long              chart_ID = 0,      // chart's ID
                       const string            name = "Arrow",    // object name
                       const ENUM_ARROW_ANCHOR anchor = ANCHOR_TOP) // anchor type
  {
//--- reset the error value
   ResetLastError();
//--- change anchor type
   if(!ObjectSetInteger(chart_ID, name, OBJPROP_ANCHOR, anchor))
     {
      Print(__FUNCTION__,
            ": failed to change anchor type! Error code = ", GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }




//+------------------------------------------------------------------+
//| Delete an arrow                                                  |
//+------------------------------------------------------------------+
bool ArrowDelete(const long   chart_ID = 0, // chart's ID
                 const string name = "Arrow") // arrow name
  {
//--- reset the error value
   ResetLastError();
//--- delete an arrow
   if(!ObjectDelete(chart_ID, name))
     {
      Print(__FUNCTION__,
            ": failed to delete an arrow! Error code = ", GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }




//+------------------------------------------------------------------+
//| Check anchor point values and set default values                 |
//| for empty ones                                                   |
//+------------------------------------------------------------------+
void ChangeArrowEmptyPoint(datetime & time, double & price)
  {
//--- if the point's time is not set, it will be on the current bar
   if(!time)
      time = TimeCurrent();
//--- if the point's price is not set, it will have Bid value
   if(!price)
      price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
  }
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
