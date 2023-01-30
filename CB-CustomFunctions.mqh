//+------------------------------------------------------------------+
//|                                           CB-CustomFunctions.mqh |
//|                                   Copyright 2021, Chris Bakowski |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Chris Bakowski"
#property link      "https://www.mql5.com"
#property strict
#include <stderror.mqh>
#include <stdlib.mqh>

//+------------------------------------------------------------------+
//| Pip Value                                                        |
//+------------------------------------------------------------------+
double PipValue()
  {
   if(_Digits >=4)
     {
      return 0.0001;
     }
   else
     {
      return 0.01;
     }
  }//calculates pip value of a a pari based on number of decimals


////+------------------------------------------------------------------+
////|  Get_Lot_Size   (old)                                            |
////+------------------------------------------------------------------+
//double Get_Lot_Size(double Risk_Per_Trade_PC, double Stop_Loss_Distance_Pips, bool Debug)
//  {
//
//   double Account_Equity   = AccountEquity();
//   double Broker_Lot_Size  = MarketInfo(Symbol(), MODE_LOTSIZE);
//   double Tick_Value       = MarketInfo(Symbol(), MODE_TICKVALUE);
//
//   if(Digits <= 3)
//     {
//      Tick_Value = Tick_Value / 100;
//     }
//
//   double Risk_Per_Trade_USD     = Account_Equity * (Risk_Per_Trade_PC / 100);
//   double Risk_In_Quote          = Risk_Per_Trade_USD / Tick_Value;
//   double Get_Lot_Size           = NormalizeDouble(Risk_In_Quote / (Stop_Loss_Distance_Pips * PipValue()) / Broker_Lot_Size,2);
//   return Get_Lot_Size;
//
//   if(Debug)
//     {
//      Print("");
//      Print("Your account equity is: " + DoubleToString(Account_Equity,2));
//      Print("Your broker's lot sizing is: " + DoubleToString(Broker_Lot_Size,2));
//      Print("Your exchange rate is: " + DoubleToString(Tick_Value,_Digits));
//      Print("Your risk per trade in USD is: " + DoubleToString(Risk_Per_Trade_USD,2));
//      Print("Your risk per trade in " + Symbol() + " is " + DoubleToString(Risk_In_Quote,_Digits));
//      Print("Your lot size should be " + DoubleToString(Get_Lot_Size,2));
//     }
//  }//dynamic lot sizing based on stoploss distance in pips


////+------------------------------------------------------------------+
////|  Get_Lot_Size                                                    |
////+------------------------------------------------------------------+
//double Get_Lot_Size(double accountEquity, double Risk_Per_Trade_PC, double Stop_Loss_Distance_Pips, bool Debug)
//  {
////usdjpy
//   double Account_Equity   = NormalizeDouble(accountEquity,2);                             //1,000
//   double Broker_Lot_Size  = MarketInfo(Symbol(), MODE_LOTSIZE);        //100,000
//   double Tick_Value       = MarketInfo(Symbol(), MODE_TICKVALUE);      //0.7415
//
//   if(Digits <= 3)
//     {
//      Tick_Value = Tick_Value / 100; //0.007415
//     }
//
//   double Risk_Per_Trade_USD     = NormalizeDouble(Account_Equity * (Risk_Per_Trade_PC / 100),2);                                                      // 1000 * (1 / 100)                       =  10
//   double Risk_In_Quote          = NormalizeDouble((Risk_Per_Trade_USD / Tick_Value),2);                                                                 // 10 / 0.007415                          = 1,348.617
//   double Get_Lot_Size           = NormalizeDouble(Risk_In_Quote / (Stop_Loss_Distance_Pips * PipValue()) / Broker_Lot_Size,2);     // (1,348.617 / (30 * 0.01)) / 100,000    = 0.0449539
//
//   if(Debug)
//     {
//      Print("");
//      Print("Your stoploss in pips is: " + (string)Stop_Loss_Distance_Pips);
//      Print("Your account equity is: " + (string)Account_Equity);
//      Print("Your broker's lot sizing is: " + (string)Broker_Lot_Size);
//      Print("Your exchange rate is: " + (string)Tick_Value);
//      Print("Your risk per trade in USD is: " + (string)Risk_Per_Trade_USD);
//      Print("Your risk per trade in " + Symbol() + " is " + (string)Risk_In_Quote);
//      Print("Your lot size should be " + (string)Get_Lot_Size);
//      Print("Minimum permitted amount of a lot is ",MarketInfo(Symbol(),MODE_MINLOT));
//     }
//
//   return Get_Lot_Size;
//  }//dynamic lot sizing based on stoploss distance in pips



//+------------------------------------------------------------------+
//| Get_StopLoss_Pips                                                |
//+------------------------------------------------------------------+
double Get_StopLoss_Pips(double Entry_Price, double stopLossPrice)
  {

   double   Price_Difference = MathAbs(Entry_Price - stopLossPrice);
   double   Pip_Value        = PipValue();
   double   Pips             = Price_Difference / Pip_Value;
   return   NormalizeDouble(Pips,1);
  }//returns an absoulte pip value from entry


//+------------------------------------------------------------------+
//| GetDistanceInPips                                                |
//+------------------------------------------------------------------+
double GetDistanceInPips(double Price1, double Price2)
  {

   double   Price_Difference = MathAbs(Price1 - Price2);
   double   Pip_Value        = PipValue();
   double   Pips             = Price_Difference / Pip_Value;
   return   NormalizeDouble(Pips,1);
  }//returns an absoulte pip value betwen 2 prices




//+------------------------------------------------------------------+
//| Price_Distance_In_Pips                                           |
//+------------------------------------------------------------------+
double Price_Distance_In_Pips(double Price_1, double Price_2)
  {

   double   Price_Difference = MathAbs(Price_1 - Price_2);
   double   Pip_Value        = PipValue();
   double   Pips             = Price_Difference / Pip_Value;
   return   Pips;
  }//returns the differnce in pips between two prices



//+------------------------------------------------------------------+
//| GetDistanceInPrice                                       |
//+------------------------------------------------------------------+
double GetDistanceInPrice(double Price_1, double Price_2)
  {

   double   Price_Difference = MathAbs(Price_1 - Price_2);
   return   Price_Difference;
  }//returns the differnce in price between two prices



//+------------------------------------------------------------------+
//| GetLotSizeFromPips                                               |
//+------------------------------------------------------------------+
double GetLotSizeFromPips(double maxRiskPrc, double maxLossInPips,  bool Debug)
  {
   double accEquity  = AccountEquity();
   double lotSize    = MarketInfo(NULL,MODE_LOTSIZE);
   double tickValue  = MarketInfo(NULL,MODE_TICKVALUE);

   if(Digits <= 3)
     {
      tickValue = tickValue /100;
     }

   double maxLossDollar       = accEquity * (maxRiskPrc/100);
   double maxLossInQuoteCurr  = maxLossDollar / tickValue;
   double optimalLotSize      = NormalizeDouble(maxLossInQuoteCurr /(maxLossInPips * PipValue())/lotSize,2);

   if(Debug)
     {
      Print("");
      Print("Your stoploss in pips is: " + (string)maxLossInPips);
      Print("Your account equity is: " + (string)accEquity);
      Print("Your broker's lot sizing is: " + (string)lotSize);
      Print("Your exchange rate is: " + (string)tickValue);
      Print("Your risk per trade in USD is: " + (string)NormalizeDouble(maxLossDollar,2));
      Print("Your risk per trade in " + Symbol() + " is " + (string)NormalizeDouble(maxLossInQuoteCurr,2));
      Print("Minimum permitted amount of a lot is ",MarketInfo(Symbol(),MODE_MINLOT));
      Print("Your lot size should be " + (string)optimalLotSize);
     }
   return optimalLotSize;
  }//function returns the optimal lot size using the size of the stoploss and pipfilter






//+------------------------------------------------------------------+
//|GetLotSizeFromPrices                                              |
//+------------------------------------------------------------------+
double GetLotSizeFromPrices(double maxRiskPrc, double entryPrice, double stopLoss,  bool Debug)
  {
   double maxLossInPips = MathAbs(entryPrice - stopLoss)/PipValue();
   return GetLotSizeFromPips(maxRiskPrc,maxLossInPips,Debug);
  }//returns the optimal lot size using the distance between 2 prices






//+------------------------------------------------------------------+
//| Print_Debug_Item                                                 |
//+------------------------------------------------------------------+
void Print_Debug_Item(string itemName, double item)
  {
   Print(itemName + " is: " + (string)item);
  }// prints item into journal for debugging




//+------------------------------------------------------------------+
//| OnInit info                                                      |
//+------------------------------------------------------------------+
void Info_On_Init()
  {

   string EA_Init_String   = "Initialising EA: " + WindowExpertName() + " at Date & Time: " + string(TimeCurrent());
   string On_Init          =
      "Account Name: " +AccountName() + "\n"
      "Account Number: " + (string)AccountNumber() + "\n"
      "Broker: " + AccountCompany() + "\n"
      "Account Currency: "+ AccountCurrency()+ "\n"
      "Equity: $" + (string)AccountEquity()+ "\n"
      "Leaverage: " + (string)AccountLeverage()+ ":1 " + "\n"
      "Asset: " + Symbol()+ "\n"
      "Pip Value: " + (string)PipValue()+ "\n";

   Print(EA_Init_String);
   Print(On_Init);

   Alert(EA_Init_String);
   Alert(On_Init);

   SendNotification(EA_Init_String);
   SendNotification(On_Init);

  }




//+------------------------------------------------------------------+
//| DeInit info                                                      |
//+------------------------------------------------------------------+
void Info_On_DeInit(int Initial_Capital, int Magic_X_Number, double Risk_Reward_Ratio)
  {

   string EA_DeInit_String   = "De-Initialising EA: " + WindowExpertName() + " at Date & Time: " + string(TimeCurrent());
   string On_DeInit          =
      "Account Name: " +AccountName() + "\n"
      "Account Number: " + (string)AccountNumber() + "\n"
      "Broker: " + AccountCompany() + "\n"
      "Account Currency: "+ AccountCurrency()+ "\n"
      "Equity: $" + (string)AccountEquity()+ "\n"
      "Leaverage: " + (string)AccountLeverage()+ ":1 " + "\n"
      "Asset: " + Symbol()+ "\n"
      "Pip Value: " + (string)PipValue()+ "\n";

   Print(EA_DeInit_String);
   Print(On_DeInit);

   Alert(EA_DeInit_String);
   Alert(On_DeInit);

   SendNotification(EA_DeInit_String);
   SendNotification(On_DeInit);

  }




//+------------------------------------------------------------------+
//| InitChecks (DLLs, AutoTrading on etc)                                                                    |
//+------------------------------------------------------------------+
int InitChecks()
  {
   Comment(" ");
//      if(TimeLocal()> D'31.12.2024')
//        {
//         MessageBox("This File Has Expired! Please purchase the password from the programmer!","Expired File");
//         Comment("The file was removed because it is past it's expiration date."+
//                 "\nPlease contact the programmer at JimdandyForex.com for the password");
//         ExpertRemove();
//         return(INIT_FAILED);
//        }
//
//      if(Password != "HolyGrail")
//        {
//         MessageBox("Please reload the Expert with the correct password.","Wrong Password Entered!");
//         Comment(WindowExpertName(),"is NOT running because you have entered the wrong password!"+
//                 "\nPlease reload the Expert with the correct password.");
//         ExpertRemove();
//         return(INIT_FAILED);
//        }

   if(!IsExpertEnabled())
     {
      MessageBox("You need to enable AutoTrading","Please enable Autotrading!");
      Comment(WindowExpertName(),"is NOT running because you have AutoTrading Disabled!"+
              "\nPlease Enable AutoTrading and reload the expert.");
      ExpertRemove();
      return(INIT_FAILED);
     }

   if(!IsTradeAllowed())
     {
      MessageBox("You need to \"Allow Live Trading\"","Please check \"Allow Live Trading\"!");
      Comment(WindowExpertName(),"is NOT running because you do not have \"Allow Live Trading\" enabled!"+
              "\nPlease Enable \"Alow Live Trading\" and reload the expert.");
      ExpertRemove();
      return(INIT_FAILED);
     }

   if(!IsDllsAllowed())
     {
      MessageBox("DLLs are NOT enabled!","Please enable DLLs!");
      Comment(WindowExpertName(),"is NOT running because you have DLLs Disabled!"+
              "\nPlease Enable DLLs and reload the expert.");
      ExpertRemove();
      return(INIT_FAILED);
     }

   if(!IsLibrariesAllowed())
     {
      MessageBox("Allow import of external experts is NOT enabled!","Please enable it!");
      Comment(WindowExpertName(),"is NOT running because you have external experts Disabled!"+
              "\nPlease Enable them and reload the expert.");
      ExpertRemove();
      return(INIT_FAILED);
     }

   else
      Comment(" ");
//Info_On_Init();
   return(INIT_SUCCEEDED);
   Comment(" ");
  }



//+------------------------------------------------------------------+
//|IsTradingAllowed - Checks Autotrading enabled prior entertrade    |                                                              |
//+------------------------------------------------------------------+
bool IsTradingAllowed()
  {
   if(!IsTradeAllowed())
     {
      Print("AutoTrading Disabled");
      return(false);
     }
   else
     {
      Print("AutoTrading Enabled");
      return(true);
     }
  }





//+------------------------------------------------------------------+
//| check contract size                                              |
//+------------------------------------------------------------------+
bool CheckContractSize()
  {

   if((SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)) == 100000)
     {
      Print("Account lot size is: " + (string)SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)
            + "; trading allowed");
      return(true);
     }
   else
     {
      Print("Account lot size is: " + (string)SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)
            + "trading not allowed on this account's lot size, Orders with this EA's presets will be either too large or too small, must trade with a standard lot size of 100000");
      return(false);
     }
  }

//checks whether the account we are tyring to trade on is a standard
//lot size of 100000. returns true if it is and reutrns flase if not




//+------------------------------------------------------------------+
//|PreTradeChecks                                                    |
//+------------------------------------------------------------------+
bool PreTradeChecks()
  {
   CheckContractSize();
   PrintSpread();

   if(IsTradingAllowed() == true)
     {
      return(true);
     }
   else
     {
      return(false);
     }
  }//Both TradingIsAllowed and CheckContractSize combined into 1 function
