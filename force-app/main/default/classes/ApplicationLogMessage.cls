/*------------------------------------------------------------
* Wrapper/bean class for the Application Log
* ------------------------------------------------------------*/
public  class ApplicationLogMessage {
   
  public String source{get;set;}
  public String sourceFunction{get;set;}
  public String referenceId{get;set;}
  public String referenceInfo{get;set;}
  public String logMessage{get;set;}
  public String payLoad{get;set;}
  public Exception ex{get;set;}
  public String debugLevel{get;set;}
  public String logCode{get;set;}
  public Long timer{get;set;}
}