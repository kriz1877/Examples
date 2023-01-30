//+------------------------------------------------------------------+
//|                                                    EX-SamCo_V4.0 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "4.00"
#property strict
#include <CB-CustomFunctions.mqh>

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+

extern   string      Trade_Settings; //Trade Settings -------------------------------------------
extern   bool        HighImpactData          =  false;         // EconData (Do Not Trade Today)?
extern   double      Riskpc_PerTrade         =  0.25;           // Risk % Per Trade
extern   bool        Dynamic_Lot_Size        =  true;         // Use Dynamic Lot Sizing?
extern   double      Fixed_Lots              =  0.5;          // Fixed Lot Amount
extern   double      RRR                     =  2.0;          // Risk : Reward Ratio
extern   bool        NoTargets               =  false;         // Do Not Use TP (ie. trail only)?
extern   double      Pip_Filter              =  1.0;           // Pip Filter
extern   bool        EnterOnPreviousCandle   =  true;         // Enter On Break of Previous High/Low
extern   int         Slippage                =  0;             // Maximum Slippage
enum     Stop_Type   {FixedPips, PreviousHighLow, ATRStop};
extern   Stop_Type   StopMethod              =  1;             // Stop Loss Method
extern   double      fixedStopInPips         =  3;            // Stop Loss in Pips
extern   int         Candles_To_Expiry       =  4;             // Candles to Order Expiration
extern   int         MaxOrdersAllowed        =  2;             // Maximum Orders Allowed

extern   string      Trailing_Stop_Settings; //Trailing Stop Settings -------------------------------------------
enum                 TrailType {BreakEven,Regular,CandleTrail,ATRTrail,R_MultipleBreakEven,None};
extern TrailType     Trailing_Type           =  5;          // Type of Trailing Stop
input  ENUM_TIMEFRAMES  TrailTimeframe       =  PERIOD_CURRENT; // Timeframe for lowest/highest candle to trail
extern int           TrailingLookback        =  10;            // Lookback on candle trailing Stop
extern int           PipsBeforeTrail         =  10;            // Pip movment before trail initiated
extern double        RMultiple               =  1;             // R Muitples before BreakEven
extern int           PipsBehindPrice         =  5;             // Pip lag behind price
extern int           TrailStopBuffer         =  3;

extern   string      Indicator_Settings; //Indicator_Settings Settings -------------------------------------------
input    int         swingLookback           =  10;            // Swing Lookback
extern   bool        useRSI                  =  false;         // Use RSI?
extern   bool        mustRetrace             =  true;          // Target within recent High/Low
input    int         Extended_Level          =  20;            // RSI Overbought/sold Level
input    int         RSI_Period              =  8;             // RSI Period
input    bool        UseStructure            =  true;          // Use Structure for ATR Stop?
input    int         StructureLookback       =  7;             // Lookback for ATR Stop Structure
input    int         AtrLength               =  14;            // ATR Stop Length
input    double      AtrMultiplier           =  1.5;           // ATR Stop Multiplier
extern   bool        useATR                  =  false;         // Use ATR?
input    double      MaxATR                  =  0.0015;        // Maximum ATR 

extern   string      Notification_Settings; //Notification Settings -------------------------------------------
input    bool        printCandles            =  true;          // Print Candles
input    bool        DeBug                   =  true;         // Print Debug Info
input    bool        Trade_Notifications     =  true;          // Send Trade Notifications to Mobile Device?
input    bool        TakeLiveTrades          =  true;          // Take Live Trades?

//+------------------------------------------------------------------+
//| Constants                                                        |
//+------------------------------------------------------------------+

int                  OrderNo;
double               FixedStopInPrice        =  fixedStopInPips * PipValue();
int                  RSI_Overbought_Level    =  100 - Extended_Level;
int                  RSI_Oversold_Level      =  0   + Extended_Level;
bool                 printAllCandles         =  false;
int                  Magic                   =  MagicNumberGenerator(1210);
double               PipFilterInPrice        =  Pip_Filter * PipValue();
double               LongLotSize, ShortLotSize;
bool                 GoLong,GoShort;
static datetime      candletime              =  0;
static datetime      currenttime             =  0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   SendNotification("SamCo_V2.0 initialised on " + Symbol());


   return(INIT_SUCCEEDED);


  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   SendNotification("SamCo_V2.0 DE-initialised on " + Symbol());
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   currenttime = Time[0];
   TrailingStop(Trailing_Type,TrailingLookback,TrailTimeframe,TrailStopBuffer,AtrMultiplier,AtrLength,UseStructure,StructureLookback,
   RMultiple,PipsBehindPrice,PipsBeforeTrail,Magic,true,Trade_Notifications);