//for convenience



//+------------------------------------------------------------------+
//| Print Spread                                                     |
//+------------------------------------------------------------------+
void PrintSpread()
  {
   double Spread        = NormalizeDouble((MarketInfo(Symbol(),MODE_SPREAD)),_Digits) * PipValue();
   double SpreadInPips  = Spread / PipValue();
   Print("Spread is : " + (string)Spread + ", or " + (string)SpreadInPips + " pips");
  }//Prints the vlaue of the spread in points and pips







//+------------------------------------------------------------------+
//| Enter_Select                                                     |
//+------------------------------------------------------------------+
int Enter_Select(bool isLong, string orderType, double lotSize, double entry, double SLpips, double TPpips, double pipFilter, int Slip, int Magic_X, datetime Expiry, bool Debug, bool Test, bool SendNotifications)
  {

   int      TicketNo;

   if(orderType == "limit")
     {
      TicketNo = Enter_Limit(isLong,lotSize,entry,SLpips,TPpips,pipFilter,Slip,Magic_X,Expiry,Debug,Test,SendNotifications);
     }
   else
      if(orderType == "stop")
        {
         TicketNo = EnterStopPips(isLong,lotSize,entry,SLpips,TPpips,pipFilter,Slip,Magic_X,Expiry,Debug,Test,SendNotifications);
        }
      else
        {
         TicketNo = Enter_Market(isLong,lotSize,SLpips,TPpips,Magic_X,Debug,Test,SendNotifications);
        }
   return(TicketNo);
  }//ordertype selecter function



//+------------------------------------------------------------------+
//| Enter_Market                                                     |
//+------------------------------------------------------------------+
int Enter_Market(bool isLong, double lotSize, double SLpips, double TPpips, int Magic_X, bool Debug, bool Test, bool SendNotifications)
  {
//--- declarations

   bool     DebugAlerts =  Debug;
   int      Expiry      =  0;
   int      TicketNo;
   string   Comments    =  "None";
   double   Lots        =  lotSize;
   int      labelAngle  =  0;

   double   Long_Entry  =  Ask;
   double   Long_SL     = (SLpips == 0) ? 0 : (Long_Entry  - (SLpips    * PipValue()));
   double   Long_TP     = (TPpips == 0) ? 0 : (Long_Entry  + (TPpips    * PipValue()));

   double   Short_Entry =  Bid;
   double   Short_SL    = (SLpips == 0) ? 0 : (Short_Entry + (SLpips    * PipValue()));
   double   Short_TP    = (TPpips == 0) ? 0 : (Short_Entry - (TPpips    * PipValue()));

   double   LongPipsRisk   =  NormalizeDouble(((Long_Entry - Long_SL)   / PipValue()),1);
   double   ShortPipsRisk  =  NormalizeDouble(((Short_SL - Short_Entry) / PipValue()),1);

//---orders

   if(isLong)
     {
      TicketNo =  OrderSend(Symbol(),OP_BUY,Lots,Long_Entry,10,Long_SL,Long_TP,Comments,Magic_X,Expiry,clrBlue);
      if(TicketNo < 1)
        {
         Print("");
         Print("Long MARKET order NOT PLACED : " + ErrorDescription(GetLastError()));
        }//order
      else
        {
         Print("");
         Print("Long MARKET order PLACED");
         Create_Label("Odr: " + (string)TicketNo,0,Low[1],clrGreen,1.0,labelAngle);
         if(SendNotifications)
           {
            SendNotification("BUY "+Symbol()+
                             ", Entry: "+(string)Long_Entry+
                             ", SL: "+(string)Long_SL+
                             ", TP: "+(string)Long_TP);

           }
        }//errors
     }//buy
   else
     {
      TicketNo =  OrderSend(Symbol(),OP_SELL,Lots,Short_Entry,10,Short_SL,Short_TP,Comments,Magic_X,Expiry,clrBlue);
      if(TicketNo < 1)
        {
         Print("");
         Print("Short MARKET order NOT PLACED : " + ErrorDescription(GetLastError()));
        }//order
      else
        {
         Print("");
         Print("Short MARKET order PLACED");
         Create_Label("Odr: " + (string)TicketNo,0,High[1],clrRed,1.0,labelAngle);
         if(SendNotifications)
           {
            SendNotification("SELL "+Symbol()+
                             ", Entry: "+(string)Short_Entry+
                             ", SL: "+(string)Short_SL+
                             ", TP: "+(string)Short_TP);
           }
        }//errors
     }//sell

//--- debug alerts


   if((Test) && (isLong == true))
     {
      Print("Odr Number is: "    + (string)TicketNo);
      Print("Long_Entry is: "       + (string)Long_Entry);
      Print("Ask is: "              + (string)Ask);
      Print("Long_SL is: "          + (string)Long_SL);
      Print("Long_TP is: "          + (string)Long_TP);
      Print("Long Risk in Pips: "   + (string)LongPipsRisk);
     }

   if((Test) && (isLong == false))
     {
      Print("Odr Number is: "    + (string)TicketNo);
      Print("Short_Entry is: "      + (string)Short_Entry);
      Print("Bid is: "              + (string)Bid);
      Print("Short_SL is: "         + (string)Short_SL);
      Print("Short_TP is: "         + (string)Short_TP);
      Print("Short Risk in Pips: "  + (string)ShortPipsRisk);
     }

   if((DebugAlerts) && (isLong == true))
     {
      Alert("Odr is: "         + (string)TicketNo);
      Alert("PipValue is: "         + (string)PipValue());
      Alert("Spread is: "           + (string)((NormalizeDouble((MarketInfo(Symbol(),MODE_SPREAD)),_Digits) * PipValue()) / 10));
      Alert("");
      Alert("Ask is: "              + (string)Ask);
      // Alert("OrderOpenPrice is: "   + (string)OrderOpenPrice());
      Alert("");
      Alert("Long_SL is: "          + (string)Long_SL);
      Alert("Long_TP is: "          + (string)Long_TP);
      Alert("Long_Entry is: "       + (string)Long_Entry);
      Alert("");
      Alert("SL in pips is: "       + (string)NormalizeDouble((Long_Entry - Long_SL),_Digits));
      Alert("TP in pips is: "       + (string)NormalizeDouble((Long_TP    - Long_Entry),_Digits));
     }
   if((DebugAlerts) && (isLong == false))
     {
      Alert("Odr is: "         + (string)TicketNo);
      Alert("PipValue is: "         + (string)PipValue());
      Alert("Spread is: "           + (string)((NormalizeDouble((MarketInfo(Symbol(),MODE_SPREAD)),_Digits) * PipValue()) / 10));
      Alert("");
      Alert("Bid is: "              + (string)Bid);
      // Alert("OrderOpenPrice is: "   + (string)OrderOpenPrice());
      Alert("");
      Alert("Short_SL is: "         + (string)Short_SL);
      Alert("Short_TP is: "         + (string)Short_TP);
      Alert("Short_Entry is: "      + (string)Short_Entry);
      Alert("");
      Alert("SL in pips is: "       + (string)NormalizeDouble((Short_SL    - Short_Entry),_Digits));
      Alert("TP in pips is: "       + (string)NormalizeDouble((Short_Entry - Short_TP),_Digits));
     }

   return(TicketNo);
  }//simple send market order funciton








//+------------------------------------------------------------------+
//| EnterStopPips                                                    |
//+------------------------------------------------------------------+
int EnterStopPips(bool isLong, double lotSize, double entry, double SLpips, double TPpips, double pipFilter, int Slip, int Magic_X, datetime Expiry, bool Debug, bool Test, bool SendNotifications)
  {
//--- declarations

   bool     DebugAlerts =  Debug;
   int      TicketNo;
   string   Comments    =  "None";
   double   Lots        =  lotSize;
   int      labelAngle  =  0;

   double   Long_Entry  =  entry         + (pipFilter * PipValue());
   double   Long_SL     = (SLpips == 0) ? 0 : (Long_Entry  - (SLpips    * PipValue()));
   double   Long_TP     = (TPpips == 0) ? 0 : (Long_Entry  + (TPpips    * PipValue()));

   double   Short_Entry =  entry         - (pipFilter * PipValue());
   double   Short_SL    = (SLpips == 0) ? 0 : (Short_Entry + (SLpips    * PipValue()));
   double   Short_TP    = (TPpips == 0) ? 0 : (Short_Entry - (TPpips    * PipValue()));

   double   LongPipsRisk   =  NormalizeDouble(((Long_Entry - Long_SL)   / PipValue()),1);
   double   ShortPipsRisk  =  NormalizeDouble(((Short_SL - Short_Entry) / PipValue()),1);

//---orders

   if(isLong)
     {
      TicketNo =  OrderSend(Symbol(),OP_BUYSTOP,Lots,Long_Entry,Slip,Long_SL,Long_TP,Comments,Magic_X,Expiry,clrGreen);
      if(TicketNo < 1)
        {
         Print("");
         Print("Long STOP order NOT PLACED : " + ErrorDescription(GetLastError()));
        }//order
      else
        {
         Print("");
         Print("Long STOP order PLACED");
         Create_Label("Odr: " + (string)TicketNo,0,Low[1],clrGreen,1.0,labelAngle);
         if(SendNotifications)
           {
            SendNotification("BUY "+Symbol()+
                             ", Entry: "+(string)Long_Entry+
                             ", SL: "+(string)Long_SL+
                             ", TP: "+(string)Long_TP);
           }
        }//errors
     }//buy
   else
     {
      TicketNo =  OrderSend(Symbol(),OP_SELLSTOP,Lots,Short_Entry,Slip,Short_SL,Short_TP,Comments,Magic_X,Expiry,clrGreen);
      if(TicketNo < 1)
        {
         Print("");
         Print("Short STOP order NOT PLACED : " + ErrorDescription(GetLastError()));
        }//order
      else
        {
         Print("");
         Print("Short STOP order PLACED");
         Create_Label("Odr: " + (string)TicketNo,0,High[1],clrRed,1.0,labelAngle);
         if(SendNotifications)
           {
            SendNotification("SELL "+Symbol()+
                             ", Entry: "+(string)Short_Entry+
                             ", SL: "+(string)Short_SL+
                             ", TP: "+(string)Short_TP);
           }
        }//errors
     }//sell

//--- debug alerts

   if((Test) && (isLong == true))
     {
      Print("Odr Number is: "    + (string)TicketNo);
      Print("Long_Entry is: "       + (string)Long_Entry);
      Print("Ask is: "              + (string)Ask);
      Print("Long_SL is: "          + (string)Long_SL);
      Print("Long_TP is: "          + (string)Long_TP);
      Print("Long Risk in Pips: "   + (string)LongPipsRisk);
     }

   if((Test) && (isLong == false))
     {
      Print("Odr Number is: "    + (string)TicketNo);
      Print("Short_Entry is: "      + (string)Short_Entry);
      Print("Bid is: "              + (string)Bid);
      Print("Short_SL is: "         + (string)Short_SL);
      Print("Short_TP is: "         + (string)Short_TP);
      Print("Short Risk in Pips: "  + (string)ShortPipsRisk);
     }

   if((DebugAlerts) && (isLong == true))
     {
      Alert("Odr is: "         + (string)TicketNo);
      Alert("PipValue is: "         + (string)PipValue());
      Alert("Spread is: "           + (string)((NormalizeDouble((MarketInfo(Symbol(),MODE_SPREAD)),_Digits) * PipValue()) / 10));
      Alert("");
      Alert("Ask is: "              + (string)Ask);
      //Alert("OrderOpenPrice is: "   + (string)OrderOpenPrice());
      Alert("");
      Alert("Long_SL is: "          + (string)Long_SL);
      Alert("Long_TP is: "          + (string)Long_TP);
      Alert("PipFilter is: "        + (string)pipFilter);
      Alert("Long_Entry is: "       + (string)Long_Entry);
      Alert("");
      Alert("SL in pips is: "       + (string)NormalizeDouble((Long_Entry - Long_SL),_Digits));
      Alert("TP in pips is: "       + (string)NormalizeDouble((Long_TP    - Long_Entry),_Digits));
     }
   if((DebugAlerts) && (isLong == false))
     {
      Alert("Odr is: "         + (string)TicketNo);
      Alert("PipValue is: "         + (string)PipValue());
      Alert("Spread is: "           + (string)((NormalizeDouble((MarketInfo(Symbol(),MODE_SPREAD)),_Digits) * PipValue()) / 10));
      Alert("");
      Alert("Bid is: "              + (string)Bid);
      //Alert("OrderOpenPrice is: "   + (string)OrderOpenPrice());
      Alert("");
      Alert("Short_SL is: "         + (string)Short_SL);
      Alert("Short_TP is: "         + (string)Short_TP);
      Alert("PipFilter is: "        + (string)pipFilter);
      Alert("Short_Entry is: "      + (string)Short_Entry);
      Alert("");
      Alert("SL in pips is: "       + (string)NormalizeDouble((Short_SL    - Short_Entry),_Digits));
      Alert("TP in pips is: "       + (string)NormalizeDouble((Short_Entry - Short_TP),_Digits));
     }
   return(TicketNo);
  }//simple send stop order funciton



