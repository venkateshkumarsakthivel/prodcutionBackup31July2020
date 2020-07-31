/* Class for CommunityHomePageRouter Component
 * On purpose without sharing as invoked by context of guest site user
*/
public without sharing class CommunityHomePageRouterController {

  //function to check if current time is within configured downtime
  //if yes then returns appropriate downtime message, else returns NULL
  @AuraEnabled
  public static String validateASPDowntimeAlert() {
    
    
    String priorDowntimeResult = GlobalUtility.validateIsASPDowntimeMessageConfigured(GlobalConstants.INDEX_LOGIN_PAGE_MESSAGE_PRIOR_OUTAGE);
    String downtimeResult = priorDowntimeResult == NULL ? GlobalUtility.validateIsASPDowntimeMessageConfigured(GlobalConstants.INDEX_LOGIN_PAGE_MESSAGE_DURING_OUTAGE) : priorDowntimeResult;
    
    return downtimeResult;
  }
}