//+------------------------------------------------------------------+
//| Moving Averages                                                  |
//+------------------------------------------------------------------+

//Daily MAs
   double   Daily_Fast        = iMA(Symbol(),PERIOD_D1,8,0,MODE_EMA,PRICE_CLOSE,1);
   double   Daily_Slow        = iMA(Symbol(),PERIOD_D1,21,0,MODE_EMA,PRICE_CLOSE,1);

//Hourly MAs
   double   Hourly_Fast       = iMA(Symbol(),PERIOD_H1,50,0,MODE_EMA,PRICE_CLOSE,1);
   double   Hourly_Slow       = iMA(Symbol(),PERIOD_H1,200,0,MODE_EMA,PRICE_CLOSE,1);

//define EMA market conditions
   bool     EMA_BEAR          = (Daily_Fast < Daily_Slow) && (Hourly_Fast < Hourly_Slow);
   bool     EMA_BULL          = (Daily_Fast > Daily_Slow) && (Hourly_Fast > Hourly_Slow);



//+------------------------------------------------------------------+
//|Highs_Lows                                                        |
//+------------------------------------------------------------------+

// boolean to define if it is or isnt daily high
   bool     isDailyHigh       =  High[1] == iHigh(Symbol(),PERIOD_D1,0);
   bool     isDailyLow        =  Low[1]  == iLow(Symbol(),PERIOD_D1,0);




//+------------------------------------------------------------------+
//|Market conditions                                                 |
//+------------------------------------------------------------------+

// check if past 10 candles from i are swing lows or highs
   bool     isSwingHigh       = IsSwingHigh(1,10,1);
   bool     isSwingLow        = IsSwingLow(1,10,1);



//+------------------------------------------------------------------+
//|Candles                                                           |
//+------------------------------------------------------------------+

//bearish candles
   bool     isEC_Bear         =  EC_Bear(1,printAllCandles,false);
   bool     isPB_Bear_JD      =  PB_Bear_JD(1,printAllCandles,false);
   bool     isPB_Bear_TV      =  PB_Bear_TV(1,printAllCandles,false);

//bullish candles
   bool     isEC_Bull         =  EC_Bull(1,printAllCandles,false);
   bool     isPB_Bull_JD      =  PB_Bull_JD(1,printAllCandles,false);
   bool     isPB_Bull_TV      =  PB_Bull_TV(1,printAllCandles,false);

   bool     BearishCandle     =  isEC_Bear || isPB_Bear_JD || isPB_Bear_TV;
   bool     BullishCandle     =  isEC_Bull || isPB_Bull_JD || isPB_Bull_TV;


//+------------------------------------------------------------------+
//| Candle Prints                                                    |
//+------------------------------------------------------------------+

// bearish
   if(printCandles && isEC_Bear && EMA_BEAR && isSwingHigh)
     {
      Create_Label("EC",1,High[1],clrRed,1,0);
     }
   if(printCandles && (isPB_Bear_JD || isPB_Bear_TV) && EMA_BEAR && isSwingHigh)
     {
      Create_Label("PB",1,High[1],clrRed,1,0);
     }

// bullish
   if(printCandles && isEC_Bull && EMA_BULL && isSwingLow)
     {
      Create_Label("EC",1,Low[1],clrGreen,1,0);
     }
   if(printCandles && (isPB_Bull_JD || isPB_Bull_TV) && EMA_BULL && isSwingLow)
     {
      Create_Label("PB",1,Low[1],clrGreen,1,0);
     }


//+------------------------------------------------------------------+
//| RSI                                                              |
//+------------------------------------------------------------------+

   double   RSI            =  iRSI(Symbol(),PERIOD_CURRENT,RSI_Period,PRICE_CLOSE,1);

   bool     RSI_Overbought =  RSI > RSI_Overbought_Level;
   bool     RSI_Oversold   =  RSI < RSI_Oversold_Level;

   bool     RSIShort       =  useRSI ? RSI_Overbought : true;
   bool     RSILong        =  useRSI ? RSI_Oversold   : true;


//+------------------------------------------------------------------+
//| ATR                                                              |
//+------------------------------------------------------------------+

   double   ATR            =  iATR(Symbol(),PERIOD_CURRENT,AtrLength,1);
   bool     ATRisMaxed     =  useATR ? (ATR > MaxATR) : false;
  