//+------------------------------------------------------------------+
//| EnterStopPrice                                                   |
//+------------------------------------------------------------------+
int EnterStopPrice(bool isLong, double lotSize, double entry, double SLPrice, double TPPrice, int Slip, int Magic_X, datetime Expiry, bool Debug, bool SendNotifications)
  {
//--- declarations

   bool     DebugAlerts =  Debug;
   int      TicketNo;
   string   Comments    =  "None";
   double   Lots        =  lotSize;
   int      labelAngle  =  0;

   double   Long_Entry  =  entry;
   double   Long_SL     =  SLPrice;
   double   Long_TP     =  TPPrice;

   double   Short_Entry =  entry;
   double   Short_SL    =  SLPrice;
   double   Short_TP    =  TPPrice;

   double   LongPipsRisk      =  NormalizeDouble(((Long_Entry - Long_SL)   / PipValue()),1);
   double   ShortPipsRisk     =  NormalizeDouble(((Short_SL - Short_Entry) / PipValue()),1);

   double   LongRRR           =  NormalizeDouble(((Long_TP - Long_Entry)/PipValue())  / ((Long_Entry - Long_SL)/PipValue()),1);
   double   ShortRRR          =  NormalizeDouble(((Short_Entry - Short_TP)/PipValue()) / ((Short_SL - Short_Entry)/PipValue()),1);

   string   shortOrderString  = "Short STOP order PLACED : SELL "+Symbol()+", Entry: "+(string)Short_Entry+", SL: "+(string)Short_SL+", TP: "+(string)Short_TP+", Pips: "+ (string)ShortPipsRisk+", RRR: "+ (string)ShortRRR+", Lots: "+ (string)Lots;
   string   shortErrorString  = "Short STOP order NOT PLACED : " + ErrorDescription(GetLastError());

   string   longOrderString   = "Long STOP order PLACED : BUY "+Symbol()+", Entry: "+(string)Long_Entry+", SL: "+(string)Long_SL+", TP: "+(string)Long_TP+", Pips: "+ (string)LongPipsRisk+", RRR: "+ (string)LongRRR+", Lots: "+ (string)Lots;
   string   longErrorString   = "Long STOP order NOT PLACED : " + ErrorDescription(GetLastError());

//---orders

   if(isLong)
     {
      TicketNo =  OrderSend(Symbol(),OP_BUYSTOP,Lots,Long_Entry,Slip,Long_SL,Long_TP,Comments,Magic_X,Expiry,clrGreen);
      if(TicketNo < 1)
        {
         if(Debug)
           {
            Print("");
            Print(longErrorString);
            Print(longOrderString);
           }
         if(SendNotifications)
           {
            SendNotification(longErrorString);
            SendNotification(longOrderString);
           }
        }//errors
      else
        {
         Create_Label("Odr: " + (string)TicketNo,0,Low[1],clrGreen,1.0,labelAngle);
         if(Debug)
           {
            Print("");
            Print(longOrderString);
           }
         if(SendNotifications)
           {
            SendNotification(longOrderString);
           }
        }
     }//buy
   else
     {
      TicketNo =  OrderSend(Symbol(),OP_SELLSTOP,Lots,Short_Entry,Slip,Short_SL,Short_TP,Comments,Magic_X,Expiry,clrGreen);
      if(TicketNo < 1)
        {
         if(Debug)
           {
            Print("");
            Print(shortErrorString);
            Print(shortOrderString);
           }
         if(SendNotifications)
           {
            SendNotification(shortErrorString);
            SendNotification(shortOrderString);
           }
        }//errors
      else
        {
         Create_Label("Odr: " + (string)TicketNo,0,High[1],clrRed,1.0,labelAngle);
         if(Debug)
           {
            Print("");
            Print(shortOrderString);
           }
         if(SendNotifications)
           {
            SendNotification(shortOrderString);
           }
        }
     }//errors

   return(TicketNo);

  }//simple send stop order funciton





//+------------------------------------------------------------------+
//| PrintEnterStopPrice                                              |
//+------------------------------------------------------------------+
void PrintEnterStopPrice(bool isLong, double lotSize, double entry, double SLPrice, double TPPrice, int Slip, int Magic_X, datetime Expiry, bool Debug, bool Test, bool SendNotifications)
  {
//--- declarations

   bool     DebugAlerts =  Debug;
   string   Comments    =  "None";
   double   Lots        =  lotSize;
   int      labelAngle  =  0;

   double   Long_Entry  =  entry;
   double   Long_SL     =  SLPrice;
   double   Long_TP     =  TPPrice;

   double   Short_Entry =  entry;
   double   Short_SL    =  SLPrice;
   double   Short_TP    =  TPPrice;

   double   LongPipsRisk   =  NormalizeDouble(((Long_Entry - Long_SL)   / PipValue()),1);
   double   ShortPipsRisk  =  NormalizeDouble(((Short_SL - Short_Entry) / PipValue()),1);

//---orders

   if(isLong)
     {
      Print("BUY "+Symbol()+
            ", Entry: "+(string)Long_Entry+
            ", SL: "+(string)Long_SL+
            ", TP: "+(string)Long_TP);
      Create_Label("BUY: " + (string)Long_Entry,0,Low[1],clrGreen,2,labelAngle);
      Create_Label("SL: " + (string)Long_SL,0,Low[1],clrGreen,3,labelAngle);
      Create_Label("TP: " + (string)Long_TP,0,Low[1],clrGreen,4,labelAngle);
      Create_Label("TP: " + (string)LongPipsRisk,0,Low[1],clrGreen,5,labelAngle);

      if(SendNotifications)
        {
         SendNotification("BUY "+Symbol()+
                          ", Entry: "+(string)Long_Entry+
                          ", SL: "+(string)Long_SL+
                          ", TP: "+(string)Long_TP+
                          ", Pips: "+(string)LongPipsRisk);
        }
     }//buy
   else
     {
      Print("SELL "+Symbol()+
            ", Entry: "+(string)Short_Entry+
            ", SL: "+(string)Short_SL+
            ", TP: "+(string)Short_TP);
      Create_Label("SELL: " + (string)Short_Entry,0,High[1],clrRed,4,labelAngle);
      Create_Label("SL: " + (string)Short_SL,0,High[1],clrRed,3,labelAngle);
      Create_Label("TP: " + (string)Short_TP,0,High[1],clrRed,2,labelAngle);
      Create_Label("Pips: " + (string)ShortPipsRisk,0,High[1],clrRed,5,labelAngle);

      if(SendNotifications)
        {
         SendNotification("SELL "+Symbol()+
                          ", Entry: "+(string)Short_Entry+
                          ", SL: "+(string)Short_SL+
                          ", TP: "+(string)Short_TP+
                          ", Pips: "+(string)ShortPipsRisk);
        }
     }//sell
  }//prints Enter_Stop values for manual trades on the same basis as algorithimc function

//+------------------------------------------------------------------+
//| Print_Enter_Stop                                                 |
//+------------------------------------------------------------------+
void Print_Enter_Stop(bool isLong, double lotSize, double entry, double SLpips, double TPpips, double pipFilter, int Slip, int Magic_X, datetime Expiry, bool Debug, bool Test, bool SendNotifications)
  {
//--- declarations

   bool     DebugAlerts =  Debug;
   string   Comments    =  "None";
   double   Lots        =  lotSize;
   int      labelAngle  =  0;

   double   Long_Entry  =  entry         + (pipFilter * PipValue());
   double   Long_SL     = (SLpips == 0) ? 0 : (Long_Entry  - (SLpips    * PipValue()));
   double   Long_TP     = (TPpips == 0) ? 0 : (Long_Entry  + (TPpips    * PipValue()));

   double   Short_Entry =  entry         - (pipFilter * PipValue());
   double   Short_SL    = (SLpips == 0) ? 0 : (Short_Entry + (SLpips    * PipValue()));
   double   Short_TP    = (TPpips == 0) ? 0 : (Short_Entry - (TPpips    * PipValue()));

   double   LongPipsRisk   =  NormalizeDouble(((Long_Entry - Long_SL)   / PipValue()),1);
   double   ShortPipsRisk  =  NormalizeDouble(((Short_SL - Short_Entry) / PipValue()),1);

//---orders

   if(isLong)
     {
      Print("BUY "+Symbol()+
            ", Entry: "+(string)Long_Entry+
            ", SL: "+(string)Long_SL+
            ", TP: "+(string)Long_TP);
      Create_Label("BUY: " + (string)Long_Entry,0,Low[1],clrGreen,2,labelAngle);
      Create_Label("SL: " + (string)Long_SL,0,Low[1],clrGreen,3,labelAngle);
      Create_Label("TP: " + (string)Long_TP,0,Low[1],clrGreen,4,labelAngle);

      if(SendNotifications)
        {
         SendNotification("BUY "+Symbol()+
                          ", Entry: "+(string)Long_Entry+
                          ", SL: "+(string)Long_SL+
                          ", TP: "+(string)Long_TP);
        }
     }//buy
   else
     {
      Print("SELL "+Symbol()+
            ", Entry: "+(string)Short_Entry+
            ", SL: "+(string)Short_SL+
            ", TP: "+(string)Short_TP);
      Create_Label("SELL: " + (string)Short_Entry,0,High[1],clrRed,4,labelAngle);
      Create_Label("SL: " + (string)Short_SL,0,High[1],clrRed,3,labelAngle);
      Create_Label("TP: " + (string)Short_TP,0,High[1],clrRed,2,labelAngle);

      if(SendNotifications)
        {
         SendNotification("SELL "+Symbol()+
                          ", Entry: "+(string)Short_Entry+
                          ", SL: "+(string)Short_SL+
                          ", TP: "+(string)Short_TP);
        }
     }//sell
  }//prints Enter_Stop values for manual trades on the same basis as algorithimc function




//+------------------------------------------------------------------+
//| Enter_Limit                                                      |
//+------------------------------------------------------------------+
int Enter_Limit(bool isLong, double lotSize, double entry, double SLpips, double TPpips, double pipFilter, int Slip, int Magic_X, datetime Expiry, bool Debug, bool Test, bool SendNotifications)
  {
//--- declarations

   bool     DebugAlerts =  Debug;
   int      TicketNo;
   string   Comments    =  "None";
   double   Lots        =  lotSize;
   int      labelAngle  =  0;

   double   Long_Entry  =  NormalizeDouble(entry         + (pipFilter * PipValue()),_Digits);
   double   Long_SL     = (SLpips == 0) ? 0 : NormalizeDouble((Long_Entry  - (SLpips    * PipValue())),_Digits);
   double   Long_TP     = (TPpips == 0) ? 0 : NormalizeDouble((Long_Entry  + (TPpips    * PipValue())),_Digits);


   double   Short_Entry =  entry         - (pipFilter * PipValue());
   double   Short_SL    = (SLpips == 0) ? 0 : NormalizeDouble((Short_Entry + (SLpips    * PipValue())),_Digits);
   double   Short_TP    = (TPpips == 0) ? 0 : NormalizeDouble((Short_Entry - (TPpips    * PipValue())),_Digits);

   double   LongPipsRisk   =  NormalizeDouble(((Long_Entry - Long_SL)   / PipValue()),1);
   double   ShortPipsRisk  =  NormalizeDouble(((Short_SL - Short_Entry) / PipValue()),1);

//---orders

   if(isLong)
     {
      TicketNo =  OrderSend(Symbol(),OP_BUYLIMIT,Lots,Long_Entry,Slip,Long_SL,Long_TP,Comments,Magic_X,Expiry,clrBlue);
      if(TicketNo < 1)
        {
         Print("");
         Print("Long LIMIT order NOT PLACED : " + ErrorDescription(GetLastError()));
        }//order
      else
        {
         Print("");
         Print("Long LIMIT order PLACED");
         Create_Label("Odr: " + (string)TicketNo,0,Low[1],clrGreen,1.0,labelAngle);
         if(SendNotifications)
           {
            SendNotification("BUY "+Symbol()+
                             ", Entry: "+(string)Long_Entry+
                             ", SL: "+(string)Long_SL+
                             ", TP: "+(string)Long_TP);
           }
        }//errors
     }//buy
   else
     {
      TicketNo =  OrderSend(Symbol(),OP_SELLLIMIT,Lots,Short_Entry,Slip,Short_SL,Short_TP,Comments,Magic_X,Expiry,clrBlue);
      if(TicketNo < 1)
        {
         Print("");
         Print("Short LIMIT order NOT PLACED : " + ErrorDescription(GetLastError()));
        }//order
      else
        {
         Print("");
         Print("Short LIMIT order PLACED");
         Create_Label("Odr: " + (string)TicketNo,0,High[1],clrRed,1.0,labelAngle);
         if(SendNotifications)
           {
            SendNotification("SELL "+Symbol()+
                             ", Entry: "+(string)Short_Entry+
                             ", SL: "+(string)Short_SL+
                             ", TP: "+(string)Short_TP);
           }

        }//errors
     }//sell

//--- debug alerts


   if((Test) && (isLong == true))
     {
      Print("Odr Number is: "    + (string)TicketNo);
      Print("Long_Entry is: "       + (string)Long_Entry);
      Print("Ask is: "              + (string)Ask);
      Print("Long_SL is: "          + (string)Long_SL);
      Print("Long_TP is: "          + (string)Long_TP);
      Print("Long Risk in Pips: "   + (string)LongPipsRisk);
     }

   if((Test) && (isLong == false))
     {
      Print("Odr Number is: "    + (string)TicketNo);
      Print("Short_Entry is: "      + (string)Short_Entry);
      Print("Bid is: "              + (string)Bid);
      Print("Short_SL is: "         + (string)Short_SL);
      Print("Short_TP is: "         + (string)Short_TP);
      Print("Shrot Risk in Pips: "   + (string)ShortPipsRisk);
     }


   if((DebugAlerts) && (isLong == true))
     {
      Alert("Odr is: "         + (string)TicketNo);
      Alert("PipValue is: "         + (string)PipValue());
      Alert("Spread is: "           + (string)((NormalizeDouble((MarketInfo(Symbol(),MODE_SPREAD)),_Digits) * PipValue()) / 10));
      Alert("");
      Alert("Ask is: "              + (string)Ask);
      // Alert("OrderOpenPrice is: "   + (string)OrderOpenPrice());
      Alert("");
      Alert("Long_SL is: "          + (string)Long_SL);
      Alert("Long_TP is: "          + (string)Long_TP);
      Alert("PipFilter is: "        + (string)pipFilter);
      Alert("Long_Entry is: "       + (string)Long_Entry);
      Alert("");
      Alert("SL in pips is: "       + (string)(Long_Entry - Long_SL));
      Alert("TP in pips is: "       + (string)(Long_TP    - Long_Entry));
     }
   if((DebugAlerts) && (isLong == false))
     {
      Alert("Odr is: "         + (string)TicketNo);
      Alert("PipValue is: "         + (string)PipValue());
      Alert("Spread is: "           + (string)((NormalizeDouble((MarketInfo(Symbol(),MODE_SPREAD)),_Digits) * PipValue()) / 10));
      Alert("");
      Alert("Bid is: "              + (string)Bid);
      //Alert("OrderOpenPrice is: "   + (string)OrderOpenPrice());
      Alert("");
      Alert("Short_SL is: "         + (string)Short_SL);
      Alert("Short_TP is: "         + (string)Short_TP);
      Alert("PipFilter is: "        + (string)pipFilter);
      Alert("Short_Entry is: "      + (string)Short_Entry);
      Alert("");
      Alert("SL in pips is: "       + (string)(Short_SL    - Short_Entry));
      Alert("TP in pips is: "       + (string)(Short_Entry - Short_TP));
     }
   return(TicketNo);
  }//simple send limit order funciton






