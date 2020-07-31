/* Class for ASPDashboardAndAccordionContainer Component
 * Validates if current time is within configured DVD downtime or not
*/
public without sharing class ASPDashboardAndAccordionContainerCon {

  //function to check if current time is within configured downtime
  //if yes then returns appropriate downtime message, else returns NULL
  @AuraEnabled
  public static String validateDVDDownTime() {
    
    return GlobalUtility.validateIsASPDowntimeMessageConfigured(GlobalConstants.DVD_DASHBOARD_MESSAGE);
  }
}