//+------------------------------------------------------------------+
//| Entries                                                          |
//+------------------------------------------------------------------+

   double   buyEntry         =  EnterOnPreviousCandle ? (High[1] + PipFilterInPrice + (Ask - Bid)) : (Ask + PipFilterInPrice);
   double   sellEntry        =  EnterOnPreviousCandle ? (Low[1]  - PipFilterInPrice - (Ask - Bid)) : (Bid - PipFilterInPrice);


//+------------------------------------------------------------------+
//| Stops & Targets                                                  |
//+------------------------------------------------------------------+


   double   BuyStopPrice      =  StopLossPrice(true,StopMethod,buyEntry,FixedStopInPrice,AtrMultiplier,AtrLength,UseStructure,StructureLookback,false);
   double   SellStopPrice     =  StopLossPrice(false,StopMethod,sellEntry,FixedStopInPrice,AtrMultiplier,AtrLength,UseStructure,StructureLookback,false);

   double   SellTargetPrice   =  TargetPrice(false,NoTargets,sellEntry,SellStopPrice,RRR,false);
   double   BuyTargetPrice    =  TargetPrice(true,NoTargets,buyEntry,BuyStopPrice,RRR,false);


   double   MinLongTarget     =  MinimumTargetPrice(true,buyEntry,BuyStopPrice,RRR,false);
   double   MinShortTarget    =  MinimumTargetPrice(false,sellEntry,SellStopPrice,RRR,false);


//swap this into the has retrtaced function
   bool     hasRetracedShort  =  mustRetrace ? MinShortTarget   > LowOfDay(1)  : false;
   bool     hasRetracedLong   =  mustRetrace ? MinLongTarget  < HighOfDay(1) : false;



//+------------------------------------------------------------------+
//| Signals                                                          |
//+------------------------------------------------------------------+

   GoShort  = (EMA_BEAR
               && isDailyHigh
               && BearishCandle
               && RSIShort
               && !ATRisMaxed
               && hasRetracedShort
               && !HighImpactData);

   GoLong   = (EMA_BULL
               && isDailyLow
               && BullishCandle
               && RSILong
               && !ATRisMaxed
               && hasRetracedLong
               && !HighImpactData);




//+------------------------------------------------------------------+
//| Orders                                                           |
//+------------------------------------------------------------------+

   if(currenttime!=candletime)
     {

      if(GoLong)
        {
         if((OrdersTotal() < MaxOrdersAllowed) && CheckSignalOncePerCandle(true) && TakeLiveTrades)
           {
            LongLotSize    = Dynamic_Lot_Size ? GetLotSizeFromPrices(Riskpc_PerTrade,buyEntry,BuyStopPrice,false) : Fixed_Lots;
            OrderNo        = EnterStopPrice(true,LongLotSize,buyEntry,BuyStopPrice,BuyTargetPrice,Slippage,
                                            Magic,ExpiryInSeconds(Candles_To_Expiry,Period()),DeBug,Trade_Notifications);
           }//ordertotal
         else
            if(CheckSignalOncePerCandle(true))
              {
               PrintEnterStopPrice(true,LongLotSize,buyEntry,BuyStopPrice,BuyTargetPrice,Slippage,
                                   Magic,ExpiryInSeconds(Candles_To_Expiry,Period()),DeBug,DeBug,Trade_Notifications);
              }
        }//golong


      if(GoShort)
        {

         if((OrdersTotal() < MaxOrdersAllowed) && CheckSignalOncePerCandle(true) && TakeLiveTrades)
           {
            ShortLotSize   = Dynamic_Lot_Size ? GetLotSizeFromPrices(Riskpc_PerTrade,sellEntry,SellStopPrice,false) : Fixed_Lots;
            OrderNo        = EnterStopPrice(false,ShortLotSize,sellEntry,SellStopPrice,SellTargetPrice,Slippage,
                                            Magic,ExpiryInSeconds(Candles_To_Expiry,Period()),DeBug,Trade_Notifications);
           }//ordertotal
         else
            if(CheckSignalOncePerCandle(true))
              {
               PrintEnterStopPrice(false,ShortLotSize,sellEntry,SellStopPrice,SellTargetPrice,Slippage,
                                   Magic,ExpiryInSeconds(Candles_To_Expiry,Period()),DeBug,DeBug,Trade_Notifications);
              }
        }//goshort

      candletime=Time[0];
     }//cahdletime reset



  }//program












//+------------------------------------------------------------------+
//| SAFE                                                             |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