//+------------------------------------------------------------------+
//| ExpiryInSeconds                                                  |
//+------------------------------------------------------------------+
datetime ExpiryInSeconds(int candles, int PeriodInMinutes)
  {
   datetime    TimeNow           =  TimeCurrent();
   datetime    SecondsToExpiry   = ((candles * PeriodInMinutes) * 60);
   datetime    ExpirySeconds   = TimeNow + SecondsToExpiry;

   if(ExpirySeconds<600)
      ExpirySeconds=600;

   return(ExpirySeconds);
  }//returns the value of x candles a seconds for expiry in ending order





//+------------------------------------------------------------------+
//| CheckSignalOncePerCandle2                                        |
//+------------------------------------------------------------------+
bool CheckSignalOncePerCandle2(bool isTrue)
  {
   static datetime candletimeLocal=0;

   if((candletimeLocal != Time[0]) && (isTrue == true))
     {
      candletimeLocal = Time[0];
      return(true);
     }
   else
      if((candletimeLocal != Time[0]) && (isTrue == false))
        {
         return(true);
        }
      else
        {
         return(false);
        }
  }//function checks Time[0] against the opening time of the candel
//and when set to true wil only allow the expert to trade once per
//candle. must be added to signal " GoLong  + CheckSignalOncePerCandle(true)
//to work




//+------------------------------------------------------------------+
//| CheckSignalOncePerCandle                                         |
//+------------------------------------------------------------------+
bool CheckSignalOncePerCandle(bool isTrue)
  {
   static datetime candletimeLocal=0;

   if((candletimeLocal != Time[0]) && (isTrue == true))
     {
      candletimeLocal = Time[0];
      return(true);
     }
   else
      if((candletimeLocal != Time[0]) && (isTrue == false))
        {
         return(true);
        }
      else
        {
         return(false);
        }
  }//function checks Time[0] against the opening time of the candel
//and when set to true wil only allow the expert to trade once per
//candle. must be added to signal " GoLong  + CheckSignalOncePerCandle(true)
//to work


//+------------------------------------------------------------------+
//| CheckSignalOncePerIndexCandle                                    |
//+------------------------------------------------------------------+
bool CheckSignalOncePerIndexCandle(bool isTrue, int i)
  {
   static datetime candletimeLocal=0;

   if((candletimeLocal != Time[i]) && (isTrue == true))
     {
      candletimeLocal = Time[i];
      return(true);
     }
   else
      if((candletimeLocal != Time[i]) && (isTrue == false))
        {
         return(true);
        }
      else
        {
         return(false);
        }
  }//function checks Time[0] against the opening time of the candel
//and when set to true wil only allow the expert to trade once per
//candle. must be added to signal " GoLong  + CheckSignalOncePerCandle(true)
//to work




//+------------------------------------------------------------------+
// TotalOpenOrders
//+------------------------------------------------------------------+
int TotalOpenOrders(int Magic_X)
  {
   int total=0;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderMagicNumber() == Magic_X)
            total++;
        }
      else
         Print(__FUNCTION__,"Failed to select order ",GetLastError());
     }
   return (total);
  }//Total of ALL orders place by this expert. just insert Magic Number
// as a parameter





//+------------------------------------------------------------------+
//Total of all BUY orders place by this expert.
//+------------------------------------------------------------------+
int TotalOpenBuyOrders(int Magic_X)
  {
   int Total=0;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderMagicNumber() == Magic_X)
            if((OrderType()==OP_BUY) || (OrderType() == OP_BUYSTOP) || (OrderType() == OP_BUYLIMIT))
               Total++;
        }
      else
         Print(__FUNCTION__,"Failed to select order",ErrorDescription(GetLastError()));
     }
//Print("Total Open Longs: " + (string)Total);
   return (Total);
  }//function to count total of all open and pending longs





//+------------------------------------------------------------------+
//Total of all SELL orders place by this expert.
//+------------------------------------------------------------------+
int TotalOpenSellOrders(int Magic_X)
  {
   int Total=0;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderMagicNumber() == Magic_X)
            if((OrderType() == OP_SELL) || (OrderType() == OP_SELLSTOP) || (OrderType() == OP_SELLLIMIT))
               Total++;
        }
      else
         Print(__FUNCTION__,"Failed to select order ",i," ",ErrorDescription(GetLastError()));
     }
//Print("Total Open Shorts: " + (string)Total);
   return (Total);
  }//function to count total of all open and pending shorts




//+------------------------------------------------------------------+
//| DeletePendingLongs                                               |
//+------------------------------------------------------------------+
void DeletePendingLongs(int Magic_X)
  {
   for(int i=0; i<=(OrdersTotal()-1); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderMagicNumber() == Magic_X)
            if((OrderType() == OP_BUYSTOP) || (OrderType() == OP_BUYLIMIT))
              {
               int Ticket = OrderTicket();
               if(!OrderDelete(Ticket))
                  Print("Failed to close open long due to: "+ ErrorDescription(GetLastError()));
               else
                  i--;
              }
        }
     }
  }//function to delete all pending long order orprint error





//+------------------------------------------------------------------+
//| DeletePendingShorts                                              |
//+------------------------------------------------------------------+
void DeletePendingShorts(int Magic_X)
  {
   for(int i=0; i<=(OrdersTotal()-1); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderMagicNumber() == Magic_X)
            if((OrderType() == OP_SELLSTOP) || (OrderType() == OP_SELLLIMIT))
              {
               int Ticket = OrderTicket();
               if(!OrderDelete(Ticket))
                  Print("Failed to close open short due to: "+ ErrorDescription(GetLastError()));
               else
                  i--;
              }
        }
     }
  }//function to delete all pending long order orprint error





//+------------------------------------------------------------------+
//|ExitLongs                                                         |
//+------------------------------------------------------------------+
void ExitLongs(int Magic_X, int Slip)
  {
//--- declarations
   int   Total       = OrdersTotal()-1;
   int   MaxAttempts = 7;
   color ShortColor  = clrRed;


   for(int i=Total; i >=0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderMagicNumber() == Magic_X)
            if((OrderType() == OP_BUY) /*|| (OrderType() == OP_BUYSTOP) || (OrderType() == OP_BUYLIMIT)*/)
              {
               int   Attempts = 1;
               while(Attempts <= MaxAttempts)
                 {
                  int Error =0;
                  RefreshRates();
                  bool result = OrderClose(OrderTicket(), OrderLots(),Bid, Slip, ShortColor);
                  if(result)
                     break;//--- breaks here if successful
                  else
                    {
                     Error = GetLastError();
                     Print("Error on Buy order closing atempt: ",ErrorDescription(Error));
                     if(Error==4108)
                        break; // invalid ticket. break out of while loop
                     switch(Error)//this switch sleeps in case of errs related to broker/termianl buy
                       {
                        case 135: //Price Changed.
                        case 136: //Off Quotes.
                        case 137: //Broker Busy
                        case 138: //Requote
                        case 146: //Trade Context Busy
                           Sleep(1000);
                           RefreshRates();//will do these things if any of these five are the case and then break below
                        default:
                           break;//break out of switch
                       }//switch
                    }//else
                  Attempts++;
                  if(Attempts == (MaxAttempts + 1))
                     Print("Could not close long trades after " + (string)MaxAttempts + " attempts.",ErrorDescription(Error));
                 }//while
              }//OP_BUY
        }//OrderSelect
      else
         Print("When selecting a trade, error ",GetLastError()," occurred"); //OrderSelect returned false
     }//for
  }//function closes all buy trades by making multiple attemps and reports on errors if unsuccessful






//+------------------------------------------------------------------+
//|ExitShorts                                                        |
//+------------------------------------------------------------------+
void ExitShorts(int Magic_X,int Slip)
  {
//--- declarations
   int   Total       = OrdersTotal()-1;
   int   MaxAttempts = 7;
   color LongColor  = clrGreen;


   for(int i=Total; i >=0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderMagicNumber() == Magic_X)
            if((OrderType() == OP_SELL) /*|| (OrderType() == OP_SELLSTOP) || (OrderType() == OP_SELLLIMIT)*/)
              {
               int   Attempts = 1;
               while(Attempts <= MaxAttempts)
                 {
                  int Error = 0;
                  RefreshRates();
                  bool result = OrderClose(OrderTicket(), OrderLots(),Ask, Slip, LongColor);
                  if(result)
                     break;//--- breaks here if successful
                  else
                    {
                     Error = GetLastError();
                     Print("Error on Sell order closing attempt: ",ErrorDescription(Error));
                     if(Error==4108)
                        break; // invalid ticket. break out of while loop
                     switch(Error)//this switch sleeps in case of errs related to broker/termianl buy
                       {
                        case 135: //Price Changed.
                        case 136: //Off Quotes.
                        case 137: //Broker Busy
                        case 138: //Requote
                        case 146: //Trade Context Busy
                           Sleep(1000);
                           RefreshRates();//will do these things if any of these five are the case and then break below
                        default:
                           break;//break out of switch
                       }//switch
                    }//else
                  Attempts++;
                  if(Attempts == (MaxAttempts + 1))
                     Print("Could not close short trades after " + (string)MaxAttempts + " attempts.",ErrorDescription(Error));
                 }//while
              }//OP_SELL
        }//OrderSelect
      else
         Print("When selecting a trade, error ",GetLastError()," occurred"); //OrderSelect returned false
     }//for
  }//function closes all sell trades by making multiple attemps and reports on errors if unsuccessful






//+------------------------------------------------------------------+
//| CloseOpenLongs                                                   |
//+------------------------------------------------------------------+
void CloseOpenLongs(int Magic_X, int Slip)
  {
   for(int i=0; i<=(OrdersTotal()-1); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderMagicNumber() == Magic_X)
            if(OrderType() == OP_BUY)
              {
               int Ticket = OrderTicket();
               if(!OrderClose(Ticket,OrderLots(),Bid,Slip,clrRed))
                  Print("Failed to close open long due to: " +ErrorDescription(GetLastError()));
               else
                  i--;
              }
        }
     }
  }//function to delete all pending long order orprint error






//+------------------------------------------------------------------+
//| CloseOpenShorts                                                  |
//+------------------------------------------------------------------+
void CloseOpenShorts(int Magic_X, int Slip)
  {
   for(int i=0; i<=(OrdersTotal()-1); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderMagicNumber() == Magic_X)
            if(OrderType() == OP_SELL)
              {
               int Ticket = OrderTicket();
               if(!OrderClose(Ticket,OrderLots(),Ask,Slip,clrGreen))
                  Print("Failed to close open short due to: " + ErrorDescription(GetLastError()));
               else
                  i--;
              }
        }
     }
  }//function to delete all pending long order orprint error





//+------------------------------------------------------------------+
//|CloseAllLongs                                                     |
//+------------------------------------------------------------------+
void CloseAllLongs(int Magic_X, int Slip)
  {
   while(TotalOpenBuyOrders(Magic_X) > 0)
     {
      DeletePendingLongs(Magic_X);
      CloseOpenLongs(Magic_X,Slip);
     }
  }//closes all pending and open long orders





//+------------------------------------------------------------------+
//|CloseAllShorts                                                    |
//+------------------------------------------------------------------+
void CloseAllShorts(int Magic_X, int Slip)
  {
   DeletePendingShorts(Magic_X);
   Sleep(200);
   ExitShorts(Magic_X,Slip);
   CloseOpenShorts(Magic_X,Slip);
  }//closes all pending and open short orders





//+------------------------------------------------------------------+
//| EnterTrade_CloseOnReverse                                                                 |
//+------------------------------------------------------------------+
int EnterTrade_CloseOnReverse(bool isLong, double StopInPips, double TargetInPips, double lotSize, int Magic_X)
  {
   int      Ticket=2;
   double   LongStop          = (StopInPips   == 0)  ? 0 : NormalizeDouble((Ask - (StopInPips    * PipValue())),_Digits);
   double   LongTarget        = (TargetInPips == 0)  ? 0 : NormalizeDouble((Ask + (TargetInPips  * PipValue())),_Digits);

   double   ShortStop         = (StopInPips   == 0)  ? 0 : NormalizeDouble((Bid + (StopInPips    * PipValue())),_Digits);
   double   ShortTarget       = (TargetInPips == 0)  ? 0 : NormalizeDouble((Bid - (TargetInPips  * PipValue())),_Digits);

   if(isLong)
     {
      CloseOpenShorts(Magic_X,10);
      if(OrdersTotal() < 1)
        {
         Ticket    = OrderSend(Symbol(),OP_BUY,lotSize,Ask,10,LongStop,LongTarget,"GoLong",Magic_X,0,clrBlue);
        }
     }
   else
      if(!isLong)
        {
         CloseOpenLongs(Magic_X,10);
         if(OrdersTotal() < 1)
           {
            Ticket   = OrderSend(Symbol(),OP_SELL,lotSize,Bid,10,ShortStop,ShortTarget,"GoShort",Magic_X,0,clrRed);
           }
        }
   return(Ticket);
  }//close on recverse function for MA based strategies



//+------------------------------------------------------------------+
//| UsingRRRTakeProfit                                               |
//+------------------------------------------------------------------+
double UsingRRRTakeProfit(double SL_InPips, double R_Multiple)
  {

   double TPinPips;

   if(R_Multiple == 0)
     {
      TPinPips = 0;
     }
   else
      if(SL_InPips != 0)
        {
         TPinPips = (SL_InPips * 2);
        }
      else
        {
         TPinPips = 0;
        }
//Alert(takeProfitInPips);
   return(TPinPips);
//---
  }//returns TP in pips when using an RRR To define,
//overcomes idveide by zero error when not using a stop




//+------------------------------------------------------------------+
//|More_Orders_Allowed                                               |
//+------------------------------------------------------------------+
bool More_Orders_Allowed(int maxOrders)
  {
   if(OrdersTotal() < maxOrders)
     {
      return(true);
     }
   else
     {
      return(false);
     }
  }//function return true if open orders less than total orders allowed





