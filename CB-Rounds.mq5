//+------------------------------------------------------------------+
//|                                                    CB-Rounds.mq5 |
//|                                                   Chris Bakowski |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Chris Bakowski"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0


//+------------------------------------------------------------------+
//|inputs                                                            |
//+------------------------------------------------------------------+
input int             gridSpace  = 50;
input color           lineColor  = clrPurple;
input ENUM_LINE_STYLE lineStyle  = STYLE_SOLID;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {

   return(INIT_SUCCEEDED);
  }
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

   return(rates_total);
  }//Oncalculate




//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, "Grid");
   double shift      = 0;
   double HighPrice  = 0;
   double LowPrice   = 0;

   double Divisor    = 0.1 / Point();

   for(shift = LowPrice; shift <= HighPrice; shift++)
     {
      ObjectDelete(0, "Grid" + (string)shift);
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