//+------------------------------------------------------------------+
//| limit                                                            |
//+------------------------------------------------------------------+
int limit()
  {
   int limit;
   int counted_bars = IndicatorCounted();

   if(!counted_bars)
     {
      limit=Bars-2;
     }
   else
     {
      limit=Bars-counted_bars-1;
     }
   return(limit);
  }//for loop decrementer





//+------------------------------------------------------------------+
//| Check HigherTimeframe Compatible                                 |
//+------------------------------------------------------------------+
int Check_Multiple_Timeframes_Compatible(int HTF, int MTF)
  {
   if(HTF<=Period())
     {
      PrintFormat("Select a Higher Timeframe that is higher than the current chart");
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(MTF<=Period())
     {
      PrintFormat("Select a Medium Timeframe that is higher than the current chart");
      return(INIT_PARAMETERS_INCORRECT);
     }
   else
     {
      return(INIT_SUCCEEDED);
     }
  }//function returns true if the hgher and medium timeframes aneterd
//are greater thabn the curent chart period and are therefore compatible


//+------------------------------------------------------------------+
//| Check HigherTimeframe Compatible                                 |
//+------------------------------------------------------------------+
int Check_Timeframe_Compatible(int HTF)
  {
   if(HTF<=Period())
     {
      PrintFormat("Select a Higher Timeframe that is higher than the current chart");
      return(INIT_PARAMETERS_INCORRECT);
     }
   else
     {
      return(INIT_SUCCEEDED);
     }
  }//function returns true if the hgher and medium timeframes aneterd
//are greater thabn the curent chart period and are therefore compatible





//--------------------------------------------------------------------
// int PivotDay( datetime BarTime, datetime ShiftHrs )
// Returns the day of the week for pivot point calculations.
// datetime BarTime: time stamp of the bar of interest
// datetime Shift:   the pivot time - server time shift
//                   i.e. if the time for pivot calculation is ahead
//                   of server time, the shift is positive.
//--------------------------------------------------------------------
int PivotDay(datetime BarTime2,datetime ShiftHrs2)
  {
   int PDay=TimeDayOfWeek(BarTime2+ShiftHrs2*3600);

   if(PDay == 0)
      PDay = 1;      // Count Sunday as Monday
   if(PDay == 6)
      PDay = 5;      // Count Saturday as Friday

   return(PDay);
  }
//+------------------------------------------------------------------+





////+------------------------------------------------------------------+
////| IsNewDay                                                         |
////+------------------------------------------------------------------+
//bool IsNewDay(datetime Today)
//  {
//
//   if(Today!=DayOfWeek())
//     {
//      Today=DayOfWeek();
//      return(true);
//     }
//   else
//     {
//      return(false);
//     }
//  }//returns true on a new sday of the week
//







//+------------------------------------------------------------------+
//| Resistance                                                       |
//+------------------------------------------------------------------+
bool Resistance(int index, double level)
  {
   int k = index;

   if((Open[k] > Close[k]) && (High[k] > level) && (Close[k] < level) && (Open[k] < level))//bearish
     {
      return(true);
     }
   else
      if((Open[k] < Close[k]) && (High[k] > level) && (Close[k] < level) && (Open[k] < level))//bullish
        {
         return(true);
        }
      else
        {
         return(false);
        }
  }// returns true if idexed candle is rejected at nominated level




//+------------------------------------------------------------------+
//| Support                                                          |
//+------------------------------------------------------------------+
bool Support(int index, double level)
  {
   int k = index;

   if((Open[k] > Close[k]) && (Low[k] < level) && (Close[k] > level) && (Open[k] > level))//bearish
     {
      return(true);
     }
   else
      if((Open[k] < Close[k]) && (Low[k] < level) && (Close[k] > level) && (Open[k] > level))//bullish
        {
         return(true);
        }
      else
        {
         return(false);
        }
  }// returns true if idexed candle is rejected at nominated level


//+------------------------------------------------------------------+
//| Dynamic_Resistance                                               |
//+------------------------------------------------------------------+
bool Dynamic_Resistance(int index, double level)
  {
   int k = index;

   if((Open[k] > Close[k]) && (High[k] > level) && (Close[k] < level) && (Open[k] < level))//bearish
     {
      return(true);
     }
   else
      if((Open[k] < Close[k]) && (High[k] > level) && (Close[k] < level) && (Open[k] < level))//bullish
        {
         return(true);
        }
      else
        {
         return(false);
        }
  }// returns true if idexed candle is rejected at nominated level




//+------------------------------------------------------------------+
//| Dynamic_Support                                                  |
//+------------------------------------------------------------------+
bool Dynamic_Support(int index, double level)
  {
   int k = index;

   if((Open[k] > Close[k]) && (Low[k] < level) && (Close[k] > level) && (Open[k] > level))//bearish
     {
      return(true);
     }
   else
      if((Open[k] < Close[k]) && (Low[k] < level) && (Close[k] > level) && (Open[k] > level))//bullish
        {
         return(true);
        }
      else
        {
         return(false);
        }
  }// returns true if idexed candle is rejected at nominated level




//+------------------------------------------------------------------+
//| Candles_In_Day                                                   |
//+------------------------------------------------------------------+
int Candles_In_Day()
  {
   int Candles_In_Day = PERIOD_D1 / Period();
   return(Candles_In_Day);
  }//returns the amount of candles in a day for shifting index based on Period()




//+------------------------------------------------------------------+
//| AOR_limit                                                        |
//+------------------------------------------------------------------+
int   AOR_limit(int highestTimeframe, int maxLookback)
  {

   int   totalLookbackinHTF      =  highestTimeframe * maxLookback;
   int   totalLookbackinCURRENT  =  totalLookbackinHTF   /  Period();
   return(totalLookbackinCURRENT);

  }//returns max lookback for deducing lokback limit on a foor loop



//+------------------------------------------------------------------+
//| isTime                                                           |
//+------------------------------------------------------------------+
bool  isTime(datetime hour, datetime minute, int CandleIndex)
  {
   if((TimeHour(Time[CandleIndex]) == hour) && (TimeMinute(Time[CandleIndex]) == minute))
     {
      return(true);
      Print("Time[i] is " + (string)hour + ":" + (string)minute);
     }
   else
     {
      return(false);
     }
  }//returns true is specified time is Time[0]




///+------------------------------------------------------------------+
//|Generate a Magic Number                                           |
//+------------------------------------------------------------------+
int MagicNumberGenerator(int MagicSeed_lc)
  {
   string mySymbol=StringSubstr(_Symbol,0,6);
   int pairNumber=0;
   int GeneratedNumber=0;
   if(mySymbol=="AUDCAD")
      pairNumber=1;
   else
      if(mySymbol == "AUDCHF")
         pairNumber=2;
      else
         if(mySymbol == "AUDJPY")
            pairNumber=3;
         else
            if(mySymbol == "AUDNZD")
               pairNumber=4;
            else
               if(mySymbol == "AUDUSD")
                  pairNumber=5;
               else
                  if(mySymbol == "CADCHF")
                     pairNumber=6;
                  else
                     if(mySymbol == "CADJPY")
                        pairNumber=7;
                     else
                        if(mySymbol == "CHFJPY")
                           pairNumber=8;
                        else
                           if(mySymbol == "EURAUD")
                              pairNumber=9;
                           else
                              if(mySymbol == "EURCAD")
                                 pairNumber=10;
                              else
                                 if(mySymbol == "EURCHF")
                                    pairNumber=11;
                                 else
                                    if(mySymbol == "EURGBP")
                                       pairNumber=12;
                                    else
                                       if(mySymbol == "EURJPY")
                                          pairNumber=13;
                                       else
                                          if(mySymbol == "EURNZD")
                                             pairNumber=14;
                                          else
                                             if(mySymbol == "EURUSD")
                                                pairNumber=15;
                                             else
                                                if(mySymbol == "GBPAUD")
                                                   pairNumber=16;
                                                else
                                                   if(mySymbol == "GBPCAD")
                                                      pairNumber=17;
                                                   else
                                                      if(mySymbol == "GBPCHF")
                                                         pairNumber=18;
                                                      else
                                                         if(mySymbol == "GBPJPY")
                                                            pairNumber=19;
                                                         else
                                                            if(mySymbol == "GBPNZD")
                                                               pairNumber=20;
                                                            else
                                                               if(mySymbol == "GBPUSD")
                                                                  pairNumber=21;
                                                               else
                                                                  if(mySymbol == "NZDCAD")
                                                                     pairNumber=22;
                                                                  else
                                                                     if(mySymbol == "NZDJPY")
                                                                        pairNumber=23;
                                                                     else
                                                                        if(mySymbol == "NZDCHF")
                                                                           pairNumber=24;
                                                                        else
                                                                           if(mySymbol == "NZDUSD")
                                                                              pairNumber=25;
                                                                           else
                                                                              if(mySymbol == "USDCAD")
                                                                                 pairNumber=26;
                                                                              else
                                                                                 if(mySymbol == "USDCHF")
                                                                                    pairNumber=27;
                                                                                 else
                                                                                    if(mySymbol == "USDJPY")
                                                                                       pairNumber=28;
                                                                                    else
                                                                                       if(mySymbol == "XAGUSD")
                                                                                          pairNumber=29;
                                                                                       else
                                                                                          if(mySymbol == "XAUUSD")
                                                                                             pairNumber=30;
                                                                                          else
                                                                                             if(mySymbol == "SPX500")
                                                                                                pairNumber=31;
                                                                                             else
                                                                                                if(mySymbol == "AUS200")
                                                                                                   pairNumber=32;
                                                                                                //do the 5 character cfd's
                                                                                                else
                                                                                                   mySymbol=StringSubstr(mySymbol,0,5);
   if(mySymbol      == "GER30")
      pairNumber=33;
   else
      if(mySymbol == "FRA40")
         pairNumber=34;
      //do the 4 characther cfd's
      else
         mySymbol=StringSubstr(mySymbol,0,4);
   if(mySymbol == "US30")
      pairNumber=35;

   GeneratedNumber=MagicSeed_lc+(pairNumber*1000)+_Period;
   return(GeneratedNumber);
  }

//+------------------------------------------------------------------+
//|OrderDebugPrints                                                  |
//+------------------------------------------------------------------+
void OrderDebugPrints(bool Debug, int TicketNumber, double PriceFilterInPips, double stop, double target, string Comments)
  {

   if(Debug == true)
     {
      if(TicketNumber < 0)
        {
         int Error = GetLastError();
         Print("  ");
         Print("Order Rejected, error: "+(string)Error+" "+ErrorDescription(Error));
         Print("  ");
        }
      else
         if(OrderSelect(TicketNumber,SELECT_BY_TICKET)==true)
           {
            Print("  ");
            Print(" Order Succesfully Placed");
            Print(" Order Type: " + IntegerToString(OrderType()));
            Print(" LotSize: " + (string)OrderLots());
            Print(" Price: " + (string)OrderOpenPrice());
            Print(" PriceFilterInPips: " + (string)PriceFilterInPips);
            Print(" StopLoss: " + (string)stop);
            Print(" TakeProfit: " + (string)target);
            Print(" Comments: " + Comments);
            Print(" Magic Number: " + (string)OrderMagicNumber());
            Print(" Ticket No: " + (string)TicketNumber);
            Print(" Total Open Orders is now: " + (string)TotalOpenOrders(OrderMagicNumber()));
            Print("  ");
           }//ticketnumber
     }//debug
  }//endfunction



//+------------------------------------------------------------------+
//| Create_Label                                                                  |
//+------------------------------------------------------------------+
void Create_Label(string text, int index, double price, color colorLabel, double shift, double angle)
  {
   double      LabelPrice  = ((colorLabel == clrRed) || (colorLabel == clrOrange)) ? (price + (Plot_Shift * shift)) : (price - (Plot_Shift * shift));
   string      TimeIndex   =  TimeToStr(Time[index]);
   double      Randomiser  = (High[index+1]) * (Low[index+1]);
   string      LabelName   =  text + TimeIndex + (string)Randomiser;
   datetime    LabelTime   =  Time[index];

   ObjectCreate(0, LabelName, OBJ_TEXT, 0, LabelTime, LabelPrice);
   ObjectSetInteger(0, LabelName, OBJPROP_COLOR, colorLabel);
   ObjectSetInteger(0, LabelName, OBJPROP_FONTSIZE, 6);
   ObjectSetString(0, LabelName, OBJPROP_TEXT,text);
   ObjectSetDouble(0, LabelName, OBJPROP_ANGLE, angle);
  }//simple label creation



//+------------------------------------------------------------------+
//| PrintBreakEven                                                   |
//+------------------------------------------------------------------+
void PrintBreakEven(int index, bool Debug)
  {
   Print("Moving Ticket " + (string)OrderTicket() + " to Break Even");
  }//Prints details of 'move stop to breakeven' for debugging




//+------------------------------------------------------------------+
//| Universal Definitions                                            |
//+------------------------------------------------------------------+

#define        UpArrow   233
#define        UpCross   71

#define        DownArrow 234
#define        DownCross 251


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double            Plot_Shift = 0.5* ((WindowPriceMax() - WindowPriceMin()) * 0.1);
double            Shift       = 50 * Point;

//--- entries
//bool           GoLong;
//bool           GoShort;

//bool           BuyEntry;
//bool           SellEntry;
//
//bool           BuyExit;
//bool           SellExit;


//--- time items
datetime Now                     = TimeCurrent(),
         Beginning_Of_Day        = Now - Now % 86400, // Beginning of the day
         Tomorrow                = Beginning_Of_Day + 86400,
         Expiration              = Tomorrow - 1;









//+------------------------------------------------------------------+
//|Candlesticks                                                      |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|Total_Candle_Size                                                 |
//+------------------------------------------------------------------+
double Total_Candle_Size(int index)
  {
   double Candle_Size = (High[index] - Low[index]);
   return(Candle_Size);
  }//returns total size of candle from high to low





//+------------------------------------------------------------------+
//|Body_Of_Candle                                                    |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Body_Of_Candle(int index)
  {
   double Body = MathAbs(Open[index] - Close[index]);
   return(Body);
  }//returns  size of body of candle



//+------------------------------------------------------------------+
//|UPPER_Wick_Of_Candle                                              |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double UPPER_Wick_Of_Candle(int index)
  {
   if(Open[index] < Close[index])//Bullish
     {
      double upperWick = (High[index] - Close[index]);
      return(NormalizeDouble(upperWick,_Digits));
     }
   else
     {
      double upperWick = (High[index] - Open[index]);
      return(NormalizeDouble(upperWick,_Digits));
     }
  }//returns size of UPPER WICK of candle








//+------------------------------------------------------------------+
//|UPPER_Wick_Of_Candle_Min                                          |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double UPPER_Wick_Of_Candle_Min(int index)
  {

   if(Open[index] < Close[index])//Bullish
     {
      double upperWick = (High[index] - Close[index]);
      if(upperWick < 0.0001)
        {
         return(0.0);
        }
      else
        {
         return(NormalizeDouble(upperWick,_Digits));
        }
     }
   else
     {
      double upperWick = (High[index] - Open[index]);
      if(upperWick < 0.0001)
        {
         return(0.0);
        }
      else
        {
         return(NormalizeDouble(upperWick,_Digits));
        }
     }

  }//returns size of UPPER WICK of candle, when size is less than e-05






//+------------------------------------------------------------------+
//|LOWER_Wick_Of_Candle                                              |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LOWER_Wick_Of_Candle(int index)
  {
   if(Open[index] < Close[index])//Bullish
     {
      double lowerWick = (Open[index] - Low[index]);
      return(NormalizeDouble(lowerWick,_Digits));
     }
   else
     {
      double lowerWick = (Close[index] - Low[index]);
      return(NormalizeDouble(lowerWick,_Digits));
     }
  }//returns size of LOWER WICK of candle






//+------------------------------------------------------------------+
//|LOWER_Wick_Of_Candle_Min_0                                        |
//+------------------------------------------------------------------+
double LOWER_Wick_Of_Candle_Min(int index)
  {

   if(Open[index] < Close[index])//Bullish
     {
      double lowerWick = (Open[index] - Low[index]);
      if(lowerWick < 0.0001)
        {
         return(0.0);
        }
      else
        {
         return(NormalizeDouble(lowerWick,_Digits));
        }
     }
   else
     {
      double lowerWick = (Close[index] - Low[index]);
      if(lowerWick < 0.0001)
        {
         return(0.0);
        }
      else
        {
         return(NormalizeDouble(lowerWick,_Digits));
        }
     }

  }//returns size of UPPER WICK of candle, when size is less than e-05





//+------------------------------------------------------------------+
//|Is_Swing_High                                                     |
//+------------------------------------------------------------------+
bool Is_Swing_High(int lookBack1, int testIndex)
  {

   int      period      =  lookBack1;
   double   swingHigh   =  iHigh(Symbol(),PERIOD_CURRENT,iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,lookBack1,0));
   double   testHigh    =  High[testIndex];

   if(testHigh == swingHigh)
     {
      return(true);
     }
   else
     {
      return(false);
     }

  }// returns true/fasle if the testIndex is the swinghigh over the lookback period





//+------------------------------------------------------------------+
//|Is_Swing_Low                                                      |
//+------------------------------------------------------------------+
bool Is_Swing_Low(int lookBack1, int testIndex)
  {

   int      period      =  lookBack1;
   double   swingLow    =  iLow(Symbol(),PERIOD_CURRENT,iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,lookBack1,0));
   double   testLow     =  Low[testIndex];

   if(testLow == swingLow)
     {
      return(true);
     }
   else
     {
      return(false);
     }

  }// returns true/fasle if the testIndex is the swinglow over the lookback period





//+------------------------------------------------------------------+
//| BreakEvenTrail                                                   |
//+------------------------------------------------------------------+
void  BreakEvenTrail(int PipsToMoveBeforeTrail, int MagicNo, bool Debug, bool SendNotifications)
  {

   double initialMovementNeeded   =  NormalizeDouble((PipsToMoveBeforeTrail * PipValue()),_Digits);
   double longPriceDistance       =  NormalizeDouble((Bid - OrderOpenPrice()),_Digits);
   double shortPriceDistance      =  NormalizeDouble((OrderOpenPrice() - Ask),_Digits);

   for(int i=OrdersTotal()-1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderMagicNumber()== MagicNo)
           {
            if(OrderType() == OP_BUY)
              {
               if(Bid - OrderOpenPrice() >  initialMovementNeeded)
                  if(OrderStopLoss() < OrderOpenPrice() || OrderStopLoss()==0)
                    {
                     if(Debug)
                       {
                        Print("Trail Type: BreakEven");
                        Print("Moving Ticket #" + (string)OrderTicket() + " to Break Even at" + (string)OrderOpenPrice());
                        Print("Moving SL from " + (string)OrderStopLoss() + ", " + (string) NormalizeDouble((MathAbs((OrderOpenPrice()- OrderStopLoss())) / PipValue()),1) + " pips to BE " + (string)OrderOpenPrice());
                       }
                     if(SendNotifications)
                       {
                        SendNotification("Order: #"+(string)OrderTicket()+
                                         " on "+(string)OrderSymbol()+
                                         ". Move SL to BREAKEVEN at "+(string)OrderOpenPrice());
                       }
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,clrDarkRed))
                       {
                        int err = GetLastError();
                        Print("Encountered an error during modification for order: " + (string)i + "! " + (string)err + " " + ErrorDescription(err));
                       }//modify
                    }
              }//buy
            else
               if(OrderType() == OP_SELL)
                 {
                  if(OrderOpenPrice() - Ask >  initialMovementNeeded)
                     if(OrderStopLoss() > OrderOpenPrice() || OrderStopLoss()==0)
                       {
                        if(Debug)
                          {
                           Print("Trail Type: BreakEven");
                           Print("Moving Ticket #" + (string)OrderTicket() + " to Break Even at" + (string)OrderOpenPrice());
                           Print("Moving SL from " + (string)OrderStopLoss() + ", " + (string) NormalizeDouble((MathAbs((OrderOpenPrice()- OrderStopLoss())) / PipValue()),1) + " pips to BE " + (string)OrderOpenPrice());
                          }

                        if(SendNotifications)
                          {
                           SendNotification("Order: #"+(string)OrderTicket()+
                                            " on "+(string)OrderSymbol()+
                                            ". Move SL to BREAKEVEN at "+(string)OrderOpenPrice());
                          }
                        if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,clrDarkRed))
                          {
                           int err = GetLastError();
                           Print("Encountered an error during modification!"+(string)err+" "+ErrorDescription(err));
                          }//modify
                       }
                 }//sell
           }//magic
        }
      else //in case it fails to select an order.
        {
         int err = GetLastError();
         Print("Encountered an error during order selection in: "+ __FUNCTION__+"!"+(string)err+" "+ErrorDescription(err));
        }// error
     }//for loop
  }//function




//+------------------------------------------------------------------+
//| RMulipleBreakEvenTrail                                          |
//+------------------------------------------------------------------+
void  RMulipleBreakEvenTrail(double RMutiplesBeforeBE, int MagicNo, bool Debug, bool SendNotifications)
  {

   double oneLongR                     =    OrderOpenPrice() - OrderStopLoss();
   double oneShortR                    =    OrderStopLoss()  - OrderOpenPrice();

   double initialLongMovementNeeded    =    NormalizeDouble(oneLongR,_Digits);
   double initialShortMovementNeeded   =    NormalizeDouble(oneShortR,_Digits);

   double longPriceDistance            =    NormalizeDouble((Bid - OrderOpenPrice()),_Digits);
   double shortPriceDistance           =    NormalizeDouble((OrderOpenPrice() - Ask),_Digits);

   for(int i=OrdersTotal()-1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderMagicNumber()== MagicNo)
           {
            if(OrderType() == OP_BUY)
              {
               if(Bid - OrderOpenPrice() >  initialLongMovementNeeded)
                  if(OrderStopLoss() < OrderOpenPrice() || OrderStopLoss()==0)
                    {
                     if(Debug)
                       {
                        Print("Trail Type: R-Multiple BreakEven");
                        Print("1 Long R-Multiple is :"+(string)NormalizeDouble(oneLongR,_Digits));
                        Print("Moving Ticket #" + (string)OrderTicket() + " to Break Even at" + (string)OrderOpenPrice());
                        Print("Moving SL from " + (string)OrderStopLoss() + ", " + (string) NormalizeDouble((MathAbs((OrderOpenPrice()- OrderStopLoss())) / PipValue()),1) + " pips to BE " + (string)OrderOpenPrice());
                       }
                     if(SendNotifications)
                       {
                        SendNotification("Order: #"+(string)OrderTicket()+
                                         " on "+(string)OrderSymbol()+
                                         ". Move SL to BREAKEVEN at "+(string)OrderOpenPrice());
                       }
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,clrDarkRed))
                       {
                        int err = GetLastError();
                        Print("Encountered an error during modification for order: " + (string)i + "! " + (string)err + " " + ErrorDescription(err));
                       }//modify
                    }
              }//buy
            else
               if(OrderType() == OP_SELL)
                 {
                  if(OrderOpenPrice() - Ask >  initialShortMovementNeeded)
                     if(OrderStopLoss() > OrderOpenPrice() || OrderStopLoss()==0)
                       {
                        if(Debug)
                          {
                           Print("Trail Type: R-Multiple BreakEven");
                           Print("1 Short R-Multiple is :"+(string)NormalizeDouble(oneShortR,_Digits) );
                           Print("Moving Ticket #" + (string)OrderTicket() + " to Break Even at" + (string)OrderOpenPrice());
                           Print("Moving SL from " + (string)OrderStopLoss() + ", " + (string) NormalizeDouble((MathAbs((OrderOpenPrice()- OrderStopLoss())) / PipValue()),1) + " pips to BE " + (string)OrderOpenPrice());
                          }

                        if(SendNotifications)
                          {
                           SendNotification("Order: #"+(string)OrderTicket()+
                                            " on "+(string)OrderSymbol()+
                                            ". Move SL to BREAKEVEN at "+(string)OrderOpenPrice());
                          }
                        if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,clrDarkRed))
                          {
                           int err = GetLastError();
                           Print("Encountered an error during modification!"+(string)err+" "+ErrorDescription(err));
                          }//modify
                       }
                 }//sell
           }//magic
        }
      else //in case it fails to select an order.
        {
         int err = GetLastError();
         Print("Encountered an error during order selection in: "+ __FUNCTION__+"!"+(string)err+" "+ErrorDescription(err));
        }// error
     }//for loop
  }//function



//+------------------------------------------------------------------+
//| RegularTrail                                                     |
//+------------------------------------------------------------------+
void RegularTrail(int PipsToTrailUp, int PipsToMoveBeforeTrail, int MagicNo, bool Debug, bool SendNotifications)
  {

   double initialMovementNeeded   =  NormalizeDouble((PipsToMoveBeforeTrail * PipValue()),_Digits);
   double longPriceDistance       =  NormalizeDouble((Bid - OrderOpenPrice()),_Digits);
   double shortPriceDistance      =  NormalizeDouble((OrderOpenPrice() - Ask),_Digits);

   double longTrailPrice          =  NormalizeDouble(Bid - (PipsToTrailUp * PipValue()),_Digits);
   double shortTrailPrice         =  NormalizeDouble(Ask + (PipsToTrailUp * PipValue()),_Digits);

   double longTrailToBid          =  NormalizeDouble((Bid - longTrailPrice),_Digits);
   double shortTrailToAsk         =  NormalizeDouble((shortTrailPrice - Ask),_Digits);

   for(int i=OrdersTotal()-1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderMagicNumber()== MagicNo)
           {
            if(OrderType()== OP_BUY)
              {
               if(Bid - OrderOpenPrice() > initialMovementNeeded)
                  if(OrderStopLoss() < longTrailPrice || OrderStopLoss()==0)
                    {
                     if(Debug)
                       {
                        Print("Trail Type: RegularTrail");
                        Print("Init Movement is: " + (string)initialMovementNeeded);
                        Print("Order: #" + (string)OrderTicket() + "'s Bid Price is " + (string)Bid);
                        Print("Distance between Current Bid and Open Price is " + (string)longPriceDistance + " or, " + (string)NormalizeDouble((longPriceDistance / PipValue()),_Digits) + " pips");
                        Print("Moving Ticket #" + (string)OrderTicket() + "'s SL");
                        Print("Pips to trail behind Bid: " + (string)PipsToTrailUp);
                        Print("Moving SL from " + (string)OrderStopLoss() + "to " + (string)longTrailPrice);
                        Print("Stoploss is now: " + (string) + longTrailToBid + " behind Bid");
                       }
                     if(SendNotifications)
                       {
                        SendNotification("Order: #"+(string)OrderTicket()+
                                         " on "+(string)OrderSymbol()+
                                         ". Move SL to "+(string)longTrailPrice);
                       }
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),longTrailPrice,OrderTakeProfit(),0,clrDarkRed))
                       {
                        int err = GetLastError();
                        Print("Encountered an error during modification for order: " + (string)i + "! " + (string)err + " " + ErrorDescription(err));
                       }//modify
                    }
              }//buy
            else
               if(OrderType()==OP_SELL)
                 {
                  if(OrderOpenPrice() - Ask > initialMovementNeeded)
                     if(OrderStopLoss() > shortTrailPrice  || OrderStopLoss()==0)
                       {
                        if(Debug)
                          {
                           Print("Trail Type: RegularTrail");
                           Print("Init Movement is: " + (string)initialMovementNeeded);
                           Print("Order: #" + (string)OrderTicket() + "'s Ask Price is " + (string)Ask);
                           Print("Distance between Current Ask and Open Price is " + (string)shortPriceDistance + " or, " + (string)NormalizeDouble((shortPriceDistance / PipValue()),_Digits) + " pips");
                           Print("Moving Ticket #" + (string)OrderTicket() + "'s SL");
                           Print("Pips to trail behind Ask: " + (string)PipsToTrailUp);
                           Print("Moving SL from " + (string)OrderStopLoss() + " to " + (string)shortTrailPrice);
                           Print("Stoploss is now: " + (string) + shortTrailToAsk + " behind Ask");
                          }
                        if(SendNotifications)
                          {
                           SendNotification("Order: #"+(string)OrderTicket()+
                                            " on "+(string)OrderSymbol()+
                                            ". Move SL to "+(string)shortTrailPrice);
                          }
                        if(!OrderModify(OrderTicket(),OrderOpenPrice(),shortTrailPrice,OrderTakeProfit(),0,clrDarkRed))
                          {
                           int err = GetLastError();
                           Print("Encountered an error during modification!"+(string)err+" "+ErrorDescription(err));
                          }//modify
                       }
                 }//sell
           }//magic
        }
      else //in case it fails to select an order.
        {
         int err = GetLastError();
         Print("Encountered an error during order selection in: "+ __FUNCTION__+"!"+(string)err+" "+ErrorDescription(err));
        }// error
     }//for loop
  }//trailing stop as a function




//+------------------------------------------------------------------+
//|CandleTrail                                                       |
//+------------------------------------------------------------------+
void CandleTrail(int lookBack, int lookbackTimeframe, int SLBuffer,int PipsToMoveBeforeTrail, int MagicNo, bool Debug, bool SendNotifications)
  {

   if(lookbackTimeframe == PERIOD_CURRENT)
     {
      lookbackTimeframe = Period();
     }

   int HTFlookBack = (lookbackTimeframe * lookBack) / Period();

   int buyStopCandle             =  iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,HTFlookBack,1);
   int sellStopCandle            =  iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,HTFlookBack,1);

   double initialMovementNeeded  =  NormalizeDouble((PipsToMoveBeforeTrail * PipValue()),_Digits);
   double priceBuffer            =  SLBuffer * PipValue();

   double longTrailPrice         =  NormalizeDouble((Low[buyStopCandle]   - priceBuffer),_Digits);
   double shortTrailPrice        =  NormalizeDouble((High[sellStopCandle] + priceBuffer),_Digits);

   double longPriceDistance       =  NormalizeDouble((Bid - OrderOpenPrice()),_Digits);
   double shortPriceDistance      =  NormalizeDouble((OrderOpenPrice() - Ask),_Digits);

   double longTrailToBid         =  NormalizeDouble((Bid - longTrailPrice),_Digits);
   double shortTrailToAsk        =  NormalizeDouble((shortTrailPrice - Ask),_Digits);

   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderMagicNumber()== MagicNo)
           {
            if(OrderType()==OP_BUY)
              {
               if(longPriceDistance > initialMovementNeeded)
                 {
                  if(OrderStopLoss() < longTrailPrice || OrderStopLoss()==0)
                     if(OrderModify(OrderTicket(),OrderOpenPrice(),longTrailPrice,OrderTakeProfit(),0,clrDarkRed))
                       {
                        if(Debug)
                          {
                           Print("Trail Type: CandleTrail");
                           Print("Stop Loss Timeframe is: " + (string)lookbackTimeframe);
                           Print("Lookback is : " + (string)lookBack);
                           Print("HTF Lookback in Current Period is: " + (string)HTFlookBack);
                           Print("Init Movement is: " + (string)initialMovementNeeded);
                           Print("Order: #" + (string)OrderTicket() + "'s Bid Price is " + (string)Bid);
                           Print("Distance between Current Bid and Open Price is " + (string)longPriceDistance + " or, " + (string)NormalizeDouble((longPriceDistance / PipValue()),_Digits) + " pips");
                           Print("Order: #" + (string)OrderTicket() + ".  Swing Low of Lookback " + (string)lookBack + " at candle " + (string)buyStopCandle + " is " + (string)Low[buyStopCandle] + ".");
                           Print("SL Buffer is " + (string)SLBuffer + ". Moving SL to " + (string)longTrailPrice);
                          }
                        if(SendNotifications)
                          {
                           SendNotification("Order: #"+(string)OrderTicket()+
                                            " on "+(string)OrderSymbol()+
                                            ". Move SL to "+(string)longTrailPrice+" behind candle # "+(string)buyStopCandle);
                          }
                       }
                     else     //if order did not get modified.
                       {
                        int err = GetLastError();
                        Print("Encountered an error on line "+(string)__LINE__+" during modification!"+(string)err+" "+ErrorDescription(err));
                       }//else
                 }//initial movement
              }//buy
            else
               if(OrderType()==OP_SELL)
                 {
                  if(shortPriceDistance > initialMovementNeeded)
                    {
                     if(OrderStopLoss() > shortTrailPrice || OrderStopLoss()==0)
                        if(OrderModify(OrderTicket(),OrderOpenPrice(),shortTrailPrice,OrderTakeProfit(),0,clrDarkRed))
                          {
                           if(Debug)
                             {
                              Print("Trail Type: CandleTrail");
                              Print("Stop Loss Timeframe is : " + (string)lookbackTimeframe);
                              Print("Lookback is : " + (string)lookBack);
                              Print("HTF Lookback in Current Period is: " + (string)HTFlookBack);
                              Print("Init Movement is: " + (string)initialMovementNeeded);
                              Print("Order: #" + (string)OrderTicket() + "'s Ask Price is " + (string)Ask);
                              Print("Distance between Current Ask and Open Price is " + (string)shortPriceDistance + " or, " + (string)NormalizeDouble((shortPriceDistance / PipValue()),_Digits) + " pips");
                              Print("Order: #" + (string)OrderTicket() + ". Swing High of Lookback " + (string)lookBack + " at candle " + (string)sellStopCandle + " is " + (string)High[sellStopCandle] + ".");
                              Print("SL Buffer is " + (string)SLBuffer + ". Moving SL to " + (string)shortTrailPrice);
                             }
                           if(SendNotifications)
                             {
                              SendNotification("Order: #"+(string)OrderTicket()+
                                               " on "+(string)OrderSymbol()+
                                               ". Move SL to "+(string)shortTrailPrice+" behind candle # "+(string)sellStopCandle);
                             }
                          }
                        else    //if order did not get modified.
                          {
                           int err = GetLastError();
                           Print("Encountered an error on line "+(string)__LINE__+" during modification!"+(string)err+" "+ErrorDescription(err));
                          }//else
                    }//initial movement
                 } //sell
           } //magic
        }//Orderselect
      else    //in case it fails to select an order.
        {
         int err = GetLastError();
         Print("Encountered an error during order selection in: "+ __FUNCTION__+"!"+(string)err+" "+ErrorDescription(err));
        }//else
     }//for loop
  }//function trails behind specified HTF candle + buffer




//+------------------------------------------------------------------+
//| AtrTrail                                                         |
//+------------------------------------------------------------------+
void AtrTrail(double atrMultiplier, int atrLength, bool useStructure, int structureLookback, int PipsToMoveBeforeTrail, int MagicNo, bool Debug, bool SendNotifications)
  {

   double initialMovementNeeded  =  NormalizeDouble((PipsToMoveBeforeTrail * PipValue()),_Digits);

   double shortPriceDistance     =  NormalizeDouble((OrderOpenPrice() - Ask),_Digits);
   double longPriceDistance      =  NormalizeDouble((Bid - OrderOpenPrice()),_Digits);

   double atrShort               = (atrMultiplier*(NormalizeDouble(iATR(Symbol(),PERIOD_CURRENT,atrLength,1),_Digits)));
   double atrLong                = (atrMultiplier*(NormalizeDouble(iATR(Symbol(),PERIOD_CURRENT,atrLength,1),_Digits)));

   double shortTrailPrice        =  useStructure ? ((High[iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,structureLookback,1)]) + atrShort) : atrShort;
   double longTrailPrice         =  useStructure ? ((Low[iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,structureLookback,1)])    - atrLong)  : atrLong;

   double longTrailToBid          =  NormalizeDouble((Bid - longTrailPrice),_Digits);
   double shortTrailToAsk         =  NormalizeDouble((shortTrailPrice - Ask),_Digits);


   for(int i=OrdersTotal()-1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderMagicNumber()== MagicNo)
           {
            if(OrderType()== OP_BUY)
              {
               if(Bid - OrderOpenPrice() > initialMovementNeeded)
                  if(OrderStopLoss() < longTrailPrice || OrderStopLoss()==0)
                    {
                     if(Debug)
                       {
                        Print("Trail Type: ATRTrail");
                        Print("Init Movement is: " + (string)initialMovementNeeded);
                        Print("Order: #" + (string)OrderTicket() + "'s Bid Price is " + (string)Bid);
                        Print("Distance between Current Bid and Open Price is " + (string)longPriceDistance + " or, " + (string)NormalizeDouble((longPriceDistance / PipValue()),_Digits) + " pips");
                        Print("Moving Ticket #" + (string)OrderTicket() + "'s SL");
                        Print("Moving LONG SL from " + (string)OrderStopLoss() + "to " + (string)longTrailPrice);
                        Print("Stoploss is now: " + (string) + longTrailToBid + " behind Bid");
                       }
                     if(SendNotifications)
                       {
                        SendNotification("Order: #"+(string)OrderTicket()+
                                         " on "+(string)OrderSymbol()+
                                         ". Move SL to "+(string)longTrailPrice);
                       }
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),longTrailPrice,OrderTakeProfit(),0,clrDarkRed))
                       {
                        int err = GetLastError();
                        Print("Encountered an error during modification for order: " + (string)i + "! " + (string)err + " " + ErrorDescription(err));
                       }//modify
                    }
              }//buy
            else
               if(OrderType()==OP_SELL)
                 {
                  if(OrderOpenPrice() - Ask > initialMovementNeeded)
                     if(OrderStopLoss() > shortTrailPrice  || OrderStopLoss()==0)
                       {
                        if(Debug)
                          {
                           Print("Trail Type: ATRTrail");
                           Print("Init Movement is: " + (string)initialMovementNeeded);
                           Print("Order: #" + (string)OrderTicket() + "'s Ask Price is " + (string)Ask);
                           Print("Distance between Current Ask and Open Price is " + (string)shortPriceDistance + " or, " + (string)NormalizeDouble((shortPriceDistance / PipValue()),_Digits) + " pips");
                           Print("Moving Ticket #" + (string)OrderTicket() + "'s SL");
                           Print("Moving SHORT SL from " + (string)OrderStopLoss() + " to " + (string)shortTrailPrice);
                           Print("Stoploss is now: " + (string) + shortTrailToAsk + " behind Ask");
                          }
                        if(SendNotifications)
                          {
                           SendNotification("Order: #"+(string)OrderTicket()+
                                            " on "+(string)OrderSymbol()+
                                            ". Move SL to "+(string)shortTrailPrice);
                          }
                        if(!OrderModify(OrderTicket(),OrderOpenPrice(),shortTrailPrice,OrderTakeProfit(),0,clrDarkRed))
                          {
                           int err = GetLastError();
                           Print("Encountered an error during modification!"+(string)err+" "+ErrorDescription(err));
                          }//modify
                       }
                 }//sell
           }//magic
        }
      else //in case it fails to select an order.
        {
         int err = GetLastError();
         Print("Encountered an error during order selection in: "+ __FUNCTION__+"!"+(string)err+" "+ErrorDescription(err));
        }// error
     }//for loop
  }//ATR  trailing stop as a function





//+------------------------------------------------------------------+







//+------------------------------------------------------------------+
//| TrailingStop                                                     |
//+------------------------------------------------------------------+
void TrailingStop(int trailType, int lookBack, int HTFCandleLookback, int SLBuffer,double atrMultiplier, int atrLength, bool useStructure, int structureLookback, double RMutiplesBeforeBE, int PipsToTrailUp,int PipsToMoveBeforeTrail,  int MagicNo, bool Debug, bool SendNotifications)
  {
   switch(trailType)
     {
      case 0:
         BreakEvenTrail(PipsToMoveBeforeTrail, MagicNo, Debug, SendNotifications);
         return;
      case 1:
         RegularTrail(PipsToTrailUp, PipsToMoveBeforeTrail, MagicNo, Debug, SendNotifications);
         return;
      case 2:
         CandleTrail(lookBack, HTFCandleLookback, SLBuffer, PipsToMoveBeforeTrail, MagicNo, Debug, SendNotifications);
         return;
      case 3:
         AtrTrail(atrMultiplier,  atrLength,  useStructure,  structureLookback,  PipsToMoveBeforeTrail,  MagicNo,  Debug, SendNotifications);
         return;
      case 4:
         RMulipleBreakEvenTrail(RMutiplesBeforeBE, MagicNo, Debug, SendNotifications);
         return;
      case 5:
      default:
         return;
     }
  }//trailing stop tye selcetor





////+------------------------------------------------------------------+
////|LotSizeDynamicOrFixed                                             |
////+------------------------------------------------------------------+
//double   LotSizeDynamicOrFixed(bool isDynamic, double accountEquity, double RiskpcPerTrade, double SL_Pips, double FixedLotAmount,bool printDebug)
//  {
//   double lotSize;
//
//   if(isDynamic)
//     {
//      lotSize = GetLotSizeFromPips(RiskpcPerTrade,SL_Pips,printDebug);
//      return(lotSize);
//     }
//   else
//     {
//      lotSize = FixedLotAmount;
//      return(lotSize);
//     }
//  }//returns either a dynamic lost size or a fixed amoutn based on a bool





//+------------------------------------------------------------------+
//| IsSwingHigh                                                      |
//+------------------------------------------------------------------+
bool IsSwingHigh(int startIndex, int lookBack, int testCandleIndex)
  {
   int      indexHighestHigh  =  iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,lookBack,startIndex);
   double   SwingHigh         =  High[indexHighestHigh];
   bool     isSwingHigh       =  High[testCandleIndex] == SwingHigh;

   if(isSwingHigh)
     {
      return(true);
     }
   else
     {
      return(false);
     }
  }// returns true if testCandleIndex bar is current swing high







//+------------------------------------------------------------------+
//| IsSwingLow                                                       |
//+------------------------------------------------------------------+
bool IsSwingLow(int startIndex, int lookBack, int testCandleIndex)
  {
   int      indexLowestLow  =  iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,lookBack,startIndex);
   double   SwingLow        =  Low[indexLowestLow];
   bool     isSwingLow      =  Low[testCandleIndex] == SwingLow;

   if(isSwingLow)
     {
      return(true);
     }
   else
     {
      return(false);
     }
  }// returns true if testCandleIndex bar is current swing low





//+------------------------------------------------------------------+
//|  EC_Bear                                                         |
//+------------------------------------------------------------------+
bool EC_Bear(int index, bool print, bool debug)
  {
   if((Close[index+1]   >     Open[index+1])  //previous candle was bullish
      && (Open[index]   >=    Close[index+1]) //open of candle greater or equal to the close of the previous
      && (Close[index]  <=    Open[index+1])  //close lower or equal to the open of the previous
      && (High[index]   >=    High[index+1])) //high is higher than the high of the previous
     {
      if(print)
        {
         Create_Label("EC",1,High[1],clrRed,1,0);
        }
      if(debug)
        {
         Print("EC_Bear on "+ Symbol() + " at " + (string)TimeCurrent());
        }
      return(true);
     }
   else
     {
      return(false);
     }
  }//return true if idex candle is a bearish engulfing





//+------------------------------------------------------------------+
//|  EC_Bull                                                         |
//+------------------------------------------------------------------+
bool EC_Bull(int index, bool print, bool debug)
  {
   if((Close[index+1]   <     Open[index+1])
      && (Open[index]   <=    Close[index+1])
      && (Close[index]  >=    Open[index+1])
      && (Low[index]    <=    Low[index+1]))
     {
      if(print)
        {
         Create_Label("EC",1,Low[1],clrGreen,1,0);
        }
      if(debug)
        {
         Print("EC_Bull on "+ Symbol() + " at " + (string)TimeCurrent());
        }
      return(true);
     }
   else
     {
      return(false);
     }
  }//returns true if indexw=ed candle is a bullish engulfing
//+------------------------------------------------------------------+







//+------------------------------------------------------------------+
//| PB_Bull_TV                                                       |
//+------------------------------------------------------------------+
bool  PB_Bull_TV(int index, bool print, bool debug)
  {
   double   currentBody    = MathAbs(Close[index]   - Open[index]);
   double   previousBody   = MathAbs(Close[index+1] - Open[index+1]);
   double   upShadow       = (Open[index] > Close[index]) ? (High[index] - Open[index]) : (High[index] - Close[index]);
   double   downShadow     = (Open[index] > Close[index]) ? (Close[index] - Low[index]) : (Open[index] - Low[index]);

   if((Open[index+1]    > Close[index+1])
      && (previousBody  > currentBody)
      && (downShadow    > 0.6 * currentBody)
      && (downShadow    > 2 * upShadow))
     {
      if(print)
        {
         Create_Label("PB",1,Low[1],clrBlue,1,0);
        }
      if(debug)
        {
         Print("PB_Bull_TV on "+ Symbol() + " at " + (string)TimeCurrent());
        }
      return(true);
     }
   else
     {
      return(false);
     }
  }// returns true if the indexed candle is a PB as defined by Tradinview




//+------------------------------------------------------------------+
//| PB_Bear_TV                                                       |
//+------------------------------------------------------------------+
bool  PB_Bear_TV(int index, bool print, bool debug)
  {
   double   currentBody    = MathAbs(Close[index]   - Open[index]);
   double   previousBody   = MathAbs(Close[index+1] - Open[index+1]);
   double   upShadow       = (Open[index] > Close[index]) ? (High[index] - Open[index]) : (High[index] - Close[index]);
   double   downShadow     = (Open[index] > Close[index]) ? (Close[index] - Low[index]) : (Open[index] - Low[index]);

   if((Close[index+1]   > Open[index+1])
      && (previousBody  > currentBody)
      && (upShadow      > 0.6 * currentBody)
      && (upShadow      > 2 * downShadow))
     {
      if(print)
        {
         Create_Label("PB",1,High[1],clrOrange,1,0);
        }
      if(debug)
        {
         Print("PB_Bear_TV on "+ Symbol() + " at " + (string)TimeCurrent());
        }
      return(true);
     }
   else
     {
      return(false);
     }
  }// returns true if the indexed candle is a PB as defined by Tradinview





//+------------------------------------------------------------------+
//|PB_Bull_JD                                                        |
//+------------------------------------------------------------------+
bool  PB_Bull_JD(int index, bool print,bool debug)
  {
   double            Fib_Level         =  0.25;
   int               Min_Candle_Size   =  50;
   double            Total_Size        =  High[index] - Low[index];
   double            Body_Size         =  MathAbs(Open[index] - Close[index]);
   double            Max_Candle_Size   =  Total_Size * Fib_Level;


   if((Body_Size < Max_Candle_Size && Total_Size > Min_Candle_Size * Point)
      && (Open[index] < Close[index])
      && (High[index] - Open[index] < Max_Candle_Size)
      && (Low[index]  < Low[index+1])
      && (Low[index]  < Low[index+2]))
     {
      if(print)
        {
         Create_Label("PB",1,Low[1],clrGreen,1,0);
        }
      if(debug)
        {
         Print("PB_Bull_JD on "+ Symbol() + " at " + (string)TimeCurrent());
        }
      return(true);
     }
   else
      if((Body_Size < Max_Candle_Size && Total_Size > Min_Candle_Size * Point)
         && (High[index] - Close[index] < Max_Candle_Size)
         && (Open[index] > Close[index])
         && (Low[index]  < Low[index+1])
         && (Low[index]  < Low[index+2]))
        {
         if(print)
           {
            Create_Label("PB",1,Low[1],clrGreen,1,0);
           }
         if(debug)
           {
            Print("PB_Bull_JD on "+ Symbol() + " at " + (string)TimeCurrent());
           }
         return(true);
        }
      else
        {
         return(false);
        }
  }// returns true if indexed candle is a bullish PB as defind by JimDandy







//+------------------------------------------------------------------+
//|PB_Bear_JD                                                        |
//+------------------------------------------------------------------+
bool  PB_Bear_JD(int index, bool print,bool debug)
  {
   double            Fib_Level         =  0.25;
   int               Min_Candle_Size   =  50;
   double            Total_Size        =  High[index] - Low[index];
   double            Body_Size         =  MathAbs(Open[index] - Close[index]);
   double            Max_Candle_Size   =  Total_Size * Fib_Level;


   if((Body_Size < Max_Candle_Size && Total_Size > Min_Candle_Size * Point)
      && (Open[index] > Close[index])
      && (Open[index] - Low[index]   < Max_Candle_Size)
      && (High[index] > High[index+1])
      && (High[index] > High[index+2]))
     {
      if(print)
        {
         Create_Label("PB",1,High[1],clrRed,1,0);
        }
      if(debug)
        {
         Print("PB_Bear_JD on "+ Symbol() + " at " + (string)TimeCurrent());
        }
      return(true);
     }
   else
      if((Body_Size < Max_Candle_Size && Total_Size > Min_Candle_Size * Point)
         && (Open[index] < Close[index])
         && (Close[index] - Low[index] < Max_Candle_Size)
         && (High[index] > High[index+1])
         && (High[index] > High[index+2]))
        {
         if(print)
           {
            Create_Label("PB",1,High[1],clrRed,1,0);
           }
         if(debug)
           {
            Print("PB_Bear_JD on "+ Symbol() + " at " + (string)TimeCurrent());
           }
         return(true);
        }
      else
        {
         return(false);
        }
  }// returns true if indexed candle is a bearish PB as defind by JimDandy



//+------------------------------------------------------------------+
//| StopLossPriceUsignPrevousLOW                                     |
//+------------------------------------------------------------------+
double StopLossPriceUsingPrevious_LOW(double SLPips)
  {
   double StopLossPriceUsignPrevious_LOW = Low[1]  - (SLPips * PipValue());
   return(StopLossPriceUsignPrevious_LOW);
  }// returns the price of the previous low - SL_InPips for long orders




//+------------------------------------------------------------------+
//| StopLossPriceUsignPrevousHIGH                                    |
//+------------------------------------------------------------------+
double StopLossPriceUsingPrevousHIGH(double SLPips)
  {
   double StopLossPriceUsignPrevious_HIGH = High[1] + (SLPips * PipValue());
   return(StopLossPriceUsignPrevious_HIGH);
  }// returns the price of the previous high + SL_InPips for short orders





//+------------------------------------------------------------------+
//| AskPlusPipFilter                                                 |
//+------------------------------------------------------------------+
double AskPlusPipFilter(double pipFilter)
  {
   double AskPlusPipFilter = Ask + (pipFilter * PipValue());
   return(AskPlusPipFilter);
  }//returns the price of the current ask plus the pip filter for long orders




//+------------------------------------------------------------------+
//| BidMinusPipFilter                                                |
//+------------------------------------------------------------------+
double BidMinusPipFilter(double pipFilter)
  {
   double BidMinusPipFilter = Bid - (pipFilter * PipValue());
   return(BidMinusPipFilter);
  }//returns the price of the current bid minus the pip filter for short orders



//+------------------------------------------------------------------+
//| HighOfDay                                                        |
//+------------------------------------------------------------------+
double HighOfDay(int index)
  {
   return(iHigh(Symbol(),PERIOD_D1,index));
  }//returns the high of the indexed day




//+------------------------------------------------------------------+
//| LowOfDay                                                         |
//+------------------------------------------------------------------+
double LowOfDay(int index)
  {
   return(iLow(Symbol(),PERIOD_D1,index));
  }//returns the low of the indexed day

//+------------------------------------------------------------------+
//| RunOncePerCandle                                                 |
//+------------------------------------------------------------------+
//void RunOncePerCandle()
//{
//
//datetime LastActionTime = 0;
//
//   // Comparing LastActionTime with the current starting time for the candle.
//   if (LastActionTime != Time[0])
//   {
//      // Code to execute once per bar.
//      Print("This code is executed only once in the bar started ", Time[0]);
//
//      LastActionTime =  Time[0];
//   }//non executable funtion. here as a pace to save this for rewritin inn idicators
//
//}


//+------------------------------------------------------------------+
//| StopLossPrice                                                    |
//+------------------------------------------------------------------+
double StopLossPrice(bool isLong, int stopMethod, double entry, double fixedStopInPrice, double atrMultiplier, int atrLength, bool useStructure, int structureLookback, bool deBug)
  {
//local
   double buyEntry   = entry;
   double sellEntry  = entry;
   double stopPrice;

   if(isLong)
     {
      //long stops
      double   fixedLongStop     =  buyEntry - fixedStopInPrice;
      double   previousLowStop   =  Low[1] - fixedStopInPrice;
      double   atrLong           = (atrMultiplier*(NormalizeDouble(iATR(Symbol(),PERIOD_CURRENT,atrLength,1),_Digits)));
      double   atrLongStop       =  useStructure ? ((Low[iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,structureLookback,1)])    - atrLong)  : atrLong;

      switch(stopMethod)
        {
         case 0   :
            stopPrice  = fixedLongStop;
            break;
         case 1   :
            stopPrice  = previousLowStop;
            break;
         case 2   :
            stopPrice  = atrLongStop;
            break;
         default  :
            stopPrice  = fixedLongStop;
        }//switch
      if(deBug)
        {
         Print("Method is: "+(string)stopMethod+", LONGStopPrice is :"+(string)NormalizeDouble(stopPrice,_Digits));
        }
      return(stopPrice);
     }//if
   else
     {
      //short stops
      double   fixedShortStop    =  sellEntry + fixedStopInPrice;
      double   previousHighStop  =  High[1] + fixedStopInPrice;
      double   atrShort          = (atrMultiplier*(NormalizeDouble(iATR(Symbol(),PERIOD_CURRENT,atrLength,1),_Digits)));
      double   atrShortStop      =  useStructure ? ((High[iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,structureLookback,1)]) + atrShort) : atrShort;

      switch(stopMethod)
        {
         case 0   :
            stopPrice = fixedShortStop;
            break;
         case 1   :
            stopPrice = previousHighStop;
            break;
         case 2   :
            stopPrice = atrShortStop;
            break;
         default  :
            stopPrice = fixedShortStop;
        }//switch
      if(deBug)
        {
         Print("Method is: "+(string)stopMethod+", SHORTStopPrice is :"+(string)NormalizeDouble(stopPrice,_Digits));
        }
      return(stopPrice);
     }//else
  }// function returns stoploss price based on stoploss method and entry
//+------------------------------------------------------------------+







//+------------------------------------------------------------------+
//|TargetPrice                                                       |
//+------------------------------------------------------------------+
double TargetPrice(bool isLong, bool noTarget, double entryPrice,double stopLossPrice, double riskRewardRatio, bool deBug)
  {
   double stopDistanceInPrice;
   double buyTargetPrice;
   double sellTargetPrice;

   if(isLong)
     {
      stopDistanceInPrice  =  entryPrice - stopLossPrice;
      buyTargetPrice       =  noTarget ? 0 : (entryPrice + (stopDistanceInPrice  * riskRewardRatio));

      if(deBug)
        {
         Print("LONG TargetPrice is :"+(string)NormalizeDouble(buyTargetPrice,_Digits));
        }
      return(buyTargetPrice);
     }//islong
   else
     {
      stopDistanceInPrice  =  stopLossPrice - entryPrice;
      sellTargetPrice      =  noTarget ? 0 : (entryPrice - (stopDistanceInPrice  * riskRewardRatio));

      if(deBug)
        {
         Print("SHORT TargetPrice is :"+(string)NormalizeDouble(sellTargetPrice,_Digits));
        }
      return(sellTargetPrice);
     }//else
  }//function returns traget price based on risk entry, stop and risk reward ratio






//+------------------------------------------------------------------+




//+------------------------------------------------------------------+
//| MinimumTargetPrice                                               |
//+------------------------------------------------------------------+
double MinimumTargetPrice(bool isLong, double entryPrice, double stopLossPrice, double riskRewardRatio, bool deBug)
  {
   double stopDistanceInPrice;
   double minTargetLong;
   double minTargetShort;


   if(isLong)
     {
      stopDistanceInPrice  =  entryPrice - stopLossPrice;
      minTargetLong        =  entryPrice + (stopDistanceInPrice  * riskRewardRatio);
      if(deBug)
        {
         Print("LONG MINTarget is :"+(string)NormalizeDouble(minTargetLong,_Digits));
        }//debug
      return(minTargetLong);
     }//islong
   else
     {
      stopDistanceInPrice  =  stopLossPrice - entryPrice;
      minTargetShort       =  entryPrice - (stopDistanceInPrice  * riskRewardRatio);
      if(deBug)
        {
         Print("SHORT MINTarget is :"+(string)NormalizeDouble(minTargetShort,_Digits));
        }//debug
      return(minTargetShort);
     }//else

  }//function returns minimum target price based on direction, entry, stop, and risk reward ratio




//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
